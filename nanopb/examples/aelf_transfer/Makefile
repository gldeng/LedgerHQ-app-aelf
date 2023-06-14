# Include the nanopb provided Makefile rules
include ../../extra/nanopb.mk

# Compiler flags to enable all warnings & debug info
CFLAGS = -Wall -Werror -g -O0
CFLAGS += "-I$(NANOPB_DIR)"

# C source code files that are required
CSRC  = aelf.c                   # The main program
CSRC += aelf.pb.c                # The compiled protocol definition
CSRC += $(NANOPB_DIR)/pb_encode.c  # The nanopb encoder
CSRC += $(NANOPB_DIR)/pb_decode.c  # The nanopb decoder
CSRC += $(NANOPB_DIR)/pb_common.c  # The nanopb common parts

# Build rule for the main program
aelf: $(CSRC)
	$(CC) $(CFLAGS) -oaelf $(CSRC)

# Build rule for the protocol
aelf.pb.c: aelf.proto
	$(PROTOC) $(PROTOC_OPTS) --nanopb_out=. aelf.proto

