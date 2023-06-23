#include "sol/parser.h"
#include "util.h"
#include <pb.h>
#include <pb_decode.h>
#include "proto/message.pb.h"

#define OFFCHAIN_MESSAGE_SIGNING_DOMAIN \
    "\xff"                              \
    "aelf offchain"

static int check_buffer_length(Parser* parser, size_t num) {
    return parser->buffer_length < num ? 1 : 0;
}

void advance(Parser* parser, size_t num) {
    parser->buffer += num;
    parser->buffer_length -= num;
}

int parse_u8(Parser* parser, uint8_t* value) {
    BAIL_IF(check_buffer_length(parser, 1));
    *value = *parser->buffer;
    advance(parser, 1);
    return 0;
}

static int parse_u16(Parser* parser, uint16_t* value) {
    uint8_t lower, upper;
    BAIL_IF(parse_u8(parser, &lower));
    BAIL_IF(parse_u8(parser, &upper));
    *value = lower + ((uint16_t) upper << 8);
    return 0;
}

int parse_u32(Parser* parser, uint32_t* value) {
    uint16_t lower, upper;
    BAIL_IF(parse_u16(parser, &lower));
    BAIL_IF(parse_u16(parser, &upper));
    *value = lower + ((uint32_t) upper << 16);
    return 0;
}

int parse_u64(Parser* parser, uint64_t* value) {
    BAIL_IF(check_buffer_length(parser, 8));
    uint32_t lower, upper;
    BAIL_IF(parse_u32(parser, &lower));
    BAIL_IF(parse_u32(parser, &upper));
    *value = lower + ((uint64_t) upper << 32);
    return 0;
}

int parse_i64(Parser* parser, int64_t* value) {
    uint64_t* as_u64 = (uint64_t*) value;
    return parse_u64(parser, as_u64);
}

int parse_length(Parser* parser, size_t* value) {
    uint8_t value_u8;
    BAIL_IF(parse_u8(parser, &value_u8));
    *value = value_u8 & 0x7f;

    if (value_u8 & 0x80) {
        BAIL_IF(parse_u8(parser, &value_u8));
        *value = ((value_u8 & 0x7f) << 7) | *value;
        if (value_u8 & 0x80) {
            BAIL_IF(parse_u8(parser, &value_u8));
            *value = ((value_u8 & 0x7f) << 14) | *value;
        }
    }
    return 0;
}

int parse_option(Parser* parser, enum Option* value) {
    uint8_t maybe_option;
    BAIL_IF(parse_u8(parser, &maybe_option));
    switch (maybe_option) {
        case OptionNone:
        case OptionSome:
            *value = (enum Option) maybe_option;
            return 0;
        default:
            break;
    }
    return 1;
}

int parse_sized_string(Parser* parser, SizedString* string) {
    // BAIL_IF(parse_u64(parser, &string->length));
    BAIL_IF(string->length > SIZE_MAX);
    size_t len = (size_t) string->length;
    BAIL_IF(check_buffer_length(parser, len));
    string->string = (const char*) parser->buffer;
    advance(parser, len);
    return 0;
}

int parse_pubkey(Parser* parser, const Pubkey** pubkey) {
    BAIL_IF(check_buffer_length(parser, PUBKEY_SIZE));
    *pubkey = (const Pubkey*) parser->buffer;
    advance(parser, PUBKEY_SIZE);
    return 0;
}

int parse_hash(Parser* parser, const Hash** hash) {
    BAIL_IF(check_buffer_length(parser, HASH_SIZE));
    *hash = (const Hash*) parser->buffer;
    advance(parser, HASH_SIZE);
    return 0;
}

int parse_version(Parser* parser, MessageHeader* header) {
    BAIL_IF(check_buffer_length(parser, 1));
    const uint8_t version = *parser->buffer;
    if (version & 0x80) {
        header->versioned = true;
        header->version = version & 0x7f;
        advance(parser, 1);
    } else {
        header->versioned = false;
        header->version = 0;
    }
    return 0;
}

int parse_message_header(Parser* parser, MessageHeader* header) {
    BAIL_IF(parse_blockhash(parser, &header->blockhash));
    return 0;
}

int parse_data(Parser* parser, const uint8_t** data, size_t* data_length) {
    BAIL_IF(parse_length(parser, data_length));
    BAIL_IF(check_buffer_length(parser, *data_length));
    *data = parser->buffer;
    advance(parser, *data_length);
    return 0;
}

int readVarInt(Parser* parser, uint64_t* value) {
    *value = 0;
    int shift = 0;
    while (1) {
        uint8_t byte = *parser->buffer;
        advance(parser, 1);
        *value |= (uint64_t) (byte & 0x7F) << shift;
        if ((byte & 0x80) == 0) {
            break;
        }
        shift += 7;
    }
    return 0;
}