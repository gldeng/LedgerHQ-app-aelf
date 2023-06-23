#pragma once

#include "sol/parser.h"
#include "sol/print_config.h"

typedef struct SystemTransferInfo {
    const Pubkey* from;
    const Pubkey* to;
    uint32_t ref_block_number;
    SizedString ref_block_prefix;
    SizedString method_name;
    const Pubkey* dest;
    SizedString ticker;
    uint32_t amount;
    SizedString memo;
} SystemTransferInfo;


typedef struct InstructionInfo {
    union {
        SystemTransferInfo transfer;
    };
} InstructionInfo;

// This symbol is defined by the link script to be at the start of the stack
// area.
extern unsigned long _stack;

#define STACK_CANARY (*((volatile uint32_t*) &_stack))

void init_canary();

void check_canary();

int parse_system_transfer_instruction(Parser* parser, SystemTransferInfo* info);

int print_system_transfer_info(const SystemTransferInfo* info);