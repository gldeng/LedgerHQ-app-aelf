#include "instruction.h"
#include "sol/parser.h"
#include "sol/transaction_summary.h"
#include "util.h"
#include <string.h>
#include "../proto/pb_decode.h"
#include "../proto/message.pb.h"

// int hexCharToInt(char c) {
//     if (c >= '0' && c <= '9') return c - '0';
//     if (c >= 'a' && c <= 'f') return c - 'a' + 10;
//     if (c >= 'A' && c <= 'F') return c - 'A' + 10;
//     return -1;
// }
// void hexStringToBinary(const char *hexString, uint8_t *binaryData, size_t binarySize) {
//     for (size_t i = 0; i < binarySize; i++) {
//         binaryData[i] = (hexCharToInt(hexString[2 * i]) << 4) | hexCharToInt(hexString[2 * i + 1]);
//     }
// }

// uint64_t readVarInt(const uint8_t *data, int *index) {
//     uint64_t result = 0;
//     int shift = 0;
//     while (1) {
//         uint8_t byte = data[*index];
//         (*index)++;
//         result |= (uint64_t) (byte & 0x7F) << shift;
//         if ((byte & 0x80) == 0) {
//             break;
//         }
//         shift += 7;
//     }
//     return result;
// }

static int parseParams(Parser *parser, SystemTransferInfo* info, uint64_t buffer_length) {
  uint8_t index = 0;
  while (index < FIELD_NUMBER_PARAMS) {
    PRINTF("GUI: %.*H\n", parser->buffer_length, parser->buffer);
    uint64_t key;
    readVarInt(parser, &key);
    uint32_t field_number = key >> 3;
    switch (field_number) {
        case 1:
            // Address 'to'
            {
                advance(parser, 2);
                uint64_t length;
                readVarInt(parser, &length);
                PRINTF("GUI LENGTH FROM: %d\n", &length);
                BAIL_IF(parse_pubkey(parser, &info->dest));
                PRINTF("FROM ADDRESS: %.*H\n", PUBKEY_SIZE, info->dest);
                index++;
            }
            break;
        case 2:
            // Ticker (String)
            {
                readVarInt(parser, &info->ticker.length);
                BAIL_IF(parse_sized_string(parser, &info->ticker));
                index++;
            }
            break;
        case 3:
            // Amount (Varint)
            {
                 BAIL_IF(parse_u32(parser, &info->ref_block_number));
                 index++;
            }
            break;
        case 4:
            // Memo (string)
            {
                readVarInt(parser, &info->memo.length);
                BAIL_IF(parse_sized_string(parser, &info->memo));
                index++;
            }
            break;
        default:
            PRINTF("Unknown field number %d\n", field_number);
            return 1;
    }
  }
  return 0;
}

int parse_system_transfer_instruction(Parser* parser,
                                      Instruction* instruction,
                                      SystemTransferInfo* info) {


    while (parser->buffer_length) {
        PRINTF("GUI: %.*H\n", parser->buffer_length, parser->buffer);
        uint64_t key;
        readVarInt(parser, &key);
        uint32_t field_number = key >> 3;
        PRINTF("GUI FIELD NUMBER: %d\n", field_number);
        switch (field_number) {
            case 1:
                // Address from
                {
                    advance(parser, 2);
                    uint64_t length;
                    readVarInt(parser, &length);
                    BAIL_IF(parse_pubkey(parser, &info->from));
                }
                break;
            case 2:
                // Address 'to'
                {
                    advance(parser, 2);
                    uint64_t length;
                    readVarInt(parser, &length);
                    BAIL_IF(parse_pubkey(parser, &info->to));
                }
                break;
            case 3:
                // ref_block_number (int64)
                {
                    // uint64_t value;
                    // readVarInt(parser, &value);
                    BAIL_IF(parse_u32(parser, &info->ref_block_number));
                }
                break;
            case 4:
                // ref_block_prefix (string)
                {
                    readVarInt(parser, &info->ref_block_prefix.length);
                    BAIL_IF(parse_sized_string(parser, &info->ref_block_prefix));
                }
                break;
            case 5:
                // method_name (string)
                {
                    readVarInt(parser, &info->method_name.length);
                    BAIL_IF(parse_sized_string(parser, &info->method_name));
                }
                break;
            case 6:
                // params (bytes)
                {
                    uint64_t length;
                    readVarInt(parser, &length);
                    parseParams(parser, info, length);
                }
                break;
            default:
                PRINTF("Unknown field number %d\n", field_number);
                return 1;
        }
    }

    // BAIL_IF(parse_pubkey(parser, &info->to));
    // BAIL_IF(parse_data(parser, &instruction->ticker, &instruction->ticker_length));
    // BAIL_IF(parse_u64(parser, &info->amount));
    
    // PRINTF("GUI PARSER:\n%.*H\n", parser->buffer_length, parser->buffer);

    // init_canary();
    // check_canary();

    // aelf_TransferInput transfer_input = aelf_TransferInput_init_zero;
    // check_canary();
    // pb_byte_t symbolBuffer[BUFFER_SIZE] = {0};
    // pb_byte_t memoBuffer[BUFFER_SIZE] = {0};
    // pb_byte_t addressBuffer[BUFFER_SIZE] = {0};
    // check_canary();

    // transfer_input.symbol.funcs.decode = read_string_field;
    // transfer_input.memo.funcs.decode = read_string_field;
    // transfer_input.to.value.funcs.decode = read_address_field;
    // transfer_input.symbol.arg = &symbolBuffer;
    // transfer_input.memo.arg = &memoBuffer;
    // transfer_input.to.value.arg = &addressBuffer;
    // check_canary();

    // aelf_Transaction txn = {};

    // txn.params.funcs.decode = read_transfer_input;
    // txn.params.arg = &transfer_input;

    // pb_istream_t stream = pb_istream_from_buffer((const pb_byte_t *)parser->buffer, (size_t)parser->buffer_length);
    // check_canary();

    // if (!pb_decode(&stream, aelf_Transaction_fields, &txn))
    // {
    //     PRINTF("Decoding failed: %s\n", PB_GET_ERROR(&stream));
    //     return 1;
    // }

    // PRINTF("Address   : %s\n", addressBuffer);
    // PRINTF("Symbol    : %s\n", symbolBuffer);
    // PRINTF("Amount    : %ld\n", transfer_input.amount);
    // PRINTF("Memo      : %s\n", memoBuffer);

    return 0;
}

int print_system_transfer_info(const SystemTransferInfo* info) {
    SummaryItem* item;

    item = transaction_summary_primary_item();
    summary_item_set_amount(item, "Transfer", info->amount);

    item = transaction_summary_general_item();
    summary_item_set_pubkey(item, "Recipient", info->to);

    return 0;
}
