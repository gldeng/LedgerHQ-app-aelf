#ifndef _APDU_REPLY_H_
#define _APDU_REPLY_H_

#ifdef TEST
#include <stdio.h>
#define THROW(code)                \
    do {                           \
        printf("error: %d", code); \
    } while (0)
#endif

typedef enum ApduReply {
    /* ApduReplySdk* come from nanos-secure-sdk/include/os.h.  Here we add the
     * 0x68__ prefix that app_main() ORs into those values before sending them
     * over the wire
     */
    ApduReplySdkException = 0x6801,
    ApduReplySdkInvalidParameter = 0x6802,
    ApduReplySdkExceptionOverflow = 0x6803,
    ApduReplySdkExceptionSecurity = 0x6804,
    ApduReplySdkInvalidCrc = 0x6805,
    ApduReplySdkInvalidChecksum = 0x6806,
    ApduReplySdkInvalidCounter = 0x6807,
    ApduReplySdkNotSupported = 0x6808,
    ApduReplySdkInvalidState = 0x6809,
    ApduReplySdkTimeout = 0x6810,
    ApduReplySdkExceptionPIC = 0x6811,
    ApduReplySdkExceptionAppExit = 0x6812,
    ApduReplySdkExceptionIoOverflow = 0x6813,
    ApduReplySdkExceptionIoHeader = 0x6814,
    ApduReplySdkExceptionIoState = 0x6815,
    ApduReplySdkExceptionIoReset = 0x6816,
    ApduReplySdkExceptionCxPort = 0x6817,
    ApduReplySdkExceptionSystem = 0x6818,
    ApduReplySdkNotEnoughSpace = 0x6819,

    ApduReplyNoApduReceived = 0x6982,

    ApduReplyAelfInvalidMessage = 0x6a80,
    ApduReplyAelfInvalidMessageHeader = 0x6a81,
    ApduReplyAelfInvalidMessageFormat = 0x6a82,
    ApduReplyAelfInvalidMessageSize = 0x6a83,
    ApduReplyAelfSummaryFinalizeFailed = 0x6f00,
    ApduReplyAelfSummaryUpdateFailed = 0x6f01,

    ApduReplyAelfFieldNumberUnknown = 0x6f02,
    ApduReplyAelfWrongTicker = 0x6f03,
    ApduReplyAelfWrongMethodName = 0x6f04,
    ApduReplyAelfWrongSmartContractAddress = 0x6f05,

    ApduReplyUnimplementedInstruction = 0x6d00,
    ApduReplyInvalidCla = 0x6e00,

    ApduReplySuccess = 0x9000,
} ApduReply;

#endif
