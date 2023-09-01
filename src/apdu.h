#pragma once

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include "globals.h"
#include "aelf/parser.h"
#include "apduCodes.h"

typedef enum ApduState {
    ApduStateUninitialized = 0,
    ApduStatePayloadInProgress,
    ApduStatePayloadComplete,
} ApduState;

typedef struct ApduHeader {
    uint8_t class;
    uint8_t instruction;
    uint8_t p1;
    uint8_t p2;
    const uint8_t* data;
    size_t data_length;
    bool deprecated_host;
} ApduHeader;

typedef struct ApduCommand {
    ApduState state;
    InstructionCode instruction;
    uint8_t num_derivation_paths;
    uint32_t derivation_path[MAX_BIP32_PATH_LENGTH];
    uint32_t derivation_path_length;
    bool non_confirm;
    bool deprecated_host;
    uint8_t message[MAX_MESSAGE_LENGTH];
    int message_length;
    Hash message_hash;
} ApduCommand;

extern ApduCommand G_command;

int apdu_handle_message(const uint8_t* apdu_message,
                        size_t apdu_message_len,
                        ApduCommand* apdu_command);