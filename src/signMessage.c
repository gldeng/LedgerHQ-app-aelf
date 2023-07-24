#include "getPubkey.h"
#include "os.h"
#include "ux.h"
#include "cx.h"
#include "menu.h"
#include "utils.h"
#include "aelf/parser.h"
#include "aelf/printer.h"
#include "aelf/print_config.h"
#include "aelf/message.h"
#include "aelf/transaction_summary.h"
#include "globals.h"
#include "apdu.h"

static uint8_t set_result_sign_message() {
    uint8_t signature[SIGNATURE_LENGTH];
    cx_ecfp_private_key_t privateKey;
    size_t sig_len = SIGNATURE_LENGTH;
    BEGIN_TRY {
        TRY {
            get_private_key(&privateKey,
                            G_command.derivation_path,
                            G_command.derivation_path_length);
            cx_ecdsa_sign_no_throw(&privateKey,
                                   CX_RND_RFC6979 | CX_LAST,
                                   CX_SHA256,
                                   G_command.message,
                                   G_command.message_length,
                                   signature,
                                   &sig_len,
                                   NULL);
            memcpy(G_io_apdu_buffer, signature, SIGNATURE_LENGTH);
        }
        CATCH_OTHER(e) {
            MEMCLEAR(privateKey);
            THROW(e);
        }
        FINALLY {
            MEMCLEAR(privateKey);
        }
    }
    END_TRY;
    return SIGNATURE_LENGTH;
}

static void send_result_sign_message(void) {
    sendResponse(set_result_sign_message(), true);
}

//////////////////////////////////////////////////////////////////////

UX_STEP_CB(ux_approve_step,
           pb,
           send_result_sign_message(),
           {
               &C_icon_validate_14,
               "Approve",
           });
UX_STEP_CB(ux_reject_step,
           pb,
           sendResponse(0, false),
           {
               &C_icon_crossmark,
               "Reject",
           });
UX_STEP_NOCB_INIT(ux_summary_step,
                  bnnn_paging,
                  {
                      size_t step_index = G_ux.flow_stack[stack_slot].index;
                      enum DisplayFlags flags = DisplayFlagNone;
                      if (N_storage.settings.pubkey_display == PubkeyDisplayLong) {
                          flags |= DisplayFlagLongPubkeys;
                      }
                      if (transaction_summary_display_item(step_index, flags)) {
                          THROW(ApduReplyAelfSummaryUpdateFailed);
                      }
                  },
                  {
                      .title = G_transaction_summary_title,
                      .text = G_transaction_summary_text,
                  });

#define MAX_FLOW_STEPS                                     \
    (MAX_TRANSACTION_SUMMARY_ITEMS + 1 /* approve */       \
     + 1                               /* reject */        \
     + 1                               /* FLOW_END_STEP */ \
    )
ux_flow_step_t static const *flow_steps[MAX_FLOW_STEPS];

void handle_sign_message_parse_message(volatile unsigned int *tx) {
    if (!tx || G_command.state != ApduStatePayloadComplete) {
        THROW(ApduReplySdkInvalidParameter);
    }

    // Handle the transaction message signing
    Parser parser = {G_command.message, G_command.message_length};
    PrintConfig print_config;
    print_config.expert_mode = (N_storage.settings.display_mode == DisplayModeExpert);
    print_config.signer_pubkey = NULL;

    // if (parse_message_header(&parser, header) != 0) {
    //     // This is not a valid Aelf message
    //     THROW(ApduReplyAelfInvalidMessage);
    // }

    if (G_command.non_confirm) {
        // Uncomment this to allow unattended signing.
        //*tx = set_result_sign_message();
        // THROW(ApduReplySuccess);
        UNUSED(tx);
        THROW(ApduReplySdkNotSupported);
    }

    // Set the transaction summary
    transaction_summary_reset();
    if (process_message_body(parser.buffer, parser.buffer_length, G_command.instruction) != 0) {
        // Message not processed, throw if blind signing is not enabled
        if (N_storage.settings.allow_blind_sign == BlindSignEnabled) {
            SummaryItem *item = transaction_summary_primary_item();
            summary_item_set_string(item, "Unrecognized", "format");

            cx_hash_sha256(G_command.message,
                           G_command.message_length,
                           (uint8_t *) &G_command.message_hash,
                           HASH_LENGTH);

            item = transaction_summary_general_item();
            summary_item_set_hash(item, "Message Hash", &G_command.message_hash);
        } else {
            THROW(ApduReplySdkNotSupported);
        }
    }
}

void handle_sign_message_ui(volatile unsigned int *flags) {
    // Display the transaction summary
    SummaryItemKind_t summary_step_kinds[MAX_TRANSACTION_SUMMARY_ITEMS];
    size_t num_summary_steps = 0;
    if (transaction_summary_finalize(summary_step_kinds, &num_summary_steps) == 0) {
        size_t num_flow_steps = 0;

        for (size_t i = 0; i < num_summary_steps; i++) {
            flow_steps[num_flow_steps++] = &ux_summary_step;
        }

        flow_steps[num_flow_steps++] = &ux_approve_step;
        flow_steps[num_flow_steps++] = &ux_reject_step;
        flow_steps[num_flow_steps++] = FLOW_END_STEP;

        ux_flow_init(0, flow_steps, NULL);
    } else {
        THROW(ApduReplyAelfSummaryFinalizeFailed);
    }

    *flags |= IO_ASYNCH_REPLY;
}
