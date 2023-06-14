#include "instruction.h"
#include "sol/parser.h"
#include "sol/transaction_summary.h"
#include "util.h"
#include <string.h>
#include <pb_decode.h>
#include "proto/message.pb.h"



int parse_system_transfer_instruction(Parser* parser,
                                      Instruction* instruction,
                                      SystemTransferInfo* info) {
    // BAIL_IF(parse_pubkey(parser, &info->to));
    // BAIL_IF(parse_data(parser, &instruction->ticker, &instruction->ticker_length));
    // BAIL_IF(parse_u64(parser, &info->amount));
    
    PRINTF("GUI PARSER:\n%.*H\n", parser->buffer_length, parser->buffer);

    init_canary();
    check_canary();

    aelf_TransferInput transfer_input = aelf_TransferInput_init_zero;
    check_canary();
    pb_byte_t symbolBuffer[BUFFER_SIZE] = {0};
    pb_byte_t memoBuffer[BUFFER_SIZE] = {0};
    pb_byte_t addressBuffer[BUFFER_SIZE] = {0};
    check_canary();

    transfer_input.symbol.funcs.decode = read_string_field;
    transfer_input.memo.funcs.decode = read_string_field;
    transfer_input.to.value.funcs.decode = read_address_field;
    transfer_input.symbol.arg = &symbolBuffer;
    transfer_input.memo.arg = &memoBuffer;
    transfer_input.to.value.arg = &addressBuffer;
    check_canary();

    aelf_Transaction txn = aelf_Transaction_init_zero;

    txn.params.funcs.decode = read_transfer_input;
    txn.params.arg = &transfer_input;

    pb_istream_t stream = pb_istream_from_buffer((const pb_byte_t *)parser->buffer, (size_t)parser->buffer_length);
    check_canary();

    if (!pb_decode(&stream, aelf_Transaction_fields, &txn))
    {
        PRINTF("Decoding failed: %s\n", PB_GET_ERROR(&stream));
        return 1;
    }

    PRINTF("Address   : %s\n", addressBuffer);
    PRINTF("Symbol    : %s\n", symbolBuffer);
    PRINTF("Amount    : %ld\n", transfer_input.amount);
    PRINTF("Memo      : %s\n", memoBuffer);

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
