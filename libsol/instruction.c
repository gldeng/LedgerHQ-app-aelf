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

    /* Allocate space for the decoded message. */
    aelf_Transaction message = aelf_Transaction_init_zero;
    
    /* Create a stream that reads from the buffer. */
    pb_istream_t stream = pb_istream_from_buffer(parser->buffer, parser->buffer_length);
    
    /* Now we are ready to decode the message. */
    uint8_t status = pb_decode(&stream, aelf_Transaction_fields, &message);
    
    /* Check for errors... */
    if (!status)
    {
        printf("Decoding failed: %s\n", PB_GET_ERROR(&stream));
        return 1;
    }
    
    /* Print the data contained in the message. */
    printf("Your ref block number was %d!\n", (int)message.ref_block_number);
    
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
