#pragma once

#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include "../../../proto/pb.h"

#define PUBKEY_SIZE    32
#define HASH_SIZE      32
#define BLOCKHASH_SIZE HASH_SIZE

#define BUFFER_SIZE 32

typedef struct Parser {
    const uint8_t* buffer;
    size_t buffer_length;
} Parser;

enum Option {
    OptionNone,
    OptionSome,
};

typedef struct SizedString {
    uint64_t length;
    // TODO: This can technically contain UTF-8. Need to figure out a
    // nano-s-compatible strategy for dealing with non-ASCII chars...
    const char* string;
} SizedString;

typedef struct Pubkey {
    uint8_t data[PUBKEY_SIZE];
} Pubkey;

typedef struct Hash {
    uint8_t data[HASH_SIZE];
} Hash;
typedef struct Hash Blockhash;

typedef struct Instruction {
    size_t ticker_length;
    const uint8_t* ticker;
} Instruction;

typedef struct MessageHeader {
    bool versioned;
    uint8_t version;
    const Blockhash* blockhash;
    size_t instructions_length;
} MessageHeader;

static inline int parser_is_empty(Parser* parser) {
    return parser->buffer_length == 0;
}


// This symbol is defined by the link script to be at the start of the stack
// area.
extern unsigned long _stack;

#define STACK_CANARY (*((volatile uint32_t*) &_stack))

void init_canary();

void check_canary();

void tohex(unsigned char * in, size_t insz, char * out, size_t outsz);

bool read_address_field(pb_istream_t *stream, const pb_field_t *field, void **arg);

bool read_string_field(pb_istream_t *stream, const pb_field_t *field, void **arg);

bool read_transfer_input(pb_istream_t *stream, const pb_field_t *field, void **arg);

void advance(Parser* parser, size_t num);

int parse_u8(Parser* parser, uint8_t* value);

int parse_u32(Parser* parser, uint32_t* value);

int parse_u64(Parser* parser, uint64_t* value);

int parse_i64(Parser* parser, int64_t* value);

int parse_length(Parser* parser, size_t* value);

int parse_option(Parser* parser, enum Option* value);

int parse_sized_string(Parser* parser, SizedString* string);

int parse_pubkey(Parser* parser, const Pubkey** pubkey);

int parse_blockhash(Parser* parser, const Hash** hash);
#define parse_blockhash parse_hash

int parse_message_header(Parser* parser, MessageHeader* header);

int parse_data(Parser* parser, const uint8_t** data, size_t* data_length);

int readVarInt(Parser* parser, int *index, uint64_t* value);

// FIXME: I don't belong here
static inline bool pubkeys_equal(const Pubkey* pubkey1, const Pubkey* pubkey2) {
    return memcmp(pubkey1, pubkey2, PUBKEY_SIZE) == 0;
}
