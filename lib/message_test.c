#include "common_byte_strings.h"
#include "message.c"
#include "aelf/parser.h"
#include "aelf/transaction_summary.h"
#include "util.h"
#include <assert.h>
#include <stdio.h>

// Disable clang format for this file to keep clear buffer formating
/* clang-format off */

void test_process_message_body_ok() {
    uint8_t msg_body[] = {10, 34, 10, 32, 205, 239, 231, 40, 73, 49, 51, 245, 38, 203, 94, 151, 226,
                          236, 51, 156, 162, 25, 190, 248, 4, 39, 234, 245, 63, 240, 0, 60, 173, 36,
                          28, 122, 18, 34, 10, 32, 39, 145, 233, 146, 165, 127, 40, 231, 90, 17, 241,
                          58, 242, 192, 174, 200, 176, 235, 53, 210, 240, 72, 212, 46, 186, 137, 1,
                          201, 46, 3, 120, 220, 24, 141, 205, 162, 75, 34, 4, 90, 116, 71, 56, 42, 8,
                          84, 114, 97, 110, 115, 102, 101, 114, 50, 52, 10, 34, 10, 32, 79, 244, 230,
                          58, 212, 170, 126, 201, 46, 101, 186, 45, 55, 178, 197, 107, 63, 130, 57,
                          11, 252, 37, 230, 108, 235, 171, 104, 33, 243, 176, 92, 11, 18, 3, 69, 76,
                          70, 24, 128, 173, 226, 4, 34, 4, 116, 101, 115, 116};

    transaction_summary_reset();
    assert(process_message_body(msg_body, ARRAY_LEN(msg_body), 3) == 0);
}

/* clang-format on */

int main() {
    test_process_message_body_ok();

    printf("passed\n");
    return 0;
}
