#include "instruction.h"
#include "sol/parser.h"
#include "sol/transaction_summary.h"
#include "util.h"
#include <string.h>


#define FROM_ADDRESS_PREFIX_LENGTH 4
static const char FROM_ADDRESS_PREFIX[] = {0x0a, 0x22, 0x0a, 0x20};

#define CONTRACT_ADDRESS_PREFIX_LENGTH 4
static const char CONTRACT_ADDRESS_PREFIX[] = {0x12, 0x22, 0x0a, 0x20};

#define REF_BLOCK_NUMBER_PREFIX_LENGTH 1
static const char REF_BLOCK_NUMBER_PREFIX[] = {0x18};
#define REF_BLOCK_PREFIX_PREFIX_LENGTH 1
static const char REF_BLOCK_PREFIX_PREFIX[] = {0x18};

#define METHOD_NAME_LENGTH 10
static const char METHOD_NAME[] = {0x2a, 0x08, 0x54, 0x72, 0x61, 0x6e, 0x73, 0x66, 0x65, 0x72};

#define PARAMS_PREFIX_LENGTH 1
static const char PARAMS_PREFIX[] = {0x32};
#define TO_ADDRESS_PREFIX_LENGTH 4
static const char TO_ADDRESS_PREFIX[] = {0x0a, 0x22, 0x0a, 0x20};
#define SYMBOL_LENGTH 5
static const char SYMBOL[] = {0x12, 0x03, 0x45, 0x4c, 0x46};

#define AMOUNT_PREFIX_LENGTH 1
static const char AMOUNT_PREFIX[] = {0x18};

#define MEMO_PREFIX_LENGTH 1
static const char MEMO_PREFIX[] = {0x22};

int parse_system_transfer_instruction(Parser* parser,
                                      Instruction* instruction,
                                      SystemTransferInfo* info) {
    BAIL_IF(assert_bytes(parser, FROM_ADDRESS_PREFIX, FROM_ADDRESS_PREFIX_LENGTH));
    BAIL_IF(parse_pubkey(parser, &info->from));
    BAIL_IF(assert_bytes(parser, CONTRACT_ADDRESS_PREFIX, CONTRACT_ADDRESS_PREFIX_LENGTH));
    Pubkey* contract_address;
    BAIL_IF(parse_pubkey(parser, &contract_address));
    BAIL_IF(assert_bytes(parser, REF_BLOCK_NUMBER_PREFIX, REF_BLOCK_NUMBER_PREFIX_LENGTH));
    uint64_t val;
    BAIL_IF(parse_varint(parser, &val));
    BAIL_IF(assert_bytes(parser, REF_BLOCK_PREFIX_PREFIX, REF_BLOCK_PREFIX_PREFIX_LENGTH));

    if(parser->buffer_length < 4) {
        return 1;
    }
    parser->buffer += 4;
    parser->buffer_length -= 4;

    BAIL_IF(assert_bytes(parser, METHOD_NAME, METHOD_NAME_LENGTH));
    BAIL_IF(assert_bytes(parser, PARAMS_PREFIX, PARAMS_PREFIX_LENGTH));
    BAIL_IF(parse_varint(parser, &val));

    BAIL_IF(parse_pubkey(parser, &info->to));
    BAIL_IF(assert_bytes(parser, SYMBOL, SYMBOL_LENGTH));

    BAIL_IF(assert_bytes(parser, AMOUNT_PREFIX, AMOUNT_PREFIX_LENGTH));
    BAIL_IF(assert_bytes(parser, MEMO_PREFIX, MEMO_PREFIX_LENGTH));

    BAIL_IF(parse_varint(parser, &val));
    if (parser->buffer_length != val) {
        return 1;
    }
    info->amount = val;
    parser->buffer += val;
    parser->buffer_length -= val;
    return 0;
}

int parse_system_get_tx_result_instruction(Parser* parser,
                                           Instruction* instruction,
                                           SystemGetTxResultInfo* info) {
    BAIL_IF(parse_pubkey(parser, &info->from));
    BAIL_IF(parse_pubkey(parser, &info->chain));
    BAIL_IF(parse_u64(parser, &info->ref_block_number));
    BAIL_IF(parse_sized_string(parser, &info->method_name));
    BAIL_IF(parse_pubkey(parser, &info->to));
    BAIL_IF(parse_data(parser, &instruction->ticker, &instruction->ticker_length));
    BAIL_IF(parse_u64(parser, &info->amount));
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

int print_system_get_tx_result_info(const SystemGetTxResultInfo* info) {
    SummaryItem* item;

    item = transaction_summary_primary_item();
    summary_item_set_string(item, "Type", "Get Transaction result");

    item = transaction_summary_general_item();
    summary_item_set_pubkey(item, "From", info->from);

    item = transaction_summary_general_item();
    summary_item_set_pubkey(item, "Contract", info->chain);

    item = transaction_summary_general_item();
    summary_item_set_i64(item, "Ref block number", info->ref_block_number);

    item = transaction_summary_general_item();
    summary_item_set_sized_string(item, "Method name", &info->method_name);

    item = transaction_summary_general_item();
    summary_item_set_pubkey(item, "Recipient", info->to);

    item = transaction_summary_general_item();
    summary_item_set_amount(item, "Amount", info->amount);

    return 0;
}