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

// uint8_t parseParams(uint8_t *data, size_t numBytes) {
//   int index = 0;
//   while (index < numBytes) {
//     uint64_t key = readVarInt(data, &index);
//     uint32_t field_number = key >> 3;
//     uint32_t wire_type = key & 7;
//     switch (field_number) {
//         case 1:
//             // Address 'to'
//             {
//                 uint64_t length = readVarInt(data, &index);
//                 index += length;
//             }
//             break;
//         case 2:
//             // Ticker (String)
//             {
//                 uint64_t length = readVarInt(data, &index);
//                 for (uint64_t i = 0; i < length; i++) {
//                     putchar(data[index + i]);
//                 }
//                 index += length;
//             }
//             break;
//         case 3:
//             // Amount (Varint)
//             {
//                 uint64_t value = readVarInt(data, &index);
//             }
//             break;
//         case 4:
//             // Memo (string)
//             {
//                 uint64_t length = readVarInt(data, &index);
//                 for (uint64_t i = 0; i < length; i++) {
//                     putchar(data[index + i]);
//                 }
//                 index += length;
//             }
//             break;
//         default:
//             PRINTF("Unknown field number %d\n", field_number);
//             return 1;
//     }
//   }
// }

int parse_system_transfer_instruction(Parser* parser,
                                      Instruction* instruction,
                                      SystemTransferInfo* info) {

    int index = 0;
    while (parser->buffer_length) {
        size_t key;
        parse_length(parser, key);
        uint32_t field_number = key >> 3;
        uint32_t wire_type = key & 7;
        switch (field_number) {
            case 1:
                // Address from
                {
                    advance(parser, 4);
                    BAIL_IF(parse_pubkey(parser, &info->from));
                }
                break;
            // case 2:
            //     // Address 'to'
            //     {
            //         advance(parser, 4);
            //         BAIL_IF(parse_pubkey(parser, &info->to));
            //     }
            //     break;
            // case 3:
            //     // ref_block_number (int64)
            //     {
            //         // uint64_t value = readVarInt(&parser->buffer, &index);
            //         BAIL_IF(parse_u64(parser, &info->ref_block_number));
            //     }
            //     break;
            // case 4:
            //     // ref_block_prefix (string)
            //     {
            //         uint64_t length = readVarInt(&parser->buffer, &index);
            //         BAIL_IF(parse_data(parser, &instruction->ticker, length));
            //         index += length;
            //     }
            //     break;
            // case 5:
            //     // method_name (string)
            //     {
            //         uint64_t length = readVarInt(&parser->buffer, &index);
            //         index += length;
            //     }
            //     break;
            // case 6:
            //     // params (bytes)
            //     {
            //         uint64_t length = readVarInt(&parser->buffer, &index);
            //         parseParams(&parser->buffer + index, length);
            //         index += length;
            //     }
            //     break;
            // case 10000:
            //     // signature (bytes)
            //     {
            //         uint64_t length = readVarInt(&parser->buffer, &index);
            //         index += length;
            //     }
            //     break;
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
