
build/nanos/bin/app.elf:     file format elf32-littlearm


Disassembly of section .text:

c0d00000 <main>:
        storage.initialized = 0x01;
        nvm_write((void *) &N_storage, (void *) &storage, sizeof(internalStorage_t));
    }
}

__attribute__((section(".boot"))) int main(void) {
c0d00000:	b570      	push	{r4, r5, r6, lr}
c0d00002:	b08c      	sub	sp, #48	; 0x30
    // exit critical section
    __asm volatile("cpsie i");
c0d00004:	b662      	cpsie	i

    // ensure exception will work as planned
    os_boot();
c0d00006:	f000 ff29 	bl	c0d00e5c <os_boot>
c0d0000a:	4c1a      	ldr	r4, [pc, #104]	; (c0d00074 <main+0x74>)
c0d0000c:	4e1a      	ldr	r6, [pc, #104]	; (c0d00078 <main+0x78>)
c0d0000e:	2021      	movs	r0, #33	; 0x21
c0d00010:	00c1      	lsls	r1, r0, #3

    for (;;) {
        UX_INIT();
c0d00012:	4620      	mov	r0, r4
c0d00014:	f004 fde8 	bl	c0d04be8 <__aeabi_memclr>
c0d00018:	466d      	mov	r5, sp

        BEGIN_TRY {
            TRY {
c0d0001a:	4628      	mov	r0, r5
c0d0001c:	f004 fefa 	bl	c0d04e14 <setjmp>
c0d00020:	85a8      	strh	r0, [r5, #44]	; 0x2c
c0d00022:	b280      	uxth	r0, r0
c0d00024:	42b0      	cmp	r0, r6
c0d00026:	d106      	bne.n	c0d00036 <main+0x36>
c0d00028:	4668      	mov	r0, sp
c0d0002a:	2100      	movs	r1, #0
                BLE_power(1, "Nano X");
#endif  // HAVE_BLE

                app_main();
            }
            CATCH(ApduReplySdkExceptionIoReset) {
c0d0002c:	8581      	strh	r1, [r0, #44]	; 0x2c
c0d0002e:	980a      	ldr	r0, [sp, #40]	; 0x28
c0d00030:	f002 fc7a 	bl	c0d02928 <try_context_set>
c0d00034:	e7eb      	b.n	c0d0000e <main+0xe>
            TRY {
c0d00036:	2800      	cmp	r0, #0
c0d00038:	d00a      	beq.n	c0d00050 <main+0x50>
c0d0003a:	4668      	mov	r0, sp
c0d0003c:	2400      	movs	r4, #0
                // reset IO and UX before continuing
                continue;
            }
            CATCH_ALL {
c0d0003e:	8584      	strh	r4, [r0, #44]	; 0x2c
c0d00040:	980a      	ldr	r0, [sp, #40]	; 0x28
c0d00042:	f002 fc71 	bl	c0d02928 <try_context_set>
            FINALLY {
            }
        }
        END_TRY;
    }
    app_exit();
c0d00046:	f000 fd8d 	bl	c0d00b64 <app_exit>
    return 0;
c0d0004a:	4620      	mov	r0, r4
c0d0004c:	b00c      	add	sp, #48	; 0x30
c0d0004e:	bd70      	pop	{r4, r5, r6, pc}
c0d00050:	4668      	mov	r0, sp
            TRY {
c0d00052:	f002 fc69 	bl	c0d02928 <try_context_set>
c0d00056:	900a      	str	r0, [sp, #40]	; 0x28
                io_seproxyhal_init();
c0d00058:	f001 f81a 	bl	c0d01090 <io_seproxyhal_init>
                nv_app_state_init();
c0d0005c:	f000 fda2 	bl	c0d00ba4 <nv_app_state_init>
c0d00060:	2000      	movs	r0, #0
                USB_power(0);
c0d00062:	f003 fc3d 	bl	c0d038e0 <USB_power>
c0d00066:	2001      	movs	r0, #1
                USB_power(1);
c0d00068:	f003 fc3a 	bl	c0d038e0 <USB_power>
                ui_idle();
c0d0006c:	f000 feb4 	bl	c0d00dd8 <ui_idle>
                app_main();
c0d00070:	f000 f9d8 	bl	c0d00424 <app_main>
c0d00074:	20000250 	.word	0x20000250
c0d00078:	00006816 	.word	0x00006816

c0d0007c <apdu_handle_message>:
 * @return zero on success, ApduReply error code otherwise.
 *
 */
int apdu_handle_message(const uint8_t* apdu_message,
                        size_t apdu_message_len,
                        ApduCommand* apdu_command) {
c0d0007c:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0007e:	b087      	sub	sp, #28
c0d00080:	4d5e      	ldr	r5, [pc, #376]	; (c0d001fc <apdu_handle_message+0x180>)
    if (!apdu_command || !apdu_message) {
c0d00082:	2800      	cmp	r0, #0
c0d00084:	d022      	beq.n	c0d000cc <apdu_handle_message+0x50>
c0d00086:	4614      	mov	r4, r2
c0d00088:	2a00      	cmp	r2, #0
c0d0008a:	d01f      	beq.n	c0d000cc <apdu_handle_message+0x50>
c0d0008c:	22d5      	movs	r2, #213	; 0xd5
c0d0008e:	01d5      	lsls	r5, r2, #7
c0d00090:	1cef      	adds	r7, r5, #3

    // parse header
    ApduHeader header = {0};

    // must at least hold the class and instruction
    if (apdu_message_len <= OFFSET_INS) {
c0d00092:	2902      	cmp	r1, #2
c0d00094:	d201      	bcs.n	c0d0009a <apdu_handle_message+0x1e>
c0d00096:	463d      	mov	r5, r7
c0d00098:	e018      	b.n	c0d000cc <apdu_handle_message+0x50>
        return ApduReplyAelfInvalidMessageSize;
    }

    header.class = apdu_message[OFFSET_CLA];
c0d0009a:	7802      	ldrb	r2, [r0, #0]
    if (header.class != CLA) {
c0d0009c:	2ae0      	cmp	r2, #224	; 0xe0
c0d0009e:	d111      	bne.n	c0d000c4 <apdu_handle_message+0x48>
        return ApduReplyAelfInvalidMessageHeader;
    }

    header.instruction = apdu_message[OFFSET_INS];
c0d000a0:	7846      	ldrb	r6, [r0, #1]
    switch (header.instruction) {
c0d000a2:	1e72      	subs	r2, r6, #1
c0d000a4:	2a03      	cmp	r2, #3
c0d000a6:	d80f      	bhi.n	c0d000c8 <apdu_handle_message+0x4c>
        case InsGetAppConfiguration:
        case InsGetPubkey:
        case InsSignMessage:
        case InsGetTxResult: {
            // must at least hold a full modern header
            if (apdu_message_len < OFFSET_CDATA) {
c0d000a8:	1f4a      	subs	r2, r1, #5
c0d000aa:	2aff      	cmp	r2, #255	; 0xff
c0d000ac:	d8f3      	bhi.n	c0d00096 <apdu_handle_message+0x1a>
            // modern data may be up to 255B
            if (apdu_message_len > UINT8_MAX + OFFSET_CDATA) {
                return ApduReplyAelfInvalidMessageSize;
            }

            header.data_length = apdu_message[OFFSET_LC];
c0d000ae:	7903      	ldrb	r3, [r0, #4]
            if (apdu_message_len != header.data_length + OFFSET_CDATA) {
c0d000b0:	1d5a      	adds	r2, r3, #5
c0d000b2:	428a      	cmp	r2, r1
c0d000b4:	d1ef      	bne.n	c0d00096 <apdu_handle_message+0x1a>
        default:
            return ApduReplyUnimplementedInstruction;
    }

    header.p1 = apdu_message[OFFSET_P1];
    header.p2 = apdu_message[OFFSET_P2];
c0d000b6:	78c2      	ldrb	r2, [r0, #3]
c0d000b8:	2101      	movs	r1, #1
            if (header.data_length > 0) {
c0d000ba:	9106      	str	r1, [sp, #24]
c0d000bc:	2b00      	cmp	r3, #0
c0d000be:	d108      	bne.n	c0d000d2 <apdu_handle_message+0x56>
c0d000c0:	9303      	str	r3, [sp, #12]
c0d000c2:	e008      	b.n	c0d000d6 <apdu_handle_message+0x5a>
c0d000c4:	1c6d      	adds	r5, r5, #1
c0d000c6:	e001      	b.n	c0d000cc <apdu_handle_message+0x50>
c0d000c8:	206d      	movs	r0, #109	; 0x6d
c0d000ca:	0205      	lsls	r5, r0, #8
    }

    apdu_command->state = ApduStatePayloadComplete;

    return 0;
c0d000cc:	4628      	mov	r0, r5
c0d000ce:	b007      	add	sp, #28
c0d000d0:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d000d2:	1d41      	adds	r1, r0, #5
c0d000d4:	9103      	str	r1, [sp, #12]
c0d000d6:	9201      	str	r2, [sp, #4]
c0d000d8:	9906      	ldr	r1, [sp, #24]
c0d000da:	400a      	ands	r2, r1
c0d000dc:	9205      	str	r2, [sp, #20]
    header.p1 = apdu_message[OFFSET_P1];
c0d000de:	7880      	ldrb	r0, [r0, #2]
    if (header.instruction == InsGetAppConfiguration) {
c0d000e0:	9004      	str	r0, [sp, #16]
c0d000e2:	2e03      	cmp	r6, #3
c0d000e4:	d00f      	beq.n	c0d00106 <apdu_handle_message+0x8a>
c0d000e6:	2e01      	cmp	r6, #1
c0d000e8:	d117      	bne.n	c0d0011a <apdu_handle_message+0x9e>
c0d000ea:	4945      	ldr	r1, [pc, #276]	; (c0d00200 <apdu_handle_message+0x184>)
        explicit_bzero(apdu_command, sizeof(ApduCommand));
c0d000ec:	4620      	mov	r0, r4
c0d000ee:	f004 fd91 	bl	c0d04c14 <explicit_bzero>
c0d000f2:	2500      	movs	r5, #0
        apdu_command->deprecated_host = header.deprecated_host;
c0d000f4:	7765      	strb	r5, [r4, #29]
c0d000f6:	2081      	movs	r0, #129	; 0x81
c0d000f8:	0040      	lsls	r0, r0, #1
        apdu_command->state = ApduStatePayloadComplete;
c0d000fa:	8020      	strh	r0, [r4, #0]
c0d000fc:	9904      	ldr	r1, [sp, #16]
        apdu_command->non_confirm = (header.p1 == P1_NON_CONFIRM);
c0d000fe:	4248      	negs	r0, r1
c0d00100:	4148      	adcs	r0, r1
c0d00102:	7720      	strb	r0, [r4, #28]
c0d00104:	e7e2      	b.n	c0d000cc <apdu_handle_message+0x50>
        if (!first_data_chunk) {
c0d00106:	9805      	ldr	r0, [sp, #20]
c0d00108:	2800      	cmp	r0, #0
c0d0010a:	d133      	bne.n	c0d00174 <apdu_handle_message+0xf8>
c0d0010c:	493c      	ldr	r1, [pc, #240]	; (c0d00200 <apdu_handle_message+0x184>)
            explicit_bzero(apdu_command, sizeof(ApduCommand));
c0d0010e:	4620      	mov	r0, r4
c0d00110:	9302      	str	r3, [sp, #8]
c0d00112:	f004 fd7f 	bl	c0d04c14 <explicit_bzero>
c0d00116:	9902      	ldr	r1, [sp, #8]
c0d00118:	e00e      	b.n	c0d00138 <apdu_handle_message+0xbc>
c0d0011a:	9302      	str	r3, [sp, #8]
c0d0011c:	4938      	ldr	r1, [pc, #224]	; (c0d00200 <apdu_handle_message+0x184>)
        explicit_bzero(apdu_command, sizeof(ApduCommand));
c0d0011e:	4620      	mov	r0, r4
c0d00120:	f004 fd78 	bl	c0d04c14 <explicit_bzero>
    if (first_data_chunk) {
c0d00124:	9805      	ldr	r0, [sp, #20]
c0d00126:	2800      	cmp	r0, #0
c0d00128:	d138      	bne.n	c0d0019c <apdu_handle_message+0x120>
        if (!header.deprecated_host && header.instruction != InsGetPubkey) {
c0d0012a:	2e02      	cmp	r6, #2
c0d0012c:	9902      	ldr	r1, [sp, #8]
c0d0012e:	d103      	bne.n	c0d00138 <apdu_handle_message+0xbc>
            apdu_command->num_derivation_paths = 1;
c0d00130:	9806      	ldr	r0, [sp, #24]
c0d00132:	70a0      	strb	r0, [r4, #2]
c0d00134:	9d03      	ldr	r5, [sp, #12]
c0d00136:	e009      	b.n	c0d0014c <apdu_handle_message+0xd0>
            if (!header.data_length) {
c0d00138:	2900      	cmp	r1, #0
c0d0013a:	d0ac      	beq.n	c0d00096 <apdu_handle_message+0x1a>
c0d0013c:	9a03      	ldr	r2, [sp, #12]
            apdu_command->num_derivation_paths = header.data[0];
c0d0013e:	7810      	ldrb	r0, [r2, #0]
c0d00140:	70a0      	strb	r0, [r4, #2]
            if (apdu_command->num_derivation_paths != 1) {
c0d00142:	2801      	cmp	r0, #1
c0d00144:	d1c2      	bne.n	c0d000cc <apdu_handle_message+0x50>
c0d00146:	1e49      	subs	r1, r1, #1
c0d00148:	1c52      	adds	r2, r2, #1
c0d0014a:	4615      	mov	r5, r2
        const int ret = read_derivation_path(header.data,
c0d0014c:	9102      	str	r1, [sp, #8]
                                             apdu_command->derivation_path,
c0d0014e:	1d22      	adds	r2, r4, #4
                                             &apdu_command->derivation_path_length);
c0d00150:	4623      	mov	r3, r4
c0d00152:	3318      	adds	r3, #24
        const int ret = read_derivation_path(header.data,
c0d00154:	4628      	mov	r0, r5
c0d00156:	9305      	str	r3, [sp, #20]
c0d00158:	f003 fd30 	bl	c0d03bbc <read_derivation_path>
c0d0015c:	462a      	mov	r2, r5
c0d0015e:	9b02      	ldr	r3, [sp, #8]
c0d00160:	4605      	mov	r5, r0
        if (ret) {
c0d00162:	2800      	cmp	r0, #0
c0d00164:	d1b2      	bne.n	c0d000cc <apdu_handle_message+0x50>
        header.data += 1 + apdu_command->derivation_path_length * 4;
c0d00166:	9805      	ldr	r0, [sp, #20]
c0d00168:	6800      	ldr	r0, [r0, #0]
c0d0016a:	0080      	lsls	r0, r0, #2
c0d0016c:	1c40      	adds	r0, r0, #1
        header.data_length -= 1 + apdu_command->derivation_path_length * 4;
c0d0016e:	1a1b      	subs	r3, r3, r0
        header.data += 1 + apdu_command->derivation_path_length * 4;
c0d00170:	1812      	adds	r2, r2, r0
c0d00172:	e015      	b.n	c0d001a0 <apdu_handle_message+0x124>
            if (apdu_command->state != ApduStatePayloadInProgress ||
c0d00174:	7820      	ldrb	r0, [r4, #0]
c0d00176:	2801      	cmp	r0, #1
c0d00178:	d1a8      	bne.n	c0d000cc <apdu_handle_message+0x50>
                apdu_command->instruction != header.instruction ||
c0d0017a:	7860      	ldrb	r0, [r4, #1]
c0d0017c:	2803      	cmp	r0, #3
c0d0017e:	d1a5      	bne.n	c0d000cc <apdu_handle_message+0x50>
c0d00180:	9904      	ldr	r1, [sp, #16]
                apdu_command->non_confirm != (header.p1 == P1_NON_CONFIRM) ||
c0d00182:	4248      	negs	r0, r1
c0d00184:	4148      	adcs	r0, r1
c0d00186:	7f21      	ldrb	r1, [r4, #28]
c0d00188:	4281      	cmp	r1, r0
c0d0018a:	d19f      	bne.n	c0d000cc <apdu_handle_message+0x50>
                apdu_command->deprecated_host != header.deprecated_host ||
c0d0018c:	7f60      	ldrb	r0, [r4, #29]
c0d0018e:	2800      	cmp	r0, #0
c0d00190:	d19c      	bne.n	c0d000cc <apdu_handle_message+0x50>
                apdu_command->num_derivation_paths != 1) {
c0d00192:	78a0      	ldrb	r0, [r4, #2]
            if (apdu_command->state != ApduStatePayloadInProgress ||
c0d00194:	2801      	cmp	r0, #1
c0d00196:	9a03      	ldr	r2, [sp, #12]
c0d00198:	d198      	bne.n	c0d000cc <apdu_handle_message+0x50>
c0d0019a:	e001      	b.n	c0d001a0 <apdu_handle_message+0x124>
c0d0019c:	9b02      	ldr	r3, [sp, #8]
c0d0019e:	9a03      	ldr	r2, [sp, #12]
c0d001a0:	2000      	movs	r0, #0
c0d001a2:	9005      	str	r0, [sp, #20]
    apdu_command->deprecated_host = header.deprecated_host;
c0d001a4:	7760      	strb	r0, [r4, #29]
    apdu_command->instruction = header.instruction;
c0d001a6:	7066      	strb	r6, [r4, #1]
    apdu_command->state = ApduStatePayloadInProgress;
c0d001a8:	9806      	ldr	r0, [sp, #24]
c0d001aa:	7020      	strb	r0, [r4, #0]
c0d001ac:	9904      	ldr	r1, [sp, #16]
    apdu_command->non_confirm = (header.p1 == P1_NON_CONFIRM);
c0d001ae:	4248      	negs	r0, r1
c0d001b0:	4148      	adcs	r0, r1
c0d001b2:	7720      	strb	r0, [r4, #28]
    if (header.data) {
c0d001b4:	2a00      	cmp	r2, #0
c0d001b6:	d016      	beq.n	c0d001e6 <apdu_handle_message+0x16a>
c0d001b8:	4611      	mov	r1, r2
c0d001ba:	2029      	movs	r0, #41	; 0x29
c0d001bc:	0146      	lsls	r6, r0, #5
        if (apdu_command->message_length + header.data_length > MAX_MESSAGE_LENGTH) {
c0d001be:	59a0      	ldr	r0, [r4, r6]
c0d001c0:	18c2      	adds	r2, r0, r3
c0d001c2:	461d      	mov	r5, r3
c0d001c4:	4b0e      	ldr	r3, [pc, #56]	; (c0d00200 <apdu_handle_message+0x184>)
c0d001c6:	3b44      	subs	r3, #68	; 0x44
c0d001c8:	429a      	cmp	r2, r3
c0d001ca:	462a      	mov	r2, r5
c0d001cc:	463d      	mov	r5, r7
c0d001ce:	d900      	bls.n	c0d001d2 <apdu_handle_message+0x156>
c0d001d0:	e77c      	b.n	c0d000cc <apdu_handle_message+0x50>
c0d001d2:	19a5      	adds	r5, r4, r6
        memcpy(apdu_command->message + apdu_command->message_length,
c0d001d4:	1820      	adds	r0, r4, r0
c0d001d6:	301e      	adds	r0, #30
c0d001d8:	4616      	mov	r6, r2
c0d001da:	f004 fd0b 	bl	c0d04bf4 <__aeabi_memcpy>
        apdu_command->message_length += header.data_length;
c0d001de:	6828      	ldr	r0, [r5, #0]
c0d001e0:	1980      	adds	r0, r0, r6
c0d001e2:	6028      	str	r0, [r5, #0]
c0d001e4:	e003      	b.n	c0d001ee <apdu_handle_message+0x172>
    } else if (header.instruction != InsGetPubkey) {
c0d001e6:	2e02      	cmp	r6, #2
c0d001e8:	463d      	mov	r5, r7
c0d001ea:	d000      	beq.n	c0d001ee <apdu_handle_message+0x172>
c0d001ec:	e76e      	b.n	c0d000cc <apdu_handle_message+0x50>
    if (header.p2 & P2_MORE) {
c0d001ee:	9801      	ldr	r0, [sp, #4]
c0d001f0:	0780      	lsls	r0, r0, #30
c0d001f2:	d401      	bmi.n	c0d001f8 <apdu_handle_message+0x17c>
c0d001f4:	2002      	movs	r0, #2
    apdu_command->state = ApduStatePayloadComplete;
c0d001f6:	7020      	strb	r0, [r4, #0]
c0d001f8:	9d05      	ldr	r5, [sp, #20]
c0d001fa:	e767      	b.n	c0d000cc <apdu_handle_message+0x50>
c0d001fc:	00006802 	.word	0x00006802
c0d00200:	00000544 	.word	0x00000544

c0d00204 <cx_ecfp_generate_pair_no_throw>:
CX_TRAMPOLINE _NR_cx_ecdsa_verify_no_throw                 cx_ecdsa_verify_no_throw
CX_TRAMPOLINE _NR_cx_ecfp_add_point_no_throw               cx_ecfp_add_point_no_throw
CX_TRAMPOLINE _NR_cx_ecfp_decode_sig_der                   cx_ecfp_decode_sig_der
CX_TRAMPOLINE _NR_cx_ecfp_encode_sig_der                   cx_ecfp_encode_sig_der
CX_TRAMPOLINE _NR_cx_ecfp_generate_pair2_no_throw          cx_ecfp_generate_pair2_no_throw
CX_TRAMPOLINE _NR_cx_ecfp_generate_pair_no_throw           cx_ecfp_generate_pair_no_throw
c0d00204:	b403      	push	{r0, r1}
c0d00206:	4801      	ldr	r0, [pc, #4]	; (c0d0020c <cx_ecfp_generate_pair_no_throw+0x8>)
c0d00208:	e01d      	b.n	c0d00246 <cx_trampoline_helper>
c0d0020a:	0000      	.short	0x0000
c0d0020c:	0000001b 	.word	0x0000001b

c0d00210 <cx_ecfp_init_private_key_no_throw>:
CX_TRAMPOLINE _NR_cx_ecfp_init_private_key_no_throw        cx_ecfp_init_private_key_no_throw
c0d00210:	b403      	push	{r0, r1}
c0d00212:	4801      	ldr	r0, [pc, #4]	; (c0d00218 <cx_ecfp_init_private_key_no_throw+0x8>)
c0d00214:	e017      	b.n	c0d00246 <cx_trampoline_helper>
c0d00216:	0000      	.short	0x0000
c0d00218:	0000001c 	.word	0x0000001c

c0d0021c <cx_eddsa_sign_no_throw>:
CX_TRAMPOLINE _NR_cx_ecfp_scalar_mult_no_throw             cx_ecfp_scalar_mult_no_throw
CX_TRAMPOLINE _NR_cx_ecschnorr_sign_no_throw               cx_ecschnorr_sign_no_throw
CX_TRAMPOLINE _NR_cx_ecschnorr_verify                      cx_ecschnorr_verify
CX_TRAMPOLINE _NR_cx_eddsa_get_public_key_internal         cx_eddsa_get_public_key_internal
CX_TRAMPOLINE _NR_cx_eddsa_get_public_key_no_throw         cx_eddsa_get_public_key_no_throw
CX_TRAMPOLINE _NR_cx_eddsa_sign_no_throw                   cx_eddsa_sign_no_throw
c0d0021c:	b403      	push	{r0, r1}
c0d0021e:	4801      	ldr	r0, [pc, #4]	; (c0d00224 <cx_eddsa_sign_no_throw+0x8>)
c0d00220:	e011      	b.n	c0d00246 <cx_trampoline_helper>
c0d00222:	0000      	.short	0x0000
c0d00224:	00000023 	.word	0x00000023

c0d00228 <cx_hash_sha256>:
CX_TRAMPOLINE _NR_cx_hash_get_info                         cx_hash_get_info
CX_TRAMPOLINE _NR_cx_hash_get_size                         cx_hash_get_size
CX_TRAMPOLINE _NR_cx_hash_init                             cx_hash_init
CX_TRAMPOLINE _NR_cx_hash_init_ex                          cx_hash_init_ex
CX_TRAMPOLINE _NR_cx_hash_no_throw                         cx_hash_no_throw
CX_TRAMPOLINE _NR_cx_hash_sha256                           cx_hash_sha256
c0d00228:	b403      	push	{r0, r1}
c0d0022a:	4801      	ldr	r0, [pc, #4]	; (c0d00230 <cx_hash_sha256+0x8>)
c0d0022c:	e00b      	b.n	c0d00246 <cx_trampoline_helper>
c0d0022e:	0000      	.short	0x0000
c0d00230:	00000033 	.word	0x00000033

c0d00234 <cx_rng_no_throw>:
CX_TRAMPOLINE _NR_cx_pbkdf2_hmac                           cx_pbkdf2_hmac
CX_TRAMPOLINE _NR_cx_pbkdf2_no_throw                       cx_pbkdf2_no_throw
CX_TRAMPOLINE _NR_cx_ripemd160_final                       cx_ripemd160_final
CX_TRAMPOLINE _NR_cx_ripemd160_init_no_throw               cx_ripemd160_init_no_throw
CX_TRAMPOLINE _NR_cx_ripemd160_update                      cx_ripemd160_update
CX_TRAMPOLINE _NR_cx_rng_no_throw                          cx_rng_no_throw
c0d00234:	b403      	push	{r0, r1}
c0d00236:	4801      	ldr	r0, [pc, #4]	; (c0d0023c <cx_rng_no_throw+0x8>)
c0d00238:	e005      	b.n	c0d00246 <cx_trampoline_helper>
c0d0023a:	0000      	.short	0x0000
c0d0023c:	00000058 	.word	0x00000058

c0d00240 <cx_x448>:
CX_TRAMPOLINE _NR_cx_swap_buffer32                         cx_swap_buffer32
CX_TRAMPOLINE _NR_cx_swap_buffer64                         cx_swap_buffer64
CX_TRAMPOLINE _NR_cx_swap_uint32                           cx_swap_uint32
CX_TRAMPOLINE _NR_cx_swap_uint64                           cx_swap_uint64
CX_TRAMPOLINE _NR_cx_x25519                                cx_x25519
CX_TRAMPOLINE _NR_cx_x448                                  cx_x448
c0d00240:	b403      	push	{r0, r1}
c0d00242:	4802      	ldr	r0, [pc, #8]	; (c0d0024c <cx_trampoline_helper+0x6>)
c0d00244:	e7ff      	b.n	c0d00246 <cx_trampoline_helper>

c0d00246 <cx_trampoline_helper>:

.thumb_func
cx_trampoline_helper:
  ldr  r1, =CX_TRAMPOLINE_ADDR // _cx_trampoline address
c0d00246:	4902      	ldr	r1, [pc, #8]	; (c0d00250 <cx_trampoline_helper+0xa>)
  bx   r1
c0d00248:	4708      	bx	r1
c0d0024a:	0000      	.short	0x0000
CX_TRAMPOLINE _NR_cx_x448                                  cx_x448
c0d0024c:	00000071 	.word	0x00000071
  ldr  r1, =CX_TRAMPOLINE_ADDR // _cx_trampoline address
c0d00250:	00120001 	.word	0x00120001

c0d00254 <reset_getpubkey_globals>:
#include "sol/printer.h"

static uint8_t G_publicKey[PUBKEY_LENGTH];
static char G_publicKeyStr[BASE58_PUBKEY_LENGTH];

void reset_getpubkey_globals(void) {
c0d00254:	b580      	push	{r7, lr}
    MEMCLEAR(G_publicKey);
c0d00256:	4804      	ldr	r0, [pc, #16]	; (c0d00268 <reset_getpubkey_globals+0x14>)
c0d00258:	2120      	movs	r1, #32
c0d0025a:	f004 fcdb 	bl	c0d04c14 <explicit_bzero>
    MEMCLEAR(G_publicKeyStr);
c0d0025e:	4803      	ldr	r0, [pc, #12]	; (c0d0026c <reset_getpubkey_globals+0x18>)
c0d00260:	212d      	movs	r1, #45	; 0x2d
c0d00262:	f004 fcd7 	bl	c0d04c14 <explicit_bzero>
}
c0d00266:	bd80      	pop	{r7, pc}
c0d00268:	20000200 	.word	0x20000200
c0d0026c:	20000220 	.word	0x20000220

c0d00270 <ux_display_public_flow_6_step_validateinit>:
             bnnn_paging,
             {
                 .title = "Pubkey",
                 .text = G_publicKeyStr,
             });
UX_STEP_CB(ux_display_public_flow_6_step,
c0d00270:	b510      	push	{r4, lr}
    memcpy(G_io_apdu_buffer, G_publicKey, PUBKEY_LENGTH);
c0d00272:	4805      	ldr	r0, [pc, #20]	; (c0d00288 <ux_display_public_flow_6_step_validateinit+0x18>)
c0d00274:	4905      	ldr	r1, [pc, #20]	; (c0d0028c <ux_display_public_flow_6_step_validateinit+0x1c>)
c0d00276:	2420      	movs	r4, #32
c0d00278:	4622      	mov	r2, r4
c0d0027a:	f004 fcbb 	bl	c0d04bf4 <__aeabi_memcpy>
c0d0027e:	2101      	movs	r1, #1
UX_STEP_CB(ux_display_public_flow_6_step,
c0d00280:	4620      	mov	r0, r4
c0d00282:	f003 fcc9 	bl	c0d03c18 <sendResponse>
c0d00286:	bd10      	pop	{r4, pc}
c0d00288:	2000092c 	.word	0x2000092c
c0d0028c:	20000200 	.word	0x20000200

c0d00290 <ux_display_public_flow_7_step_validateinit>:
           sendResponse(set_result_get_pubkey(), true),
           {
               &C_icon_validate_14,
               "Approve",
           });
UX_STEP_CB(ux_display_public_flow_7_step,
c0d00290:	b580      	push	{r7, lr}
c0d00292:	2000      	movs	r0, #0
c0d00294:	4601      	mov	r1, r0
c0d00296:	f003 fcbf 	bl	c0d03c18 <sendResponse>
c0d0029a:	bd80      	pop	{r7, pc}

c0d0029c <handle_get_pubkey>:
UX_FLOW(ux_display_public_flow,
        &ux_display_public_flow_5_step,
        &ux_display_public_flow_6_step,
        &ux_display_public_flow_7_step);

void handle_get_pubkey(volatile unsigned int *flags, volatile unsigned int *tx) {
c0d0029c:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0029e:	b081      	sub	sp, #4
    if (!flags || !tx || (G_command.instruction != InsGetPubkey) ||
c0d002a0:	2800      	cmp	r0, #0
c0d002a2:	d026      	beq.n	c0d002f2 <handle_get_pubkey+0x56>
c0d002a4:	2900      	cmp	r1, #0
c0d002a6:	d024      	beq.n	c0d002f2 <handle_get_pubkey+0x56>
c0d002a8:	4604      	mov	r4, r0
c0d002aa:	4d19      	ldr	r5, [pc, #100]	; (c0d00310 <handle_get_pubkey+0x74>)
c0d002ac:	7868      	ldrb	r0, [r5, #1]
c0d002ae:	2802      	cmp	r0, #2
c0d002b0:	d11f      	bne.n	c0d002f2 <handle_get_pubkey+0x56>
c0d002b2:	7828      	ldrb	r0, [r5, #0]
c0d002b4:	2802      	cmp	r0, #2
c0d002b6:	d11c      	bne.n	c0d002f2 <handle_get_pubkey+0x56>
c0d002b8:	9100      	str	r1, [sp, #0]
        G_command.state != ApduStatePayloadComplete) {
        THROW(ApduReplySdkInvalidParameter);
    }

    get_public_key(G_publicKey, G_command.derivation_path, G_command.derivation_path_length);
c0d002ba:	69aa      	ldr	r2, [r5, #24]
c0d002bc:	1d29      	adds	r1, r5, #4
c0d002be:	4f16      	ldr	r7, [pc, #88]	; (c0d00318 <handle_get_pubkey+0x7c>)
c0d002c0:	4638      	mov	r0, r7
c0d002c2:	f003 fb99 	bl	c0d039f8 <get_public_key>
c0d002c6:	2620      	movs	r6, #32
    encode_base58(G_publicKey, PUBKEY_LENGTH, G_publicKeyStr, BASE58_PUBKEY_LENGTH);
c0d002c8:	4a14      	ldr	r2, [pc, #80]	; (c0d0031c <handle_get_pubkey+0x80>)
c0d002ca:	232d      	movs	r3, #45	; 0x2d
c0d002cc:	4638      	mov	r0, r7
c0d002ce:	4631      	mov	r1, r6
c0d002d0:	f001 ff48 	bl	c0d02164 <encode_base58>

    if (G_command.non_confirm) {
c0d002d4:	7f28      	ldrb	r0, [r5, #28]
c0d002d6:	2800      	cmp	r0, #0
c0d002d8:	d10e      	bne.n	c0d002f8 <handle_get_pubkey+0x5c>
        *tx = set_result_get_pubkey();
        THROW(ApduReplySuccess);
    } else {
        ux_flow_init(0, ux_display_public_flow, NULL);
c0d002da:	4912      	ldr	r1, [pc, #72]	; (c0d00324 <handle_get_pubkey+0x88>)
c0d002dc:	4479      	add	r1, pc
c0d002de:	2000      	movs	r0, #0
c0d002e0:	4602      	mov	r2, r0
c0d002e2:	f003 fe0b 	bl	c0d03efc <ux_flow_init>
        *flags |= IO_ASYNCH_REPLY;
c0d002e6:	6820      	ldr	r0, [r4, #0]
c0d002e8:	2110      	movs	r1, #16
c0d002ea:	4301      	orrs	r1, r0
c0d002ec:	6021      	str	r1, [r4, #0]
    }
}
c0d002ee:	b001      	add	sp, #4
c0d002f0:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d002f2:	4808      	ldr	r0, [pc, #32]	; (c0d00314 <handle_get_pubkey+0x78>)
        THROW(ApduReplySdkInvalidParameter);
c0d002f4:	f000 fdb8 	bl	c0d00e68 <os_longjmp>
    memcpy(G_io_apdu_buffer, G_publicKey, PUBKEY_LENGTH);
c0d002f8:	4809      	ldr	r0, [pc, #36]	; (c0d00320 <handle_get_pubkey+0x84>)
c0d002fa:	4907      	ldr	r1, [pc, #28]	; (c0d00318 <handle_get_pubkey+0x7c>)
c0d002fc:	4632      	mov	r2, r6
c0d002fe:	f004 fc79 	bl	c0d04bf4 <__aeabi_memcpy>
        *tx = set_result_get_pubkey();
c0d00302:	9800      	ldr	r0, [sp, #0]
c0d00304:	6006      	str	r6, [r0, #0]
c0d00306:	2009      	movs	r0, #9
c0d00308:	0300      	lsls	r0, r0, #12
        THROW(ApduReplySuccess);
c0d0030a:	f000 fdad 	bl	c0d00e68 <os_longjmp>
c0d0030e:	46c0      	nop			; (mov r8, r8)
c0d00310:	20000368 	.word	0x20000368
c0d00314:	00006802 	.word	0x00006802
c0d00318:	20000200 	.word	0x20000200
c0d0031c:	20000220 	.word	0x20000220
c0d00320:	2000092c 	.word	0x2000092c
c0d00324:	00004ccc 	.word	0x00004ccc

c0d00328 <parse_system_transfer_instruction>:
//   }
// }

int parse_system_transfer_instruction(Parser* parser,
                                      Instruction* instruction,
                                      SystemTransferInfo* info) {
c0d00328:	b580      	push	{r7, lr}

    int index = 0;
    while (parser->buffer_length) {
c0d0032a:	6841      	ldr	r1, [r0, #4]
c0d0032c:	2900      	cmp	r1, #0
c0d0032e:	d008      	beq.n	c0d00342 <parse_system_transfer_instruction+0x1a>
        size_t key;
        parse_length(parser, key);
c0d00330:	f001 fdca 	bl	c0d01ec8 <parse_length>
            //         uint64_t length = readVarInt(&parser->buffer, &index);
            //         index += length;
            //     }
            //     break;
            default:
                PRINTF("Unknown field number %d\n", field_number);
c0d00334:	4804      	ldr	r0, [pc, #16]	; (c0d00348 <parse_system_transfer_instruction+0x20>)
c0d00336:	4478      	add	r0, pc
c0d00338:	2100      	movs	r1, #0
c0d0033a:	f001 fa4f 	bl	c0d017dc <mcu_usb_printf>
c0d0033e:	2001      	movs	r0, #1
    // PRINTF("Symbol    : %s\n", symbolBuffer);
    // PRINTF("Amount    : %ld\n", transfer_input.amount);
    // PRINTF("Memo      : %s\n", memoBuffer);

    return 0;
}
c0d00340:	bd80      	pop	{r7, pc}
c0d00342:	2000      	movs	r0, #0
c0d00344:	bd80      	pop	{r7, pc}
c0d00346:	46c0      	nop			; (mov r8, r8)
c0d00348:	00004e1e 	.word	0x00004e1e

c0d0034c <print_system_transfer_info>:

int print_system_transfer_info(const SystemTransferInfo* info) {
c0d0034c:	b510      	push	{r4, lr}
c0d0034e:	4604      	mov	r4, r0
    SummaryItem* item;

    item = transaction_summary_primary_item();
c0d00350:	f002 fb32 	bl	c0d029b8 <transaction_summary_primary_item>
    summary_item_set_amount(item, "Transfer", info->amount);
c0d00354:	6a22      	ldr	r2, [r4, #32]
c0d00356:	6a63      	ldr	r3, [r4, #36]	; 0x24
c0d00358:	4906      	ldr	r1, [pc, #24]	; (c0d00374 <print_system_transfer_info+0x28>)
c0d0035a:	4479      	add	r1, pc
c0d0035c:	f002 fb00 	bl	c0d02960 <summary_item_set_amount>

    item = transaction_summary_general_item();
c0d00360:	f002 fb32 	bl	c0d029c8 <transaction_summary_general_item>
    summary_item_set_pubkey(item, "Recipient", info->to);
c0d00364:	6862      	ldr	r2, [r4, #4]
c0d00366:	4904      	ldr	r1, [pc, #16]	; (c0d00378 <print_system_transfer_info+0x2c>)
c0d00368:	4479      	add	r1, pc
c0d0036a:	f002 faff 	bl	c0d0296c <summary_item_set_pubkey>
c0d0036e:	2000      	movs	r0, #0

    return 0;
c0d00370:	bd10      	pop	{r4, pc}
c0d00372:	46c0      	nop			; (mov r8, r8)
c0d00374:	00004e13 	.word	0x00004e13
c0d00378:	00004e0e 	.word	0x00004e0e

c0d0037c <handleApdu>:
void handleApdu(volatile unsigned int *flags, volatile unsigned int *tx, int rx) {
c0d0037c:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0037e:	b081      	sub	sp, #4
    if (!flags || !tx) {
c0d00380:	2800      	cmp	r0, #0
c0d00382:	d023      	beq.n	c0d003cc <handleApdu+0x50>
c0d00384:	460c      	mov	r4, r1
c0d00386:	2900      	cmp	r1, #0
c0d00388:	d020      	beq.n	c0d003cc <handleApdu+0x50>
    if (rx < 0) {
c0d0038a:	2a00      	cmp	r2, #0
c0d0038c:	d421      	bmi.n	c0d003d2 <handleApdu+0x56>
c0d0038e:	4606      	mov	r6, r0
    const int ret = apdu_handle_message(G_io_apdu_buffer, rx, &G_command);
c0d00390:	4d21      	ldr	r5, [pc, #132]	; (c0d00418 <handleApdu+0x9c>)
c0d00392:	4f22      	ldr	r7, [pc, #136]	; (c0d0041c <handleApdu+0xa0>)
c0d00394:	4628      	mov	r0, r5
c0d00396:	4611      	mov	r1, r2
c0d00398:	463a      	mov	r2, r7
c0d0039a:	f7ff fe6f 	bl	c0d0007c <apdu_handle_message>
    if (ret != 0) {
c0d0039e:	2800      	cmp	r0, #0
c0d003a0:	d119      	bne.n	c0d003d6 <handleApdu+0x5a>
    if (G_command.state == ApduStatePayloadInProgress) {
c0d003a2:	7838      	ldrb	r0, [r7, #0]
c0d003a4:	2801      	cmp	r0, #1
c0d003a6:	d02d      	beq.n	c0d00404 <handleApdu+0x88>
    switch (G_command.instruction) {
c0d003a8:	7878      	ldrb	r0, [r7, #1]
c0d003aa:	2802      	cmp	r0, #2
c0d003ac:	d008      	beq.n	c0d003c0 <handleApdu+0x44>
c0d003ae:	2803      	cmp	r0, #3
c0d003b0:	d113      	bne.n	c0d003da <handleApdu+0x5e>
            handle_sign_message_parse_message(tx);
c0d003b2:	4620      	mov	r0, r4
c0d003b4:	f002 f8f0 	bl	c0d02598 <handle_sign_message_parse_message>
            handle_sign_message_ui(flags);
c0d003b8:	4630      	mov	r0, r6
c0d003ba:	f002 f94b 	bl	c0d02654 <handle_sign_message_ui>
c0d003be:	e003      	b.n	c0d003c8 <handleApdu+0x4c>
            handle_get_pubkey(flags, tx);
c0d003c0:	4630      	mov	r0, r6
c0d003c2:	4621      	mov	r1, r4
c0d003c4:	f7ff ff6a 	bl	c0d0029c <handle_get_pubkey>
}
c0d003c8:	b001      	add	sp, #4
c0d003ca:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d003cc:	4811      	ldr	r0, [pc, #68]	; (c0d00414 <handleApdu+0x98>)
        THROW(ApduReplySdkInvalidParameter);
c0d003ce:	f000 fd4b 	bl	c0d00e68 <os_longjmp>
c0d003d2:	4810      	ldr	r0, [pc, #64]	; (c0d00414 <handleApdu+0x98>)
        THROW(ApduReplySdkExceptionIoOverflow);
c0d003d4:	3011      	adds	r0, #17
c0d003d6:	f000 fd47 	bl	c0d00e68 <os_longjmp>
    switch (G_command.instruction) {
c0d003da:	2801      	cmp	r0, #1
c0d003dc:	d116      	bne.n	c0d0040c <handleApdu+0x90>
            G_io_apdu_buffer[0] = N_storage.settings.allow_blind_sign;
c0d003de:	4e10      	ldr	r6, [pc, #64]	; (c0d00420 <handleApdu+0xa4>)
c0d003e0:	447e      	add	r6, pc
c0d003e2:	4630      	mov	r0, r6
c0d003e4:	f001 fdaa 	bl	c0d01f3c <pic>
c0d003e8:	7800      	ldrb	r0, [r0, #0]
c0d003ea:	7028      	strb	r0, [r5, #0]
            G_io_apdu_buffer[1] = N_storage.settings.pubkey_display;
c0d003ec:	4630      	mov	r0, r6
c0d003ee:	f001 fda5 	bl	c0d01f3c <pic>
c0d003f2:	7840      	ldrb	r0, [r0, #1]
c0d003f4:	7068      	strb	r0, [r5, #1]
c0d003f6:	2001      	movs	r0, #1
            G_io_apdu_buffer[2] = MAJOR_VERSION;
c0d003f8:	70a8      	strb	r0, [r5, #2]
c0d003fa:	2000      	movs	r0, #0
            G_io_apdu_buffer[3] = MINOR_VERSION;
c0d003fc:	70e8      	strb	r0, [r5, #3]
            G_io_apdu_buffer[4] = PATCH_VERSION;
c0d003fe:	7128      	strb	r0, [r5, #4]
c0d00400:	2005      	movs	r0, #5
            *tx = 5;
c0d00402:	6020      	str	r0, [r4, #0]
c0d00404:	2009      	movs	r0, #9
c0d00406:	0300      	lsls	r0, r0, #12
c0d00408:	f000 fd2e 	bl	c0d00e68 <os_longjmp>
c0d0040c:	206d      	movs	r0, #109	; 0x6d
c0d0040e:	0200      	lsls	r0, r0, #8
            THROW(ApduReplyUnimplementedInstruction);
c0d00410:	f000 fd2a 	bl	c0d00e68 <os_longjmp>
c0d00414:	00006802 	.word	0x00006802
c0d00418:	2000092c 	.word	0x2000092c
c0d0041c:	20000368 	.word	0x20000368
c0d00420:	000056dc 	.word	0x000056dc

c0d00424 <app_main>:
void app_main(void) {
c0d00424:	b092      	sub	sp, #72	; 0x48
c0d00426:	2400      	movs	r4, #0
    volatile unsigned int rx = 0;
c0d00428:	9411      	str	r4, [sp, #68]	; 0x44
    volatile unsigned int tx = 0;
c0d0042a:	9410      	str	r4, [sp, #64]	; 0x40
    volatile unsigned int flags = 0;
c0d0042c:	940f      	str	r4, [sp, #60]	; 0x3c
    reset_getpubkey_globals();
c0d0042e:	f7ff ff11 	bl	c0d00254 <reset_getpubkey_globals>
    MEMCLEAR(G_command);
c0d00432:	483e      	ldr	r0, [pc, #248]	; (c0d0052c <app_main+0x108>)
c0d00434:	493e      	ldr	r1, [pc, #248]	; (c0d00530 <app_main+0x10c>)
c0d00436:	f004 fbed 	bl	c0d04c14 <explicit_bzero>
    MEMCLEAR(G_io_seproxyhal_spi_buffer);
c0d0043a:	483e      	ldr	r0, [pc, #248]	; (c0d00534 <app_main+0x110>)
c0d0043c:	2180      	movs	r1, #128	; 0x80
c0d0043e:	f004 fbe9 	bl	c0d04c14 <explicit_bzero>
c0d00442:	4841      	ldr	r0, [pc, #260]	; (c0d00548 <app_main+0x124>)
c0d00444:	4478      	add	r0, pc
c0d00446:	9001      	str	r0, [sp, #4]
c0d00448:	4d3c      	ldr	r5, [pc, #240]	; (c0d0053c <app_main+0x118>)
c0d0044a:	a80e      	add	r0, sp, #56	; 0x38
        volatile unsigned short sw = 0;
c0d0044c:	8004      	strh	r4, [r0, #0]
c0d0044e:	af02      	add	r7, sp, #8
            TRY {
c0d00450:	4638      	mov	r0, r7
c0d00452:	f004 fcdf 	bl	c0d04e14 <setjmp>
c0d00456:	85b8      	strh	r0, [r7, #44]	; 0x2c
c0d00458:	b287      	uxth	r7, r0
c0d0045a:	2f00      	cmp	r7, #0
c0d0045c:	d018      	beq.n	c0d00490 <app_main+0x6c>
c0d0045e:	4606      	mov	r6, r0
c0d00460:	4835      	ldr	r0, [pc, #212]	; (c0d00538 <app_main+0x114>)
c0d00462:	4287      	cmp	r7, r0
c0d00464:	d057      	beq.n	c0d00516 <app_main+0xf2>
c0d00466:	9600      	str	r6, [sp, #0]
c0d00468:	a802      	add	r0, sp, #8
            CATCH_OTHER(e) {
c0d0046a:	8584      	strh	r4, [r0, #44]	; 0x2c
c0d0046c:	980c      	ldr	r0, [sp, #48]	; 0x30
c0d0046e:	f002 fa5b 	bl	c0d02928 <try_context_set>
c0d00472:	200f      	movs	r0, #15
c0d00474:	0301      	lsls	r1, r0, #12
                switch (e & 0xF000) {
c0d00476:	4031      	ands	r1, r6
c0d00478:	2009      	movs	r0, #9
c0d0047a:	0300      	lsls	r0, r0, #12
c0d0047c:	4281      	cmp	r1, r0
c0d0047e:	d003      	beq.n	c0d00488 <app_main+0x64>
c0d00480:	2203      	movs	r2, #3
c0d00482:	0352      	lsls	r2, r2, #13
c0d00484:	4291      	cmp	r1, r2
c0d00486:	d120      	bne.n	c0d004ca <app_main+0xa6>
c0d00488:	a90e      	add	r1, sp, #56	; 0x38
c0d0048a:	9a00      	ldr	r2, [sp, #0]
c0d0048c:	800a      	strh	r2, [r1, #0]
c0d0048e:	e023      	b.n	c0d004d8 <app_main+0xb4>
c0d00490:	a802      	add	r0, sp, #8
            TRY {
c0d00492:	f002 fa49 	bl	c0d02928 <try_context_set>
                rx = tx;
c0d00496:	9910      	ldr	r1, [sp, #64]	; 0x40
c0d00498:	9111      	str	r1, [sp, #68]	; 0x44
                tx = 0;  // ensure no race in catch_other if io_exchange throws
c0d0049a:	9410      	str	r4, [sp, #64]	; 0x40
            TRY {
c0d0049c:	900c      	str	r0, [sp, #48]	; 0x30
                rx = io_exchange(CHANNEL_APDU | flags, rx);
c0d0049e:	980f      	ldr	r0, [sp, #60]	; 0x3c
c0d004a0:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d004a2:	b2c0      	uxtb	r0, r0
c0d004a4:	b289      	uxth	r1, r1
c0d004a6:	f000 ff03 	bl	c0d012b0 <io_exchange>
c0d004aa:	9011      	str	r0, [sp, #68]	; 0x44
                flags = 0;
c0d004ac:	940f      	str	r4, [sp, #60]	; 0x3c
                if (rx == 0) {
c0d004ae:	9811      	ldr	r0, [sp, #68]	; 0x44
c0d004b0:	2800      	cmp	r0, #0
c0d004b2:	d038      	beq.n	c0d00526 <app_main+0x102>
                PRINTF("New APDU received:\n%.*H\n", rx, G_io_apdu_buffer);
c0d004b4:	9911      	ldr	r1, [sp, #68]	; 0x44
c0d004b6:	9801      	ldr	r0, [sp, #4]
c0d004b8:	462a      	mov	r2, r5
c0d004ba:	f001 f98f 	bl	c0d017dc <mcu_usb_printf>
                handleApdu(&flags, &tx, rx);
c0d004be:	9a11      	ldr	r2, [sp, #68]	; 0x44
c0d004c0:	a80f      	add	r0, sp, #60	; 0x3c
c0d004c2:	a910      	add	r1, sp, #64	; 0x40
c0d004c4:	f7ff ff5a 	bl	c0d0037c <handleApdu>
c0d004c8:	e017      	b.n	c0d004fa <app_main+0xd6>
                        sw = 0x6800 | (e & 0x7FF);
c0d004ca:	491e      	ldr	r1, [pc, #120]	; (c0d00544 <app_main+0x120>)
c0d004cc:	400e      	ands	r6, r1
c0d004ce:	210d      	movs	r1, #13
c0d004d0:	02c9      	lsls	r1, r1, #11
c0d004d2:	1871      	adds	r1, r6, r1
c0d004d4:	aa0e      	add	r2, sp, #56	; 0x38
c0d004d6:	8011      	strh	r1, [r2, #0]
                if (e != 0x9000) {
c0d004d8:	4287      	cmp	r7, r0
c0d004da:	d003      	beq.n	c0d004e4 <app_main+0xc0>
c0d004dc:	2010      	movs	r0, #16
                    flags &= ~IO_ASYNCH_REPLY;
c0d004de:	990f      	ldr	r1, [sp, #60]	; 0x3c
c0d004e0:	4381      	bics	r1, r0
c0d004e2:	910f      	str	r1, [sp, #60]	; 0x3c
                G_io_apdu_buffer[tx] = sw >> 8;
c0d004e4:	980e      	ldr	r0, [sp, #56]	; 0x38
c0d004e6:	0a00      	lsrs	r0, r0, #8
c0d004e8:	9910      	ldr	r1, [sp, #64]	; 0x40
c0d004ea:	5468      	strb	r0, [r5, r1]
                G_io_apdu_buffer[tx + 1] = sw;
c0d004ec:	980e      	ldr	r0, [sp, #56]	; 0x38
c0d004ee:	9910      	ldr	r1, [sp, #64]	; 0x40
c0d004f0:	1949      	adds	r1, r1, r5
c0d004f2:	7048      	strb	r0, [r1, #1]
                tx += 2;
c0d004f4:	9810      	ldr	r0, [sp, #64]	; 0x40
c0d004f6:	1c80      	adds	r0, r0, #2
c0d004f8:	9010      	str	r0, [sp, #64]	; 0x40
            FINALLY {
c0d004fa:	f002 fa09 	bl	c0d02910 <try_context_get>
c0d004fe:	a902      	add	r1, sp, #8
c0d00500:	4288      	cmp	r0, r1
c0d00502:	d102      	bne.n	c0d0050a <app_main+0xe6>
c0d00504:	980c      	ldr	r0, [sp, #48]	; 0x30
c0d00506:	f002 fa0f 	bl	c0d02928 <try_context_set>
c0d0050a:	a802      	add	r0, sp, #8
        END_TRY;
c0d0050c:	8d80      	ldrh	r0, [r0, #44]	; 0x2c
c0d0050e:	2800      	cmp	r0, #0
c0d00510:	d09b      	beq.n	c0d0044a <app_main+0x26>
c0d00512:	f000 fca9 	bl	c0d00e68 <os_longjmp>
c0d00516:	a802      	add	r0, sp, #8
            CATCH(ApduReplySdkExceptionIoReset) {
c0d00518:	8584      	strh	r4, [r0, #44]	; 0x2c
c0d0051a:	980c      	ldr	r0, [sp, #48]	; 0x30
c0d0051c:	f002 fa04 	bl	c0d02928 <try_context_set>
c0d00520:	4805      	ldr	r0, [pc, #20]	; (c0d00538 <app_main+0x114>)
                THROW(ApduReplySdkExceptionIoReset);
c0d00522:	f000 fca1 	bl	c0d00e68 <os_longjmp>
c0d00526:	4806      	ldr	r0, [pc, #24]	; (c0d00540 <app_main+0x11c>)
                    THROW(ApduReplyNoApduReceived);
c0d00528:	f000 fc9e 	bl	c0d00e68 <os_longjmp>
c0d0052c:	20000368 	.word	0x20000368
c0d00530:	00000544 	.word	0x00000544
c0d00534:	200008ac 	.word	0x200008ac
c0d00538:	00006816 	.word	0x00006816
c0d0053c:	2000092c 	.word	0x2000092c
c0d00540:	00006982 	.word	0x00006982
c0d00544:	000007ff 	.word	0x000007ff
c0d00548:	00004d3c 	.word	0x00004d3c

c0d0054c <io_seproxyhal_display>:
void io_seproxyhal_display(const bagl_element_t *element) {
c0d0054c:	b580      	push	{r7, lr}
    io_seproxyhal_display_default((bagl_element_t *) element);
c0d0054e:	f000 fe11 	bl	c0d01174 <io_seproxyhal_display_default>
}
c0d00552:	bd80      	pop	{r7, pc}

c0d00554 <io_event>:
unsigned char io_event(unsigned char channel) {
c0d00554:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00556:	b081      	sub	sp, #4
    switch (G_io_seproxyhal_spi_buffer[0]) {
c0d00558:	4df8      	ldr	r5, [pc, #992]	; (c0d0093c <io_event+0x3e8>)
c0d0055a:	7828      	ldrb	r0, [r5, #0]
c0d0055c:	280c      	cmp	r0, #12
c0d0055e:	dd10      	ble.n	c0d00582 <io_event+0x2e>
c0d00560:	280d      	cmp	r0, #13
c0d00562:	d068      	beq.n	c0d00636 <io_event+0xe2>
c0d00564:	280e      	cmp	r0, #14
c0d00566:	d100      	bne.n	c0d0056a <io_event+0x16>
c0d00568:	e0b0      	b.n	c0d006cc <io_event+0x178>
c0d0056a:	2815      	cmp	r0, #21
c0d0056c:	d10f      	bne.n	c0d0058e <io_event+0x3a>
            if (G_io_apdu_media == IO_APDU_MEDIA_USB_HID &&
c0d0056e:	48f4      	ldr	r0, [pc, #976]	; (c0d00940 <io_event+0x3ec>)
c0d00570:	7980      	ldrb	r0, [r0, #6]
c0d00572:	2801      	cmp	r0, #1
c0d00574:	d10b      	bne.n	c0d0058e <io_event+0x3a>
static inline uint16_t U2BE(const uint8_t *buf, size_t off) {
  return (buf[off] << 8) | buf[off + 1];
}
static inline uint32_t U4BE(const uint8_t *buf, size_t off) {
  return (((uint32_t)buf[off]) << 24) | (buf[off + 1] << 16) |
         (buf[off + 2] << 8) | buf[off + 3];
c0d00576:	79a8      	ldrb	r0, [r5, #6]
c0d00578:	0700      	lsls	r0, r0, #28
c0d0057a:	d408      	bmi.n	c0d0058e <io_event+0x3a>
c0d0057c:	48f1      	ldr	r0, [pc, #964]	; (c0d00944 <io_event+0x3f0>)
                THROW(ApduReplySdkExceptionIoReset);
c0d0057e:	f000 fc73 	bl	c0d00e68 <os_longjmp>
    switch (G_io_seproxyhal_spi_buffer[0]) {
c0d00582:	2805      	cmp	r0, #5
c0d00584:	d100      	bne.n	c0d00588 <io_event+0x34>
c0d00586:	e0f6      	b.n	c0d00776 <io_event+0x222>
c0d00588:	280c      	cmp	r0, #12
c0d0058a:	d100      	bne.n	c0d0058e <io_event+0x3a>
c0d0058c:	e260      	b.n	c0d00a50 <io_event+0x4fc>
            UX_DEFAULT_EVENT();
c0d0058e:	4cee      	ldr	r4, [pc, #952]	; (c0d00948 <io_event+0x3f4>)
c0d00590:	2700      	movs	r7, #0
c0d00592:	6067      	str	r7, [r4, #4]
c0d00594:	2001      	movs	r0, #1
c0d00596:	7020      	strb	r0, [r4, #0]
c0d00598:	4620      	mov	r0, r4
c0d0059a:	f002 f961 	bl	c0d02860 <os_ux>
c0d0059e:	2004      	movs	r0, #4
c0d005a0:	f002 f9d0 	bl	c0d02944 <os_sched_last_status>
c0d005a4:	6060      	str	r0, [r4, #4]
c0d005a6:	2869      	cmp	r0, #105	; 0x69
c0d005a8:	d000      	beq.n	c0d005ac <io_event+0x58>
c0d005aa:	e13e      	b.n	c0d0082a <io_event+0x2d6>
c0d005ac:	f000 fd88 	bl	c0d010c0 <io_seproxyhal_init_ux>
c0d005b0:	f000 fd88 	bl	c0d010c4 <io_seproxyhal_init_button>
c0d005b4:	25c2      	movs	r5, #194	; 0xc2
c0d005b6:	4ee5      	ldr	r6, [pc, #916]	; (c0d0094c <io_event+0x3f8>)
c0d005b8:	5377      	strh	r7, [r6, r5]
c0d005ba:	2004      	movs	r0, #4
c0d005bc:	f002 f9c2 	bl	c0d02944 <os_sched_last_status>
c0d005c0:	6060      	str	r0, [r4, #4]
c0d005c2:	2800      	cmp	r0, #0
c0d005c4:	d100      	bne.n	c0d005c8 <io_event+0x74>
c0d005c6:	e243      	b.n	c0d00a50 <io_event+0x4fc>
c0d005c8:	2897      	cmp	r0, #151	; 0x97
c0d005ca:	d100      	bne.n	c0d005ce <io_event+0x7a>
c0d005cc:	e240      	b.n	c0d00a50 <io_event+0x4fc>
c0d005ce:	24c4      	movs	r4, #196	; 0xc4
c0d005d0:	5930      	ldr	r0, [r6, r4]
c0d005d2:	2800      	cmp	r0, #0
c0d005d4:	d100      	bne.n	c0d005d8 <io_event+0x84>
c0d005d6:	e23b      	b.n	c0d00a50 <io_event+0x4fc>
c0d005d8:	5b70      	ldrh	r0, [r6, r5]
c0d005da:	21c8      	movs	r1, #200	; 0xc8
c0d005dc:	5c71      	ldrb	r1, [r6, r1]
c0d005de:	b280      	uxth	r0, r0
c0d005e0:	4288      	cmp	r0, r1
c0d005e2:	d300      	bcc.n	c0d005e6 <io_event+0x92>
c0d005e4:	e234      	b.n	c0d00a50 <io_event+0x4fc>
c0d005e6:	f002 f979 	bl	c0d028dc <io_seph_is_status_sent>
c0d005ea:	2800      	cmp	r0, #0
c0d005ec:	d000      	beq.n	c0d005f0 <io_event+0x9c>
c0d005ee:	e22f      	b.n	c0d00a50 <io_event+0x4fc>
c0d005f0:	f002 f8f8 	bl	c0d027e4 <os_perso_isonboarded>
c0d005f4:	28aa      	cmp	r0, #170	; 0xaa
c0d005f6:	d104      	bne.n	c0d00602 <io_event+0xae>
c0d005f8:	f002 f924 	bl	c0d02844 <os_global_pin_is_validated>
c0d005fc:	28aa      	cmp	r0, #170	; 0xaa
c0d005fe:	d000      	beq.n	c0d00602 <io_event+0xae>
c0d00600:	e226      	b.n	c0d00a50 <io_event+0x4fc>
c0d00602:	5931      	ldr	r1, [r6, r4]
c0d00604:	5b72      	ldrh	r2, [r6, r5]
c0d00606:	0150      	lsls	r0, r2, #5
c0d00608:	1808      	adds	r0, r1, r0
c0d0060a:	23d0      	movs	r3, #208	; 0xd0
c0d0060c:	58f3      	ldr	r3, [r6, r3]
c0d0060e:	2b00      	cmp	r3, #0
c0d00610:	d004      	beq.n	c0d0061c <io_event+0xc8>
c0d00612:	4798      	blx	r3
c0d00614:	2800      	cmp	r0, #0
c0d00616:	d007      	beq.n	c0d00628 <io_event+0xd4>
c0d00618:	5b72      	ldrh	r2, [r6, r5]
c0d0061a:	5931      	ldr	r1, [r6, r4]
c0d0061c:	2801      	cmp	r0, #1
c0d0061e:	d101      	bne.n	c0d00624 <io_event+0xd0>
c0d00620:	0150      	lsls	r0, r2, #5
c0d00622:	1808      	adds	r0, r1, r0
    io_seproxyhal_display_default((bagl_element_t *) element);
c0d00624:	f000 fda6 	bl	c0d01174 <io_seproxyhal_display_default>
            UX_DEFAULT_EVENT();
c0d00628:	5b70      	ldrh	r0, [r6, r5]
c0d0062a:	1c40      	adds	r0, r0, #1
c0d0062c:	5370      	strh	r0, [r6, r5]
c0d0062e:	5931      	ldr	r1, [r6, r4]
c0d00630:	2900      	cmp	r1, #0
c0d00632:	d1d2      	bne.n	c0d005da <io_event+0x86>
c0d00634:	e20c      	b.n	c0d00a50 <io_event+0x4fc>
            UX_DISPLAYED_EVENT({});
c0d00636:	4cc4      	ldr	r4, [pc, #784]	; (c0d00948 <io_event+0x3f4>)
c0d00638:	2700      	movs	r7, #0
c0d0063a:	6067      	str	r7, [r4, #4]
c0d0063c:	2001      	movs	r0, #1
c0d0063e:	7020      	strb	r0, [r4, #0]
c0d00640:	4620      	mov	r0, r4
c0d00642:	f002 f90d 	bl	c0d02860 <os_ux>
c0d00646:	2004      	movs	r0, #4
c0d00648:	f002 f97c 	bl	c0d02944 <os_sched_last_status>
c0d0064c:	6060      	str	r0, [r4, #4]
c0d0064e:	2800      	cmp	r0, #0
c0d00650:	d100      	bne.n	c0d00654 <io_event+0x100>
c0d00652:	e1fd      	b.n	c0d00a50 <io_event+0x4fc>
c0d00654:	2869      	cmp	r0, #105	; 0x69
c0d00656:	d100      	bne.n	c0d0065a <io_event+0x106>
c0d00658:	e17a      	b.n	c0d00950 <io_event+0x3fc>
c0d0065a:	2897      	cmp	r0, #151	; 0x97
c0d0065c:	d100      	bne.n	c0d00660 <io_event+0x10c>
c0d0065e:	e1f7      	b.n	c0d00a50 <io_event+0x4fc>
c0d00660:	25c4      	movs	r5, #196	; 0xc4
c0d00662:	4cba      	ldr	r4, [pc, #744]	; (c0d0094c <io_event+0x3f8>)
c0d00664:	5960      	ldr	r0, [r4, r5]
c0d00666:	2800      	cmp	r0, #0
c0d00668:	d100      	bne.n	c0d0066c <io_event+0x118>
c0d0066a:	e1e9      	b.n	c0d00a40 <io_event+0x4ec>
c0d0066c:	26c2      	movs	r6, #194	; 0xc2
c0d0066e:	5ba0      	ldrh	r0, [r4, r6]
c0d00670:	21c8      	movs	r1, #200	; 0xc8
c0d00672:	5c61      	ldrb	r1, [r4, r1]
c0d00674:	b280      	uxth	r0, r0
c0d00676:	4288      	cmp	r0, r1
c0d00678:	d300      	bcc.n	c0d0067c <io_event+0x128>
c0d0067a:	e1e1      	b.n	c0d00a40 <io_event+0x4ec>
c0d0067c:	f002 f92e 	bl	c0d028dc <io_seph_is_status_sent>
c0d00680:	2800      	cmp	r0, #0
c0d00682:	d000      	beq.n	c0d00686 <io_event+0x132>
c0d00684:	e1dc      	b.n	c0d00a40 <io_event+0x4ec>
c0d00686:	f002 f8ad 	bl	c0d027e4 <os_perso_isonboarded>
c0d0068a:	28aa      	cmp	r0, #170	; 0xaa
c0d0068c:	d104      	bne.n	c0d00698 <io_event+0x144>
c0d0068e:	f002 f8d9 	bl	c0d02844 <os_global_pin_is_validated>
c0d00692:	28aa      	cmp	r0, #170	; 0xaa
c0d00694:	d000      	beq.n	c0d00698 <io_event+0x144>
c0d00696:	e1d3      	b.n	c0d00a40 <io_event+0x4ec>
c0d00698:	5961      	ldr	r1, [r4, r5]
c0d0069a:	5ba2      	ldrh	r2, [r4, r6]
c0d0069c:	0150      	lsls	r0, r2, #5
c0d0069e:	1808      	adds	r0, r1, r0
c0d006a0:	23d0      	movs	r3, #208	; 0xd0
c0d006a2:	58e3      	ldr	r3, [r4, r3]
c0d006a4:	2b00      	cmp	r3, #0
c0d006a6:	d004      	beq.n	c0d006b2 <io_event+0x15e>
c0d006a8:	4798      	blx	r3
c0d006aa:	2800      	cmp	r0, #0
c0d006ac:	d007      	beq.n	c0d006be <io_event+0x16a>
c0d006ae:	5ba2      	ldrh	r2, [r4, r6]
c0d006b0:	5961      	ldr	r1, [r4, r5]
c0d006b2:	2801      	cmp	r0, #1
c0d006b4:	d101      	bne.n	c0d006ba <io_event+0x166>
c0d006b6:	0150      	lsls	r0, r2, #5
c0d006b8:	1808      	adds	r0, r1, r0
    io_seproxyhal_display_default((bagl_element_t *) element);
c0d006ba:	f000 fd5b 	bl	c0d01174 <io_seproxyhal_display_default>
            UX_DISPLAYED_EVENT({});
c0d006be:	5ba0      	ldrh	r0, [r4, r6]
c0d006c0:	1c40      	adds	r0, r0, #1
c0d006c2:	53a0      	strh	r0, [r4, r6]
c0d006c4:	5961      	ldr	r1, [r4, r5]
c0d006c6:	2900      	cmp	r1, #0
c0d006c8:	d1d2      	bne.n	c0d00670 <io_event+0x11c>
c0d006ca:	e1b9      	b.n	c0d00a40 <io_event+0x4ec>
            UX_TICKER_EVENT(G_io_seproxyhal_spi_buffer, {
c0d006cc:	4d9e      	ldr	r5, [pc, #632]	; (c0d00948 <io_event+0x3f4>)
c0d006ce:	2700      	movs	r7, #0
c0d006d0:	606f      	str	r7, [r5, #4]
c0d006d2:	2001      	movs	r0, #1
c0d006d4:	7028      	strb	r0, [r5, #0]
c0d006d6:	4628      	mov	r0, r5
c0d006d8:	f002 f8c2 	bl	c0d02860 <os_ux>
c0d006dc:	2004      	movs	r0, #4
c0d006de:	f002 f931 	bl	c0d02944 <os_sched_last_status>
c0d006e2:	6068      	str	r0, [r5, #4]
c0d006e4:	2869      	cmp	r0, #105	; 0x69
c0d006e6:	d000      	beq.n	c0d006ea <io_event+0x196>
c0d006e8:	e0d5      	b.n	c0d00896 <io_event+0x342>
c0d006ea:	f000 fce9 	bl	c0d010c0 <io_seproxyhal_init_ux>
c0d006ee:	f000 fce9 	bl	c0d010c4 <io_seproxyhal_init_button>
c0d006f2:	24c2      	movs	r4, #194	; 0xc2
c0d006f4:	4e95      	ldr	r6, [pc, #596]	; (c0d0094c <io_event+0x3f8>)
c0d006f6:	2000      	movs	r0, #0
c0d006f8:	5330      	strh	r0, [r6, r4]
c0d006fa:	2004      	movs	r0, #4
c0d006fc:	f002 f922 	bl	c0d02944 <os_sched_last_status>
c0d00700:	6068      	str	r0, [r5, #4]
c0d00702:	2800      	cmp	r0, #0
c0d00704:	d100      	bne.n	c0d00708 <io_event+0x1b4>
c0d00706:	e1a3      	b.n	c0d00a50 <io_event+0x4fc>
c0d00708:	2897      	cmp	r0, #151	; 0x97
c0d0070a:	d100      	bne.n	c0d0070e <io_event+0x1ba>
c0d0070c:	e1a0      	b.n	c0d00a50 <io_event+0x4fc>
c0d0070e:	25c4      	movs	r5, #196	; 0xc4
c0d00710:	5970      	ldr	r0, [r6, r5]
c0d00712:	2800      	cmp	r0, #0
c0d00714:	d100      	bne.n	c0d00718 <io_event+0x1c4>
c0d00716:	e19b      	b.n	c0d00a50 <io_event+0x4fc>
c0d00718:	5b30      	ldrh	r0, [r6, r4]
c0d0071a:	21c8      	movs	r1, #200	; 0xc8
c0d0071c:	5c71      	ldrb	r1, [r6, r1]
c0d0071e:	b280      	uxth	r0, r0
c0d00720:	4288      	cmp	r0, r1
c0d00722:	d300      	bcc.n	c0d00726 <io_event+0x1d2>
c0d00724:	e194      	b.n	c0d00a50 <io_event+0x4fc>
c0d00726:	f002 f8d9 	bl	c0d028dc <io_seph_is_status_sent>
c0d0072a:	2800      	cmp	r0, #0
c0d0072c:	d000      	beq.n	c0d00730 <io_event+0x1dc>
c0d0072e:	e18f      	b.n	c0d00a50 <io_event+0x4fc>
c0d00730:	f002 f858 	bl	c0d027e4 <os_perso_isonboarded>
c0d00734:	28aa      	cmp	r0, #170	; 0xaa
c0d00736:	d104      	bne.n	c0d00742 <io_event+0x1ee>
c0d00738:	f002 f884 	bl	c0d02844 <os_global_pin_is_validated>
c0d0073c:	28aa      	cmp	r0, #170	; 0xaa
c0d0073e:	d000      	beq.n	c0d00742 <io_event+0x1ee>
c0d00740:	e186      	b.n	c0d00a50 <io_event+0x4fc>
c0d00742:	5971      	ldr	r1, [r6, r5]
c0d00744:	5b32      	ldrh	r2, [r6, r4]
c0d00746:	0150      	lsls	r0, r2, #5
c0d00748:	1808      	adds	r0, r1, r0
c0d0074a:	23d0      	movs	r3, #208	; 0xd0
c0d0074c:	58f3      	ldr	r3, [r6, r3]
c0d0074e:	2b00      	cmp	r3, #0
c0d00750:	d004      	beq.n	c0d0075c <io_event+0x208>
c0d00752:	4798      	blx	r3
c0d00754:	2800      	cmp	r0, #0
c0d00756:	d007      	beq.n	c0d00768 <io_event+0x214>
c0d00758:	5b32      	ldrh	r2, [r6, r4]
c0d0075a:	5971      	ldr	r1, [r6, r5]
c0d0075c:	2801      	cmp	r0, #1
c0d0075e:	d101      	bne.n	c0d00764 <io_event+0x210>
c0d00760:	0150      	lsls	r0, r2, #5
c0d00762:	1808      	adds	r0, r1, r0
    io_seproxyhal_display_default((bagl_element_t *) element);
c0d00764:	f000 fd06 	bl	c0d01174 <io_seproxyhal_display_default>
            UX_TICKER_EVENT(G_io_seproxyhal_spi_buffer, {
c0d00768:	5b30      	ldrh	r0, [r6, r4]
c0d0076a:	1c40      	adds	r0, r0, #1
c0d0076c:	5330      	strh	r0, [r6, r4]
c0d0076e:	5971      	ldr	r1, [r6, r5]
c0d00770:	2900      	cmp	r1, #0
c0d00772:	d1d2      	bne.n	c0d0071a <io_event+0x1c6>
c0d00774:	e16c      	b.n	c0d00a50 <io_event+0x4fc>
            UX_BUTTON_PUSH_EVENT(G_io_seproxyhal_spi_buffer);
c0d00776:	4ce5      	ldr	r4, [pc, #916]	; (c0d00b0c <io_event+0x5b8>)
c0d00778:	2700      	movs	r7, #0
c0d0077a:	6067      	str	r7, [r4, #4]
c0d0077c:	2001      	movs	r0, #1
c0d0077e:	7020      	strb	r0, [r4, #0]
c0d00780:	4620      	mov	r0, r4
c0d00782:	f002 f86d 	bl	c0d02860 <os_ux>
c0d00786:	2004      	movs	r0, #4
c0d00788:	f002 f8dc 	bl	c0d02944 <os_sched_last_status>
c0d0078c:	6060      	str	r0, [r4, #4]
c0d0078e:	2800      	cmp	r0, #0
c0d00790:	d100      	bne.n	c0d00794 <io_event+0x240>
c0d00792:	e15d      	b.n	c0d00a50 <io_event+0x4fc>
c0d00794:	2897      	cmp	r0, #151	; 0x97
c0d00796:	d100      	bne.n	c0d0079a <io_event+0x246>
c0d00798:	e15a      	b.n	c0d00a50 <io_event+0x4fc>
c0d0079a:	2869      	cmp	r0, #105	; 0x69
c0d0079c:	d000      	beq.n	c0d007a0 <io_event+0x24c>
c0d0079e:	e116      	b.n	c0d009ce <io_event+0x47a>
c0d007a0:	f000 fc8e 	bl	c0d010c0 <io_seproxyhal_init_ux>
c0d007a4:	f000 fc8e 	bl	c0d010c4 <io_seproxyhal_init_button>
c0d007a8:	25c2      	movs	r5, #194	; 0xc2
c0d007aa:	4ed9      	ldr	r6, [pc, #868]	; (c0d00b10 <io_event+0x5bc>)
c0d007ac:	5377      	strh	r7, [r6, r5]
c0d007ae:	2004      	movs	r0, #4
c0d007b0:	f002 f8c8 	bl	c0d02944 <os_sched_last_status>
c0d007b4:	6060      	str	r0, [r4, #4]
c0d007b6:	2800      	cmp	r0, #0
c0d007b8:	d100      	bne.n	c0d007bc <io_event+0x268>
c0d007ba:	e149      	b.n	c0d00a50 <io_event+0x4fc>
c0d007bc:	2897      	cmp	r0, #151	; 0x97
c0d007be:	d100      	bne.n	c0d007c2 <io_event+0x26e>
c0d007c0:	e146      	b.n	c0d00a50 <io_event+0x4fc>
c0d007c2:	24c4      	movs	r4, #196	; 0xc4
c0d007c4:	5930      	ldr	r0, [r6, r4]
c0d007c6:	2800      	cmp	r0, #0
c0d007c8:	d100      	bne.n	c0d007cc <io_event+0x278>
c0d007ca:	e141      	b.n	c0d00a50 <io_event+0x4fc>
c0d007cc:	5b70      	ldrh	r0, [r6, r5]
c0d007ce:	21c8      	movs	r1, #200	; 0xc8
c0d007d0:	5c71      	ldrb	r1, [r6, r1]
c0d007d2:	b280      	uxth	r0, r0
c0d007d4:	4288      	cmp	r0, r1
c0d007d6:	d300      	bcc.n	c0d007da <io_event+0x286>
c0d007d8:	e13a      	b.n	c0d00a50 <io_event+0x4fc>
c0d007da:	f002 f87f 	bl	c0d028dc <io_seph_is_status_sent>
c0d007de:	2800      	cmp	r0, #0
c0d007e0:	d000      	beq.n	c0d007e4 <io_event+0x290>
c0d007e2:	e135      	b.n	c0d00a50 <io_event+0x4fc>
c0d007e4:	f001 fffe 	bl	c0d027e4 <os_perso_isonboarded>
c0d007e8:	28aa      	cmp	r0, #170	; 0xaa
c0d007ea:	d104      	bne.n	c0d007f6 <io_event+0x2a2>
c0d007ec:	f002 f82a 	bl	c0d02844 <os_global_pin_is_validated>
c0d007f0:	28aa      	cmp	r0, #170	; 0xaa
c0d007f2:	d000      	beq.n	c0d007f6 <io_event+0x2a2>
c0d007f4:	e12c      	b.n	c0d00a50 <io_event+0x4fc>
c0d007f6:	5931      	ldr	r1, [r6, r4]
c0d007f8:	5b72      	ldrh	r2, [r6, r5]
c0d007fa:	0150      	lsls	r0, r2, #5
c0d007fc:	1808      	adds	r0, r1, r0
c0d007fe:	23d0      	movs	r3, #208	; 0xd0
c0d00800:	58f3      	ldr	r3, [r6, r3]
c0d00802:	2b00      	cmp	r3, #0
c0d00804:	d004      	beq.n	c0d00810 <io_event+0x2bc>
c0d00806:	4798      	blx	r3
c0d00808:	2800      	cmp	r0, #0
c0d0080a:	d007      	beq.n	c0d0081c <io_event+0x2c8>
c0d0080c:	5b72      	ldrh	r2, [r6, r5]
c0d0080e:	5931      	ldr	r1, [r6, r4]
c0d00810:	2801      	cmp	r0, #1
c0d00812:	d101      	bne.n	c0d00818 <io_event+0x2c4>
c0d00814:	0150      	lsls	r0, r2, #5
c0d00816:	1808      	adds	r0, r1, r0
    io_seproxyhal_display_default((bagl_element_t *) element);
c0d00818:	f000 fcac 	bl	c0d01174 <io_seproxyhal_display_default>
            UX_BUTTON_PUSH_EVENT(G_io_seproxyhal_spi_buffer);
c0d0081c:	5b70      	ldrh	r0, [r6, r5]
c0d0081e:	1c40      	adds	r0, r0, #1
c0d00820:	5370      	strh	r0, [r6, r5]
c0d00822:	5931      	ldr	r1, [r6, r4]
c0d00824:	2900      	cmp	r1, #0
c0d00826:	d1d2      	bne.n	c0d007ce <io_event+0x27a>
c0d00828:	e112      	b.n	c0d00a50 <io_event+0x4fc>
c0d0082a:	25c4      	movs	r5, #196	; 0xc4
            UX_DEFAULT_EVENT();
c0d0082c:	4cb8      	ldr	r4, [pc, #736]	; (c0d00b10 <io_event+0x5bc>)
c0d0082e:	5960      	ldr	r0, [r4, r5]
c0d00830:	2800      	cmp	r0, #0
c0d00832:	d100      	bne.n	c0d00836 <io_event+0x2e2>
c0d00834:	e104      	b.n	c0d00a40 <io_event+0x4ec>
c0d00836:	26c2      	movs	r6, #194	; 0xc2
c0d00838:	5ba0      	ldrh	r0, [r4, r6]
c0d0083a:	21c8      	movs	r1, #200	; 0xc8
c0d0083c:	5c61      	ldrb	r1, [r4, r1]
c0d0083e:	b280      	uxth	r0, r0
c0d00840:	4288      	cmp	r0, r1
c0d00842:	d300      	bcc.n	c0d00846 <io_event+0x2f2>
c0d00844:	e0fc      	b.n	c0d00a40 <io_event+0x4ec>
c0d00846:	f002 f849 	bl	c0d028dc <io_seph_is_status_sent>
c0d0084a:	2800      	cmp	r0, #0
c0d0084c:	d000      	beq.n	c0d00850 <io_event+0x2fc>
c0d0084e:	e0f7      	b.n	c0d00a40 <io_event+0x4ec>
c0d00850:	f001 ffc8 	bl	c0d027e4 <os_perso_isonboarded>
c0d00854:	28aa      	cmp	r0, #170	; 0xaa
c0d00856:	d104      	bne.n	c0d00862 <io_event+0x30e>
c0d00858:	f001 fff4 	bl	c0d02844 <os_global_pin_is_validated>
c0d0085c:	28aa      	cmp	r0, #170	; 0xaa
c0d0085e:	d000      	beq.n	c0d00862 <io_event+0x30e>
c0d00860:	e0ee      	b.n	c0d00a40 <io_event+0x4ec>
c0d00862:	5961      	ldr	r1, [r4, r5]
c0d00864:	5ba2      	ldrh	r2, [r4, r6]
c0d00866:	0150      	lsls	r0, r2, #5
c0d00868:	1808      	adds	r0, r1, r0
c0d0086a:	23d0      	movs	r3, #208	; 0xd0
c0d0086c:	58e3      	ldr	r3, [r4, r3]
c0d0086e:	2b00      	cmp	r3, #0
c0d00870:	d004      	beq.n	c0d0087c <io_event+0x328>
c0d00872:	4798      	blx	r3
c0d00874:	2800      	cmp	r0, #0
c0d00876:	d007      	beq.n	c0d00888 <io_event+0x334>
c0d00878:	5ba2      	ldrh	r2, [r4, r6]
c0d0087a:	5961      	ldr	r1, [r4, r5]
c0d0087c:	2801      	cmp	r0, #1
c0d0087e:	d101      	bne.n	c0d00884 <io_event+0x330>
c0d00880:	0150      	lsls	r0, r2, #5
c0d00882:	1808      	adds	r0, r1, r0
    io_seproxyhal_display_default((bagl_element_t *) element);
c0d00884:	f000 fc76 	bl	c0d01174 <io_seproxyhal_display_default>
            UX_DEFAULT_EVENT();
c0d00888:	5ba0      	ldrh	r0, [r4, r6]
c0d0088a:	1c40      	adds	r0, r0, #1
c0d0088c:	53a0      	strh	r0, [r4, r6]
c0d0088e:	5961      	ldr	r1, [r4, r5]
c0d00890:	2900      	cmp	r1, #0
c0d00892:	d1d2      	bne.n	c0d0083a <io_event+0x2e6>
c0d00894:	e0d4      	b.n	c0d00a40 <io_event+0x4ec>
c0d00896:	4604      	mov	r4, r0
c0d00898:	20dc      	movs	r0, #220	; 0xdc
            UX_TICKER_EVENT(G_io_seproxyhal_spi_buffer, {
c0d0089a:	4e9d      	ldr	r6, [pc, #628]	; (c0d00b10 <io_event+0x5bc>)
c0d0089c:	5831      	ldr	r1, [r6, r0]
c0d0089e:	2900      	cmp	r1, #0
c0d008a0:	d010      	beq.n	c0d008c4 <io_event+0x370>
c0d008a2:	460a      	mov	r2, r1
c0d008a4:	3a64      	subs	r2, #100	; 0x64
c0d008a6:	d200      	bcs.n	c0d008aa <io_event+0x356>
c0d008a8:	463a      	mov	r2, r7
c0d008aa:	5032      	str	r2, [r6, r0]
c0d008ac:	2964      	cmp	r1, #100	; 0x64
c0d008ae:	d809      	bhi.n	c0d008c4 <io_event+0x370>
c0d008b0:	21d8      	movs	r1, #216	; 0xd8
c0d008b2:	5871      	ldr	r1, [r6, r1]
c0d008b4:	2900      	cmp	r1, #0
c0d008b6:	d100      	bne.n	c0d008ba <io_event+0x366>
c0d008b8:	e0d3      	b.n	c0d00a62 <io_event+0x50e>
c0d008ba:	22e0      	movs	r2, #224	; 0xe0
c0d008bc:	58b2      	ldr	r2, [r6, r2]
c0d008be:	5032      	str	r2, [r6, r0]
c0d008c0:	2000      	movs	r0, #0
c0d008c2:	4788      	blx	r1
c0d008c4:	2c00      	cmp	r4, #0
c0d008c6:	d100      	bne.n	c0d008ca <io_event+0x376>
c0d008c8:	e0c2      	b.n	c0d00a50 <io_event+0x4fc>
c0d008ca:	2c97      	cmp	r4, #151	; 0x97
c0d008cc:	d100      	bne.n	c0d008d0 <io_event+0x37c>
c0d008ce:	e0bf      	b.n	c0d00a50 <io_event+0x4fc>
c0d008d0:	24c4      	movs	r4, #196	; 0xc4
c0d008d2:	5930      	ldr	r0, [r6, r4]
c0d008d4:	2800      	cmp	r0, #0
c0d008d6:	d02b      	beq.n	c0d00930 <io_event+0x3dc>
c0d008d8:	25c2      	movs	r5, #194	; 0xc2
c0d008da:	5b70      	ldrh	r0, [r6, r5]
c0d008dc:	21c8      	movs	r1, #200	; 0xc8
c0d008de:	5c71      	ldrb	r1, [r6, r1]
c0d008e0:	b280      	uxth	r0, r0
c0d008e2:	4288      	cmp	r0, r1
c0d008e4:	d224      	bcs.n	c0d00930 <io_event+0x3dc>
c0d008e6:	f001 fff9 	bl	c0d028dc <io_seph_is_status_sent>
c0d008ea:	2800      	cmp	r0, #0
c0d008ec:	d120      	bne.n	c0d00930 <io_event+0x3dc>
c0d008ee:	f001 ff79 	bl	c0d027e4 <os_perso_isonboarded>
c0d008f2:	28aa      	cmp	r0, #170	; 0xaa
c0d008f4:	d103      	bne.n	c0d008fe <io_event+0x3aa>
c0d008f6:	f001 ffa5 	bl	c0d02844 <os_global_pin_is_validated>
c0d008fa:	28aa      	cmp	r0, #170	; 0xaa
c0d008fc:	d118      	bne.n	c0d00930 <io_event+0x3dc>
c0d008fe:	5931      	ldr	r1, [r6, r4]
c0d00900:	5b72      	ldrh	r2, [r6, r5]
c0d00902:	0150      	lsls	r0, r2, #5
c0d00904:	1808      	adds	r0, r1, r0
c0d00906:	23d0      	movs	r3, #208	; 0xd0
c0d00908:	58f3      	ldr	r3, [r6, r3]
c0d0090a:	2b00      	cmp	r3, #0
c0d0090c:	d004      	beq.n	c0d00918 <io_event+0x3c4>
c0d0090e:	4798      	blx	r3
c0d00910:	2800      	cmp	r0, #0
c0d00912:	d007      	beq.n	c0d00924 <io_event+0x3d0>
c0d00914:	5b72      	ldrh	r2, [r6, r5]
c0d00916:	5931      	ldr	r1, [r6, r4]
c0d00918:	2801      	cmp	r0, #1
c0d0091a:	d101      	bne.n	c0d00920 <io_event+0x3cc>
c0d0091c:	0150      	lsls	r0, r2, #5
c0d0091e:	1808      	adds	r0, r1, r0
    io_seproxyhal_display_default((bagl_element_t *) element);
c0d00920:	f000 fc28 	bl	c0d01174 <io_seproxyhal_display_default>
            UX_TICKER_EVENT(G_io_seproxyhal_spi_buffer, {
c0d00924:	5b70      	ldrh	r0, [r6, r5]
c0d00926:	1c40      	adds	r0, r0, #1
c0d00928:	5370      	strh	r0, [r6, r5]
c0d0092a:	5931      	ldr	r1, [r6, r4]
c0d0092c:	2900      	cmp	r1, #0
c0d0092e:	d1d5      	bne.n	c0d008dc <io_event+0x388>
c0d00930:	20c8      	movs	r0, #200	; 0xc8
c0d00932:	5c30      	ldrb	r0, [r6, r0]
c0d00934:	21c2      	movs	r1, #194	; 0xc2
c0d00936:	5a71      	ldrh	r1, [r6, r1]
c0d00938:	e086      	b.n	c0d00a48 <io_event+0x4f4>
c0d0093a:	46c0      	nop			; (mov r8, r8)
c0d0093c:	200008ac 	.word	0x200008ac
c0d00940:	20000a30 	.word	0x20000a30
c0d00944:	00006816 	.word	0x00006816
c0d00948:	20000358 	.word	0x20000358
c0d0094c:	20000250 	.word	0x20000250
            UX_DISPLAYED_EVENT({});
c0d00950:	f000 fbb6 	bl	c0d010c0 <io_seproxyhal_init_ux>
c0d00954:	f000 fbb6 	bl	c0d010c4 <io_seproxyhal_init_button>
c0d00958:	25c2      	movs	r5, #194	; 0xc2
c0d0095a:	4e6d      	ldr	r6, [pc, #436]	; (c0d00b10 <io_event+0x5bc>)
c0d0095c:	5377      	strh	r7, [r6, r5]
c0d0095e:	2004      	movs	r0, #4
c0d00960:	f001 fff0 	bl	c0d02944 <os_sched_last_status>
c0d00964:	6060      	str	r0, [r4, #4]
c0d00966:	2800      	cmp	r0, #0
c0d00968:	d072      	beq.n	c0d00a50 <io_event+0x4fc>
c0d0096a:	2897      	cmp	r0, #151	; 0x97
c0d0096c:	d070      	beq.n	c0d00a50 <io_event+0x4fc>
c0d0096e:	24c4      	movs	r4, #196	; 0xc4
c0d00970:	5930      	ldr	r0, [r6, r4]
c0d00972:	2800      	cmp	r0, #0
c0d00974:	d06c      	beq.n	c0d00a50 <io_event+0x4fc>
c0d00976:	5b70      	ldrh	r0, [r6, r5]
c0d00978:	21c8      	movs	r1, #200	; 0xc8
c0d0097a:	5c71      	ldrb	r1, [r6, r1]
c0d0097c:	b280      	uxth	r0, r0
c0d0097e:	4288      	cmp	r0, r1
c0d00980:	d266      	bcs.n	c0d00a50 <io_event+0x4fc>
c0d00982:	f001 ffab 	bl	c0d028dc <io_seph_is_status_sent>
c0d00986:	2800      	cmp	r0, #0
c0d00988:	d162      	bne.n	c0d00a50 <io_event+0x4fc>
c0d0098a:	f001 ff2b 	bl	c0d027e4 <os_perso_isonboarded>
c0d0098e:	28aa      	cmp	r0, #170	; 0xaa
c0d00990:	d103      	bne.n	c0d0099a <io_event+0x446>
c0d00992:	f001 ff57 	bl	c0d02844 <os_global_pin_is_validated>
c0d00996:	28aa      	cmp	r0, #170	; 0xaa
c0d00998:	d15a      	bne.n	c0d00a50 <io_event+0x4fc>
c0d0099a:	5931      	ldr	r1, [r6, r4]
c0d0099c:	5b72      	ldrh	r2, [r6, r5]
c0d0099e:	0150      	lsls	r0, r2, #5
c0d009a0:	1808      	adds	r0, r1, r0
c0d009a2:	23d0      	movs	r3, #208	; 0xd0
c0d009a4:	58f3      	ldr	r3, [r6, r3]
c0d009a6:	2b00      	cmp	r3, #0
c0d009a8:	d004      	beq.n	c0d009b4 <io_event+0x460>
c0d009aa:	4798      	blx	r3
c0d009ac:	2800      	cmp	r0, #0
c0d009ae:	d007      	beq.n	c0d009c0 <io_event+0x46c>
c0d009b0:	5b72      	ldrh	r2, [r6, r5]
c0d009b2:	5931      	ldr	r1, [r6, r4]
c0d009b4:	2801      	cmp	r0, #1
c0d009b6:	d101      	bne.n	c0d009bc <io_event+0x468>
c0d009b8:	0150      	lsls	r0, r2, #5
c0d009ba:	1808      	adds	r0, r1, r0
    io_seproxyhal_display_default((bagl_element_t *) element);
c0d009bc:	f000 fbda 	bl	c0d01174 <io_seproxyhal_display_default>
            UX_DISPLAYED_EVENT({});
c0d009c0:	5b70      	ldrh	r0, [r6, r5]
c0d009c2:	1c40      	adds	r0, r0, #1
c0d009c4:	5370      	strh	r0, [r6, r5]
c0d009c6:	5931      	ldr	r1, [r6, r4]
c0d009c8:	2900      	cmp	r1, #0
c0d009ca:	d1d5      	bne.n	c0d00978 <io_event+0x424>
c0d009cc:	e040      	b.n	c0d00a50 <io_event+0x4fc>
c0d009ce:	20d4      	movs	r0, #212	; 0xd4
            UX_BUTTON_PUSH_EVENT(G_io_seproxyhal_spi_buffer);
c0d009d0:	4c4f      	ldr	r4, [pc, #316]	; (c0d00b10 <io_event+0x5bc>)
c0d009d2:	5820      	ldr	r0, [r4, r0]
c0d009d4:	2800      	cmp	r0, #0
c0d009d6:	d003      	beq.n	c0d009e0 <io_event+0x48c>
c0d009d8:	78e9      	ldrb	r1, [r5, #3]
c0d009da:	0849      	lsrs	r1, r1, #1
c0d009dc:	f000 fc12 	bl	c0d01204 <io_seproxyhal_button_push>
c0d009e0:	25c4      	movs	r5, #196	; 0xc4
c0d009e2:	5960      	ldr	r0, [r4, r5]
c0d009e4:	2800      	cmp	r0, #0
c0d009e6:	d02b      	beq.n	c0d00a40 <io_event+0x4ec>
c0d009e8:	26c2      	movs	r6, #194	; 0xc2
c0d009ea:	5ba0      	ldrh	r0, [r4, r6]
c0d009ec:	21c8      	movs	r1, #200	; 0xc8
c0d009ee:	5c61      	ldrb	r1, [r4, r1]
c0d009f0:	b280      	uxth	r0, r0
c0d009f2:	4288      	cmp	r0, r1
c0d009f4:	d224      	bcs.n	c0d00a40 <io_event+0x4ec>
c0d009f6:	f001 ff71 	bl	c0d028dc <io_seph_is_status_sent>
c0d009fa:	2800      	cmp	r0, #0
c0d009fc:	d120      	bne.n	c0d00a40 <io_event+0x4ec>
c0d009fe:	f001 fef1 	bl	c0d027e4 <os_perso_isonboarded>
c0d00a02:	28aa      	cmp	r0, #170	; 0xaa
c0d00a04:	d103      	bne.n	c0d00a0e <io_event+0x4ba>
c0d00a06:	f001 ff1d 	bl	c0d02844 <os_global_pin_is_validated>
c0d00a0a:	28aa      	cmp	r0, #170	; 0xaa
c0d00a0c:	d118      	bne.n	c0d00a40 <io_event+0x4ec>
c0d00a0e:	5961      	ldr	r1, [r4, r5]
c0d00a10:	5ba2      	ldrh	r2, [r4, r6]
c0d00a12:	0150      	lsls	r0, r2, #5
c0d00a14:	1808      	adds	r0, r1, r0
c0d00a16:	23d0      	movs	r3, #208	; 0xd0
c0d00a18:	58e3      	ldr	r3, [r4, r3]
c0d00a1a:	2b00      	cmp	r3, #0
c0d00a1c:	d004      	beq.n	c0d00a28 <io_event+0x4d4>
c0d00a1e:	4798      	blx	r3
c0d00a20:	2800      	cmp	r0, #0
c0d00a22:	d007      	beq.n	c0d00a34 <io_event+0x4e0>
c0d00a24:	5ba2      	ldrh	r2, [r4, r6]
c0d00a26:	5961      	ldr	r1, [r4, r5]
c0d00a28:	2801      	cmp	r0, #1
c0d00a2a:	d101      	bne.n	c0d00a30 <io_event+0x4dc>
c0d00a2c:	0150      	lsls	r0, r2, #5
c0d00a2e:	1808      	adds	r0, r1, r0
    io_seproxyhal_display_default((bagl_element_t *) element);
c0d00a30:	f000 fba0 	bl	c0d01174 <io_seproxyhal_display_default>
            UX_BUTTON_PUSH_EVENT(G_io_seproxyhal_spi_buffer);
c0d00a34:	5ba0      	ldrh	r0, [r4, r6]
c0d00a36:	1c40      	adds	r0, r0, #1
c0d00a38:	53a0      	strh	r0, [r4, r6]
c0d00a3a:	5961      	ldr	r1, [r4, r5]
c0d00a3c:	2900      	cmp	r1, #0
c0d00a3e:	d1d5      	bne.n	c0d009ec <io_event+0x498>
c0d00a40:	20c8      	movs	r0, #200	; 0xc8
c0d00a42:	5c20      	ldrb	r0, [r4, r0]
c0d00a44:	21c2      	movs	r1, #194	; 0xc2
c0d00a46:	5a61      	ldrh	r1, [r4, r1]
c0d00a48:	4281      	cmp	r1, r0
c0d00a4a:	d301      	bcc.n	c0d00a50 <io_event+0x4fc>
c0d00a4c:	f001 ff46 	bl	c0d028dc <io_seph_is_status_sent>
    if (!io_seproxyhal_spi_is_status_sent()) {
c0d00a50:	f001 ff44 	bl	c0d028dc <io_seph_is_status_sent>
c0d00a54:	2800      	cmp	r0, #0
c0d00a56:	d101      	bne.n	c0d00a5c <io_event+0x508>
        io_seproxyhal_general_status();
c0d00a58:	f000 fa14 	bl	c0d00e84 <io_seproxyhal_general_status>
c0d00a5c:	2001      	movs	r0, #1
    return 1;
c0d00a5e:	b001      	add	sp, #4
c0d00a60:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00a62:	482c      	ldr	r0, [pc, #176]	; (c0d00b14 <io_event+0x5c0>)
c0d00a64:	6801      	ldr	r1, [r0, #0]
            UX_TICKER_EVENT(G_io_seproxyhal_spi_buffer, {
c0d00a66:	2900      	cmp	r1, #0
c0d00a68:	d100      	bne.n	c0d00a6c <io_event+0x518>
c0d00a6a:	e72b      	b.n	c0d008c4 <io_event+0x370>
c0d00a6c:	2c00      	cmp	r4, #0
c0d00a6e:	d0ef      	beq.n	c0d00a50 <io_event+0x4fc>
c0d00a70:	2c97      	cmp	r4, #151	; 0x97
c0d00a72:	d0ed      	beq.n	c0d00a50 <io_event+0x4fc>
c0d00a74:	4f28      	ldr	r7, [pc, #160]	; (c0d00b18 <io_event+0x5c4>)
c0d00a76:	6838      	ldr	r0, [r7, #0]
c0d00a78:	1c40      	adds	r0, r0, #1
c0d00a7a:	f003 ffb3 	bl	c0d049e4 <__aeabi_uidivmod>
c0d00a7e:	6039      	str	r1, [r7, #0]
c0d00a80:	f000 fb1e 	bl	c0d010c0 <io_seproxyhal_init_ux>
c0d00a84:	f000 fb1e 	bl	c0d010c4 <io_seproxyhal_init_button>
c0d00a88:	27c2      	movs	r7, #194	; 0xc2
c0d00a8a:	2000      	movs	r0, #0
c0d00a8c:	53f0      	strh	r0, [r6, r7]
c0d00a8e:	2004      	movs	r0, #4
c0d00a90:	f001 ff58 	bl	c0d02944 <os_sched_last_status>
c0d00a94:	6068      	str	r0, [r5, #4]
c0d00a96:	2800      	cmp	r0, #0
c0d00a98:	d100      	bne.n	c0d00a9c <io_event+0x548>
c0d00a9a:	e713      	b.n	c0d008c4 <io_event+0x370>
c0d00a9c:	2897      	cmp	r0, #151	; 0x97
c0d00a9e:	d100      	bne.n	c0d00aa2 <io_event+0x54e>
c0d00aa0:	e710      	b.n	c0d008c4 <io_event+0x370>
c0d00aa2:	25c4      	movs	r5, #196	; 0xc4
c0d00aa4:	5970      	ldr	r0, [r6, r5]
c0d00aa6:	2800      	cmp	r0, #0
c0d00aa8:	d100      	bne.n	c0d00aac <io_event+0x558>
c0d00aaa:	e70b      	b.n	c0d008c4 <io_event+0x370>
c0d00aac:	5bf0      	ldrh	r0, [r6, r7]
c0d00aae:	21c8      	movs	r1, #200	; 0xc8
c0d00ab0:	5c71      	ldrb	r1, [r6, r1]
c0d00ab2:	b280      	uxth	r0, r0
c0d00ab4:	4288      	cmp	r0, r1
c0d00ab6:	d300      	bcc.n	c0d00aba <io_event+0x566>
c0d00ab8:	e704      	b.n	c0d008c4 <io_event+0x370>
c0d00aba:	f001 ff0f 	bl	c0d028dc <io_seph_is_status_sent>
c0d00abe:	2800      	cmp	r0, #0
c0d00ac0:	d000      	beq.n	c0d00ac4 <io_event+0x570>
c0d00ac2:	e6ff      	b.n	c0d008c4 <io_event+0x370>
c0d00ac4:	f001 fe8e 	bl	c0d027e4 <os_perso_isonboarded>
c0d00ac8:	28aa      	cmp	r0, #170	; 0xaa
c0d00aca:	d104      	bne.n	c0d00ad6 <io_event+0x582>
c0d00acc:	f001 feba 	bl	c0d02844 <os_global_pin_is_validated>
c0d00ad0:	28aa      	cmp	r0, #170	; 0xaa
c0d00ad2:	d000      	beq.n	c0d00ad6 <io_event+0x582>
c0d00ad4:	e6f6      	b.n	c0d008c4 <io_event+0x370>
c0d00ad6:	5971      	ldr	r1, [r6, r5]
c0d00ad8:	5bf2      	ldrh	r2, [r6, r7]
c0d00ada:	0150      	lsls	r0, r2, #5
c0d00adc:	1808      	adds	r0, r1, r0
c0d00ade:	23d0      	movs	r3, #208	; 0xd0
c0d00ae0:	58f3      	ldr	r3, [r6, r3]
c0d00ae2:	2b00      	cmp	r3, #0
c0d00ae4:	d004      	beq.n	c0d00af0 <io_event+0x59c>
c0d00ae6:	4798      	blx	r3
c0d00ae8:	2800      	cmp	r0, #0
c0d00aea:	d007      	beq.n	c0d00afc <io_event+0x5a8>
c0d00aec:	5bf2      	ldrh	r2, [r6, r7]
c0d00aee:	5971      	ldr	r1, [r6, r5]
c0d00af0:	2801      	cmp	r0, #1
c0d00af2:	d101      	bne.n	c0d00af8 <io_event+0x5a4>
c0d00af4:	0150      	lsls	r0, r2, #5
c0d00af6:	1808      	adds	r0, r1, r0
    io_seproxyhal_display_default((bagl_element_t *) element);
c0d00af8:	f000 fb3c 	bl	c0d01174 <io_seproxyhal_display_default>
            UX_TICKER_EVENT(G_io_seproxyhal_spi_buffer, {
c0d00afc:	5bf0      	ldrh	r0, [r6, r7]
c0d00afe:	1c40      	adds	r0, r0, #1
c0d00b00:	53f0      	strh	r0, [r6, r7]
c0d00b02:	5971      	ldr	r1, [r6, r5]
c0d00b04:	2900      	cmp	r1, #0
c0d00b06:	d1d2      	bne.n	c0d00aae <io_event+0x55a>
c0d00b08:	e6dc      	b.n	c0d008c4 <io_event+0x370>
c0d00b0a:	46c0      	nop			; (mov r8, r8)
c0d00b0c:	20000358 	.word	0x20000358
c0d00b10:	20000250 	.word	0x20000250
c0d00b14:	20000364 	.word	0x20000364
c0d00b18:	20000360 	.word	0x20000360

c0d00b1c <io_exchange_al>:
unsigned short io_exchange_al(unsigned char channel, unsigned short tx_len) {
c0d00b1c:	b5b0      	push	{r4, r5, r7, lr}
c0d00b1e:	4605      	mov	r5, r0
c0d00b20:	2007      	movs	r0, #7
    switch (channel & ~(IO_FLAGS)) {
c0d00b22:	4028      	ands	r0, r5
c0d00b24:	2400      	movs	r4, #0
c0d00b26:	2801      	cmp	r0, #1
c0d00b28:	d012      	beq.n	c0d00b50 <io_exchange_al+0x34>
c0d00b2a:	2802      	cmp	r0, #2
c0d00b2c:	d112      	bne.n	c0d00b54 <io_exchange_al+0x38>
            if (tx_len) {
c0d00b2e:	2900      	cmp	r1, #0
c0d00b30:	d007      	beq.n	c0d00b42 <io_exchange_al+0x26>
                io_seproxyhal_spi_send(G_io_apdu_buffer, tx_len);
c0d00b32:	480a      	ldr	r0, [pc, #40]	; (c0d00b5c <io_exchange_al+0x40>)
c0d00b34:	f001 fec6 	bl	c0d028c4 <io_seph_send>
                if (channel & IO_RESET_AFTER_REPLIED) {
c0d00b38:	0628      	lsls	r0, r5, #24
c0d00b3a:	d509      	bpl.n	c0d00b50 <io_exchange_al+0x34>
                    reset();
c0d00b3c:	f001 fe2e 	bl	c0d0279c <halt>
c0d00b40:	e006      	b.n	c0d00b50 <io_exchange_al+0x34>
c0d00b42:	2041      	movs	r0, #65	; 0x41
c0d00b44:	0081      	lsls	r1, r0, #2
                return io_seproxyhal_spi_recv(G_io_apdu_buffer, sizeof(G_io_apdu_buffer), 0);
c0d00b46:	4805      	ldr	r0, [pc, #20]	; (c0d00b5c <io_exchange_al+0x40>)
c0d00b48:	2200      	movs	r2, #0
c0d00b4a:	f001 fed3 	bl	c0d028f4 <io_seph_recv>
c0d00b4e:	4604      	mov	r4, r0
}
c0d00b50:	4620      	mov	r0, r4
c0d00b52:	bdb0      	pop	{r4, r5, r7, pc}
c0d00b54:	4802      	ldr	r0, [pc, #8]	; (c0d00b60 <io_exchange_al+0x44>)
            THROW(ApduReplySdkInvalidParameter);
c0d00b56:	f000 f987 	bl	c0d00e68 <os_longjmp>
c0d00b5a:	46c0      	nop			; (mov r8, r8)
c0d00b5c:	2000092c 	.word	0x2000092c
c0d00b60:	00006802 	.word	0x00006802

c0d00b64 <app_exit>:
void app_exit(void) {
c0d00b64:	b510      	push	{r4, lr}
c0d00b66:	b08c      	sub	sp, #48	; 0x30
c0d00b68:	466c      	mov	r4, sp
        TRY_L(exit) {
c0d00b6a:	4620      	mov	r0, r4
c0d00b6c:	f004 f952 	bl	c0d04e14 <setjmp>
c0d00b70:	85a0      	strh	r0, [r4, #44]	; 0x2c
c0d00b72:	0400      	lsls	r0, r0, #16
c0d00b74:	d00d      	beq.n	c0d00b92 <app_exit+0x2e>
        FINALLY_L(exit) {
c0d00b76:	f001 fecb 	bl	c0d02910 <try_context_get>
c0d00b7a:	4669      	mov	r1, sp
c0d00b7c:	4288      	cmp	r0, r1
c0d00b7e:	d102      	bne.n	c0d00b86 <app_exit+0x22>
c0d00b80:	980a      	ldr	r0, [sp, #40]	; 0x28
c0d00b82:	f001 fed1 	bl	c0d02928 <try_context_set>
c0d00b86:	4668      	mov	r0, sp
    END_TRY_L(exit);
c0d00b88:	8d80      	ldrh	r0, [r0, #44]	; 0x2c
c0d00b8a:	2800      	cmp	r0, #0
c0d00b8c:	d108      	bne.n	c0d00ba0 <app_exit+0x3c>
}
c0d00b8e:	b00c      	add	sp, #48	; 0x30
c0d00b90:	bd10      	pop	{r4, pc}
c0d00b92:	4668      	mov	r0, sp
        TRY_L(exit) {
c0d00b94:	f001 fec8 	bl	c0d02928 <try_context_set>
c0d00b98:	900a      	str	r0, [sp, #40]	; 0x28
c0d00b9a:	20ff      	movs	r0, #255	; 0xff
            os_sched_exit(-1);
c0d00b9c:	f001 fe86 	bl	c0d028ac <os_sched_exit>
    END_TRY_L(exit);
c0d00ba0:	f000 f962 	bl	c0d00e68 <os_longjmp>

c0d00ba4 <nv_app_state_init>:
void nv_app_state_init() {
c0d00ba4:	b580      	push	{r7, lr}
c0d00ba6:	b082      	sub	sp, #8
    if (N_storage.initialized != 0x01) {
c0d00ba8:	480a      	ldr	r0, [pc, #40]	; (c0d00bd4 <nv_app_state_init+0x30>)
c0d00baa:	4478      	add	r0, pc
c0d00bac:	f001 f9c6 	bl	c0d01f3c <pic>
c0d00bb0:	78c0      	ldrb	r0, [r0, #3]
c0d00bb2:	2801      	cmp	r0, #1
c0d00bb4:	d009      	beq.n	c0d00bca <nv_app_state_init+0x26>
c0d00bb6:	4806      	ldr	r0, [pc, #24]	; (c0d00bd0 <nv_app_state_init+0x2c>)
        storage.settings.allow_blind_sign = BlindSignDisabled;
c0d00bb8:	9001      	str	r0, [sp, #4]
        nvm_write((void *) &N_storage, (void *) &storage, sizeof(internalStorage_t));
c0d00bba:	4807      	ldr	r0, [pc, #28]	; (c0d00bd8 <nv_app_state_init+0x34>)
c0d00bbc:	4478      	add	r0, pc
c0d00bbe:	f001 f9bd 	bl	c0d01f3c <pic>
c0d00bc2:	a901      	add	r1, sp, #4
c0d00bc4:	2204      	movs	r2, #4
c0d00bc6:	f001 fdf5 	bl	c0d027b4 <nvm_write>
}
c0d00bca:	b002      	add	sp, #8
c0d00bcc:	bd80      	pop	{r7, pc}
c0d00bce:	46c0      	nop			; (mov r8, r8)
c0d00bd0:	01000100 	.word	0x01000100
c0d00bd4:	00004f12 	.word	0x00004f12
c0d00bd8:	00004f00 	.word	0x00004f00

c0d00bdc <settings_submenu_getter>:
    "Display mode",
    "Back",
};

const char* settings_submenu_getter(unsigned int idx) {
    if (idx < ARRAYLEN(settings_submenu_getter_values)) {
c0d00bdc:	2803      	cmp	r0, #3
c0d00bde:	d804      	bhi.n	c0d00bea <settings_submenu_getter+0xe>
        return settings_submenu_getter_values[idx];
c0d00be0:	0080      	lsls	r0, r0, #2
c0d00be2:	4903      	ldr	r1, [pc, #12]	; (c0d00bf0 <settings_submenu_getter+0x14>)
c0d00be4:	4479      	add	r1, pc
c0d00be6:	5808      	ldr	r0, [r1, r0]
    }
    return NULL;
}
c0d00be8:	4770      	bx	lr
c0d00bea:	2000      	movs	r0, #0
c0d00bec:	4770      	bx	lr
c0d00bee:	46c0      	nop			; (mov r8, r8)
c0d00bf0:	00004638 	.word	0x00004638

c0d00bf4 <settings_submenu_selector>:

void settings_submenu_selector(unsigned int idx) {
c0d00bf4:	b580      	push	{r7, lr}
    switch (idx) {
c0d00bf6:	2802      	cmp	r0, #2
c0d00bf8:	d00e      	beq.n	c0d00c18 <settings_submenu_selector+0x24>
c0d00bfa:	2801      	cmp	r0, #1
c0d00bfc:	d017      	beq.n	c0d00c2e <settings_submenu_selector+0x3a>
c0d00bfe:	2800      	cmp	r0, #0
c0d00c00:	d122      	bne.n	c0d00c48 <settings_submenu_selector+0x54>
        case 0:
            ux_menulist_init_select(0,
                                    allow_blind_sign_data_getter,
                                    allow_blind_sign_data_selector,
                                    N_storage.settings.allow_blind_sign);
c0d00c02:	4813      	ldr	r0, [pc, #76]	; (c0d00c50 <settings_submenu_selector+0x5c>)
c0d00c04:	4478      	add	r0, pc
c0d00c06:	f001 f999 	bl	c0d01f3c <pic>
c0d00c0a:	7803      	ldrb	r3, [r0, #0]
c0d00c0c:	2000      	movs	r0, #0
            ux_menulist_init_select(0,
c0d00c0e:	4911      	ldr	r1, [pc, #68]	; (c0d00c54 <settings_submenu_selector+0x60>)
c0d00c10:	4479      	add	r1, pc
c0d00c12:	4a11      	ldr	r2, [pc, #68]	; (c0d00c58 <settings_submenu_selector+0x64>)
c0d00c14:	447a      	add	r2, pc
c0d00c16:	e014      	b.n	c0d00c42 <settings_submenu_selector+0x4e>
            break;
        case 2:
            ux_menulist_init_select(0,
                                    display_mode_data_getter,
                                    display_mode_data_selector,
                                    N_storage.settings.display_mode);
c0d00c18:	4813      	ldr	r0, [pc, #76]	; (c0d00c68 <settings_submenu_selector+0x74>)
c0d00c1a:	4478      	add	r0, pc
c0d00c1c:	f001 f98e 	bl	c0d01f3c <pic>
c0d00c20:	7883      	ldrb	r3, [r0, #2]
c0d00c22:	2000      	movs	r0, #0
            ux_menulist_init_select(0,
c0d00c24:	4911      	ldr	r1, [pc, #68]	; (c0d00c6c <settings_submenu_selector+0x78>)
c0d00c26:	4479      	add	r1, pc
c0d00c28:	4a11      	ldr	r2, [pc, #68]	; (c0d00c70 <settings_submenu_selector+0x7c>)
c0d00c2a:	447a      	add	r2, pc
c0d00c2c:	e009      	b.n	c0d00c42 <settings_submenu_selector+0x4e>
                                    N_storage.settings.pubkey_display);
c0d00c2e:	480b      	ldr	r0, [pc, #44]	; (c0d00c5c <settings_submenu_selector+0x68>)
c0d00c30:	4478      	add	r0, pc
c0d00c32:	f001 f983 	bl	c0d01f3c <pic>
c0d00c36:	7843      	ldrb	r3, [r0, #1]
c0d00c38:	2000      	movs	r0, #0
            ux_menulist_init_select(0,
c0d00c3a:	4909      	ldr	r1, [pc, #36]	; (c0d00c60 <settings_submenu_selector+0x6c>)
c0d00c3c:	4479      	add	r1, pc
c0d00c3e:	4a09      	ldr	r2, [pc, #36]	; (c0d00c64 <settings_submenu_selector+0x70>)
c0d00c40:	447a      	add	r2, pc
c0d00c42:	f003 fddd 	bl	c0d04800 <ux_menulist_init_select>
            break;
        default:
            ui_idle();
    }
}
c0d00c46:	bd80      	pop	{r7, pc}
            ui_idle();
c0d00c48:	f000 f8c6 	bl	c0d00dd8 <ui_idle>
}
c0d00c4c:	bd80      	pop	{r7, pc}
c0d00c4e:	46c0      	nop			; (mov r8, r8)
c0d00c50:	00004eb8 	.word	0x00004eb8
c0d00c54:	00000061 	.word	0x00000061
c0d00c58:	00000075 	.word	0x00000075
c0d00c5c:	00004e8c 	.word	0x00004e8c
c0d00c60:	000000a9 	.word	0x000000a9
c0d00c64:	000000bd 	.word	0x000000bd
c0d00c68:	00004ea2 	.word	0x00004ea2
c0d00c6c:	00000137 	.word	0x00000137
c0d00c70:	0000014b 	.word	0x0000014b

c0d00c74 <allow_blind_sign_data_getter>:
}

const char* const no_yes_data_getter_values[] = {"No", "Yes", "Back"};

static const char* allow_blind_sign_data_getter(unsigned int idx) {
    if (idx < ARRAYLEN(no_yes_data_getter_values)) {
c0d00c74:	2802      	cmp	r0, #2
c0d00c76:	d804      	bhi.n	c0d00c82 <allow_blind_sign_data_getter+0xe>
        return no_yes_data_getter_values[idx];
c0d00c78:	0080      	lsls	r0, r0, #2
c0d00c7a:	4903      	ldr	r1, [pc, #12]	; (c0d00c88 <allow_blind_sign_data_getter+0x14>)
c0d00c7c:	4479      	add	r1, pc
c0d00c7e:	5808      	ldr	r0, [r1, r0]
    }
    return NULL;
}
c0d00c80:	4770      	bx	lr
c0d00c82:	2000      	movs	r0, #0
c0d00c84:	4770      	bx	lr
c0d00c86:	46c0      	nop			; (mov r8, r8)
c0d00c88:	000045b0 	.word	0x000045b0

c0d00c8c <allow_blind_sign_data_selector>:

void allow_blind_sign_data_selector(unsigned int idx) {
c0d00c8c:	b5b0      	push	{r4, r5, r7, lr}
c0d00c8e:	b082      	sub	sp, #8
    switch (idx) {
c0d00c90:	2801      	cmp	r0, #1
c0d00c92:	d00b      	beq.n	c0d00cac <allow_blind_sign_data_selector+0x20>
c0d00c94:	2800      	cmp	r0, #0
c0d00c96:	d114      	bne.n	c0d00cc2 <allow_blind_sign_data_selector+0x36>
c0d00c98:	466c      	mov	r4, sp
c0d00c9a:	2000      	movs	r0, #0
            value = (uint8_t) blind_sign;
c0d00c9c:	7020      	strb	r0, [r4, #0]
            nvm_write((void*) &N_storage.settings.allow_blind_sign, &value, sizeof(value));
c0d00c9e:	480e      	ldr	r0, [pc, #56]	; (c0d00cd8 <allow_blind_sign_data_selector+0x4c>)
c0d00ca0:	4478      	add	r0, pc
c0d00ca2:	f001 f94b 	bl	c0d01f3c <pic>
c0d00ca6:	2201      	movs	r2, #1
c0d00ca8:	4621      	mov	r1, r4
c0d00caa:	e008      	b.n	c0d00cbe <allow_blind_sign_data_selector+0x32>
c0d00cac:	ac01      	add	r4, sp, #4
c0d00cae:	2501      	movs	r5, #1
            value = (uint8_t) blind_sign;
c0d00cb0:	7025      	strb	r5, [r4, #0]
            nvm_write((void*) &N_storage.settings.allow_blind_sign, &value, sizeof(value));
c0d00cb2:	480a      	ldr	r0, [pc, #40]	; (c0d00cdc <allow_blind_sign_data_selector+0x50>)
c0d00cb4:	4478      	add	r0, pc
c0d00cb6:	f001 f941 	bl	c0d01f3c <pic>
c0d00cba:	4621      	mov	r1, r4
c0d00cbc:	462a      	mov	r2, r5
c0d00cbe:	f001 fd79 	bl	c0d027b4 <nvm_write>
            break;
        default:
            break;
    }
    unsigned int select_item = settings_submenu_option_index(SettingsMenuOptionAllowBlindSign);
    ux_menulist_init_select(0, settings_submenu_getter, settings_submenu_selector, select_item);
c0d00cc2:	4907      	ldr	r1, [pc, #28]	; (c0d00ce0 <allow_blind_sign_data_selector+0x54>)
c0d00cc4:	4479      	add	r1, pc
c0d00cc6:	4a07      	ldr	r2, [pc, #28]	; (c0d00ce4 <allow_blind_sign_data_selector+0x58>)
c0d00cc8:	447a      	add	r2, pc
c0d00cca:	2000      	movs	r0, #0
c0d00ccc:	4603      	mov	r3, r0
c0d00cce:	f003 fd97 	bl	c0d04800 <ux_menulist_init_select>
}
c0d00cd2:	b002      	add	sp, #8
c0d00cd4:	bdb0      	pop	{r4, r5, r7, pc}
c0d00cd6:	46c0      	nop			; (mov r8, r8)
c0d00cd8:	00004e1c 	.word	0x00004e1c
c0d00cdc:	00004e08 	.word	0x00004e08
c0d00ce0:	ffffff15 	.word	0xffffff15
c0d00ce4:	ffffff29 	.word	0xffffff29

c0d00ce8 <pubkey_display_data_getter>:
}

const char* const pubkey_display_data_getter_values[] = {"Long", "Short", "Back"};

static const char* pubkey_display_data_getter(unsigned int idx) {
    if (idx < ARRAYLEN(pubkey_display_data_getter_values)) {
c0d00ce8:	2802      	cmp	r0, #2
c0d00cea:	d804      	bhi.n	c0d00cf6 <pubkey_display_data_getter+0xe>
        return pubkey_display_data_getter_values[idx];
c0d00cec:	0080      	lsls	r0, r0, #2
c0d00cee:	4903      	ldr	r1, [pc, #12]	; (c0d00cfc <pubkey_display_data_getter+0x14>)
c0d00cf0:	4479      	add	r1, pc
c0d00cf2:	5808      	ldr	r0, [r1, r0]
    }
    return NULL;
}
c0d00cf4:	4770      	bx	lr
c0d00cf6:	2000      	movs	r0, #0
c0d00cf8:	4770      	bx	lr
c0d00cfa:	46c0      	nop			; (mov r8, r8)
c0d00cfc:	00004548 	.word	0x00004548

c0d00d00 <pubkey_display_data_selector>:

static void pubkey_display_data_selector(unsigned int idx) {
c0d00d00:	b5b0      	push	{r4, r5, r7, lr}
c0d00d02:	b082      	sub	sp, #8
    switch (idx) {
c0d00d04:	2801      	cmp	r0, #1
c0d00d06:	d00c      	beq.n	c0d00d22 <pubkey_display_data_selector+0x22>
c0d00d08:	2800      	cmp	r0, #0
c0d00d0a:	d116      	bne.n	c0d00d3a <pubkey_display_data_selector+0x3a>
c0d00d0c:	466c      	mov	r4, sp
c0d00d0e:	2000      	movs	r0, #0
            value = (uint8_t) pubkey_display;
c0d00d10:	7020      	strb	r0, [r4, #0]
            nvm_write((void*) &N_storage.settings.pubkey_display, &value, sizeof(value));
c0d00d12:	480f      	ldr	r0, [pc, #60]	; (c0d00d50 <pubkey_display_data_selector+0x50>)
c0d00d14:	4478      	add	r0, pc
c0d00d16:	f001 f911 	bl	c0d01f3c <pic>
c0d00d1a:	1c40      	adds	r0, r0, #1
c0d00d1c:	2201      	movs	r2, #1
c0d00d1e:	4621      	mov	r1, r4
c0d00d20:	e009      	b.n	c0d00d36 <pubkey_display_data_selector+0x36>
c0d00d22:	ac01      	add	r4, sp, #4
c0d00d24:	2501      	movs	r5, #1
            value = (uint8_t) pubkey_display;
c0d00d26:	7025      	strb	r5, [r4, #0]
            nvm_write((void*) &N_storage.settings.pubkey_display, &value, sizeof(value));
c0d00d28:	480a      	ldr	r0, [pc, #40]	; (c0d00d54 <pubkey_display_data_selector+0x54>)
c0d00d2a:	4478      	add	r0, pc
c0d00d2c:	f001 f906 	bl	c0d01f3c <pic>
c0d00d30:	1c40      	adds	r0, r0, #1
c0d00d32:	4621      	mov	r1, r4
c0d00d34:	462a      	mov	r2, r5
c0d00d36:	f001 fd3d 	bl	c0d027b4 <nvm_write>
c0d00d3a:	2000      	movs	r0, #0
            break;
        default:
            break;
    }
    unsigned int select_item = settings_submenu_option_index(SettingsMenuOptionPubkeyLength);
    ux_menulist_init_select(0, settings_submenu_getter, settings_submenu_selector, select_item);
c0d00d3c:	4906      	ldr	r1, [pc, #24]	; (c0d00d58 <pubkey_display_data_selector+0x58>)
c0d00d3e:	4479      	add	r1, pc
c0d00d40:	4a06      	ldr	r2, [pc, #24]	; (c0d00d5c <pubkey_display_data_selector+0x5c>)
c0d00d42:	447a      	add	r2, pc
c0d00d44:	2301      	movs	r3, #1
c0d00d46:	f003 fd5b 	bl	c0d04800 <ux_menulist_init_select>
}
c0d00d4a:	b002      	add	sp, #8
c0d00d4c:	bdb0      	pop	{r4, r5, r7, pc}
c0d00d4e:	46c0      	nop			; (mov r8, r8)
c0d00d50:	00004da8 	.word	0x00004da8
c0d00d54:	00004d92 	.word	0x00004d92
c0d00d58:	fffffe9b 	.word	0xfffffe9b
c0d00d5c:	fffffeaf 	.word	0xfffffeaf

c0d00d60 <display_mode_data_getter>:
}

const char* const display_mode_data_getter_values[] = {"User", "Expert", "Back"};

static const char* display_mode_data_getter(unsigned int idx) {
    if (idx < ARRAYLEN(display_mode_data_getter_values)) {
c0d00d60:	2802      	cmp	r0, #2
c0d00d62:	d804      	bhi.n	c0d00d6e <display_mode_data_getter+0xe>
        return display_mode_data_getter_values[idx];
c0d00d64:	0080      	lsls	r0, r0, #2
c0d00d66:	4903      	ldr	r1, [pc, #12]	; (c0d00d74 <display_mode_data_getter+0x14>)
c0d00d68:	4479      	add	r1, pc
c0d00d6a:	5808      	ldr	r0, [r1, r0]
    }
    return NULL;
}
c0d00d6c:	4770      	bx	lr
c0d00d6e:	2000      	movs	r0, #0
c0d00d70:	4770      	bx	lr
c0d00d72:	46c0      	nop			; (mov r8, r8)
c0d00d74:	000044dc 	.word	0x000044dc

c0d00d78 <display_mode_data_selector>:

static void display_mode_data_selector(unsigned int idx) {
c0d00d78:	b5b0      	push	{r4, r5, r7, lr}
c0d00d7a:	b082      	sub	sp, #8
    switch (idx) {
c0d00d7c:	2801      	cmp	r0, #1
c0d00d7e:	d00c      	beq.n	c0d00d9a <display_mode_data_selector+0x22>
c0d00d80:	2800      	cmp	r0, #0
c0d00d82:	d116      	bne.n	c0d00db2 <display_mode_data_selector+0x3a>
c0d00d84:	466c      	mov	r4, sp
c0d00d86:	2000      	movs	r0, #0
            value = (uint8_t) display_mode;
c0d00d88:	7020      	strb	r0, [r4, #0]
            nvm_write((void*) &N_storage.settings.display_mode, &value, sizeof(value));
c0d00d8a:	480f      	ldr	r0, [pc, #60]	; (c0d00dc8 <display_mode_data_selector+0x50>)
c0d00d8c:	4478      	add	r0, pc
c0d00d8e:	f001 f8d5 	bl	c0d01f3c <pic>
c0d00d92:	1c80      	adds	r0, r0, #2
c0d00d94:	2201      	movs	r2, #1
c0d00d96:	4621      	mov	r1, r4
c0d00d98:	e009      	b.n	c0d00dae <display_mode_data_selector+0x36>
c0d00d9a:	ac01      	add	r4, sp, #4
c0d00d9c:	2501      	movs	r5, #1
            value = (uint8_t) display_mode;
c0d00d9e:	7025      	strb	r5, [r4, #0]
            nvm_write((void*) &N_storage.settings.display_mode, &value, sizeof(value));
c0d00da0:	480a      	ldr	r0, [pc, #40]	; (c0d00dcc <display_mode_data_selector+0x54>)
c0d00da2:	4478      	add	r0, pc
c0d00da4:	f001 f8ca 	bl	c0d01f3c <pic>
c0d00da8:	1c80      	adds	r0, r0, #2
c0d00daa:	4621      	mov	r1, r4
c0d00dac:	462a      	mov	r2, r5
c0d00dae:	f001 fd01 	bl	c0d027b4 <nvm_write>
c0d00db2:	2000      	movs	r0, #0
            break;
        default:
            break;
    }
    unsigned int select_item = settings_submenu_option_index(SettingsMenuOptionDisplayMode);
    ux_menulist_init_select(0, settings_submenu_getter, settings_submenu_selector, select_item);
c0d00db4:	4906      	ldr	r1, [pc, #24]	; (c0d00dd0 <display_mode_data_selector+0x58>)
c0d00db6:	4479      	add	r1, pc
c0d00db8:	4a06      	ldr	r2, [pc, #24]	; (c0d00dd4 <display_mode_data_selector+0x5c>)
c0d00dba:	447a      	add	r2, pc
c0d00dbc:	2302      	movs	r3, #2
c0d00dbe:	f003 fd1f 	bl	c0d04800 <ux_menulist_init_select>
}
c0d00dc2:	b002      	add	sp, #8
c0d00dc4:	bdb0      	pop	{r4, r5, r7, pc}
c0d00dc6:	46c0      	nop			; (mov r8, r8)
c0d00dc8:	00004d30 	.word	0x00004d30
c0d00dcc:	00004d1a 	.word	0x00004d1a
c0d00dd0:	fffffe23 	.word	0xfffffe23
c0d00dd4:	fffffe37 	.word	0xfffffe37

c0d00dd8 <ui_idle>:
        &ux_idle_flow_2_step,
        &ux_idle_flow_3_step,
        &ux_idle_flow_4_step,
        FLOW_LOOP);

void ui_idle(void) {
c0d00dd8:	b580      	push	{r7, lr}
    // reserve a display stack slot if none yet
    if (G_ux.stack_count == 0) {
c0d00dda:	4806      	ldr	r0, [pc, #24]	; (c0d00df4 <ui_idle+0x1c>)
c0d00ddc:	7800      	ldrb	r0, [r0, #0]
c0d00dde:	2800      	cmp	r0, #0
c0d00de0:	d101      	bne.n	c0d00de6 <ui_idle+0xe>
        ux_stack_push();
c0d00de2:	f003 fd33 	bl	c0d0484c <ux_stack_push>
    }
    ux_flow_init(0, ux_idle_flow, NULL);
c0d00de6:	4904      	ldr	r1, [pc, #16]	; (c0d00df8 <ui_idle+0x20>)
c0d00de8:	4479      	add	r1, pc
c0d00dea:	2000      	movs	r0, #0
c0d00dec:	4602      	mov	r2, r0
c0d00dee:	f003 f885 	bl	c0d03efc <ux_flow_init>
}
c0d00df2:	bd80      	pop	{r7, pc}
c0d00df4:	20000250 	.word	0x20000250
c0d00df8:	000044fc 	.word	0x000044fc

c0d00dfc <ux_idle_flow_2_step_validateinit>:
UX_STEP_CB(ux_idle_flow_2_step,
c0d00dfc:	b580      	push	{r7, lr}
c0d00dfe:	2000      	movs	r0, #0
c0d00e00:	4903      	ldr	r1, [pc, #12]	; (c0d00e10 <ux_idle_flow_2_step_validateinit+0x14>)
c0d00e02:	4479      	add	r1, pc
c0d00e04:	4a03      	ldr	r2, [pc, #12]	; (c0d00e14 <ux_idle_flow_2_step_validateinit+0x18>)
c0d00e06:	447a      	add	r2, pc
c0d00e08:	f003 fd1a 	bl	c0d04840 <ux_menulist_init>
c0d00e0c:	bd80      	pop	{r7, pc}
c0d00e0e:	46c0      	nop			; (mov r8, r8)
c0d00e10:	fffffdd7 	.word	0xfffffdd7
c0d00e14:	fffffdeb 	.word	0xfffffdeb

c0d00e18 <ux_idle_flow_4_step_validateinit>:
UX_STEP_CB(ux_idle_flow_4_step,
c0d00e18:	20ff      	movs	r0, #255	; 0xff
c0d00e1a:	f001 fd47 	bl	c0d028ac <os_sched_exit>

c0d00e1e <process_message_body>:
#include <string.h>

// change this if you want to be able to add succesive tx
#define MAX_INSTRUCTIONS 1

int process_message_body(const uint8_t* message_body, int message_body_length, int ins_code) {
c0d00e1e:	b570      	push	{r4, r5, r6, lr}
c0d00e20:	b090      	sub	sp, #64	; 0x40
c0d00e22:	4615      	mov	r5, r2
c0d00e24:	460c      	mov	r4, r1
c0d00e26:	4606      	mov	r6, r0
c0d00e28:	a804      	add	r0, sp, #16
c0d00e2a:	2130      	movs	r1, #48	; 0x30
    size_t instruction_count = 0;
    InstructionInfo instruction_info[MAX_INSTRUCTIONS];
    explicit_bzero(instruction_info, sizeof(InstructionInfo) * MAX_INSTRUCTIONS);
c0d00e2c:	f003 fef2 	bl	c0d04c14 <explicit_bzero>
    size_t display_instruction_count = 0;
    InstructionInfo* display_instruction_info[MAX_INSTRUCTIONS];

    // init parser body
    Parser parser = {message_body, message_body_length};
c0d00e30:	9403      	str	r4, [sp, #12]
c0d00e32:	9602      	str	r6, [sp, #8]
c0d00e34:	2401      	movs	r4, #1
    Instruction instruction;
    InstructionInfo* info = &instruction_info[instruction_count];

    switch (ins_code) {
c0d00e36:	2d03      	cmp	r5, #3
c0d00e38:	d10d      	bne.n	c0d00e56 <process_message_body+0x38>
c0d00e3a:	a802      	add	r0, sp, #8
c0d00e3c:	4669      	mov	r1, sp
c0d00e3e:	aa04      	add	r2, sp, #16
        case 3:  // TRANSFER
            parse_system_transfer_instruction(&parser, &instruction, &info->transfer);
c0d00e40:	f7ff fa72 	bl	c0d00328 <parse_system_transfer_instruction>
c0d00e44:	2d03      	cmp	r5, #3
c0d00e46:	d106      	bne.n	c0d00e56 <process_message_body+0x38>
c0d00e48:	9803      	ldr	r0, [sp, #12]
c0d00e4a:	2800      	cmp	r0, #0
c0d00e4c:	d103      	bne.n	c0d00e56 <process_message_body+0x38>
c0d00e4e:	a804      	add	r0, sp, #16
    // Ensure we've consumed the entire message body
    BAIL_IF(!parser_is_empty(&parser));

    switch (ins_code) {
        case 3:  // TRANSFER
            return print_system_transfer_info(&display_instruction_info[0]->transfer);
c0d00e50:	f7ff fa7c 	bl	c0d0034c <print_system_transfer_info>
c0d00e54:	4604      	mov	r4, r0
    };
    return 1;
c0d00e56:	4620      	mov	r0, r4
c0d00e58:	b010      	add	sp, #64	; 0x40
c0d00e5a:	bd70      	pop	{r4, r5, r6, pc}

c0d00e5c <os_boot>:

// apdu buffer must hold a complete apdu to avoid troubles
unsigned char G_io_apdu_buffer[IO_APDU_BUFFER_SIZE];

#ifndef BOLOS_OS_UPGRADER_APP
void os_boot(void) {
c0d00e5c:	b580      	push	{r7, lr}
c0d00e5e:	2000      	movs	r0, #0
  // // TODO patch entry point when romming (f)
  // // set the default try context to nothing
#ifndef HAVE_BOLOS
  try_context_set(NULL);
c0d00e60:	f001 fd62 	bl	c0d02928 <try_context_set>
#endif // HAVE_BOLOS
}
c0d00e64:	bd80      	pop	{r7, pc}
	...

c0d00e68 <os_longjmp>:
  }
  return xoracc;
}

#ifndef HAVE_BOLOS
void os_longjmp(unsigned int exception) {
c0d00e68:	4604      	mov	r4, r0
#ifdef HAVE_PRINTF  
  unsigned int lr_val;
  __asm volatile("mov %0, lr" :"=r"(lr_val));
c0d00e6a:	4672      	mov	r2, lr
  PRINTF("exception[%d]: LR=0x%08X\n", exception, lr_val);
c0d00e6c:	4804      	ldr	r0, [pc, #16]	; (c0d00e80 <os_longjmp+0x18>)
c0d00e6e:	4478      	add	r0, pc
c0d00e70:	4621      	mov	r1, r4
c0d00e72:	f000 fcb3 	bl	c0d017dc <mcu_usb_printf>
#endif // HAVE_PRINTF
  longjmp(try_context_get()->jmp_buf, exception);
c0d00e76:	f001 fd4b 	bl	c0d02910 <try_context_get>
c0d00e7a:	4621      	mov	r1, r4
c0d00e7c:	f003 ffd6 	bl	c0d04e2c <longjmp>
c0d00e80:	0000448e 	.word	0x0000448e

c0d00e84 <io_seproxyhal_general_status>:
  0,
  2,
  SEPROXYHAL_TAG_GENERAL_STATUS_LAST_COMMAND>>8,
  SEPROXYHAL_TAG_GENERAL_STATUS_LAST_COMMAND,
};
void io_seproxyhal_general_status(void) {
c0d00e84:	b580      	push	{r7, lr}
  // send the general status
  io_seproxyhal_spi_send(seph_io_general_status, sizeof(seph_io_general_status));
c0d00e86:	4803      	ldr	r0, [pc, #12]	; (c0d00e94 <io_seproxyhal_general_status+0x10>)
c0d00e88:	4478      	add	r0, pc
c0d00e8a:	2105      	movs	r1, #5
c0d00e8c:	f001 fd1a 	bl	c0d028c4 <io_seph_send>
}
c0d00e90:	bd80      	pop	{r7, pc}
c0d00e92:	46c0      	nop			; (mov r8, r8)
c0d00e94:	0000448e 	.word	0x0000448e

c0d00e98 <io_seproxyhal_handle_usb_event>:
}

#ifdef HAVE_IO_USB
#ifdef HAVE_L4_USBLIB

void io_seproxyhal_handle_usb_event(void) {
c0d00e98:	b510      	push	{r4, lr}
  switch(G_io_seproxyhal_spi_buffer[3]) {
c0d00e9a:	4816      	ldr	r0, [pc, #88]	; (c0d00ef4 <io_seproxyhal_handle_usb_event+0x5c>)
c0d00e9c:	78c0      	ldrb	r0, [r0, #3]
c0d00e9e:	2803      	cmp	r0, #3
c0d00ea0:	dc07      	bgt.n	c0d00eb2 <io_seproxyhal_handle_usb_event+0x1a>
c0d00ea2:	2801      	cmp	r0, #1
c0d00ea4:	d00d      	beq.n	c0d00ec2 <io_seproxyhal_handle_usb_event+0x2a>
c0d00ea6:	2802      	cmp	r0, #2
c0d00ea8:	d11f      	bne.n	c0d00eea <io_seproxyhal_handle_usb_event+0x52>
      }
      memset(G_io_app.usb_ep_xfer_len, 0, sizeof(G_io_app.usb_ep_xfer_len));
      memset(G_io_app.usb_ep_timeouts, 0, sizeof(G_io_app.usb_ep_timeouts));
      break;
    case SEPROXYHAL_TAG_USB_EVENT_SOF:
      USBD_LL_SOF(&USBD_Device);
c0d00eaa:	4813      	ldr	r0, [pc, #76]	; (c0d00ef8 <io_seproxyhal_handle_usb_event+0x60>)
c0d00eac:	f002 f918 	bl	c0d030e0 <USBD_LL_SOF>
      break;
    case SEPROXYHAL_TAG_USB_EVENT_RESUMED:
      USBD_LL_Resume(&USBD_Device);
      break;
  }
}
c0d00eb0:	bd10      	pop	{r4, pc}
  switch(G_io_seproxyhal_spi_buffer[3]) {
c0d00eb2:	2804      	cmp	r0, #4
c0d00eb4:	d016      	beq.n	c0d00ee4 <io_seproxyhal_handle_usb_event+0x4c>
c0d00eb6:	2808      	cmp	r0, #8
c0d00eb8:	d117      	bne.n	c0d00eea <io_seproxyhal_handle_usb_event+0x52>
      USBD_LL_Resume(&USBD_Device);
c0d00eba:	480f      	ldr	r0, [pc, #60]	; (c0d00ef8 <io_seproxyhal_handle_usb_event+0x60>)
c0d00ebc:	f002 f90e 	bl	c0d030dc <USBD_LL_Resume>
}
c0d00ec0:	bd10      	pop	{r4, pc}
      USBD_LL_SetSpeed(&USBD_Device, USBD_SPEED_FULL);
c0d00ec2:	4c0d      	ldr	r4, [pc, #52]	; (c0d00ef8 <io_seproxyhal_handle_usb_event+0x60>)
c0d00ec4:	2101      	movs	r1, #1
c0d00ec6:	4620      	mov	r0, r4
c0d00ec8:	f002 f903 	bl	c0d030d2 <USBD_LL_SetSpeed>
      USBD_LL_Reset(&USBD_Device);
c0d00ecc:	4620      	mov	r0, r4
c0d00ece:	f002 f8e1 	bl	c0d03094 <USBD_LL_Reset>
      if (G_io_app.apdu_media != IO_APDU_MEDIA_NONE) {
c0d00ed2:	480a      	ldr	r0, [pc, #40]	; (c0d00efc <io_seproxyhal_handle_usb_event+0x64>)
c0d00ed4:	7981      	ldrb	r1, [r0, #6]
c0d00ed6:	2900      	cmp	r1, #0
c0d00ed8:	d108      	bne.n	c0d00eec <io_seproxyhal_handle_usb_event+0x54>
      memset(G_io_app.usb_ep_timeouts, 0, sizeof(G_io_app.usb_ep_timeouts));
c0d00eda:	300c      	adds	r0, #12
c0d00edc:	2112      	movs	r1, #18
c0d00ede:	f003 fe83 	bl	c0d04be8 <__aeabi_memclr>
}
c0d00ee2:	bd10      	pop	{r4, pc}
      USBD_LL_Suspend(&USBD_Device);
c0d00ee4:	4804      	ldr	r0, [pc, #16]	; (c0d00ef8 <io_seproxyhal_handle_usb_event+0x60>)
c0d00ee6:	f002 f8f7 	bl	c0d030d8 <USBD_LL_Suspend>
}
c0d00eea:	bd10      	pop	{r4, pc}
c0d00eec:	2005      	movs	r0, #5
        THROW(EXCEPTION_IO_RESET);
c0d00eee:	f7ff ffbb 	bl	c0d00e68 <os_longjmp>
c0d00ef2:	46c0      	nop			; (mov r8, r8)
c0d00ef4:	200008ac 	.word	0x200008ac
c0d00ef8:	20000cb8 	.word	0x20000cb8
c0d00efc:	20000a30 	.word	0x20000a30

c0d00f00 <io_seproxyhal_get_ep_rx_size>:

uint16_t io_seproxyhal_get_ep_rx_size(uint8_t epnum) {
c0d00f00:	217f      	movs	r1, #127	; 0x7f
  if ((epnum & 0x7F) < IO_USB_MAX_ENDPOINTS) {
c0d00f02:	4001      	ands	r1, r0
c0d00f04:	2905      	cmp	r1, #5
c0d00f06:	d803      	bhi.n	c0d00f10 <io_seproxyhal_get_ep_rx_size+0x10>
    return G_io_app.usb_ep_xfer_len[epnum&0x7F];
c0d00f08:	4802      	ldr	r0, [pc, #8]	; (c0d00f14 <io_seproxyhal_get_ep_rx_size+0x14>)
c0d00f0a:	1840      	adds	r0, r0, r1
c0d00f0c:	7b00      	ldrb	r0, [r0, #12]
  }
  return 0;
}
c0d00f0e:	4770      	bx	lr
c0d00f10:	2000      	movs	r0, #0
c0d00f12:	4770      	bx	lr
c0d00f14:	20000a30 	.word	0x20000a30

c0d00f18 <io_seproxyhal_handle_usb_ep_xfer_event>:

void io_seproxyhal_handle_usb_ep_xfer_event(void) {
c0d00f18:	b580      	push	{r7, lr}
  uint8_t epnum;

  epnum = G_io_seproxyhal_spi_buffer[3] & 0x7F;
c0d00f1a:	4815      	ldr	r0, [pc, #84]	; (c0d00f70 <io_seproxyhal_handle_usb_ep_xfer_event+0x58>)
c0d00f1c:	78c2      	ldrb	r2, [r0, #3]
c0d00f1e:	217f      	movs	r1, #127	; 0x7f
c0d00f20:	4011      	ands	r1, r2

  switch(G_io_seproxyhal_spi_buffer[4]) {
c0d00f22:	7902      	ldrb	r2, [r0, #4]
c0d00f24:	2a04      	cmp	r2, #4
c0d00f26:	d014      	beq.n	c0d00f52 <io_seproxyhal_handle_usb_ep_xfer_event+0x3a>
c0d00f28:	2a02      	cmp	r2, #2
c0d00f2a:	d006      	beq.n	c0d00f3a <io_seproxyhal_handle_usb_ep_xfer_event+0x22>
c0d00f2c:	2a01      	cmp	r2, #1
c0d00f2e:	d11d      	bne.n	c0d00f6c <io_seproxyhal_handle_usb_ep_xfer_event+0x54>
    /* This event is received when a new SETUP token had been received on a control endpoint */
    case SEPROXYHAL_TAG_USB_EP_XFER_SETUP:
      // assume length of setup packet, and that it is on endpoint 0
      USBD_LL_SetupStage(&USBD_Device, &G_io_seproxyhal_spi_buffer[6]);
c0d00f30:	1d81      	adds	r1, r0, #6
c0d00f32:	4811      	ldr	r0, [pc, #68]	; (c0d00f78 <io_seproxyhal_handle_usb_ep_xfer_event+0x60>)
c0d00f34:	f001 ffbe 	bl	c0d02eb4 <USBD_LL_SetupStage>
        // prepare reception
        USBD_LL_DataOutStage(&USBD_Device, epnum, &G_io_seproxyhal_spi_buffer[6]);
      }
      break;
  }
}
c0d00f38:	bd80      	pop	{r7, pc}
      if (epnum < IO_USB_MAX_ENDPOINTS) {
c0d00f3a:	2905      	cmp	r1, #5
c0d00f3c:	d816      	bhi.n	c0d00f6c <io_seproxyhal_handle_usb_ep_xfer_event+0x54>
        G_io_app.usb_ep_timeouts[epnum].timeout = 0;
c0d00f3e:	004a      	lsls	r2, r1, #1
c0d00f40:	4b0c      	ldr	r3, [pc, #48]	; (c0d00f74 <io_seproxyhal_handle_usb_ep_xfer_event+0x5c>)
c0d00f42:	189a      	adds	r2, r3, r2
c0d00f44:	2300      	movs	r3, #0
c0d00f46:	8253      	strh	r3, [r2, #18]
        USBD_LL_DataInStage(&USBD_Device, epnum, &G_io_seproxyhal_spi_buffer[6]);
c0d00f48:	1d82      	adds	r2, r0, #6
c0d00f4a:	480b      	ldr	r0, [pc, #44]	; (c0d00f78 <io_seproxyhal_handle_usb_ep_xfer_event+0x60>)
c0d00f4c:	f002 f836 	bl	c0d02fbc <USBD_LL_DataInStage>
}
c0d00f50:	bd80      	pop	{r7, pc}
      if (epnum < IO_USB_MAX_ENDPOINTS) {
c0d00f52:	2905      	cmp	r1, #5
c0d00f54:	d80a      	bhi.n	c0d00f6c <io_seproxyhal_handle_usb_ep_xfer_event+0x54>
        G_io_app.usb_ep_xfer_len[epnum] = MIN(G_io_seproxyhal_spi_buffer[5], IO_SEPROXYHAL_BUFFER_SIZE_B - 6);
c0d00f56:	4a07      	ldr	r2, [pc, #28]	; (c0d00f74 <io_seproxyhal_handle_usb_ep_xfer_event+0x5c>)
c0d00f58:	1852      	adds	r2, r2, r1
c0d00f5a:	7943      	ldrb	r3, [r0, #5]
c0d00f5c:	2b7a      	cmp	r3, #122	; 0x7a
c0d00f5e:	d300      	bcc.n	c0d00f62 <io_seproxyhal_handle_usb_ep_xfer_event+0x4a>
c0d00f60:	237a      	movs	r3, #122	; 0x7a
c0d00f62:	7313      	strb	r3, [r2, #12]
        USBD_LL_DataOutStage(&USBD_Device, epnum, &G_io_seproxyhal_spi_buffer[6]);
c0d00f64:	1d82      	adds	r2, r0, #6
c0d00f66:	4804      	ldr	r0, [pc, #16]	; (c0d00f78 <io_seproxyhal_handle_usb_ep_xfer_event+0x60>)
c0d00f68:	f001 ffd2 	bl	c0d02f10 <USBD_LL_DataOutStage>
}
c0d00f6c:	bd80      	pop	{r7, pc}
c0d00f6e:	46c0      	nop			; (mov r8, r8)
c0d00f70:	200008ac 	.word	0x200008ac
c0d00f74:	20000a30 	.word	0x20000a30
c0d00f78:	20000cb8 	.word	0x20000cb8

c0d00f7c <io_usb_send_ep>:
#endif // HAVE_L4_USBLIB

// TODO, refactor this using the USB DataIn event like for the U2F tunnel
// TODO add a blocking parameter, for HID KBD sending, or use a USB busy flag per channel to know if
// the transfer has been processed or not. and move on to the next transfer on the same endpoint
void io_usb_send_ep(unsigned int ep, unsigned char* buffer, unsigned short length, unsigned int timeout) {
c0d00f7c:	b570      	push	{r4, r5, r6, lr}
  if (timeout) {
    timeout++;
  }

  // won't send if overflowing seproxyhal buffer format
  if (length > 255) {
c0d00f7e:	2aff      	cmp	r2, #255	; 0xff
c0d00f80:	d81d      	bhi.n	c0d00fbe <io_usb_send_ep+0x42>
c0d00f82:	4615      	mov	r5, r2
c0d00f84:	460e      	mov	r6, r1
c0d00f86:	4604      	mov	r4, r0
    return;
  }

  G_io_seproxyhal_spi_buffer[0] = SEPROXYHAL_TAG_USB_EP_PREPARE;
c0d00f88:	480d      	ldr	r0, [pc, #52]	; (c0d00fc0 <io_usb_send_ep+0x44>)
  G_io_seproxyhal_spi_buffer[1] = (3+length)>>8;
  G_io_seproxyhal_spi_buffer[2] = (3+length);
  G_io_seproxyhal_spi_buffer[3] = ep|0x80;
  G_io_seproxyhal_spi_buffer[4] = SEPROXYHAL_TAG_USB_EP_PREPARE_DIR_IN;
  G_io_seproxyhal_spi_buffer[5] = length;
c0d00f8a:	7142      	strb	r2, [r0, #5]
c0d00f8c:	2120      	movs	r1, #32
  G_io_seproxyhal_spi_buffer[4] = SEPROXYHAL_TAG_USB_EP_PREPARE_DIR_IN;
c0d00f8e:	7101      	strb	r1, [r0, #4]
c0d00f90:	2150      	movs	r1, #80	; 0x50
  G_io_seproxyhal_spi_buffer[0] = SEPROXYHAL_TAG_USB_EP_PREPARE;
c0d00f92:	7001      	strb	r1, [r0, #0]
c0d00f94:	2180      	movs	r1, #128	; 0x80
  G_io_seproxyhal_spi_buffer[3] = ep|0x80;
c0d00f96:	4321      	orrs	r1, r4
c0d00f98:	70c1      	strb	r1, [r0, #3]
  G_io_seproxyhal_spi_buffer[1] = (3+length)>>8;
c0d00f9a:	1cd1      	adds	r1, r2, #3
  G_io_seproxyhal_spi_buffer[2] = (3+length);
c0d00f9c:	7081      	strb	r1, [r0, #2]
  G_io_seproxyhal_spi_buffer[1] = (3+length)>>8;
c0d00f9e:	0a09      	lsrs	r1, r1, #8
c0d00fa0:	7041      	strb	r1, [r0, #1]
c0d00fa2:	2106      	movs	r1, #6
  io_seproxyhal_spi_send(G_io_seproxyhal_spi_buffer, 6);
c0d00fa4:	f001 fc8e 	bl	c0d028c4 <io_seph_send>
  io_seproxyhal_spi_send(buffer, length);
c0d00fa8:	4630      	mov	r0, r6
c0d00faa:	4629      	mov	r1, r5
c0d00fac:	f001 fc8a 	bl	c0d028c4 <io_seph_send>
  // setup timeout of the endpoint
  G_io_app.usb_ep_timeouts[ep&0x7F].timeout = IO_RAPDU_TRANSMIT_TIMEOUT_MS;
c0d00fb0:	0660      	lsls	r0, r4, #25
c0d00fb2:	0e00      	lsrs	r0, r0, #24
c0d00fb4:	4903      	ldr	r1, [pc, #12]	; (c0d00fc4 <io_usb_send_ep+0x48>)
c0d00fb6:	1808      	adds	r0, r1, r0
c0d00fb8:	217d      	movs	r1, #125	; 0x7d
c0d00fba:	0109      	lsls	r1, r1, #4
c0d00fbc:	8241      	strh	r1, [r0, #18]
}
c0d00fbe:	bd70      	pop	{r4, r5, r6, pc}
c0d00fc0:	200008ac 	.word	0x200008ac
c0d00fc4:	20000a30 	.word	0x20000a30

c0d00fc8 <io_usb_send_apdu_data>:

void io_usb_send_apdu_data(unsigned char* buffer, unsigned short length) {
c0d00fc8:	b580      	push	{r7, lr}
c0d00fca:	460a      	mov	r2, r1
c0d00fcc:	4601      	mov	r1, r0
c0d00fce:	2082      	movs	r0, #130	; 0x82
c0d00fd0:	2314      	movs	r3, #20
  // wait for 20 events before hanging up and timeout (~2 seconds of timeout)
  io_usb_send_ep(0x82, buffer, length, 20);
c0d00fd2:	f7ff ffd3 	bl	c0d00f7c <io_usb_send_ep>
}
c0d00fd6:	bd80      	pop	{r7, pc}

c0d00fd8 <io_usb_send_apdu_data_ep0x83>:

#ifdef HAVE_WEBUSB
void io_usb_send_apdu_data_ep0x83(unsigned char* buffer, unsigned short length) {
c0d00fd8:	b580      	push	{r7, lr}
c0d00fda:	460a      	mov	r2, r1
c0d00fdc:	4601      	mov	r1, r0
c0d00fde:	2083      	movs	r0, #131	; 0x83
c0d00fe0:	2314      	movs	r3, #20
  // wait for 20 events before hanging up and timeout (~2 seconds of timeout)
  io_usb_send_ep(0x83, buffer, length, 20);
c0d00fe2:	f7ff ffcb 	bl	c0d00f7c <io_usb_send_ep>
}
c0d00fe6:	bd80      	pop	{r7, pc}

c0d00fe8 <io_seproxyhal_handle_event>:
    // copy apdu to apdu buffer
    memcpy(G_io_apdu_buffer, G_io_seproxyhal_spi_buffer+3, G_io_app.apdu_length);
  }
}

unsigned int io_seproxyhal_handle_event(void) {
c0d00fe8:	b510      	push	{r4, lr}
  return (buf[off] << 8) | buf[off + 1];
c0d00fea:	4826      	ldr	r0, [pc, #152]	; (c0d01084 <io_seproxyhal_handle_event+0x9c>)
c0d00fec:	7881      	ldrb	r1, [r0, #2]
c0d00fee:	7842      	ldrb	r2, [r0, #1]
c0d00ff0:	0212      	lsls	r2, r2, #8
c0d00ff2:	1852      	adds	r2, r2, r1
#if defined(HAVE_IO_USB) || defined(HAVE_BLE)
  unsigned int rx_len = U2BE(G_io_seproxyhal_spi_buffer, 1);
#endif

  switch(G_io_seproxyhal_spi_buffer[0]) {
c0d00ff4:	7801      	ldrb	r1, [r0, #0]
c0d00ff6:	290f      	cmp	r1, #15
c0d00ff8:	dc08      	bgt.n	c0d0100c <io_seproxyhal_handle_event+0x24>
c0d00ffa:	290e      	cmp	r1, #14
c0d00ffc:	d01c      	beq.n	c0d01038 <io_seproxyhal_handle_event+0x50>
c0d00ffe:	290f      	cmp	r1, #15
c0d01000:	d12d      	bne.n	c0d0105e <io_seproxyhal_handle_event+0x76>
  #ifdef HAVE_IO_USB
    case SEPROXYHAL_TAG_USB_EVENT:
      if (rx_len != 1) {
c0d01002:	2a01      	cmp	r2, #1
c0d01004:	d132      	bne.n	c0d0106c <io_seproxyhal_handle_event+0x84>
        return 0;
      }
      io_seproxyhal_handle_usb_event();
c0d01006:	f7ff ff47 	bl	c0d00e98 <io_seproxyhal_handle_usb_event>
c0d0100a:	e033      	b.n	c0d01074 <io_seproxyhal_handle_event+0x8c>
  switch(G_io_seproxyhal_spi_buffer[0]) {
c0d0100c:	2910      	cmp	r1, #16
c0d0100e:	d02b      	beq.n	c0d01068 <io_seproxyhal_handle_event+0x80>
c0d01010:	2916      	cmp	r1, #22
c0d01012:	d124      	bne.n	c0d0105e <io_seproxyhal_handle_event+0x76>
  if (G_io_app.apdu_state == APDU_IDLE) {
c0d01014:	491c      	ldr	r1, [pc, #112]	; (c0d01088 <io_seproxyhal_handle_event+0xa0>)
c0d01016:	780b      	ldrb	r3, [r1, #0]
c0d01018:	2401      	movs	r4, #1
c0d0101a:	2b00      	cmp	r3, #0
c0d0101c:	d12b      	bne.n	c0d01076 <io_seproxyhal_handle_event+0x8e>
c0d0101e:	230a      	movs	r3, #10
    G_io_app.apdu_state = APDU_RAW; // for next call to io_exchange
c0d01020:	700b      	strb	r3, [r1, #0]
c0d01022:	2306      	movs	r3, #6
    G_io_app.apdu_media = IO_APDU_MEDIA_RAW; // for application code
c0d01024:	718b      	strb	r3, [r1, #6]
    G_io_app.apdu_length = MIN(size, max);
c0d01026:	2a7d      	cmp	r2, #125	; 0x7d
c0d01028:	d300      	bcc.n	c0d0102c <io_seproxyhal_handle_event+0x44>
c0d0102a:	227d      	movs	r2, #125	; 0x7d
c0d0102c:	804a      	strh	r2, [r1, #2]
    memcpy(G_io_apdu_buffer, G_io_seproxyhal_spi_buffer+3, G_io_app.apdu_length);
c0d0102e:	1cc1      	adds	r1, r0, #3
c0d01030:	4816      	ldr	r0, [pc, #88]	; (c0d0108c <io_seproxyhal_handle_event+0xa4>)
c0d01032:	f003 fddf 	bl	c0d04bf4 <__aeabi_memcpy>
c0d01036:	e01e      	b.n	c0d01076 <io_seproxyhal_handle_event+0x8e>
      return 1;

      // ask the user if not processed here
    case SEPROXYHAL_TAG_TICKER_EVENT:
      // process ticker events to timeout the IO transfers, and forward to the user io_event function too
      G_io_app.ms += 100; // value is by default, don't change the ticker configuration
c0d01038:	4813      	ldr	r0, [pc, #76]	; (c0d01088 <io_seproxyhal_handle_event+0xa0>)
c0d0103a:	6881      	ldr	r1, [r0, #8]
c0d0103c:	3164      	adds	r1, #100	; 0x64
c0d0103e:	6081      	str	r1, [r0, #8]
c0d01040:	211c      	movs	r1, #28
#ifdef HAVE_IO_USB
      {
        unsigned int i = IO_USB_MAX_ENDPOINTS;
        while(i--) {
          if (G_io_app.usb_ep_timeouts[i].timeout) {
c0d01042:	5a42      	ldrh	r2, [r0, r1]
c0d01044:	2a00      	cmp	r2, #0
c0d01046:	d007      	beq.n	c0d01058 <io_seproxyhal_handle_event+0x70>
            G_io_app.usb_ep_timeouts[i].timeout-=MIN(G_io_app.usb_ep_timeouts[i].timeout, 100);
c0d01048:	2a64      	cmp	r2, #100	; 0x64
c0d0104a:	4613      	mov	r3, r2
c0d0104c:	d800      	bhi.n	c0d01050 <io_seproxyhal_handle_event+0x68>
c0d0104e:	2364      	movs	r3, #100	; 0x64
c0d01050:	3b64      	subs	r3, #100	; 0x64
c0d01052:	5243      	strh	r3, [r0, r1]
            if (!G_io_app.usb_ep_timeouts[i].timeout) {
c0d01054:	2a64      	cmp	r2, #100	; 0x64
c0d01056:	d910      	bls.n	c0d0107a <io_seproxyhal_handle_event+0x92>
        while(i--) {
c0d01058:	1e89      	subs	r1, r1, #2
c0d0105a:	2910      	cmp	r1, #16
c0d0105c:	d1f1      	bne.n	c0d01042 <io_seproxyhal_handle_event+0x5a>
c0d0105e:	2002      	movs	r0, #2
      }
#endif // HAVE_BLE_APDU
      __attribute__((fallthrough));
      // no break is intentional
    default:
      return io_event(CHANNEL_SPI);
c0d01060:	f7ff fa78 	bl	c0d00554 <io_event>
c0d01064:	4604      	mov	r4, r0
c0d01066:	e006      	b.n	c0d01076 <io_seproxyhal_handle_event+0x8e>
      if (rx_len < 3) {
c0d01068:	2a03      	cmp	r2, #3
c0d0106a:	d201      	bcs.n	c0d01070 <io_seproxyhal_handle_event+0x88>
c0d0106c:	2400      	movs	r4, #0
c0d0106e:	e002      	b.n	c0d01076 <io_seproxyhal_handle_event+0x8e>
      io_seproxyhal_handle_usb_ep_xfer_event();
c0d01070:	f7ff ff52 	bl	c0d00f18 <io_seproxyhal_handle_usb_ep_xfer_event>
c0d01074:	2401      	movs	r4, #1
  }
  // defaultly return as not processed
  return 0;
}
c0d01076:	4620      	mov	r0, r4
c0d01078:	bd10      	pop	{r4, pc}
c0d0107a:	2100      	movs	r1, #0
              G_io_app.apdu_state = APDU_IDLE;
c0d0107c:	7001      	strb	r1, [r0, #0]
c0d0107e:	2005      	movs	r0, #5
              THROW(EXCEPTION_IO_RESET);
c0d01080:	f7ff fef2 	bl	c0d00e68 <os_longjmp>
c0d01084:	200008ac 	.word	0x200008ac
c0d01088:	20000a30 	.word	0x20000a30
c0d0108c:	2000092c 	.word	0x2000092c

c0d01090 <io_seproxyhal_init>:
  1,
  SEPROXYHAL_TAG_MCU_TYPE_PROTECT,
};
#endif // (!defined(HAVE_BOLOS) && defined(HAVE_MCU_PROTECT))

void io_seproxyhal_init(void) {
c0d01090:	b580      	push	{r7, lr}
// get API level
SYSCALL unsigned int get_api_level(void);

#ifndef HAVE_BOLOS
static inline void check_api_level(unsigned int apiLevel) {
  if (apiLevel < get_api_level()) {
c0d01092:	f001 fb75 	bl	c0d02780 <get_api_level>
c0d01096:	280d      	cmp	r0, #13
c0d01098:	d20a      	bcs.n	c0d010b0 <io_seproxyhal_init+0x20>
  memset(&G_io_app, 0, sizeof(G_io_app));
#ifdef HAVE_BLE
  G_io_app.plane_mode = plane;
#endif // HAVE_BLE

  G_io_app.apdu_state = APDU_IDLE;
c0d0109a:	4807      	ldr	r0, [pc, #28]	; (c0d010b8 <io_seproxyhal_init+0x28>)
c0d0109c:	2120      	movs	r1, #32
c0d0109e:	f003 fda3 	bl	c0d04be8 <__aeabi_memclr>
  #ifdef DEBUG_APDU
  debug_apdus_offset = 0;
  #endif // DEBUG_APDU

  #ifdef HAVE_USB_APDU
  io_usb_hid_init();
c0d010a2:	f000 fb15 	bl	c0d016d0 <io_usb_hid_init>
#endif // TARGET_BLUE
}

void io_seproxyhal_init_button(void) {
  // no button push so far
  G_ux_os.button_mask = 0;
c0d010a6:	4805      	ldr	r0, [pc, #20]	; (c0d010bc <io_seproxyhal_init+0x2c>)
c0d010a8:	2100      	movs	r1, #0
c0d010aa:	6001      	str	r1, [r0, #0]
  G_ux_os.button_same_mask_counter = 0;
c0d010ac:	6041      	str	r1, [r0, #4]
}
c0d010ae:	bd80      	pop	{r7, pc}
c0d010b0:	20ff      	movs	r0, #255	; 0xff
    os_sched_exit(-1);
c0d010b2:	f001 fbfb 	bl	c0d028ac <os_sched_exit>
c0d010b6:	46c0      	nop			; (mov r8, r8)
c0d010b8:	20000a30 	.word	0x20000a30
c0d010bc:	20000a50 	.word	0x20000a50

c0d010c0 <io_seproxyhal_init_ux>:
}
c0d010c0:	4770      	bx	lr
	...

c0d010c4 <io_seproxyhal_init_button>:
  G_ux_os.button_mask = 0;
c0d010c4:	4802      	ldr	r0, [pc, #8]	; (c0d010d0 <io_seproxyhal_init_button+0xc>)
c0d010c6:	2100      	movs	r1, #0
c0d010c8:	6001      	str	r1, [r0, #0]
  G_ux_os.button_same_mask_counter = 0;
c0d010ca:	6041      	str	r1, [r0, #4]
}
c0d010cc:	4770      	bx	lr
c0d010ce:	46c0      	nop			; (mov r8, r8)
c0d010d0:	20000a50 	.word	0x20000a50

c0d010d4 <io_seproxyhal_display_icon>:
  // remaining length of bitmap bits to be displayed
  return len;
}
#endif // SEPROXYHAL_TAG_SCREEN_DISPLAY_RAW_STATUS

void io_seproxyhal_display_icon(bagl_component_t* icon_component, bagl_icon_details_t* icon_det) {
c0d010d4:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d010d6:	b087      	sub	sp, #28
c0d010d8:	4605      	mov	r5, r0
  bagl_component_t icon_component_mod;
  const bagl_icon_details_t* icon_details = (bagl_icon_details_t*)PIC(icon_det);
c0d010da:	4608      	mov	r0, r1
c0d010dc:	f000 ff2e 	bl	c0d01f3c <pic>

  if (icon_details && icon_details->bitmap) {
c0d010e0:	2800      	cmp	r0, #0
c0d010e2:	d043      	beq.n	c0d0116c <io_seproxyhal_display_icon+0x98>
c0d010e4:	4604      	mov	r4, r0
c0d010e6:	6900      	ldr	r0, [r0, #16]
c0d010e8:	2800      	cmp	r0, #0
c0d010ea:	d03f      	beq.n	c0d0116c <io_seproxyhal_display_icon+0x98>
    // ensure not being out of bounds in the icon component agianst the declared icon real size
    memcpy(&icon_component_mod, (void *)PIC(icon_component), sizeof(bagl_component_t));
c0d010ec:	4628      	mov	r0, r5
c0d010ee:	f000 ff25 	bl	c0d01f3c <pic>
c0d010f2:	4601      	mov	r1, r0
c0d010f4:	466d      	mov	r5, sp
c0d010f6:	221c      	movs	r2, #28
c0d010f8:	4628      	mov	r0, r5
c0d010fa:	f003 fd7b 	bl	c0d04bf4 <__aeabi_memcpy>
    icon_component_mod.width = icon_details->width;
c0d010fe:	6826      	ldr	r6, [r4, #0]
c0d01100:	80ee      	strh	r6, [r5, #6]
    icon_component_mod.height = icon_details->height;
c0d01102:	6867      	ldr	r7, [r4, #4]
c0d01104:	812f      	strh	r7, [r5, #8]
#else // !SEPROXYHAL_TAG_SCREEN_DISPLAY_RAW_STATUS
#ifdef HAVE_SE_SCREEN
    bagl_draw_glyph(&icon_component_mod, icon_details);
#endif // HAVE_SE_SCREEN
#if !defined(HAVE_SE_SCREEN) || (defined(HAVE_SE_SCREEN) && defined(HAVE_PRINTF))
    if (io_seproxyhal_spi_is_status_sent()) {
c0d01106:	f001 fbe9 	bl	c0d028dc <io_seph_is_status_sent>
c0d0110a:	2800      	cmp	r0, #0
c0d0110c:	d12e      	bne.n	c0d0116c <io_seproxyhal_display_icon+0x98>
c0d0110e:	b2b9      	uxth	r1, r7
c0d01110:	b2b2      	uxth	r2, r6
    unsigned int w = ((icon_component->width*icon_component->height*icon_details->bpp)/8)+((icon_component->width*icon_component->height*icon_details->bpp)%8?1:0);
    unsigned short length = sizeof(bagl_component_t)
                            +1 /* bpp */
                            +h /* color index */
                            +w; /* image bitmap size */
    G_io_seproxyhal_spi_buffer[0] = SEPROXYHAL_TAG_SCREEN_DISPLAY_STATUS;
c0d01112:	4d17      	ldr	r5, [pc, #92]	; (c0d01170 <io_seproxyhal_display_icon+0x9c>)
c0d01114:	2065      	movs	r0, #101	; 0x65
c0d01116:	7028      	strb	r0, [r5, #0]
    unsigned int h = (1<<(icon_details->bpp))*sizeof(unsigned int);
c0d01118:	68a0      	ldr	r0, [r4, #8]
    unsigned int w = ((icon_component->width*icon_component->height*icon_details->bpp)/8)+((icon_component->width*icon_component->height*icon_details->bpp)%8?1:0);
c0d0111a:	4342      	muls	r2, r0
c0d0111c:	434a      	muls	r2, r1
c0d0111e:	0751      	lsls	r1, r2, #29
c0d01120:	08d6      	lsrs	r6, r2, #3
c0d01122:	2900      	cmp	r1, #0
c0d01124:	d000      	beq.n	c0d01128 <io_seproxyhal_display_icon+0x54>
c0d01126:	1c76      	adds	r6, r6, #1
c0d01128:	2704      	movs	r7, #4
    unsigned int h = (1<<(icon_details->bpp))*sizeof(unsigned int);
c0d0112a:	4087      	lsls	r7, r0
                            +h /* color index */
c0d0112c:	19b8      	adds	r0, r7, r6
                            +w; /* image bitmap size */
c0d0112e:	301d      	adds	r0, #29
#if defined(HAVE_SE_SCREEN) && defined(HAVE_PRINTF)
    G_io_seproxyhal_spi_buffer[0] = SEPROXYHAL_TAG_DBG_SCREEN_DISPLAY_STATUS;
#endif // HAVE_SE_SCREEN && HAVE_PRINTF
    G_io_seproxyhal_spi_buffer[1] = length>>8;
    G_io_seproxyhal_spi_buffer[2] = length;
c0d01130:	70a8      	strb	r0, [r5, #2]
    G_io_seproxyhal_spi_buffer[1] = length>>8;
c0d01132:	0a00      	lsrs	r0, r0, #8
c0d01134:	7068      	strb	r0, [r5, #1]
c0d01136:	2103      	movs	r1, #3
    io_seproxyhal_spi_send(G_io_seproxyhal_spi_buffer, 3);
c0d01138:	4628      	mov	r0, r5
c0d0113a:	f001 fbc3 	bl	c0d028c4 <io_seph_send>
c0d0113e:	4668      	mov	r0, sp
c0d01140:	211c      	movs	r1, #28
    io_seproxyhal_spi_send((unsigned char*)icon_component, sizeof(bagl_component_t));
c0d01142:	f001 fbbf 	bl	c0d028c4 <io_seph_send>
    G_io_seproxyhal_spi_buffer[0] = icon_details->bpp;
c0d01146:	68a0      	ldr	r0, [r4, #8]
c0d01148:	7028      	strb	r0, [r5, #0]
c0d0114a:	2101      	movs	r1, #1
    io_seproxyhal_spi_send(G_io_seproxyhal_spi_buffer, 1);
c0d0114c:	4628      	mov	r0, r5
c0d0114e:	f001 fbb9 	bl	c0d028c4 <io_seph_send>
    io_seproxyhal_spi_send((unsigned char*)PIC(icon_details->colors), h);
c0d01152:	68e0      	ldr	r0, [r4, #12]
c0d01154:	f000 fef2 	bl	c0d01f3c <pic>
c0d01158:	b2b9      	uxth	r1, r7
c0d0115a:	f001 fbb3 	bl	c0d028c4 <io_seph_send>
    io_seproxyhal_spi_send((unsigned char*)PIC(icon_details->bitmap), w);
c0d0115e:	b2b5      	uxth	r5, r6
c0d01160:	6920      	ldr	r0, [r4, #16]
c0d01162:	f000 feeb 	bl	c0d01f3c <pic>
c0d01166:	4629      	mov	r1, r5
c0d01168:	f001 fbac 	bl	c0d028c4 <io_seph_send>
#endif // !HAVE_SE_SCREEN || (HAVE_SE_SCREEN && HAVE_PRINTF)
#endif // !SEPROXYHAL_TAG_SCREEN_DISPLAY_RAW_STATUS
  }
}
c0d0116c:	b007      	add	sp, #28
c0d0116e:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d01170:	200008ac 	.word	0x200008ac

c0d01174 <io_seproxyhal_display_default>:

void io_seproxyhal_display_default(const bagl_element_t* element) {
c0d01174:	b570      	push	{r4, r5, r6, lr}

  const bagl_element_t* el = (const bagl_element_t*) PIC(element);
c0d01176:	f000 fee1 	bl	c0d01f3c <pic>
c0d0117a:	4604      	mov	r4, r0
  const char* txt = (const char*)PIC(el->text);
c0d0117c:	69c0      	ldr	r0, [r0, #28]
c0d0117e:	f000 fedd 	bl	c0d01f3c <pic>
c0d01182:	4605      	mov	r5, r0
  // process automagically address from rom and from ram
  unsigned int type = (el->component.type & ~(BAGL_FLAG_TOUCHABLE));
c0d01184:	7821      	ldrb	r1, [r4, #0]
c0d01186:	207f      	movs	r0, #127	; 0x7f
c0d01188:	4008      	ands	r0, r1

  if (type != BAGL_NONE) {
c0d0118a:	d00a      	beq.n	c0d011a2 <io_seproxyhal_display_default+0x2e>
    if (txt != NULL) {
c0d0118c:	2d00      	cmp	r5, #0
c0d0118e:	d009      	beq.n	c0d011a4 <io_seproxyhal_display_default+0x30>
      // consider an icon details descriptor is pointed by the context
      if (type == BAGL_ICON && el->component.icon_id == 0) {
c0d01190:	2805      	cmp	r0, #5
c0d01192:	d102      	bne.n	c0d0119a <io_seproxyhal_display_default+0x26>
c0d01194:	7ea0      	ldrb	r0, [r4, #26]
c0d01196:	2800      	cmp	r0, #0
c0d01198:	d02d      	beq.n	c0d011f6 <io_seproxyhal_display_default+0x82>
      else {
#ifdef HAVE_SE_SCREEN
        bagl_draw_with_context(&el->component, txt, strlen(txt), BAGL_ENCODING_LATIN1);
#endif // HAVE_SE_SCREEN
#if !defined(HAVE_SE_SCREEN) || (defined(HAVE_SE_SCREEN) && defined(HAVE_PRINTF))
        if (io_seproxyhal_spi_is_status_sent()) {
c0d0119a:	f001 fb9f 	bl	c0d028dc <io_seph_is_status_sent>
c0d0119e:	2800      	cmp	r0, #0
c0d011a0:	d011      	beq.n	c0d011c6 <io_seproxyhal_display_default+0x52>
      io_seproxyhal_spi_send(G_io_seproxyhal_spi_buffer, 3);
      io_seproxyhal_spi_send((unsigned char*)&el->component, sizeof(bagl_component_t));
#endif // !HAVE_SE_SCREEN || (HAVE_SE_SCREEN && HAVE_PRINTF)
    }
  }
}
c0d011a2:	bd70      	pop	{r4, r5, r6, pc}
      if (io_seproxyhal_spi_is_status_sent()) {
c0d011a4:	f001 fb9a 	bl	c0d028dc <io_seph_is_status_sent>
c0d011a8:	2800      	cmp	r0, #0
c0d011aa:	d1fa      	bne.n	c0d011a2 <io_seproxyhal_display_default+0x2e>
      G_io_seproxyhal_spi_buffer[0] = SEPROXYHAL_TAG_SCREEN_DISPLAY_STATUS;
c0d011ac:	4814      	ldr	r0, [pc, #80]	; (c0d01200 <io_seproxyhal_display_default+0x8c>)
c0d011ae:	251c      	movs	r5, #28
      G_io_seproxyhal_spi_buffer[2] = length;
c0d011b0:	7085      	strb	r5, [r0, #2]
c0d011b2:	2100      	movs	r1, #0
      G_io_seproxyhal_spi_buffer[1] = length>>8;
c0d011b4:	7041      	strb	r1, [r0, #1]
c0d011b6:	2165      	movs	r1, #101	; 0x65
      G_io_seproxyhal_spi_buffer[0] = SEPROXYHAL_TAG_SCREEN_DISPLAY_STATUS;
c0d011b8:	7001      	strb	r1, [r0, #0]
c0d011ba:	2103      	movs	r1, #3
      io_seproxyhal_spi_send(G_io_seproxyhal_spi_buffer, 3);
c0d011bc:	f001 fb82 	bl	c0d028c4 <io_seph_send>
      io_seproxyhal_spi_send((unsigned char*)&el->component, sizeof(bagl_component_t));
c0d011c0:	4620      	mov	r0, r4
c0d011c2:	4629      	mov	r1, r5
c0d011c4:	e014      	b.n	c0d011f0 <io_seproxyhal_display_default+0x7c>
        unsigned short length = sizeof(bagl_component_t)+strlen((const char*)txt);
c0d011c6:	4628      	mov	r0, r5
c0d011c8:	f003 fe3e 	bl	c0d04e48 <strlen>
c0d011cc:	4606      	mov	r6, r0
        G_io_seproxyhal_spi_buffer[0] = SEPROXYHAL_TAG_SCREEN_DISPLAY_STATUS;
c0d011ce:	480c      	ldr	r0, [pc, #48]	; (c0d01200 <io_seproxyhal_display_default+0x8c>)
c0d011d0:	2165      	movs	r1, #101	; 0x65
c0d011d2:	7001      	strb	r1, [r0, #0]
        unsigned short length = sizeof(bagl_component_t)+strlen((const char*)txt);
c0d011d4:	4631      	mov	r1, r6
c0d011d6:	311c      	adds	r1, #28
        G_io_seproxyhal_spi_buffer[2] = length;
c0d011d8:	7081      	strb	r1, [r0, #2]
        G_io_seproxyhal_spi_buffer[1] = length>>8;
c0d011da:	0a09      	lsrs	r1, r1, #8
c0d011dc:	7041      	strb	r1, [r0, #1]
c0d011de:	2103      	movs	r1, #3
        io_seproxyhal_spi_send(G_io_seproxyhal_spi_buffer, 3);
c0d011e0:	f001 fb70 	bl	c0d028c4 <io_seph_send>
c0d011e4:	211c      	movs	r1, #28
        io_seproxyhal_spi_send((unsigned char*)&el->component, sizeof(bagl_component_t));
c0d011e6:	4620      	mov	r0, r4
c0d011e8:	f001 fb6c 	bl	c0d028c4 <io_seph_send>
        io_seproxyhal_spi_send((unsigned char*)txt, length-sizeof(bagl_component_t));
c0d011ec:	b2b1      	uxth	r1, r6
c0d011ee:	4628      	mov	r0, r5
c0d011f0:	f001 fb68 	bl	c0d028c4 <io_seph_send>
}
c0d011f4:	bd70      	pop	{r4, r5, r6, pc}
        io_seproxyhal_display_icon((bagl_component_t*)&el->component, (bagl_icon_details_t*)txt);
c0d011f6:	4620      	mov	r0, r4
c0d011f8:	4629      	mov	r1, r5
c0d011fa:	f7ff ff6b 	bl	c0d010d4 <io_seproxyhal_display_icon>
}
c0d011fe:	bd70      	pop	{r4, r5, r6, pc}
c0d01200:	200008ac 	.word	0x200008ac

c0d01204 <io_seproxyhal_button_push>:

  // compute scrolled text length
  return 2*(textlen - e->component.width)*1000/e->component.icon_id + 2*(e->component.stroke & ~(0x80))*100;
}

void io_seproxyhal_button_push(button_push_callback_t button_callback, unsigned int new_button_mask) {
c0d01204:	b570      	push	{r4, r5, r6, lr}
  if (button_callback) {
c0d01206:	2800      	cmp	r0, #0
c0d01208:	d025      	beq.n	c0d01256 <io_seproxyhal_button_push+0x52>
c0d0120a:	460b      	mov	r3, r1
c0d0120c:	4602      	mov	r2, r0
    unsigned int button_mask;
    unsigned int button_same_mask_counter;
    // enable speeded up long push
    if (new_button_mask == G_ux_os.button_mask) {
c0d0120e:	4c12      	ldr	r4, [pc, #72]	; (c0d01258 <io_seproxyhal_button_push+0x54>)
c0d01210:	cc03      	ldmia	r4!, {r0, r1}
c0d01212:	3c08      	subs	r4, #8
c0d01214:	4298      	cmp	r0, r3
c0d01216:	d101      	bne.n	c0d0121c <io_seproxyhal_button_push+0x18>
      // each 100ms ~
      G_ux_os.button_same_mask_counter++;
c0d01218:	1c49      	adds	r1, r1, #1
c0d0121a:	6061      	str	r1, [r4, #4]
    }

    // when new_button_mask is 0 and

    // append the button mask
    button_mask = G_ux_os.button_mask | new_button_mask;
c0d0121c:	4318      	orrs	r0, r3

    // pre reset variable due to os_sched_exit
    button_same_mask_counter = G_ux_os.button_same_mask_counter;

    // reset button mask
    if (new_button_mask == 0) {
c0d0121e:	2b00      	cmp	r3, #0
c0d01220:	d002      	beq.n	c0d01228 <io_seproxyhal_button_push+0x24>

      // notify button released event
      button_mask |= BUTTON_EVT_RELEASED;
    }
    else {
      G_ux_os.button_mask = button_mask;
c0d01222:	6020      	str	r0, [r4, #0]
    }

    // reset counter when button mask changes
    if (new_button_mask != G_ux_os.button_mask) {
c0d01224:	4605      	mov	r5, r0
c0d01226:	e005      	b.n	c0d01234 <io_seproxyhal_button_push+0x30>
c0d01228:	2500      	movs	r5, #0
      G_ux_os.button_mask = 0;
c0d0122a:	6025      	str	r5, [r4, #0]
      G_ux_os.button_same_mask_counter=0;
c0d0122c:	6065      	str	r5, [r4, #4]
c0d0122e:	4e0b      	ldr	r6, [pc, #44]	; (c0d0125c <io_seproxyhal_button_push+0x58>)
      button_mask |= BUTTON_EVT_RELEASED;
c0d01230:	1c76      	adds	r6, r6, #1
c0d01232:	4330      	orrs	r0, r6
    if (new_button_mask != G_ux_os.button_mask) {
c0d01234:	429d      	cmp	r5, r3
c0d01236:	d001      	beq.n	c0d0123c <io_seproxyhal_button_push+0x38>
c0d01238:	2300      	movs	r3, #0
      G_ux_os.button_same_mask_counter=0;
c0d0123a:	6063      	str	r3, [r4, #4]
    }

    if (button_same_mask_counter >= BUTTON_FAST_THRESHOLD_CS) {
c0d0123c:	2908      	cmp	r1, #8
c0d0123e:	d309      	bcc.n	c0d01254 <io_seproxyhal_button_push+0x50>
c0d01240:	4c07      	ldr	r4, [pc, #28]	; (c0d01260 <io_seproxyhal_button_push+0x5c>)
      // fast bit when pressing and timing is right
      if ((button_same_mask_counter%BUTTON_FAST_ACTION_CS) == 0) {
c0d01242:	434c      	muls	r4, r1
c0d01244:	2301      	movs	r3, #1
c0d01246:	4d07      	ldr	r5, [pc, #28]	; (c0d01264 <io_seproxyhal_button_push+0x60>)
c0d01248:	42ac      	cmp	r4, r5
c0d0124a:	d201      	bcs.n	c0d01250 <io_seproxyhal_button_push+0x4c>
c0d0124c:	079c      	lsls	r4, r3, #30
c0d0124e:	4320      	orrs	r0, r4
c0d01250:	07db      	lsls	r3, r3, #31
      }
      */

      // discard the release event after a fastskip has been detected, to avoid strange at release behavior
      // and also to enable user to cancel an operation by starting triggering the fast skip
      button_mask &= ~BUTTON_EVT_RELEASED;
c0d01252:	4398      	bics	r0, r3
    }

    // indicate if button have been released
    button_callback(button_mask, button_same_mask_counter);
c0d01254:	4790      	blx	r2

  }
}
c0d01256:	bd70      	pop	{r4, r5, r6, pc}
c0d01258:	20000a50 	.word	0x20000a50
c0d0125c:	7fffffff 	.word	0x7fffffff
c0d01260:	aaaaaaab 	.word	0xaaaaaaab
c0d01264:	55555556 	.word	0x55555556

c0d01268 <os_io_seproxyhal_get_app_name_and_version>:
#ifdef HAVE_IO_U2F
u2f_service_t G_io_u2f;
#endif // HAVE_IO_U2F

unsigned int os_io_seproxyhal_get_app_name_and_version(void) __attribute__((weak));
unsigned int os_io_seproxyhal_get_app_name_and_version(void) {
c0d01268:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0126a:	b081      	sub	sp, #4
  unsigned int tx_len, len;
  // build the get app name and version reply
  tx_len = 0;
  G_io_apdu_buffer[tx_len++] = 1; // format ID
c0d0126c:	4e0f      	ldr	r6, [pc, #60]	; (c0d012ac <os_io_seproxyhal_get_app_name_and_version+0x44>)
c0d0126e:	2401      	movs	r4, #1
c0d01270:	7034      	strb	r4, [r6, #0]

#ifndef HAVE_BOLOS
  // append app name
  len = os_registry_get_current_app_tag(BOLOS_TAG_APPNAME, G_io_apdu_buffer+tx_len+1, sizeof(G_io_apdu_buffer)-tx_len-1);
c0d01272:	1cb1      	adds	r1, r6, #2
c0d01274:	27ff      	movs	r7, #255	; 0xff
c0d01276:	3702      	adds	r7, #2
c0d01278:	1c7a      	adds	r2, r7, #1
c0d0127a:	4620      	mov	r0, r4
c0d0127c:	f001 fb0a 	bl	c0d02894 <os_registry_get_current_app_tag>
c0d01280:	4605      	mov	r5, r0
  G_io_apdu_buffer[tx_len++] = len;
c0d01282:	7070      	strb	r0, [r6, #1]
  tx_len += len;
  // append app version
  len = os_registry_get_current_app_tag(BOLOS_TAG_APPVERSION, G_io_apdu_buffer+tx_len+1, sizeof(G_io_apdu_buffer)-tx_len-1);
c0d01284:	1a3a      	subs	r2, r7, r0
  tx_len += len;
c0d01286:	1987      	adds	r7, r0, r6
  len = os_registry_get_current_app_tag(BOLOS_TAG_APPVERSION, G_io_apdu_buffer+tx_len+1, sizeof(G_io_apdu_buffer)-tx_len-1);
c0d01288:	1cf9      	adds	r1, r7, #3
c0d0128a:	2002      	movs	r0, #2
c0d0128c:	f001 fb02 	bl	c0d02894 <os_registry_get_current_app_tag>
  G_io_apdu_buffer[tx_len++] = len;
c0d01290:	70b8      	strb	r0, [r7, #2]
c0d01292:	182d      	adds	r5, r5, r0
  tx_len += len;
c0d01294:	19ae      	adds	r6, r5, r6
#endif // HAVE_BOLOS

#if !defined(HAVE_IO_TASK) || !defined(HAVE_BOLOS)
  // to be fixed within io tasks
  // return OS flags to notify of platform's global state (pin lock etc)
  G_io_apdu_buffer[tx_len++] = 1; // flags length
c0d01296:	70f4      	strb	r4, [r6, #3]
  G_io_apdu_buffer[tx_len++] = os_flags();
c0d01298:	f001 faf0 	bl	c0d0287c <os_flags>
c0d0129c:	2100      	movs	r1, #0
#endif // !defined(HAVE_IO_TASK) || !defined(HAVE_BOLOS)

  // status words
  G_io_apdu_buffer[tx_len++] = 0x90;
  G_io_apdu_buffer[tx_len++] = 0x00;
c0d0129e:	71b1      	strb	r1, [r6, #6]
c0d012a0:	2190      	movs	r1, #144	; 0x90
  G_io_apdu_buffer[tx_len++] = 0x90;
c0d012a2:	7171      	strb	r1, [r6, #5]
  G_io_apdu_buffer[tx_len++] = os_flags();
c0d012a4:	7130      	strb	r0, [r6, #4]
  G_io_apdu_buffer[tx_len++] = 0x00;
c0d012a6:	1de8      	adds	r0, r5, #7
  return tx_len;
c0d012a8:	b001      	add	sp, #4
c0d012aa:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d012ac:	2000092c 	.word	0x2000092c

c0d012b0 <io_exchange>:
  return processed;
}

#endif // HAVE_BOLOS_NO_DEFAULT_APDU

unsigned short io_exchange(unsigned char channel, unsigned short tx_len) {
c0d012b0:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d012b2:	b085      	sub	sp, #20
c0d012b4:	4602      	mov	r2, r0
    }
  }
#endif // DEBUG_APDU

reply_apdu:
  switch(channel&~(IO_FLAGS)) {
c0d012b6:	0740      	lsls	r0, r0, #29
c0d012b8:	d007      	beq.n	c0d012ca <io_exchange+0x1a>
c0d012ba:	4616      	mov	r6, r2
      }
    }
    break;

  default:
    return io_exchange_al(channel, tx_len);
c0d012bc:	b2f0      	uxtb	r0, r6
c0d012be:	b289      	uxth	r1, r1
c0d012c0:	f7ff fc2c 	bl	c0d00b1c <io_exchange_al>
  }
}
c0d012c4:	b280      	uxth	r0, r0
c0d012c6:	b005      	add	sp, #20
c0d012c8:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d012ca:	4d8a      	ldr	r5, [pc, #552]	; (c0d014f4 <io_exchange+0x244>)
c0d012cc:	488b      	ldr	r0, [pc, #556]	; (c0d014fc <io_exchange+0x24c>)
c0d012ce:	4478      	add	r0, pc
c0d012d0:	9000      	str	r0, [sp, #0]
c0d012d2:	4c87      	ldr	r4, [pc, #540]	; (c0d014f0 <io_exchange+0x240>)
c0d012d4:	4616      	mov	r6, r2
c0d012d6:	2710      	movs	r7, #16
c0d012d8:	4017      	ands	r7, r2
    if (tx_len && !(channel&IO_ASYNCH_REPLY)) {
c0d012da:	0408      	lsls	r0, r1, #16
c0d012dc:	9604      	str	r6, [sp, #16]
c0d012de:	d073      	beq.n	c0d013c8 <io_exchange+0x118>
c0d012e0:	2f00      	cmp	r7, #0
c0d012e2:	d171      	bne.n	c0d013c8 <io_exchange+0x118>
c0d012e4:	9103      	str	r1, [sp, #12]
c0d012e6:	9202      	str	r2, [sp, #8]
      while (io_seproxyhal_spi_is_status_sent()) {
c0d012e8:	f001 faf8 	bl	c0d028dc <io_seph_is_status_sent>
c0d012ec:	2800      	cmp	r0, #0
c0d012ee:	d008      	beq.n	c0d01302 <io_exchange+0x52>
c0d012f0:	2180      	movs	r1, #128	; 0x80
c0d012f2:	2200      	movs	r2, #0
        io_seproxyhal_spi_recv(G_io_seproxyhal_spi_buffer, sizeof(G_io_seproxyhal_spi_buffer), 0);
c0d012f4:	4620      	mov	r0, r4
c0d012f6:	f001 fafd 	bl	c0d028f4 <io_seph_recv>
c0d012fa:	2001      	movs	r0, #1
        os_io_seph_recv_and_process(1);
c0d012fc:	f000 f908 	bl	c0d01510 <os_io_seph_recv_and_process>
c0d01300:	e7f2      	b.n	c0d012e8 <io_exchange+0x38>
      timeout_ms = G_io_app.ms + IO_RAPDU_TRANSMIT_TIMEOUT_MS;
c0d01302:	68a8      	ldr	r0, [r5, #8]
        switch(G_io_app.apdu_state) {
c0d01304:	7829      	ldrb	r1, [r5, #0]
c0d01306:	2909      	cmp	r1, #9
c0d01308:	dd08      	ble.n	c0d0131c <io_exchange+0x6c>
c0d0130a:	290a      	cmp	r1, #10
c0d0130c:	9a03      	ldr	r2, [sp, #12]
c0d0130e:	d00e      	beq.n	c0d0132e <io_exchange+0x7e>
c0d01310:	9001      	str	r0, [sp, #4]
c0d01312:	290b      	cmp	r1, #11
c0d01314:	d122      	bne.n	c0d0135c <io_exchange+0xac>
c0d01316:	487b      	ldr	r0, [pc, #492]	; (c0d01504 <io_exchange+0x254>)
c0d01318:	4478      	add	r0, pc
c0d0131a:	e004      	b.n	c0d01326 <io_exchange+0x76>
c0d0131c:	9001      	str	r0, [sp, #4]
c0d0131e:	2907      	cmp	r1, #7
c0d01320:	9800      	ldr	r0, [sp, #0]
c0d01322:	9a03      	ldr	r2, [sp, #12]
c0d01324:	d117      	bne.n	c0d01356 <io_exchange+0xa6>
c0d01326:	b291      	uxth	r1, r2
c0d01328:	f000 fa3e 	bl	c0d017a8 <io_usb_hid_send>
c0d0132c:	e01d      	b.n	c0d0136a <io_exchange+0xba>
c0d0132e:	20ff      	movs	r0, #255	; 0xff
c0d01330:	3006      	adds	r0, #6
            if (tx_len > sizeof(G_io_apdu_buffer)) {
c0d01332:	b296      	uxth	r6, r2
c0d01334:	4286      	cmp	r6, r0
c0d01336:	d300      	bcc.n	c0d0133a <io_exchange+0x8a>
c0d01338:	e0d6      	b.n	c0d014e8 <io_exchange+0x238>
            G_io_seproxyhal_spi_buffer[2]  = (tx_len);
c0d0133a:	70a2      	strb	r2, [r4, #2]
c0d0133c:	2053      	movs	r0, #83	; 0x53
            G_io_seproxyhal_spi_buffer[0]  = SEPROXYHAL_TAG_RAPDU;
c0d0133e:	7020      	strb	r0, [r4, #0]
            G_io_seproxyhal_spi_buffer[1]  = (tx_len)>>8;
c0d01340:	0a10      	lsrs	r0, r2, #8
c0d01342:	7060      	strb	r0, [r4, #1]
c0d01344:	2103      	movs	r1, #3
            io_seproxyhal_spi_send(G_io_seproxyhal_spi_buffer, 3);
c0d01346:	4620      	mov	r0, r4
c0d01348:	f001 fabc 	bl	c0d028c4 <io_seph_send>
            io_seproxyhal_spi_send(G_io_apdu_buffer, tx_len);
c0d0134c:	486a      	ldr	r0, [pc, #424]	; (c0d014f8 <io_exchange+0x248>)
c0d0134e:	4631      	mov	r1, r6
c0d01350:	f001 fab8 	bl	c0d028c4 <io_seph_send>
c0d01354:	e027      	b.n	c0d013a6 <io_exchange+0xf6>
        switch(G_io_app.apdu_state) {
c0d01356:	2900      	cmp	r1, #0
c0d01358:	d100      	bne.n	c0d0135c <io_exchange+0xac>
c0d0135a:	e0c2      	b.n	c0d014e2 <io_exchange+0x232>
            if (io_exchange_al(channel, tx_len) == 0) {
c0d0135c:	b2f0      	uxtb	r0, r6
c0d0135e:	b291      	uxth	r1, r2
c0d01360:	f7ff fbdc 	bl	c0d00b1c <io_exchange_al>
c0d01364:	2800      	cmp	r0, #0
c0d01366:	d000      	beq.n	c0d0136a <io_exchange+0xba>
c0d01368:	e0bb      	b.n	c0d014e2 <io_exchange+0x232>
        while (G_io_app.apdu_state != APDU_IDLE) {
c0d0136a:	7828      	ldrb	r0, [r5, #0]
c0d0136c:	2800      	cmp	r0, #0
c0d0136e:	d01a      	beq.n	c0d013a6 <io_exchange+0xf6>
c0d01370:	207d      	movs	r0, #125	; 0x7d
c0d01372:	0100      	lsls	r0, r0, #4
c0d01374:	9901      	ldr	r1, [sp, #4]
c0d01376:	180e      	adds	r6, r1, r0
  io_seproxyhal_spi_send(seph_io_general_status, sizeof(seph_io_general_status));
c0d01378:	4863      	ldr	r0, [pc, #396]	; (c0d01508 <io_exchange+0x258>)
c0d0137a:	4478      	add	r0, pc
c0d0137c:	2105      	movs	r1, #5
c0d0137e:	f001 faa1 	bl	c0d028c4 <io_seph_send>
c0d01382:	2180      	movs	r1, #128	; 0x80
c0d01384:	2200      	movs	r2, #0
            io_seproxyhal_spi_recv(G_io_seproxyhal_spi_buffer, sizeof(G_io_seproxyhal_spi_buffer), 0);
c0d01386:	4620      	mov	r0, r4
c0d01388:	f001 fab4 	bl	c0d028f4 <io_seph_recv>
            if (G_io_app.ms >= timeout_ms) {
c0d0138c:	68a8      	ldr	r0, [r5, #8]
c0d0138e:	42b0      	cmp	r0, r6
c0d01390:	d300      	bcc.n	c0d01394 <io_exchange+0xe4>
c0d01392:	e0a0      	b.n	c0d014d6 <io_exchange+0x226>
            io_seproxyhal_handle_event();
c0d01394:	f7ff fe28 	bl	c0d00fe8 <io_seproxyhal_handle_event>
          } while (io_seproxyhal_spi_is_status_sent());
c0d01398:	f001 faa0 	bl	c0d028dc <io_seph_is_status_sent>
c0d0139c:	2800      	cmp	r0, #0
c0d0139e:	d1f0      	bne.n	c0d01382 <io_exchange+0xd2>
        while (G_io_app.apdu_state != APDU_IDLE) {
c0d013a0:	7828      	ldrb	r0, [r5, #0]
c0d013a2:	2800      	cmp	r0, #0
c0d013a4:	d1e8      	bne.n	c0d01378 <io_exchange+0xc8>
c0d013a6:	2000      	movs	r0, #0
        G_io_app.apdu_media = IO_APDU_MEDIA_NONE;
c0d013a8:	71a8      	strb	r0, [r5, #6]
        G_io_app.apdu_state = APDU_IDLE;
c0d013aa:	7028      	strb	r0, [r5, #0]
        G_io_app.apdu_length = 0;
c0d013ac:	8068      	strh	r0, [r5, #2]
c0d013ae:	9e04      	ldr	r6, [sp, #16]
        if (channel & IO_RETURN_AFTER_TX) {
c0d013b0:	06b1      	lsls	r1, r6, #26
c0d013b2:	d487      	bmi.n	c0d012c4 <io_exchange+0x14>
  io_seproxyhal_spi_send(seph_io_general_status, sizeof(seph_io_general_status));
c0d013b4:	4852      	ldr	r0, [pc, #328]	; (c0d01500 <io_exchange+0x250>)
c0d013b6:	4478      	add	r0, pc
c0d013b8:	2105      	movs	r1, #5
c0d013ba:	f001 fa83 	bl	c0d028c4 <io_seph_send>
      if (channel & IO_RESET_AFTER_REPLIED) {
c0d013be:	b270      	sxtb	r0, r6
c0d013c0:	2800      	cmp	r0, #0
c0d013c2:	9a02      	ldr	r2, [sp, #8]
c0d013c4:	d500      	bpl.n	c0d013c8 <io_exchange+0x118>
c0d013c6:	e089      	b.n	c0d014dc <io_exchange+0x22c>
    if (!(channel&IO_ASYNCH_REPLY)) {
c0d013c8:	2f00      	cmp	r7, #0
c0d013ca:	4f4b      	ldr	r7, [pc, #300]	; (c0d014f8 <io_exchange+0x248>)
c0d013cc:	d104      	bne.n	c0d013d8 <io_exchange+0x128>
      if ((channel & (CHANNEL_APDU|IO_RECEIVE_DATA)) == (CHANNEL_APDU|IO_RECEIVE_DATA)) {
c0d013ce:	0650      	lsls	r0, r2, #25
c0d013d0:	d47e      	bmi.n	c0d014d0 <io_exchange+0x220>
c0d013d2:	2000      	movs	r0, #0
      G_io_app.apdu_media = IO_APDU_MEDIA_NONE;
c0d013d4:	71a8      	strb	r0, [r5, #6]
      G_io_app.apdu_state = APDU_IDLE;
c0d013d6:	7028      	strb	r0, [r5, #0]
c0d013d8:	2000      	movs	r0, #0
c0d013da:	8068      	strh	r0, [r5, #2]
  io_seproxyhal_spi_send(seph_io_general_status, sizeof(seph_io_general_status));
c0d013dc:	484b      	ldr	r0, [pc, #300]	; (c0d0150c <io_exchange+0x25c>)
c0d013de:	4478      	add	r0, pc
c0d013e0:	2105      	movs	r1, #5
c0d013e2:	f001 fa6f 	bl	c0d028c4 <io_seph_send>
c0d013e6:	2180      	movs	r1, #128	; 0x80
c0d013e8:	2600      	movs	r6, #0
      rx_len = io_seproxyhal_spi_recv(G_io_seproxyhal_spi_buffer, sizeof(G_io_seproxyhal_spi_buffer), 0);
c0d013ea:	4620      	mov	r0, r4
c0d013ec:	4632      	mov	r2, r6
c0d013ee:	f001 fa81 	bl	c0d028f4 <io_seph_recv>
      if (rx_len < 3 || rx_len != U2(G_io_seproxyhal_spi_buffer[1],G_io_seproxyhal_spi_buffer[2])+3U) {
c0d013f2:	2803      	cmp	r0, #3
c0d013f4:	d30f      	bcc.n	c0d01416 <io_exchange+0x166>
c0d013f6:	78a1      	ldrb	r1, [r4, #2]
c0d013f8:	7862      	ldrb	r2, [r4, #1]
c0d013fa:	0212      	lsls	r2, r2, #8
c0d013fc:	1851      	adds	r1, r2, r1
c0d013fe:	1cc9      	adds	r1, r1, #3
c0d01400:	4281      	cmp	r1, r0
c0d01402:	d108      	bne.n	c0d01416 <io_exchange+0x166>
      io_seproxyhal_handle_event();
c0d01404:	f7ff fdf0 	bl	c0d00fe8 <io_seproxyhal_handle_event>
      if (G_io_app.apdu_state != APDU_IDLE && G_io_app.apdu_length > 0) {
c0d01408:	7828      	ldrb	r0, [r5, #0]
c0d0140a:	2800      	cmp	r0, #0
c0d0140c:	d0e6      	beq.n	c0d013dc <io_exchange+0x12c>
c0d0140e:	8868      	ldrh	r0, [r5, #2]
c0d01410:	2800      	cmp	r0, #0
c0d01412:	d0e3      	beq.n	c0d013dc <io_exchange+0x12c>
c0d01414:	e001      	b.n	c0d0141a <io_exchange+0x16a>
        G_io_app.apdu_state = APDU_IDLE;
c0d01416:	702e      	strb	r6, [r5, #0]
c0d01418:	e7de      	b.n	c0d013d8 <io_exchange+0x128>
        if (os_perso_isonboarded() == BOLOS_TRUE && os_global_pin_is_validated() != BOLOS_TRUE) {
c0d0141a:	f001 f9e3 	bl	c0d027e4 <os_perso_isonboarded>
c0d0141e:	28aa      	cmp	r0, #170	; 0xaa
c0d01420:	d103      	bne.n	c0d0142a <io_exchange+0x17a>
c0d01422:	f001 fa0f 	bl	c0d02844 <os_global_pin_is_validated>
c0d01426:	28aa      	cmp	r0, #170	; 0xaa
c0d01428:	d114      	bne.n	c0d01454 <io_exchange+0x1a4>
  if (DEFAULT_APDU_CLA == G_io_apdu_buffer[APDU_OFF_CLA]) {
c0d0142a:	7838      	ldrb	r0, [r7, #0]
c0d0142c:	28b0      	cmp	r0, #176	; 0xb0
c0d0142e:	d14d      	bne.n	c0d014cc <io_exchange+0x21c>
    switch (G_io_apdu_buffer[APDU_OFF_INS]) {
c0d01430:	7878      	ldrb	r0, [r7, #1]
c0d01432:	28a7      	cmp	r0, #167	; 0xa7
c0d01434:	d016      	beq.n	c0d01464 <io_exchange+0x1b4>
c0d01436:	2802      	cmp	r0, #2
c0d01438:	d023      	beq.n	c0d01482 <io_exchange+0x1d2>
c0d0143a:	2801      	cmp	r0, #1
c0d0143c:	d146      	bne.n	c0d014cc <io_exchange+0x21c>
        if (!G_io_apdu_buffer[APDU_OFF_P1] && !G_io_apdu_buffer[APDU_OFF_P2]) {
c0d0143e:	78b8      	ldrb	r0, [r7, #2]
c0d01440:	78f9      	ldrb	r1, [r7, #3]
c0d01442:	4301      	orrs	r1, r0
c0d01444:	d142      	bne.n	c0d014cc <io_exchange+0x21c>
c0d01446:	2007      	movs	r0, #7
c0d01448:	9e04      	ldr	r6, [sp, #16]
          *channel &= ~IO_FLAGS;
c0d0144a:	4006      	ands	r6, r0
          *tx_len = os_io_seproxyhal_get_app_name_and_version();
c0d0144c:	f7ff ff0c 	bl	c0d01268 <os_io_seproxyhal_get_app_name_and_version>
c0d01450:	4601      	mov	r1, r0
c0d01452:	e036      	b.n	c0d014c2 <io_exchange+0x212>
c0d01454:	2015      	movs	r0, #21
          G_io_apdu_buffer[(tx_len)++] = (SWO_SEC_PIN_15) & 0xFF;
c0d01456:	7078      	strb	r0, [r7, #1]
c0d01458:	2055      	movs	r0, #85	; 0x55
          G_io_apdu_buffer[(tx_len)++] = (SWO_SEC_PIN_15 >> 8) & 0xFF;
c0d0145a:	7038      	strb	r0, [r7, #0]
c0d0145c:	2007      	movs	r0, #7
c0d0145e:	9e04      	ldr	r6, [sp, #16]
          channel &= ~IO_FLAGS;
c0d01460:	4006      	ands	r6, r0
c0d01462:	e00c      	b.n	c0d0147e <io_exchange+0x1ce>
        if (!G_io_apdu_buffer[APDU_OFF_P1] && !G_io_apdu_buffer[APDU_OFF_P2]) {
c0d01464:	78b8      	ldrb	r0, [r7, #2]
c0d01466:	78f9      	ldrb	r1, [r7, #3]
c0d01468:	4301      	orrs	r1, r0
c0d0146a:	d12f      	bne.n	c0d014cc <io_exchange+0x21c>
          G_io_apdu_buffer[(*tx_len)++] = 0x00;
c0d0146c:	707e      	strb	r6, [r7, #1]
c0d0146e:	2090      	movs	r0, #144	; 0x90
          G_io_apdu_buffer[(*tx_len)++] = 0x90;
c0d01470:	7038      	strb	r0, [r7, #0]
c0d01472:	2007      	movs	r0, #7
c0d01474:	9e04      	ldr	r6, [sp, #16]
          *channel &= ~IO_FLAGS;
c0d01476:	4006      	ands	r6, r0
c0d01478:	207f      	movs	r0, #127	; 0x7f
c0d0147a:	43c0      	mvns	r0, r0
          *channel |= IO_RESET_AFTER_REPLIED;
c0d0147c:	1836      	adds	r6, r6, r0
c0d0147e:	2102      	movs	r1, #2
c0d01480:	e01f      	b.n	c0d014c2 <io_exchange+0x212>
        if (!G_io_apdu_buffer[APDU_OFF_P1] && !G_io_apdu_buffer[APDU_OFF_P2]) {
c0d01482:	78b8      	ldrb	r0, [r7, #2]
c0d01484:	78f9      	ldrb	r1, [r7, #3]
c0d01486:	4301      	orrs	r1, r0
c0d01488:	d120      	bne.n	c0d014cc <io_exchange+0x21c>
          if (os_global_pin_is_validated() == BOLOS_UX_OK) {
c0d0148a:	f001 f9db 	bl	c0d02844 <os_global_pin_is_validated>
c0d0148e:	28aa      	cmp	r0, #170	; 0xaa
c0d01490:	d10f      	bne.n	c0d014b2 <io_exchange+0x202>
c0d01492:	2001      	movs	r0, #1
            G_io_apdu_buffer[(*tx_len)++] = 0x01;
c0d01494:	7038      	strb	r0, [r7, #0]
            i = os_perso_seed_cookie(G_io_apdu_buffer+1+1, MIN(64,sizeof(G_io_apdu_buffer)-1-1-2));
c0d01496:	1cb8      	adds	r0, r7, #2
c0d01498:	2140      	movs	r1, #64	; 0x40
c0d0149a:	f001 f9c7 	bl	c0d0282c <os_perso_seed_cookie>
            G_io_apdu_buffer[(*tx_len)++] = i;
c0d0149e:	7078      	strb	r0, [r7, #1]
            *tx_len += i;
c0d014a0:	1c81      	adds	r1, r0, #2
            G_io_apdu_buffer[(*tx_len)++] = 0x90;
c0d014a2:	b289      	uxth	r1, r1
c0d014a4:	2290      	movs	r2, #144	; 0x90
c0d014a6:	547a      	strb	r2, [r7, r1]
c0d014a8:	1cc1      	adds	r1, r0, #3
            G_io_apdu_buffer[(*tx_len)++] = 0x00;
c0d014aa:	b289      	uxth	r1, r1
c0d014ac:	547e      	strb	r6, [r7, r1]
c0d014ae:	1d01      	adds	r1, r0, #4
c0d014b0:	e004      	b.n	c0d014bc <io_exchange+0x20c>
c0d014b2:	2085      	movs	r0, #133	; 0x85
            G_io_apdu_buffer[(*tx_len)++] = 0x85;
c0d014b4:	7078      	strb	r0, [r7, #1]
c0d014b6:	2069      	movs	r0, #105	; 0x69
            G_io_apdu_buffer[(*tx_len)++] = 0x69;
c0d014b8:	7038      	strb	r0, [r7, #0]
c0d014ba:	2102      	movs	r1, #2
c0d014bc:	2007      	movs	r0, #7
c0d014be:	9e04      	ldr	r6, [sp, #16]
          *channel &= ~IO_FLAGS;
c0d014c0:	4006      	ands	r6, r0
  switch(channel&~(IO_FLAGS)) {
c0d014c2:	b2f2      	uxtb	r2, r6
c0d014c4:	0770      	lsls	r0, r6, #29
c0d014c6:	d100      	bne.n	c0d014ca <io_exchange+0x21a>
c0d014c8:	e705      	b.n	c0d012d6 <io_exchange+0x26>
c0d014ca:	e6f7      	b.n	c0d012bc <io_exchange+0xc>
        return G_io_app.apdu_length;
c0d014cc:	8868      	ldrh	r0, [r5, #2]
c0d014ce:	e6f9      	b.n	c0d012c4 <io_exchange+0x14>
        return G_io_app.apdu_length-5;
c0d014d0:	8868      	ldrh	r0, [r5, #2]
c0d014d2:	1f40      	subs	r0, r0, #5
c0d014d4:	e6f6      	b.n	c0d012c4 <io_exchange+0x14>
c0d014d6:	2005      	movs	r0, #5
              THROW(EXCEPTION_IO_RESET);
c0d014d8:	f7ff fcc6 	bl	c0d00e68 <os_longjmp>
c0d014dc:	2005      	movs	r0, #5
        os_sched_exit((bolos_task_status_t)EXCEPTION_IO_RESET);
c0d014de:	f001 f9e5 	bl	c0d028ac <os_sched_exit>
c0d014e2:	2004      	movs	r0, #4
            THROW(INVALID_STATE);
c0d014e4:	f7ff fcc0 	bl	c0d00e68 <os_longjmp>
c0d014e8:	2002      	movs	r0, #2
              THROW(INVALID_PARAMETER);
c0d014ea:	f7ff fcbd 	bl	c0d00e68 <os_longjmp>
c0d014ee:	46c0      	nop			; (mov r8, r8)
c0d014f0:	200008ac 	.word	0x200008ac
c0d014f4:	20000a30 	.word	0x20000a30
c0d014f8:	2000092c 	.word	0x2000092c
c0d014fc:	fffffcf7 	.word	0xfffffcf7
c0d01500:	00003f60 	.word	0x00003f60
c0d01504:	fffffcbd 	.word	0xfffffcbd
c0d01508:	00003f9c 	.word	0x00003f9c
c0d0150c:	00003f38 	.word	0x00003f38

c0d01510 <os_io_seph_recv_and_process>:

unsigned int os_io_seph_recv_and_process(unsigned int dont_process_ux_events) {
c0d01510:	b5b0      	push	{r4, r5, r7, lr}
c0d01512:	4604      	mov	r4, r0
  io_seproxyhal_spi_send(seph_io_general_status, sizeof(seph_io_general_status));
c0d01514:	480f      	ldr	r0, [pc, #60]	; (c0d01554 <os_io_seph_recv_and_process+0x44>)
c0d01516:	4478      	add	r0, pc
c0d01518:	2105      	movs	r1, #5
c0d0151a:	f001 f9d3 	bl	c0d028c4 <io_seph_send>
  // send general status before receiving next event
  io_seproxyhal_general_status();

  io_seproxyhal_spi_recv(G_io_seproxyhal_spi_buffer, sizeof(G_io_seproxyhal_spi_buffer), 0);
c0d0151e:	4d0b      	ldr	r5, [pc, #44]	; (c0d0154c <os_io_seph_recv_and_process+0x3c>)
c0d01520:	2180      	movs	r1, #128	; 0x80
c0d01522:	2200      	movs	r2, #0
c0d01524:	4628      	mov	r0, r5
c0d01526:	f001 f9e5 	bl	c0d028f4 <io_seph_recv>

  switch (G_io_seproxyhal_spi_buffer[0]) {
c0d0152a:	7828      	ldrb	r0, [r5, #0]
c0d0152c:	2815      	cmp	r0, #21
c0d0152e:	d808      	bhi.n	c0d01542 <os_io_seph_recv_and_process+0x32>
c0d01530:	2101      	movs	r1, #1
c0d01532:	4081      	lsls	r1, r0
c0d01534:	4806      	ldr	r0, [pc, #24]	; (c0d01550 <os_io_seph_recv_and_process+0x40>)
c0d01536:	4201      	tst	r1, r0
c0d01538:	d003      	beq.n	c0d01542 <os_io_seph_recv_and_process+0x32>
    case SEPROXYHAL_TAG_BUTTON_PUSH_EVENT:
    case SEPROXYHAL_TAG_TICKER_EVENT:
    case SEPROXYHAL_TAG_DISPLAY_PROCESSED_EVENT:
    case SEPROXYHAL_TAG_STATUS_EVENT:
      // perform UX event on these ones, don't process as an IO event
      if (dont_process_ux_events) {
c0d0153a:	2c00      	cmp	r4, #0
c0d0153c:	d001      	beq.n	c0d01542 <os_io_seph_recv_and_process+0x32>
c0d0153e:	2000      	movs	r0, #0
      if (io_seproxyhal_handle_event()) {
        return 1;
      }
  }
  return 0;
}
c0d01540:	bdb0      	pop	{r4, r5, r7, pc}
      if (io_seproxyhal_handle_event()) {
c0d01542:	f7ff fd51 	bl	c0d00fe8 <io_seproxyhal_handle_event>
c0d01546:	1e41      	subs	r1, r0, #1
c0d01548:	4188      	sbcs	r0, r1
c0d0154a:	bdb0      	pop	{r4, r5, r7, pc}
c0d0154c:	200008ac 	.word	0x200008ac
c0d01550:	00207020 	.word	0x00207020
c0d01554:	00003e00 	.word	0x00003e00

c0d01558 <mcu_usb_prints>:
  return ret;
}
#endif // !defined(APP_UX)

#ifdef HAVE_PRINTF
void mcu_usb_prints(const char* str, unsigned int charcount) {
c0d01558:	b5b0      	push	{r4, r5, r7, lr}
c0d0155a:	b082      	sub	sp, #8
c0d0155c:	460c      	mov	r4, r1
c0d0155e:	4605      	mov	r5, r0
c0d01560:	a801      	add	r0, sp, #4
  unsigned char buf[4];

  buf[0] = SEPROXYHAL_TAG_PRINTF;
  buf[1] = charcount >> 8;
  buf[2] = charcount;
c0d01562:	7081      	strb	r1, [r0, #2]
c0d01564:	215f      	movs	r1, #95	; 0x5f
  buf[0] = SEPROXYHAL_TAG_PRINTF;
c0d01566:	7001      	strb	r1, [r0, #0]
  buf[1] = charcount >> 8;
c0d01568:	0a21      	lsrs	r1, r4, #8
c0d0156a:	7041      	strb	r1, [r0, #1]
c0d0156c:	2103      	movs	r1, #3
  io_seproxyhal_spi_send(buf, 3);
c0d0156e:	f001 f9a9 	bl	c0d028c4 <io_seph_send>
  io_seproxyhal_spi_send((unsigned char*)str, charcount);
c0d01572:	b2a1      	uxth	r1, r4
c0d01574:	4628      	mov	r0, r5
c0d01576:	f001 f9a5 	bl	c0d028c4 <io_seph_send>
}
c0d0157a:	b002      	add	sp, #8
c0d0157c:	bdb0      	pop	{r4, r5, r7, pc}
	...

c0d01580 <io_usb_hid_receive>:
volatile unsigned int   G_io_usb_hid_channel;
volatile unsigned int   G_io_usb_hid_remaining_length;
volatile unsigned int   G_io_usb_hid_sequence_number;
volatile unsigned char* G_io_usb_hid_current_buffer;

io_usb_hid_receive_status_t io_usb_hid_receive (io_send_t sndfct, unsigned char* buffer, unsigned short l) {
c0d01580:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d01582:	b081      	sub	sp, #4
c0d01584:	9200      	str	r2, [sp, #0]
c0d01586:	4605      	mov	r5, r0
  // avoid over/under flows
  if (buffer != G_io_usb_ep_buffer) {
c0d01588:	4c4a      	ldr	r4, [pc, #296]	; (c0d016b4 <io_usb_hid_receive+0x134>)
c0d0158a:	42a1      	cmp	r1, r4
c0d0158c:	d00f      	beq.n	c0d015ae <io_usb_hid_receive+0x2e>
c0d0158e:	460f      	mov	r7, r1
    memset(G_io_usb_ep_buffer, 0, sizeof(G_io_usb_ep_buffer));
c0d01590:	4c48      	ldr	r4, [pc, #288]	; (c0d016b4 <io_usb_hid_receive+0x134>)
c0d01592:	2640      	movs	r6, #64	; 0x40
c0d01594:	4620      	mov	r0, r4
c0d01596:	4631      	mov	r1, r6
c0d01598:	f003 fb26 	bl	c0d04be8 <__aeabi_memclr>
c0d0159c:	9a00      	ldr	r2, [sp, #0]
    memmove(G_io_usb_ep_buffer, buffer, MIN(l, sizeof(G_io_usb_ep_buffer)));
c0d0159e:	2a40      	cmp	r2, #64	; 0x40
c0d015a0:	d300      	bcc.n	c0d015a4 <io_usb_hid_receive+0x24>
c0d015a2:	4632      	mov	r2, r6
c0d015a4:	4620      	mov	r0, r4
c0d015a6:	4639      	mov	r1, r7
c0d015a8:	f003 fb28 	bl	c0d04bfc <__aeabi_memmove>
c0d015ac:	4c41      	ldr	r4, [pc, #260]	; (c0d016b4 <io_usb_hid_receive+0x134>)
  }

  // process the chunk content
  switch(G_io_usb_ep_buffer[2]) {
c0d015ae:	78a0      	ldrb	r0, [r4, #2]
c0d015b0:	2801      	cmp	r0, #1
c0d015b2:	dc0a      	bgt.n	c0d015ca <io_usb_hid_receive+0x4a>
c0d015b4:	2800      	cmp	r0, #0
c0d015b6:	d02e      	beq.n	c0d01616 <io_usb_hid_receive+0x96>
c0d015b8:	2801      	cmp	r0, #1
c0d015ba:	d16a      	bne.n	c0d01692 <io_usb_hid_receive+0x112>
    // await for the next chunk
    goto apdu_reset;

  case 0x01: // ALLOCATE CHANNEL
    // do not reset the current apdu reception if any
    cx_rng_no_throw(G_io_usb_ep_buffer+3, 4);
c0d015bc:	1ce0      	adds	r0, r4, #3
c0d015be:	2104      	movs	r1, #4
c0d015c0:	f7fe fe38 	bl	c0d00234 <cx_rng_no_throw>
c0d015c4:	2140      	movs	r1, #64	; 0x40
    // send the response
    sndfct(G_io_usb_ep_buffer, IO_HID_EP_LENGTH);
c0d015c6:	4620      	mov	r0, r4
c0d015c8:	e030      	b.n	c0d0162c <io_usb_hid_receive+0xac>
  switch(G_io_usb_ep_buffer[2]) {
c0d015ca:	2802      	cmp	r0, #2
c0d015cc:	d02c      	beq.n	c0d01628 <io_usb_hid_receive+0xa8>
c0d015ce:	2805      	cmp	r0, #5
c0d015d0:	d15f      	bne.n	c0d01692 <io_usb_hid_receive+0x112>
c0d015d2:	7920      	ldrb	r0, [r4, #4]
c0d015d4:	78e1      	ldrb	r1, [r4, #3]
c0d015d6:	0209      	lsls	r1, r1, #8
c0d015d8:	1808      	adds	r0, r1, r0
    if ((unsigned int)U2BE(G_io_usb_ep_buffer, 3) != (unsigned int)G_io_usb_hid_sequence_number) {
c0d015da:	4e37      	ldr	r6, [pc, #220]	; (c0d016b8 <io_usb_hid_receive+0x138>)
c0d015dc:	6831      	ldr	r1, [r6, #0]
c0d015de:	2700      	movs	r7, #0
c0d015e0:	4281      	cmp	r1, r0
c0d015e2:	d15d      	bne.n	c0d016a0 <io_usb_hid_receive+0x120>
    if (G_io_usb_hid_sequence_number == 0) {
c0d015e4:	6830      	ldr	r0, [r6, #0]
c0d015e6:	2800      	cmp	r0, #0
c0d015e8:	d023      	beq.n	c0d01632 <io_usb_hid_receive+0xb2>
c0d015ea:	9800      	ldr	r0, [sp, #0]
c0d015ec:	1f40      	subs	r0, r0, #5
      if (l > G_io_usb_hid_remaining_length) {
c0d015ee:	b282      	uxth	r2, r0
c0d015f0:	4932      	ldr	r1, [pc, #200]	; (c0d016bc <io_usb_hid_receive+0x13c>)
c0d015f2:	680b      	ldr	r3, [r1, #0]
c0d015f4:	4293      	cmp	r3, r2
c0d015f6:	d200      	bcs.n	c0d015fa <io_usb_hid_receive+0x7a>
        l = G_io_usb_hid_remaining_length;
c0d015f8:	6808      	ldr	r0, [r1, #0]
c0d015fa:	4622      	mov	r2, r4
      if (l > sizeof(G_io_usb_ep_buffer) - 5) {
c0d015fc:	b281      	uxth	r1, r0
c0d015fe:	293b      	cmp	r1, #59	; 0x3b
c0d01600:	d300      	bcc.n	c0d01604 <io_usb_hid_receive+0x84>
c0d01602:	203b      	movs	r0, #59	; 0x3b
      memmove((void*)G_io_usb_hid_current_buffer, G_io_usb_ep_buffer+5, l);
c0d01604:	b285      	uxth	r5, r0
c0d01606:	4c2e      	ldr	r4, [pc, #184]	; (c0d016c0 <io_usb_hid_receive+0x140>)
c0d01608:	6820      	ldr	r0, [r4, #0]
c0d0160a:	1d51      	adds	r1, r2, #5
c0d0160c:	462a      	mov	r2, r5
c0d0160e:	f003 faf5 	bl	c0d04bfc <__aeabi_memmove>
    G_io_usb_hid_current_buffer += l;
c0d01612:	6824      	ldr	r4, [r4, #0]
c0d01614:	e033      	b.n	c0d0167e <io_usb_hid_receive+0xfe>
c0d01616:	2700      	movs	r7, #0
    memset(G_io_usb_ep_buffer+3, 0, 4); // PROTOCOL VERSION is 0
c0d01618:	71a7      	strb	r7, [r4, #6]
c0d0161a:	7167      	strb	r7, [r4, #5]
c0d0161c:	7127      	strb	r7, [r4, #4]
c0d0161e:	70e7      	strb	r7, [r4, #3]
c0d01620:	2140      	movs	r1, #64	; 0x40
    sndfct(G_io_usb_ep_buffer, IO_HID_EP_LENGTH);
c0d01622:	4620      	mov	r0, r4
c0d01624:	47a8      	blx	r5
c0d01626:	e03b      	b.n	c0d016a0 <io_usb_hid_receive+0x120>
    goto apdu_reset;

  case 0x02: // ECHO|PING
    // do not reset the current apdu reception if any
    // send the response
    sndfct(G_io_usb_ep_buffer, IO_HID_EP_LENGTH);
c0d01628:	4822      	ldr	r0, [pc, #136]	; (c0d016b4 <io_usb_hid_receive+0x134>)
c0d0162a:	2140      	movs	r1, #64	; 0x40
c0d0162c:	47a8      	blx	r5
c0d0162e:	2700      	movs	r7, #0
c0d01630:	e036      	b.n	c0d016a0 <io_usb_hid_receive+0x120>
c0d01632:	79a0      	ldrb	r0, [r4, #6]
c0d01634:	7961      	ldrb	r1, [r4, #5]
c0d01636:	0209      	lsls	r1, r1, #8
c0d01638:	1809      	adds	r1, r1, r0
      G_io_usb_hid_total_length = U2BE(G_io_usb_ep_buffer, 5); //(G_io_usb_ep_buffer[5]<<8)+(G_io_usb_ep_buffer[6]&0xFF);
c0d0163a:	4822      	ldr	r0, [pc, #136]	; (c0d016c4 <io_usb_hid_receive+0x144>)
c0d0163c:	6001      	str	r1, [r0, #0]
      if (G_io_usb_hid_total_length > sizeof(G_io_apdu_buffer)) {
c0d0163e:	6801      	ldr	r1, [r0, #0]
c0d01640:	2241      	movs	r2, #65	; 0x41
c0d01642:	0092      	lsls	r2, r2, #2
c0d01644:	4291      	cmp	r1, r2
c0d01646:	d82b      	bhi.n	c0d016a0 <io_usb_hid_receive+0x120>
      G_io_usb_hid_remaining_length = G_io_usb_hid_total_length;
c0d01648:	6800      	ldr	r0, [r0, #0]
c0d0164a:	491c      	ldr	r1, [pc, #112]	; (c0d016bc <io_usb_hid_receive+0x13c>)
c0d0164c:	6008      	str	r0, [r1, #0]
c0d0164e:	7860      	ldrb	r0, [r4, #1]
c0d01650:	7822      	ldrb	r2, [r4, #0]
c0d01652:	0212      	lsls	r2, r2, #8
c0d01654:	1810      	adds	r0, r2, r0
      G_io_usb_hid_channel = U2BE(G_io_usb_ep_buffer, 0);
c0d01656:	4a1c      	ldr	r2, [pc, #112]	; (c0d016c8 <io_usb_hid_receive+0x148>)
c0d01658:	6010      	str	r0, [r2, #0]
      if (l > G_io_usb_hid_remaining_length) {
c0d0165a:	680a      	ldr	r2, [r1, #0]
      l -= 2;
c0d0165c:	9800      	ldr	r0, [sp, #0]
c0d0165e:	1fc0      	subs	r0, r0, #7
      if (l > G_io_usb_hid_remaining_length) {
c0d01660:	b283      	uxth	r3, r0
c0d01662:	429a      	cmp	r2, r3
c0d01664:	d200      	bcs.n	c0d01668 <io_usb_hid_receive+0xe8>
        l = G_io_usb_hid_remaining_length;
c0d01666:	6808      	ldr	r0, [r1, #0]
      if (l > sizeof(G_io_usb_ep_buffer) - 7) {
c0d01668:	b281      	uxth	r1, r0
c0d0166a:	2939      	cmp	r1, #57	; 0x39
c0d0166c:	d300      	bcc.n	c0d01670 <io_usb_hid_receive+0xf0>
c0d0166e:	2039      	movs	r0, #57	; 0x39
      memmove((void*)G_io_usb_hid_current_buffer, G_io_usb_ep_buffer+7, l);
c0d01670:	b285      	uxth	r5, r0
c0d01672:	1de1      	adds	r1, r4, #7
c0d01674:	4c15      	ldr	r4, [pc, #84]	; (c0d016cc <io_usb_hid_receive+0x14c>)
c0d01676:	4620      	mov	r0, r4
c0d01678:	462a      	mov	r2, r5
c0d0167a:	f003 fabb 	bl	c0d04bf4 <__aeabi_memcpy>
    G_io_usb_hid_remaining_length -= l;
c0d0167e:	480f      	ldr	r0, [pc, #60]	; (c0d016bc <io_usb_hid_receive+0x13c>)
c0d01680:	6801      	ldr	r1, [r0, #0]
c0d01682:	1b49      	subs	r1, r1, r5
c0d01684:	6001      	str	r1, [r0, #0]
    G_io_usb_hid_current_buffer += l;
c0d01686:	1960      	adds	r0, r4, r5
c0d01688:	490d      	ldr	r1, [pc, #52]	; (c0d016c0 <io_usb_hid_receive+0x140>)
c0d0168a:	6008      	str	r0, [r1, #0]
    G_io_usb_hid_sequence_number++;
c0d0168c:	6830      	ldr	r0, [r6, #0]
c0d0168e:	1c40      	adds	r0, r0, #1
c0d01690:	6030      	str	r0, [r6, #0]
    // await for the next chunk
    goto apdu_reset;
  }

  // if more data to be received, notify it
  if (G_io_usb_hid_remaining_length) {
c0d01692:	480a      	ldr	r0, [pc, #40]	; (c0d016bc <io_usb_hid_receive+0x13c>)
c0d01694:	6800      	ldr	r0, [r0, #0]
c0d01696:	2800      	cmp	r0, #0
c0d01698:	d001      	beq.n	c0d0169e <io_usb_hid_receive+0x11e>
c0d0169a:	2701      	movs	r7, #1
c0d0169c:	e007      	b.n	c0d016ae <io_usb_hid_receive+0x12e>
c0d0169e:	2702      	movs	r7, #2
c0d016a0:	4805      	ldr	r0, [pc, #20]	; (c0d016b8 <io_usb_hid_receive+0x138>)
c0d016a2:	2100      	movs	r1, #0
c0d016a4:	6001      	str	r1, [r0, #0]
c0d016a6:	4806      	ldr	r0, [pc, #24]	; (c0d016c0 <io_usb_hid_receive+0x140>)
c0d016a8:	6001      	str	r1, [r0, #0]
c0d016aa:	4804      	ldr	r0, [pc, #16]	; (c0d016bc <io_usb_hid_receive+0x13c>)
c0d016ac:	6001      	str	r1, [r0, #0]
  return IO_USB_APDU_RECEIVED;

apdu_reset:
  io_usb_hid_init();
  return IO_USB_APDU_RESET;
}
c0d016ae:	4638      	mov	r0, r7
c0d016b0:	b001      	add	sp, #4
c0d016b2:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d016b4:	20000a58 	.word	0x20000a58
c0d016b8:	20000a98 	.word	0x20000a98
c0d016bc:	20000aa0 	.word	0x20000aa0
c0d016c0:	20000aa4 	.word	0x20000aa4
c0d016c4:	20000a9c 	.word	0x20000a9c
c0d016c8:	20000aa8 	.word	0x20000aa8
c0d016cc:	2000092c 	.word	0x2000092c

c0d016d0 <io_usb_hid_init>:

void io_usb_hid_init(void) {
  G_io_usb_hid_sequence_number = 0; 
c0d016d0:	4803      	ldr	r0, [pc, #12]	; (c0d016e0 <io_usb_hid_init+0x10>)
c0d016d2:	2100      	movs	r1, #0
c0d016d4:	6001      	str	r1, [r0, #0]
  G_io_usb_hid_remaining_length = 0;
  G_io_usb_hid_current_buffer = NULL;
c0d016d6:	4803      	ldr	r0, [pc, #12]	; (c0d016e4 <io_usb_hid_init+0x14>)
c0d016d8:	6001      	str	r1, [r0, #0]
  G_io_usb_hid_remaining_length = 0;
c0d016da:	4803      	ldr	r0, [pc, #12]	; (c0d016e8 <io_usb_hid_init+0x18>)
c0d016dc:	6001      	str	r1, [r0, #0]
}
c0d016de:	4770      	bx	lr
c0d016e0:	20000a98 	.word	0x20000a98
c0d016e4:	20000aa4 	.word	0x20000aa4
c0d016e8:	20000aa0 	.word	0x20000aa0

c0d016ec <io_usb_hid_sent>:

/**
 * sent the next io_usb_hid transport chunk (rx on the host, tx on the device)
 */
void io_usb_hid_sent(io_send_t sndfct) {
c0d016ec:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d016ee:	b081      	sub	sp, #4
c0d016f0:	4a27      	ldr	r2, [pc, #156]	; (c0d01790 <io_usb_hid_sent+0xa4>)
c0d016f2:	6815      	ldr	r5, [r2, #0]
  unsigned int l;

  // only prepare next chunk if some data to be sent remain
  if (G_io_usb_hid_remaining_length && G_io_usb_hid_current_buffer) {
c0d016f4:	4b27      	ldr	r3, [pc, #156]	; (c0d01794 <io_usb_hid_sent+0xa8>)
c0d016f6:	6819      	ldr	r1, [r3, #0]
c0d016f8:	2900      	cmp	r1, #0
c0d016fa:	d021      	beq.n	c0d01740 <io_usb_hid_sent+0x54>
c0d016fc:	2d00      	cmp	r5, #0
c0d016fe:	d01f      	beq.n	c0d01740 <io_usb_hid_sent+0x54>
c0d01700:	9000      	str	r0, [sp, #0]
    // fill the chunk
    memset(G_io_usb_ep_buffer, 0, sizeof(G_io_usb_ep_buffer));
c0d01702:	4c27      	ldr	r4, [pc, #156]	; (c0d017a0 <io_usb_hid_sent+0xb4>)
c0d01704:	1d67      	adds	r7, r4, #5
c0d01706:	263b      	movs	r6, #59	; 0x3b
c0d01708:	4638      	mov	r0, r7
c0d0170a:	4631      	mov	r1, r6
c0d0170c:	f003 fa6c 	bl	c0d04be8 <__aeabi_memclr>
c0d01710:	4a20      	ldr	r2, [pc, #128]	; (c0d01794 <io_usb_hid_sent+0xa8>)
c0d01712:	2005      	movs	r0, #5

    // keep the channel identifier
    G_io_usb_ep_buffer[0] = (G_io_usb_hid_channel>>8)&0xFF;
    G_io_usb_ep_buffer[1] = G_io_usb_hid_channel&0xFF;
    G_io_usb_ep_buffer[2] = 0x05;
c0d01714:	70a0      	strb	r0, [r4, #2]
    G_io_usb_ep_buffer[0] = (G_io_usb_hid_channel>>8)&0xFF;
c0d01716:	4823      	ldr	r0, [pc, #140]	; (c0d017a4 <io_usb_hid_sent+0xb8>)
c0d01718:	6801      	ldr	r1, [r0, #0]
c0d0171a:	0a09      	lsrs	r1, r1, #8
c0d0171c:	7021      	strb	r1, [r4, #0]
    G_io_usb_ep_buffer[1] = G_io_usb_hid_channel&0xFF;
c0d0171e:	6800      	ldr	r0, [r0, #0]
c0d01720:	7060      	strb	r0, [r4, #1]
    G_io_usb_ep_buffer[3] = G_io_usb_hid_sequence_number>>8;
c0d01722:	491d      	ldr	r1, [pc, #116]	; (c0d01798 <io_usb_hid_sent+0xac>)
c0d01724:	6808      	ldr	r0, [r1, #0]
c0d01726:	0a00      	lsrs	r0, r0, #8
c0d01728:	70e0      	strb	r0, [r4, #3]
    G_io_usb_ep_buffer[4] = G_io_usb_hid_sequence_number;
c0d0172a:	6808      	ldr	r0, [r1, #0]
c0d0172c:	7120      	strb	r0, [r4, #4]

    if (G_io_usb_hid_sequence_number == 0) {
c0d0172e:	6809      	ldr	r1, [r1, #0]
c0d01730:	6810      	ldr	r0, [r2, #0]
c0d01732:	2900      	cmp	r1, #0
c0d01734:	d00c      	beq.n	c0d01750 <io_usb_hid_sent+0x64>
      memmove(G_io_usb_ep_buffer+7, (const void*)G_io_usb_hid_current_buffer, l);
      G_io_usb_hid_current_buffer += l;
      G_io_usb_hid_remaining_length -= l;
    }
    else {
      l = ((G_io_usb_hid_remaining_length>IO_HID_EP_LENGTH-5) ? IO_HID_EP_LENGTH-5 : G_io_usb_hid_remaining_length);
c0d01736:	283b      	cmp	r0, #59	; 0x3b
c0d01738:	d800      	bhi.n	c0d0173c <io_usb_hid_sent+0x50>
c0d0173a:	6816      	ldr	r6, [r2, #0]
      memmove(G_io_usb_ep_buffer+5, (const void*)G_io_usb_hid_current_buffer, l);
c0d0173c:	4638      	mov	r0, r7
c0d0173e:	e012      	b.n	c0d01766 <io_usb_hid_sent+0x7a>
  G_io_usb_hid_sequence_number = 0; 
c0d01740:	4815      	ldr	r0, [pc, #84]	; (c0d01798 <io_usb_hid_sent+0xac>)
c0d01742:	2100      	movs	r1, #0
c0d01744:	6001      	str	r1, [r0, #0]
  G_io_usb_hid_current_buffer = NULL;
c0d01746:	6011      	str	r1, [r2, #0]
  // cleanup when everything has been sent (ack for the last sent usb in packet)
  else {
    io_usb_hid_init();

    // we sent the whole response
    G_io_app.apdu_state = APDU_IDLE;
c0d01748:	4814      	ldr	r0, [pc, #80]	; (c0d0179c <io_usb_hid_sent+0xb0>)
c0d0174a:	7001      	strb	r1, [r0, #0]
  G_io_usb_hid_remaining_length = 0;
c0d0174c:	6019      	str	r1, [r3, #0]
c0d0174e:	e01d      	b.n	c0d0178c <io_usb_hid_sent+0xa0>
      l = ((G_io_usb_hid_remaining_length>IO_HID_EP_LENGTH-7) ? IO_HID_EP_LENGTH-7 : G_io_usb_hid_remaining_length);
c0d01750:	2839      	cmp	r0, #57	; 0x39
c0d01752:	d901      	bls.n	c0d01758 <io_usb_hid_sent+0x6c>
c0d01754:	2639      	movs	r6, #57	; 0x39
c0d01756:	e000      	b.n	c0d0175a <io_usb_hid_sent+0x6e>
c0d01758:	6816      	ldr	r6, [r2, #0]
      G_io_usb_ep_buffer[5] = G_io_usb_hid_remaining_length>>8;
c0d0175a:	6810      	ldr	r0, [r2, #0]
c0d0175c:	0a00      	lsrs	r0, r0, #8
c0d0175e:	7160      	strb	r0, [r4, #5]
      G_io_usb_ep_buffer[6] = G_io_usb_hid_remaining_length;
c0d01760:	6810      	ldr	r0, [r2, #0]
c0d01762:	71a0      	strb	r0, [r4, #6]
      memmove(G_io_usb_ep_buffer+7, (const void*)G_io_usb_hid_current_buffer, l);
c0d01764:	1de0      	adds	r0, r4, #7
c0d01766:	4629      	mov	r1, r5
c0d01768:	4632      	mov	r2, r6
c0d0176a:	f003 fa47 	bl	c0d04bfc <__aeabi_memmove>
c0d0176e:	4b09      	ldr	r3, [pc, #36]	; (c0d01794 <io_usb_hid_sent+0xa8>)
c0d01770:	9a00      	ldr	r2, [sp, #0]
c0d01772:	4907      	ldr	r1, [pc, #28]	; (c0d01790 <io_usb_hid_sent+0xa4>)
c0d01774:	6818      	ldr	r0, [r3, #0]
c0d01776:	1b80      	subs	r0, r0, r6
c0d01778:	6018      	str	r0, [r3, #0]
c0d0177a:	19a8      	adds	r0, r5, r6
c0d0177c:	6008      	str	r0, [r1, #0]
c0d0177e:	4906      	ldr	r1, [pc, #24]	; (c0d01798 <io_usb_hid_sent+0xac>)
    G_io_usb_hid_sequence_number++;
c0d01780:	6808      	ldr	r0, [r1, #0]
c0d01782:	1c40      	adds	r0, r0, #1
c0d01784:	6008      	str	r0, [r1, #0]
    sndfct(G_io_usb_ep_buffer, sizeof(G_io_usb_ep_buffer));
c0d01786:	4806      	ldr	r0, [pc, #24]	; (c0d017a0 <io_usb_hid_sent+0xb4>)
c0d01788:	2140      	movs	r1, #64	; 0x40
c0d0178a:	4790      	blx	r2
  }
}
c0d0178c:	b001      	add	sp, #4
c0d0178e:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d01790:	20000aa4 	.word	0x20000aa4
c0d01794:	20000aa0 	.word	0x20000aa0
c0d01798:	20000a98 	.word	0x20000a98
c0d0179c:	20000a30 	.word	0x20000a30
c0d017a0:	20000a58 	.word	0x20000a58
c0d017a4:	20000aa8 	.word	0x20000aa8

c0d017a8 <io_usb_hid_send>:

void io_usb_hid_send(io_send_t sndfct, unsigned short sndlength) {
c0d017a8:	b580      	push	{r7, lr}
  // perform send
  if (sndlength) {
c0d017aa:	2900      	cmp	r1, #0
c0d017ac:	d00b      	beq.n	c0d017c6 <io_usb_hid_send+0x1e>
    G_io_usb_hid_sequence_number = 0; 
c0d017ae:	4a06      	ldr	r2, [pc, #24]	; (c0d017c8 <io_usb_hid_send+0x20>)
c0d017b0:	2300      	movs	r3, #0
c0d017b2:	6013      	str	r3, [r2, #0]
    G_io_usb_hid_current_buffer = G_io_apdu_buffer;
    G_io_usb_hid_remaining_length = sndlength;
c0d017b4:	4a05      	ldr	r2, [pc, #20]	; (c0d017cc <io_usb_hid_send+0x24>)
c0d017b6:	6011      	str	r1, [r2, #0]
    G_io_usb_hid_current_buffer = G_io_apdu_buffer;
c0d017b8:	4a05      	ldr	r2, [pc, #20]	; (c0d017d0 <io_usb_hid_send+0x28>)
c0d017ba:	4b06      	ldr	r3, [pc, #24]	; (c0d017d4 <io_usb_hid_send+0x2c>)
c0d017bc:	6013      	str	r3, [r2, #0]
    G_io_usb_hid_total_length = sndlength;
c0d017be:	4a06      	ldr	r2, [pc, #24]	; (c0d017d8 <io_usb_hid_send+0x30>)
c0d017c0:	6011      	str	r1, [r2, #0]
    io_usb_hid_sent(sndfct);
c0d017c2:	f7ff ff93 	bl	c0d016ec <io_usb_hid_sent>
  }
}
c0d017c6:	bd80      	pop	{r7, pc}
c0d017c8:	20000a98 	.word	0x20000a98
c0d017cc:	20000aa0 	.word	0x20000aa0
c0d017d0:	20000aa4 	.word	0x20000aa4
c0d017d4:	2000092c 	.word	0x2000092c
c0d017d8:	20000a9c 	.word	0x20000a9c

c0d017dc <mcu_usb_printf>:
#include "usbd_def.h"
#include "usbd_core.h"

void screen_printf(const char* format, ...) __attribute__ ((weak, alias ("mcu_usb_printf")));

void mcu_usb_printf(const char* format, ...) {
c0d017dc:	b083      	sub	sp, #12
c0d017de:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d017e0:	b08e      	sub	sp, #56	; 0x38
c0d017e2:	ac13      	add	r4, sp, #76	; 0x4c
c0d017e4:	c40e      	stmia	r4!, {r1, r2, r3}
    char cStrlenSet;

    //
    // Check the arguments.
    //
    if(format == 0) {
c0d017e6:	2800      	cmp	r0, #0
c0d017e8:	d100      	bne.n	c0d017ec <mcu_usb_printf+0x10>
c0d017ea:	e181      	b.n	c0d01af0 <mcu_usb_printf+0x314>
c0d017ec:	4604      	mov	r4, r0
c0d017ee:	a813      	add	r0, sp, #76	; 0x4c
    }

    //
    // Start the varargs processing.
    //
    va_start(vaArgP, format);
c0d017f0:	9008      	str	r0, [sp, #32]

    //
    // Loop while there are more characters in the string.
    //
    while(*format)
c0d017f2:	7820      	ldrb	r0, [r4, #0]
c0d017f4:	2800      	cmp	r0, #0
c0d017f6:	d100      	bne.n	c0d017fa <mcu_usb_printf+0x1e>
c0d017f8:	e17a      	b.n	c0d01af0 <mcu_usb_printf+0x314>
c0d017fa:	2101      	movs	r1, #1
c0d017fc:	9103      	str	r1, [sp, #12]
c0d017fe:	2500      	movs	r5, #0
    {
        //
        // Find the first non-% character, or the end of the string.
        //
        for(ulIdx = 0; (format[ulIdx] != '%') && (format[ulIdx] != '\0');
c0d01800:	2800      	cmp	r0, #0
c0d01802:	d005      	beq.n	c0d01810 <mcu_usb_printf+0x34>
c0d01804:	2825      	cmp	r0, #37	; 0x25
c0d01806:	d003      	beq.n	c0d01810 <mcu_usb_printf+0x34>
c0d01808:	1960      	adds	r0, r4, r5
c0d0180a:	7840      	ldrb	r0, [r0, #1]
            ulIdx++)
c0d0180c:	1c6d      	adds	r5, r5, #1
c0d0180e:	e7f7      	b.n	c0d01800 <mcu_usb_printf+0x24>
        }

        //
        // Write this portion of the string.
        //
        mcu_usb_prints(format, ulIdx);
c0d01810:	4620      	mov	r0, r4
c0d01812:	4629      	mov	r1, r5
c0d01814:	f7ff fea0 	bl	c0d01558 <mcu_usb_prints>
        format += ulIdx;

        //
        // See if the next character is a %.
        //
        if(*format == '%')
c0d01818:	5d60      	ldrb	r0, [r4, r5]
c0d0181a:	2825      	cmp	r0, #37	; 0x25
c0d0181c:	d143      	bne.n	c0d018a6 <mcu_usb_printf+0xca>
            ulCount = 0;
            cFill = ' ';
            ulStrlen = 0;
            cStrlenSet = 0;
            ulCap = 0;
            ulBase = 10;
c0d0181e:	1960      	adds	r0, r4, r5
c0d01820:	1c44      	adds	r4, r0, #1
c0d01822:	2300      	movs	r3, #0
c0d01824:	2720      	movs	r7, #32
c0d01826:	461e      	mov	r6, r3
c0d01828:	4618      	mov	r0, r3
again:

            //
            // Determine how to handle the next character.
            //
            switch(*format++)
c0d0182a:	7821      	ldrb	r1, [r4, #0]
c0d0182c:	1c64      	adds	r4, r4, #1
c0d0182e:	2200      	movs	r2, #0
c0d01830:	292d      	cmp	r1, #45	; 0x2d
c0d01832:	dc0c      	bgt.n	c0d0184e <mcu_usb_printf+0x72>
c0d01834:	4610      	mov	r0, r2
c0d01836:	d0f8      	beq.n	c0d0182a <mcu_usb_printf+0x4e>
c0d01838:	2925      	cmp	r1, #37	; 0x25
c0d0183a:	d06d      	beq.n	c0d01918 <mcu_usb_printf+0x13c>
c0d0183c:	292a      	cmp	r1, #42	; 0x2a
c0d0183e:	d000      	beq.n	c0d01842 <mcu_usb_printf+0x66>
c0d01840:	e101      	b.n	c0d01a46 <mcu_usb_printf+0x26a>
                  goto error;
                }

                case '*':
                {
                  if (*format == 's' ) {
c0d01842:	7820      	ldrb	r0, [r4, #0]
c0d01844:	2873      	cmp	r0, #115	; 0x73
c0d01846:	d000      	beq.n	c0d0184a <mcu_usb_printf+0x6e>
c0d01848:	e0fd      	b.n	c0d01a46 <mcu_usb_printf+0x26a>
c0d0184a:	2002      	movs	r0, #2
c0d0184c:	e026      	b.n	c0d0189c <mcu_usb_printf+0xc0>
            switch(*format++)
c0d0184e:	2947      	cmp	r1, #71	; 0x47
c0d01850:	dc2b      	bgt.n	c0d018aa <mcu_usb_printf+0xce>
c0d01852:	460a      	mov	r2, r1
c0d01854:	3a30      	subs	r2, #48	; 0x30
c0d01856:	2a0a      	cmp	r2, #10
c0d01858:	d20f      	bcs.n	c0d0187a <mcu_usb_printf+0x9e>
c0d0185a:	9705      	str	r7, [sp, #20]
c0d0185c:	2230      	movs	r2, #48	; 0x30
c0d0185e:	461f      	mov	r7, r3
                    if((format[-1] == '0') && (ulCount == 0))
c0d01860:	460b      	mov	r3, r1
c0d01862:	4053      	eors	r3, r2
c0d01864:	9706      	str	r7, [sp, #24]
c0d01866:	433b      	orrs	r3, r7
c0d01868:	d000      	beq.n	c0d0186c <mcu_usb_printf+0x90>
c0d0186a:	9a05      	ldr	r2, [sp, #20]
c0d0186c:	230a      	movs	r3, #10
                    ulCount *= 10;
c0d0186e:	9f06      	ldr	r7, [sp, #24]
c0d01870:	437b      	muls	r3, r7
                    ulCount += format[-1] - '0';
c0d01872:	185b      	adds	r3, r3, r1
c0d01874:	3b30      	subs	r3, #48	; 0x30
c0d01876:	4617      	mov	r7, r2
c0d01878:	e7d7      	b.n	c0d0182a <mcu_usb_printf+0x4e>
            switch(*format++)
c0d0187a:	292e      	cmp	r1, #46	; 0x2e
c0d0187c:	d000      	beq.n	c0d01880 <mcu_usb_printf+0xa4>
c0d0187e:	e0e2      	b.n	c0d01a46 <mcu_usb_printf+0x26a>
                  if (format[0] == '*' && (format[1] == 's' || format[1] == 'H' || format[1] == 'h')) {
c0d01880:	7820      	ldrb	r0, [r4, #0]
c0d01882:	282a      	cmp	r0, #42	; 0x2a
c0d01884:	d000      	beq.n	c0d01888 <mcu_usb_printf+0xac>
c0d01886:	e0de      	b.n	c0d01a46 <mcu_usb_printf+0x26a>
c0d01888:	7860      	ldrb	r0, [r4, #1]
c0d0188a:	2848      	cmp	r0, #72	; 0x48
c0d0188c:	d004      	beq.n	c0d01898 <mcu_usb_printf+0xbc>
c0d0188e:	2873      	cmp	r0, #115	; 0x73
c0d01890:	d002      	beq.n	c0d01898 <mcu_usb_printf+0xbc>
c0d01892:	2868      	cmp	r0, #104	; 0x68
c0d01894:	d000      	beq.n	c0d01898 <mcu_usb_printf+0xbc>
c0d01896:	e0d6      	b.n	c0d01a46 <mcu_usb_printf+0x26a>
c0d01898:	1c64      	adds	r4, r4, #1
c0d0189a:	2001      	movs	r0, #1
c0d0189c:	9908      	ldr	r1, [sp, #32]
c0d0189e:	1d0a      	adds	r2, r1, #4
c0d018a0:	9208      	str	r2, [sp, #32]
c0d018a2:	680e      	ldr	r6, [r1, #0]
c0d018a4:	e7c1      	b.n	c0d0182a <mcu_usb_printf+0x4e>
c0d018a6:	1964      	adds	r4, r4, r5
c0d018a8:	e0dd      	b.n	c0d01a66 <mcu_usb_printf+0x28a>
            switch(*format++)
c0d018aa:	2967      	cmp	r1, #103	; 0x67
c0d018ac:	9404      	str	r4, [sp, #16]
c0d018ae:	dd08      	ble.n	c0d018c2 <mcu_usb_printf+0xe6>
c0d018b0:	2972      	cmp	r1, #114	; 0x72
c0d018b2:	dd10      	ble.n	c0d018d6 <mcu_usb_printf+0xfa>
c0d018b4:	2973      	cmp	r1, #115	; 0x73
c0d018b6:	d032      	beq.n	c0d0191e <mcu_usb_printf+0x142>
c0d018b8:	2975      	cmp	r1, #117	; 0x75
c0d018ba:	d036      	beq.n	c0d0192a <mcu_usb_printf+0x14e>
c0d018bc:	2978      	cmp	r1, #120	; 0x78
c0d018be:	d010      	beq.n	c0d018e2 <mcu_usb_printf+0x106>
c0d018c0:	e0c1      	b.n	c0d01a46 <mcu_usb_printf+0x26a>
c0d018c2:	2962      	cmp	r1, #98	; 0x62
c0d018c4:	dc16      	bgt.n	c0d018f4 <mcu_usb_printf+0x118>
c0d018c6:	2948      	cmp	r1, #72	; 0x48
c0d018c8:	d100      	bne.n	c0d018cc <mcu_usb_printf+0xf0>
c0d018ca:	e0a4      	b.n	c0d01a16 <mcu_usb_printf+0x23a>
c0d018cc:	2958      	cmp	r1, #88	; 0x58
c0d018ce:	d000      	beq.n	c0d018d2 <mcu_usb_printf+0xf6>
c0d018d0:	e0b9      	b.n	c0d01a46 <mcu_usb_printf+0x26a>
c0d018d2:	2001      	movs	r0, #1
c0d018d4:	e006      	b.n	c0d018e4 <mcu_usb_printf+0x108>
c0d018d6:	2968      	cmp	r1, #104	; 0x68
c0d018d8:	d100      	bne.n	c0d018dc <mcu_usb_printf+0x100>
c0d018da:	e0a0      	b.n	c0d01a1e <mcu_usb_printf+0x242>
c0d018dc:	2970      	cmp	r1, #112	; 0x70
c0d018de:	d000      	beq.n	c0d018e2 <mcu_usb_printf+0x106>
c0d018e0:	e0b1      	b.n	c0d01a46 <mcu_usb_printf+0x26a>
c0d018e2:	2000      	movs	r0, #0
c0d018e4:	9001      	str	r0, [sp, #4]
                case 'p':
                {
                    //
                    // Get the value from the varargs.
                    //
                    ulValue = va_arg(vaArgP, unsigned long);
c0d018e6:	9808      	ldr	r0, [sp, #32]
c0d018e8:	1d01      	adds	r1, r0, #4
c0d018ea:	9108      	str	r1, [sp, #32]
c0d018ec:	6800      	ldr	r0, [r0, #0]
c0d018ee:	900d      	str	r0, [sp, #52]	; 0x34
c0d018f0:	2610      	movs	r6, #16
c0d018f2:	e022      	b.n	c0d0193a <mcu_usb_printf+0x15e>
            switch(*format++)
c0d018f4:	2963      	cmp	r1, #99	; 0x63
c0d018f6:	d100      	bne.n	c0d018fa <mcu_usb_printf+0x11e>
c0d018f8:	e0aa      	b.n	c0d01a50 <mcu_usb_printf+0x274>
c0d018fa:	2964      	cmp	r1, #100	; 0x64
c0d018fc:	d000      	beq.n	c0d01900 <mcu_usb_printf+0x124>
c0d018fe:	e0a2      	b.n	c0d01a46 <mcu_usb_printf+0x26a>
                    ulValue = va_arg(vaArgP, unsigned long);
c0d01900:	9808      	ldr	r0, [sp, #32]
c0d01902:	1d01      	adds	r1, r0, #4
c0d01904:	9108      	str	r1, [sp, #32]
c0d01906:	6800      	ldr	r0, [r0, #0]
c0d01908:	900d      	str	r0, [sp, #52]	; 0x34
c0d0190a:	260a      	movs	r6, #10
                    if((long)ulValue < 0)
c0d0190c:	2800      	cmp	r0, #0
c0d0190e:	d500      	bpl.n	c0d01912 <mcu_usb_printf+0x136>
c0d01910:	e0d2      	b.n	c0d01ab8 <mcu_usb_printf+0x2dc>
c0d01912:	2100      	movs	r1, #0
c0d01914:	9101      	str	r1, [sp, #4]
c0d01916:	e010      	b.n	c0d0193a <mcu_usb_printf+0x15e>
c0d01918:	9404      	str	r4, [sp, #16]
                case '%':
                {
                    //
                    // Simply write a single %.
                    //
                    mcu_usb_prints(format - 1, 1);
c0d0191a:	1e60      	subs	r0, r4, #1
c0d0191c:	e09e      	b.n	c0d01a5c <mcu_usb_printf+0x280>
c0d0191e:	4619      	mov	r1, r3
c0d01920:	4a77      	ldr	r2, [pc, #476]	; (c0d01b00 <mcu_usb_printf+0x324>)
c0d01922:	447a      	add	r2, pc
c0d01924:	9206      	str	r2, [sp, #24]
c0d01926:	2400      	movs	r4, #0
c0d01928:	e07e      	b.n	c0d01a28 <mcu_usb_printf+0x24c>
                    ulValue = va_arg(vaArgP, unsigned long);
c0d0192a:	9808      	ldr	r0, [sp, #32]
c0d0192c:	1d01      	adds	r1, r0, #4
c0d0192e:	9108      	str	r1, [sp, #32]
c0d01930:	6800      	ldr	r0, [r0, #0]
c0d01932:	900d      	str	r0, [sp, #52]	; 0x34
c0d01934:	2100      	movs	r1, #0
c0d01936:	9101      	str	r1, [sp, #4]
c0d01938:	260a      	movs	r6, #10
c0d0193a:	9903      	ldr	r1, [sp, #12]
c0d0193c:	9102      	str	r1, [sp, #8]
c0d0193e:	9705      	str	r7, [sp, #20]
c0d01940:	9007      	str	r0, [sp, #28]
                        (((ulIdx * ulBase) <= ulValue) &&
c0d01942:	4286      	cmp	r6, r0
c0d01944:	d901      	bls.n	c0d0194a <mcu_usb_printf+0x16e>
c0d01946:	9f03      	ldr	r7, [sp, #12]
c0d01948:	e014      	b.n	c0d01974 <mcu_usb_printf+0x198>
                    for(ulIdx = 1;
c0d0194a:	1e5a      	subs	r2, r3, #1
c0d0194c:	4630      	mov	r0, r6
c0d0194e:	4607      	mov	r7, r0
c0d01950:	4615      	mov	r5, r2
c0d01952:	2100      	movs	r1, #0
                        (((ulIdx * ulBase) <= ulValue) &&
c0d01954:	4630      	mov	r0, r6
c0d01956:	463a      	mov	r2, r7
c0d01958:	460b      	mov	r3, r1
c0d0195a:	f003 f87b 	bl	c0d04a54 <__aeabi_lmul>
c0d0195e:	1e4a      	subs	r2, r1, #1
c0d01960:	4191      	sbcs	r1, r2
c0d01962:	9a07      	ldr	r2, [sp, #28]
c0d01964:	4290      	cmp	r0, r2
c0d01966:	d804      	bhi.n	c0d01972 <mcu_usb_printf+0x196>
                    for(ulIdx = 1;
c0d01968:	1e6a      	subs	r2, r5, #1
c0d0196a:	2900      	cmp	r1, #0
c0d0196c:	462b      	mov	r3, r5
c0d0196e:	d0ee      	beq.n	c0d0194e <mcu_usb_printf+0x172>
c0d01970:	e000      	b.n	c0d01974 <mcu_usb_printf+0x198>
c0d01972:	462b      	mov	r3, r5
c0d01974:	9a02      	ldr	r2, [sp, #8]
                    if(ulNeg)
c0d01976:	4610      	mov	r0, r2
c0d01978:	9903      	ldr	r1, [sp, #12]
c0d0197a:	4048      	eors	r0, r1
c0d0197c:	1a1c      	subs	r4, r3, r0
                    if(ulNeg && (cFill == '0'))
c0d0197e:	9406      	str	r4, [sp, #24]
c0d01980:	2a00      	cmp	r2, #0
c0d01982:	d001      	beq.n	c0d01988 <mcu_usb_printf+0x1ac>
c0d01984:	2500      	movs	r5, #0
c0d01986:	e00c      	b.n	c0d019a2 <mcu_usb_printf+0x1c6>
c0d01988:	9a05      	ldr	r2, [sp, #20]
c0d0198a:	b2d2      	uxtb	r2, r2
c0d0198c:	2100      	movs	r1, #0
c0d0198e:	2a30      	cmp	r2, #48	; 0x30
c0d01990:	460d      	mov	r5, r1
c0d01992:	d106      	bne.n	c0d019a2 <mcu_usb_printf+0x1c6>
c0d01994:	aa09      	add	r2, sp, #36	; 0x24
c0d01996:	461d      	mov	r5, r3
c0d01998:	232d      	movs	r3, #45	; 0x2d
                        pcBuf[ulPos++] = '-';
c0d0199a:	7013      	strb	r3, [r2, #0]
c0d0199c:	462b      	mov	r3, r5
c0d0199e:	2501      	movs	r5, #1
c0d019a0:	9903      	ldr	r1, [sp, #12]
c0d019a2:	9c06      	ldr	r4, [sp, #24]
                    if((ulCount > 1) && (ulCount < 16))
c0d019a4:	1ea2      	subs	r2, r4, #2
c0d019a6:	2a0d      	cmp	r2, #13
c0d019a8:	d80f      	bhi.n	c0d019ca <mcu_usb_printf+0x1ee>
c0d019aa:	9102      	str	r1, [sp, #8]
c0d019ac:	1e61      	subs	r1, r4, #1
c0d019ae:	d00b      	beq.n	c0d019c8 <mcu_usb_printf+0x1ec>
c0d019b0:	4244      	negs	r4, r0
c0d019b2:	a809      	add	r0, sp, #36	; 0x24
                        for(ulCount--; ulCount; ulCount--)
c0d019b4:	1940      	adds	r0, r0, r5
                            pcBuf[ulPos++] = cFill;
c0d019b6:	9a05      	ldr	r2, [sp, #20]
c0d019b8:	b2d2      	uxtb	r2, r2
c0d019ba:	9306      	str	r3, [sp, #24]
c0d019bc:	f003 f922 	bl	c0d04c04 <__aeabi_memset>
                        for(ulCount--; ulCount; ulCount--)
c0d019c0:	9806      	ldr	r0, [sp, #24]
c0d019c2:	1828      	adds	r0, r5, r0
c0d019c4:	1900      	adds	r0, r0, r4
c0d019c6:	1e45      	subs	r5, r0, #1
c0d019c8:	9902      	ldr	r1, [sp, #8]
                    if(ulNeg)
c0d019ca:	2900      	cmp	r1, #0
c0d019cc:	d103      	bne.n	c0d019d6 <mcu_usb_printf+0x1fa>
c0d019ce:	a809      	add	r0, sp, #36	; 0x24
c0d019d0:	212d      	movs	r1, #45	; 0x2d
                        pcBuf[ulPos++] = '-';
c0d019d2:	5541      	strb	r1, [r0, r5]
c0d019d4:	1c6d      	adds	r5, r5, #1
                    for(; ulIdx; ulIdx /= ulBase)
c0d019d6:	2f00      	cmp	r7, #0
c0d019d8:	d01a      	beq.n	c0d01a10 <mcu_usb_printf+0x234>
c0d019da:	4634      	mov	r4, r6
c0d019dc:	9801      	ldr	r0, [sp, #4]
c0d019de:	2800      	cmp	r0, #0
c0d019e0:	d002      	beq.n	c0d019e8 <mcu_usb_printf+0x20c>
c0d019e2:	4e4d      	ldr	r6, [pc, #308]	; (c0d01b18 <mcu_usb_printf+0x33c>)
c0d019e4:	447e      	add	r6, pc
c0d019e6:	e001      	b.n	c0d019ec <mcu_usb_printf+0x210>
c0d019e8:	4e4a      	ldr	r6, [pc, #296]	; (c0d01b14 <mcu_usb_printf+0x338>)
c0d019ea:	447e      	add	r6, pc
c0d019ec:	9807      	ldr	r0, [sp, #28]
c0d019ee:	4639      	mov	r1, r7
c0d019f0:	f002 ffbc 	bl	c0d0496c <__udivsi3>
c0d019f4:	4621      	mov	r1, r4
c0d019f6:	f002 fff5 	bl	c0d049e4 <__aeabi_uidivmod>
c0d019fa:	5c70      	ldrb	r0, [r6, r1]
c0d019fc:	a909      	add	r1, sp, #36	; 0x24
                          pcBuf[ulPos++] = g_pcHex[(ulValue / ulIdx) % ulBase];
c0d019fe:	5548      	strb	r0, [r1, r5]
                    for(; ulIdx; ulIdx /= ulBase)
c0d01a00:	4638      	mov	r0, r7
c0d01a02:	4621      	mov	r1, r4
c0d01a04:	f002 ffb2 	bl	c0d0496c <__udivsi3>
c0d01a08:	1c6d      	adds	r5, r5, #1
c0d01a0a:	42bc      	cmp	r4, r7
c0d01a0c:	4607      	mov	r7, r0
c0d01a0e:	d9ed      	bls.n	c0d019ec <mcu_usb_printf+0x210>
c0d01a10:	a809      	add	r0, sp, #36	; 0x24
                    mcu_usb_prints(pcBuf, ulPos);
c0d01a12:	4629      	mov	r1, r5
c0d01a14:	e023      	b.n	c0d01a5e <mcu_usb_printf+0x282>
c0d01a16:	4619      	mov	r1, r3
c0d01a18:	4a3a      	ldr	r2, [pc, #232]	; (c0d01b04 <mcu_usb_printf+0x328>)
c0d01a1a:	447a      	add	r2, pc
c0d01a1c:	e002      	b.n	c0d01a24 <mcu_usb_printf+0x248>
c0d01a1e:	4619      	mov	r1, r3
c0d01a20:	4a39      	ldr	r2, [pc, #228]	; (c0d01b08 <mcu_usb_printf+0x32c>)
c0d01a22:	447a      	add	r2, pc
c0d01a24:	9206      	str	r2, [sp, #24]
c0d01a26:	9c03      	ldr	r4, [sp, #12]
                    pcStr = va_arg(vaArgP, char *);
c0d01a28:	9a08      	ldr	r2, [sp, #32]
c0d01a2a:	1d13      	adds	r3, r2, #4
c0d01a2c:	9308      	str	r3, [sp, #32]
                    switch(cStrlenSet) {
c0d01a2e:	b2c0      	uxtb	r0, r0
                    pcStr = va_arg(vaArgP, char *);
c0d01a30:	6817      	ldr	r7, [r2, #0]
                    switch(cStrlenSet) {
c0d01a32:	2800      	cmp	r0, #0
c0d01a34:	d01a      	beq.n	c0d01a6c <mcu_usb_printf+0x290>
c0d01a36:	2801      	cmp	r0, #1
c0d01a38:	d020      	beq.n	c0d01a7c <mcu_usb_printf+0x2a0>
c0d01a3a:	2802      	cmp	r0, #2
c0d01a3c:	d11d      	bne.n	c0d01a7a <mcu_usb_printf+0x29e>
                        if (pcStr[0] == '\0') {
c0d01a3e:	7838      	ldrb	r0, [r7, #0]
c0d01a40:	2800      	cmp	r0, #0
c0d01a42:	9c04      	ldr	r4, [sp, #16]
c0d01a44:	d03e      	beq.n	c0d01ac4 <mcu_usb_printf+0x2e8>
c0d01a46:	9404      	str	r4, [sp, #16]
                default:
                {
                    //
                    // Indicate an error.
                    //
                    mcu_usb_prints("ERROR", 5);
c0d01a48:	482c      	ldr	r0, [pc, #176]	; (c0d01afc <mcu_usb_printf+0x320>)
c0d01a4a:	4478      	add	r0, pc
c0d01a4c:	2105      	movs	r1, #5
c0d01a4e:	e006      	b.n	c0d01a5e <mcu_usb_printf+0x282>
                    ulValue = va_arg(vaArgP, unsigned long);
c0d01a50:	9808      	ldr	r0, [sp, #32]
c0d01a52:	1d01      	adds	r1, r0, #4
c0d01a54:	9108      	str	r1, [sp, #32]
c0d01a56:	6800      	ldr	r0, [r0, #0]
c0d01a58:	900d      	str	r0, [sp, #52]	; 0x34
c0d01a5a:	a80d      	add	r0, sp, #52	; 0x34
c0d01a5c:	2101      	movs	r1, #1
c0d01a5e:	f7ff fd7b 	bl	c0d01558 <mcu_usb_prints>
c0d01a62:	9c04      	ldr	r4, [sp, #16]
    while(*format)
c0d01a64:	7820      	ldrb	r0, [r4, #0]
c0d01a66:	2800      	cmp	r0, #0
c0d01a68:	d042      	beq.n	c0d01af0 <mcu_usb_printf+0x314>
c0d01a6a:	e6c8      	b.n	c0d017fe <mcu_usb_printf+0x22>
c0d01a6c:	2000      	movs	r0, #0
                        for(ulIdx = 0; pcStr[ulIdx] != '\0'; ulIdx++)
c0d01a6e:	5c3a      	ldrb	r2, [r7, r0]
c0d01a70:	1c40      	adds	r0, r0, #1
c0d01a72:	2a00      	cmp	r2, #0
c0d01a74:	d1fb      	bne.n	c0d01a6e <mcu_usb_printf+0x292>
                    switch(ulBase) {
c0d01a76:	1e46      	subs	r6, r0, #1
c0d01a78:	e000      	b.n	c0d01a7c <mcu_usb_printf+0x2a0>
c0d01a7a:	462e      	mov	r6, r5
c0d01a7c:	2c00      	cmp	r4, #0
c0d01a7e:	d015      	beq.n	c0d01aac <mcu_usb_printf+0x2d0>
                        for (ulCount = 0; ulCount < ulIdx; ulCount++) {
c0d01a80:	2e00      	cmp	r6, #0
c0d01a82:	d0ee      	beq.n	c0d01a62 <mcu_usb_printf+0x286>
                          nibble1 = (pcStr[ulCount]>>4)&0xF;
c0d01a84:	7838      	ldrb	r0, [r7, #0]
c0d01a86:	9007      	str	r0, [sp, #28]
c0d01a88:	0900      	lsrs	r0, r0, #4
c0d01a8a:	9c06      	ldr	r4, [sp, #24]
c0d01a8c:	1820      	adds	r0, r4, r0
c0d01a8e:	2501      	movs	r5, #1
c0d01a90:	4629      	mov	r1, r5
c0d01a92:	f7ff fd61 	bl	c0d01558 <mcu_usb_prints>
c0d01a96:	200f      	movs	r0, #15
                          nibble2 = pcStr[ulCount]&0xF;
c0d01a98:	9907      	ldr	r1, [sp, #28]
c0d01a9a:	4008      	ands	r0, r1
c0d01a9c:	1820      	adds	r0, r4, r0
c0d01a9e:	4629      	mov	r1, r5
c0d01aa0:	f7ff fd5a 	bl	c0d01558 <mcu_usb_prints>
                        for (ulCount = 0; ulCount < ulIdx; ulCount++) {
c0d01aa4:	1c7f      	adds	r7, r7, #1
c0d01aa6:	1e76      	subs	r6, r6, #1
c0d01aa8:	d1ec      	bne.n	c0d01a84 <mcu_usb_printf+0x2a8>
c0d01aaa:	e7da      	b.n	c0d01a62 <mcu_usb_printf+0x286>
c0d01aac:	9106      	str	r1, [sp, #24]
                        mcu_usb_prints(pcStr, ulIdx);
c0d01aae:	4638      	mov	r0, r7
c0d01ab0:	4631      	mov	r1, r6
c0d01ab2:	f7ff fd51 	bl	c0d01558 <mcu_usb_prints>
c0d01ab6:	e00f      	b.n	c0d01ad8 <mcu_usb_printf+0x2fc>
                        ulValue = -(long)ulValue;
c0d01ab8:	4240      	negs	r0, r0
c0d01aba:	900d      	str	r0, [sp, #52]	; 0x34
c0d01abc:	2100      	movs	r1, #0
c0d01abe:	9102      	str	r1, [sp, #8]
            ulCap = 0;
c0d01ac0:	9101      	str	r1, [sp, #4]
c0d01ac2:	e73c      	b.n	c0d0193e <mcu_usb_printf+0x162>
c0d01ac4:	9106      	str	r1, [sp, #24]
                          do {
c0d01ac6:	1c74      	adds	r4, r6, #1
                            mcu_usb_prints(" ", 1);
c0d01ac8:	4810      	ldr	r0, [pc, #64]	; (c0d01b0c <mcu_usb_printf+0x330>)
c0d01aca:	4478      	add	r0, pc
c0d01acc:	2101      	movs	r1, #1
c0d01ace:	f7ff fd43 	bl	c0d01558 <mcu_usb_prints>
                          } while(ulStrlen-- > 0);
c0d01ad2:	1e64      	subs	r4, r4, #1
c0d01ad4:	d1f8      	bne.n	c0d01ac8 <mcu_usb_printf+0x2ec>
        for(ulIdx = 0; (format[ulIdx] != '%') && (format[ulIdx] != '\0');
c0d01ad6:	462e      	mov	r6, r5
c0d01ad8:	9806      	ldr	r0, [sp, #24]
                    if(ulCount > ulIdx)
c0d01ada:	42b0      	cmp	r0, r6
c0d01adc:	d9c1      	bls.n	c0d01a62 <mcu_usb_printf+0x286>
                        while(ulCount--)
c0d01ade:	1a34      	subs	r4, r6, r0
                            mcu_usb_prints(" ", 1);
c0d01ae0:	480b      	ldr	r0, [pc, #44]	; (c0d01b10 <mcu_usb_printf+0x334>)
c0d01ae2:	4478      	add	r0, pc
c0d01ae4:	2101      	movs	r1, #1
c0d01ae6:	f7ff fd37 	bl	c0d01558 <mcu_usb_prints>
                        while(ulCount--)
c0d01aea:	1c64      	adds	r4, r4, #1
c0d01aec:	d3f8      	bcc.n	c0d01ae0 <mcu_usb_printf+0x304>
c0d01aee:	e7b8      	b.n	c0d01a62 <mcu_usb_printf+0x286>

    //
    // End the varargs processing.
    //
    va_end(vaArgP);
}
c0d01af0:	b00e      	add	sp, #56	; 0x38
c0d01af2:	bcf0      	pop	{r4, r5, r6, r7}
c0d01af4:	bc01      	pop	{r0}
c0d01af6:	b003      	add	sp, #12
c0d01af8:	4700      	bx	r0
c0d01afa:	46c0      	nop			; (mov r8, r8)
c0d01afc:	000038d3 	.word	0x000038d3
c0d01b00:	00003a01 	.word	0x00003a01
c0d01b04:	00003919 	.word	0x00003919
c0d01b08:	00003901 	.word	0x00003901
c0d01b0c:	00003851 	.word	0x00003851
c0d01b10:	00003839 	.word	0x00003839
c0d01b14:	00003939 	.word	0x00003939
c0d01b18:	0000394f 	.word	0x0000394f

c0d01b1c <snprintf>:
#endif // HAVE_PRINTF

#ifdef HAVE_SPRINTF
//unsigned int snprintf(unsigned char * str, unsigned int str_size, const char* format, ...)
int snprintf(char * str, size_t str_size, const char * format, ...)
 {
c0d01b1c:	b081      	sub	sp, #4
c0d01b1e:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d01b20:	b08e      	sub	sp, #56	; 0x38
c0d01b22:	9313      	str	r3, [sp, #76]	; 0x4c
    char cStrlenSet;

    //
    // Check the arguments.
    //
    if(str == NULL ||str_size < 1) {
c0d01b24:	2800      	cmp	r0, #0
c0d01b26:	d100      	bne.n	c0d01b2a <snprintf+0xe>
c0d01b28:	e1be      	b.n	c0d01ea8 <snprintf+0x38c>
c0d01b2a:	460d      	mov	r5, r1
c0d01b2c:	2900      	cmp	r1, #0
c0d01b2e:	d100      	bne.n	c0d01b32 <snprintf+0x16>
c0d01b30:	e1ba      	b.n	c0d01ea8 <snprintf+0x38c>
c0d01b32:	4614      	mov	r4, r2
c0d01b34:	4606      	mov	r6, r0
      return 0;
    }

    // ensure terminating string with a \0
    memset(str, 0, str_size);
c0d01b36:	4629      	mov	r1, r5
c0d01b38:	f003 f856 	bl	c0d04be8 <__aeabi_memclr>
    str_size--;
c0d01b3c:	1e6b      	subs	r3, r5, #1
c0d01b3e:	d100      	bne.n	c0d01b42 <snprintf+0x26>
c0d01b40:	e1b2      	b.n	c0d01ea8 <snprintf+0x38c>
c0d01b42:	a813      	add	r0, sp, #76	; 0x4c
    }

    //
    // Start the varargs processing.
    //
    va_start(vaArgP, format);
c0d01b44:	9009      	str	r0, [sp, #36]	; 0x24

    //
    // Loop while there are more characters in the string.
    //
    while(*format)
c0d01b46:	7821      	ldrb	r1, [r4, #0]
c0d01b48:	2900      	cmp	r1, #0
c0d01b4a:	d100      	bne.n	c0d01b4e <snprintf+0x32>
c0d01b4c:	e1ac      	b.n	c0d01ea8 <snprintf+0x38c>
c0d01b4e:	4630      	mov	r0, r6
c0d01b50:	2201      	movs	r2, #1
c0d01b52:	9204      	str	r2, [sp, #16]
c0d01b54:	2600      	movs	r6, #0
    {
        //
        // Find the first non-% character, or the end of the string.
        //
        for(ulIdx = 0; (format[ulIdx] != '%') && (format[ulIdx] != '\0');
c0d01b56:	2900      	cmp	r1, #0
c0d01b58:	d005      	beq.n	c0d01b66 <snprintf+0x4a>
c0d01b5a:	2925      	cmp	r1, #37	; 0x25
c0d01b5c:	d003      	beq.n	c0d01b66 <snprintf+0x4a>
c0d01b5e:	19a1      	adds	r1, r4, r6
c0d01b60:	7849      	ldrb	r1, [r1, #1]
            ulIdx++)
c0d01b62:	1c76      	adds	r6, r6, #1
c0d01b64:	e7f7      	b.n	c0d01b56 <snprintf+0x3a>
        }

        //
        // Write this portion of the string.
        //
        ulIdx = MIN(ulIdx, str_size);
c0d01b66:	429e      	cmp	r6, r3
c0d01b68:	d300      	bcc.n	c0d01b6c <snprintf+0x50>
c0d01b6a:	461e      	mov	r6, r3
c0d01b6c:	4605      	mov	r5, r0
        memmove(str, format, ulIdx);
c0d01b6e:	4621      	mov	r1, r4
c0d01b70:	4632      	mov	r2, r6
c0d01b72:	461f      	mov	r7, r3
c0d01b74:	f003 f842 	bl	c0d04bfc <__aeabi_memmove>
c0d01b78:	463b      	mov	r3, r7
        str+= ulIdx;
        str_size -= ulIdx;
c0d01b7a:	1bbb      	subs	r3, r7, r6
c0d01b7c:	d100      	bne.n	c0d01b80 <snprintf+0x64>
c0d01b7e:	e193      	b.n	c0d01ea8 <snprintf+0x38c>
c0d01b80:	19ad      	adds	r5, r5, r6
        format += ulIdx;

        //
        // See if the next character is a %.
        //
        if(*format == '%')
c0d01b82:	5da1      	ldrb	r1, [r4, r6]
        format += ulIdx;
c0d01b84:	19a4      	adds	r4, r4, r6
        if(*format == '%')
c0d01b86:	2925      	cmp	r1, #37	; 0x25
c0d01b88:	4628      	mov	r0, r5
c0d01b8a:	d000      	beq.n	c0d01b8e <snprintf+0x72>
c0d01b8c:	e171      	b.n	c0d01e72 <snprintf+0x356>
c0d01b8e:	9006      	str	r0, [sp, #24]
        {
            //
            // Skip the %.
            //
            format++;
c0d01b90:	1c64      	adds	r4, r4, #1
c0d01b92:	2000      	movs	r0, #0
c0d01b94:	2520      	movs	r5, #32
c0d01b96:	4607      	mov	r7, r0
c0d01b98:	9007      	str	r0, [sp, #28]
c0d01b9a:	9305      	str	r3, [sp, #20]
again:

            //
            // Determine how to handle the next character.
            //
            switch(*format++)
c0d01b9c:	7821      	ldrb	r1, [r4, #0]
c0d01b9e:	1c64      	adds	r4, r4, #1
c0d01ba0:	2200      	movs	r2, #0
c0d01ba2:	292d      	cmp	r1, #45	; 0x2d
c0d01ba4:	dc0c      	bgt.n	c0d01bc0 <snprintf+0xa4>
c0d01ba6:	4610      	mov	r0, r2
c0d01ba8:	d0f8      	beq.n	c0d01b9c <snprintf+0x80>
c0d01baa:	2925      	cmp	r1, #37	; 0x25
c0d01bac:	d06d      	beq.n	c0d01c8a <snprintf+0x16e>
c0d01bae:	292a      	cmp	r1, #42	; 0x2a
c0d01bb0:	d000      	beq.n	c0d01bb4 <snprintf+0x98>
c0d01bb2:	e12e      	b.n	c0d01e12 <snprintf+0x2f6>
                  goto error;
                }

                case '*':
                {
                  if (*format == 's' ) {
c0d01bb4:	7821      	ldrb	r1, [r4, #0]
c0d01bb6:	2973      	cmp	r1, #115	; 0x73
c0d01bb8:	d000      	beq.n	c0d01bbc <snprintf+0xa0>
c0d01bba:	e173      	b.n	c0d01ea4 <snprintf+0x388>
c0d01bbc:	2002      	movs	r0, #2
c0d01bbe:	e029      	b.n	c0d01c14 <snprintf+0xf8>
            switch(*format++)
c0d01bc0:	2947      	cmp	r1, #71	; 0x47
c0d01bc2:	dc2c      	bgt.n	c0d01c1e <snprintf+0x102>
c0d01bc4:	460a      	mov	r2, r1
c0d01bc6:	3a30      	subs	r2, #48	; 0x30
c0d01bc8:	2a0a      	cmp	r2, #10
c0d01bca:	d212      	bcs.n	c0d01bf2 <snprintf+0xd6>
c0d01bcc:	9708      	str	r7, [sp, #32]
c0d01bce:	462f      	mov	r7, r5
c0d01bd0:	2230      	movs	r2, #48	; 0x30
                    if((format[-1] == '0') && (ulCount == 0))
c0d01bd2:	460b      	mov	r3, r1
c0d01bd4:	4053      	eors	r3, r2
c0d01bd6:	9d07      	ldr	r5, [sp, #28]
c0d01bd8:	432b      	orrs	r3, r5
c0d01bda:	d000      	beq.n	c0d01bde <snprintf+0xc2>
c0d01bdc:	463a      	mov	r2, r7
c0d01bde:	230a      	movs	r3, #10
                    ulCount *= 10;
c0d01be0:	9d07      	ldr	r5, [sp, #28]
c0d01be2:	436b      	muls	r3, r5
                    ulCount += format[-1] - '0';
c0d01be4:	1859      	adds	r1, r3, r1
c0d01be6:	3930      	subs	r1, #48	; 0x30
c0d01be8:	9107      	str	r1, [sp, #28]
c0d01bea:	4615      	mov	r5, r2
c0d01bec:	9b05      	ldr	r3, [sp, #20]
c0d01bee:	9f08      	ldr	r7, [sp, #32]
c0d01bf0:	e7d4      	b.n	c0d01b9c <snprintf+0x80>
            switch(*format++)
c0d01bf2:	292e      	cmp	r1, #46	; 0x2e
c0d01bf4:	d000      	beq.n	c0d01bf8 <snprintf+0xdc>
c0d01bf6:	e10c      	b.n	c0d01e12 <snprintf+0x2f6>
                  if (format[0] == '*' && (format[1] == 's' || format[1] == 'H' || format[1] == 'h')) {
c0d01bf8:	7821      	ldrb	r1, [r4, #0]
c0d01bfa:	292a      	cmp	r1, #42	; 0x2a
c0d01bfc:	d000      	beq.n	c0d01c00 <snprintf+0xe4>
c0d01bfe:	e151      	b.n	c0d01ea4 <snprintf+0x388>
c0d01c00:	7860      	ldrb	r0, [r4, #1]
c0d01c02:	2848      	cmp	r0, #72	; 0x48
c0d01c04:	d004      	beq.n	c0d01c10 <snprintf+0xf4>
c0d01c06:	2873      	cmp	r0, #115	; 0x73
c0d01c08:	d002      	beq.n	c0d01c10 <snprintf+0xf4>
c0d01c0a:	2868      	cmp	r0, #104	; 0x68
c0d01c0c:	d000      	beq.n	c0d01c10 <snprintf+0xf4>
c0d01c0e:	e148      	b.n	c0d01ea2 <snprintf+0x386>
c0d01c10:	1c64      	adds	r4, r4, #1
c0d01c12:	2001      	movs	r0, #1
c0d01c14:	9909      	ldr	r1, [sp, #36]	; 0x24
c0d01c16:	1d0a      	adds	r2, r1, #4
c0d01c18:	9209      	str	r2, [sp, #36]	; 0x24
c0d01c1a:	680f      	ldr	r7, [r1, #0]
c0d01c1c:	e7be      	b.n	c0d01b9c <snprintf+0x80>
            switch(*format++)
c0d01c1e:	2967      	cmp	r1, #103	; 0x67
c0d01c20:	dd08      	ble.n	c0d01c34 <snprintf+0x118>
c0d01c22:	2972      	cmp	r1, #114	; 0x72
c0d01c24:	dd10      	ble.n	c0d01c48 <snprintf+0x12c>
c0d01c26:	2973      	cmp	r1, #115	; 0x73
c0d01c28:	d031      	beq.n	c0d01c8e <snprintf+0x172>
c0d01c2a:	2975      	cmp	r1, #117	; 0x75
c0d01c2c:	d034      	beq.n	c0d01c98 <snprintf+0x17c>
c0d01c2e:	2978      	cmp	r1, #120	; 0x78
c0d01c30:	d010      	beq.n	c0d01c54 <snprintf+0x138>
c0d01c32:	e0ee      	b.n	c0d01e12 <snprintf+0x2f6>
c0d01c34:	2962      	cmp	r1, #98	; 0x62
c0d01c36:	dc16      	bgt.n	c0d01c66 <snprintf+0x14a>
c0d01c38:	2948      	cmp	r1, #72	; 0x48
c0d01c3a:	d100      	bne.n	c0d01c3e <snprintf+0x122>
c0d01c3c:	e0ac      	b.n	c0d01d98 <snprintf+0x27c>
c0d01c3e:	2958      	cmp	r1, #88	; 0x58
c0d01c40:	d000      	beq.n	c0d01c44 <snprintf+0x128>
c0d01c42:	e0e6      	b.n	c0d01e12 <snprintf+0x2f6>
c0d01c44:	2001      	movs	r0, #1
c0d01c46:	e006      	b.n	c0d01c56 <snprintf+0x13a>
c0d01c48:	2968      	cmp	r1, #104	; 0x68
c0d01c4a:	d100      	bne.n	c0d01c4e <snprintf+0x132>
c0d01c4c:	e0a8      	b.n	c0d01da0 <snprintf+0x284>
c0d01c4e:	2970      	cmp	r1, #112	; 0x70
c0d01c50:	d000      	beq.n	c0d01c54 <snprintf+0x138>
c0d01c52:	e0de      	b.n	c0d01e12 <snprintf+0x2f6>
c0d01c54:	2000      	movs	r0, #0
c0d01c56:	9000      	str	r0, [sp, #0]
                case 'p':
                {
                    //
                    // Get the value from the varargs.
                    //
                    ulValue = va_arg(vaArgP, unsigned long);
c0d01c58:	9809      	ldr	r0, [sp, #36]	; 0x24
c0d01c5a:	1d01      	adds	r1, r0, #4
c0d01c5c:	9109      	str	r1, [sp, #36]	; 0x24
c0d01c5e:	6802      	ldr	r2, [r0, #0]
c0d01c60:	2100      	movs	r1, #0
c0d01c62:	2710      	movs	r7, #16
c0d01c64:	e01f      	b.n	c0d01ca6 <snprintf+0x18a>
            switch(*format++)
c0d01c66:	2963      	cmp	r1, #99	; 0x63
c0d01c68:	d100      	bne.n	c0d01c6c <snprintf+0x150>
c0d01c6a:	e0f7      	b.n	c0d01e5c <snprintf+0x340>
c0d01c6c:	2964      	cmp	r1, #100	; 0x64
c0d01c6e:	d000      	beq.n	c0d01c72 <snprintf+0x156>
c0d01c70:	e0cf      	b.n	c0d01e12 <snprintf+0x2f6>
                    ulValue = va_arg(vaArgP, unsigned long);
c0d01c72:	9809      	ldr	r0, [sp, #36]	; 0x24
c0d01c74:	1d01      	adds	r1, r0, #4
c0d01c76:	9109      	str	r1, [sp, #36]	; 0x24
c0d01c78:	6800      	ldr	r0, [r0, #0]
                    if((long)ulValue < 0)
c0d01c7a:	17c1      	asrs	r1, r0, #31
c0d01c7c:	1842      	adds	r2, r0, r1
c0d01c7e:	404a      	eors	r2, r1
c0d01c80:	0fc1      	lsrs	r1, r0, #31
c0d01c82:	2000      	movs	r0, #0
c0d01c84:	9000      	str	r0, [sp, #0]
c0d01c86:	270a      	movs	r7, #10
c0d01c88:	e00d      	b.n	c0d01ca6 <snprintf+0x18a>
c0d01c8a:	2025      	movs	r0, #37	; 0x25
c0d01c8c:	e0ea      	b.n	c0d01e64 <snprintf+0x348>
c0d01c8e:	4625      	mov	r5, r4
c0d01c90:	4a88      	ldr	r2, [pc, #544]	; (c0d01eb4 <snprintf+0x398>)
c0d01c92:	447a      	add	r2, pc
c0d01c94:	2300      	movs	r3, #0
c0d01c96:	e087      	b.n	c0d01da8 <snprintf+0x28c>
                    ulValue = va_arg(vaArgP, unsigned long);
c0d01c98:	9809      	ldr	r0, [sp, #36]	; 0x24
c0d01c9a:	1d01      	adds	r1, r0, #4
c0d01c9c:	9109      	str	r1, [sp, #36]	; 0x24
c0d01c9e:	6802      	ldr	r2, [r0, #0]
c0d01ca0:	2100      	movs	r1, #0
c0d01ca2:	270a      	movs	r7, #10
            ulCap = 0;
c0d01ca4:	9100      	str	r1, [sp, #0]
c0d01ca6:	9e07      	ldr	r6, [sp, #28]
                    // Determine the number of digits in the string version of
                    // the value.
                    //
convert:
                    for(ulIdx = 1;
                        (((ulIdx * ulBase) <= ulValue) &&
c0d01ca8:	9208      	str	r2, [sp, #32]
c0d01caa:	4297      	cmp	r7, r2
c0d01cac:	9503      	str	r5, [sp, #12]
c0d01cae:	9101      	str	r1, [sp, #4]
c0d01cb0:	d901      	bls.n	c0d01cb6 <snprintf+0x19a>
c0d01cb2:	2501      	movs	r5, #1
c0d01cb4:	e011      	b.n	c0d01cda <snprintf+0x1be>
                    for(ulIdx = 1;
c0d01cb6:	1e72      	subs	r2, r6, #1
c0d01cb8:	4638      	mov	r0, r7
c0d01cba:	4605      	mov	r5, r0
c0d01cbc:	4616      	mov	r6, r2
c0d01cbe:	2100      	movs	r1, #0
                        (((ulIdx * ulBase) <= ulValue) &&
c0d01cc0:	4638      	mov	r0, r7
c0d01cc2:	462a      	mov	r2, r5
c0d01cc4:	460b      	mov	r3, r1
c0d01cc6:	f002 fec5 	bl	c0d04a54 <__aeabi_lmul>
c0d01cca:	1e4a      	subs	r2, r1, #1
c0d01ccc:	4191      	sbcs	r1, r2
c0d01cce:	9a08      	ldr	r2, [sp, #32]
c0d01cd0:	4290      	cmp	r0, r2
c0d01cd2:	d802      	bhi.n	c0d01cda <snprintf+0x1be>
                    for(ulIdx = 1;
c0d01cd4:	1e72      	subs	r2, r6, #1
c0d01cd6:	2900      	cmp	r1, #0
c0d01cd8:	d0ef      	beq.n	c0d01cba <snprintf+0x19e>
c0d01cda:	9607      	str	r6, [sp, #28]
c0d01cdc:	2600      	movs	r6, #0
c0d01cde:	9901      	ldr	r1, [sp, #4]

                    //
                    // If the value is negative, reduce the count of padding
                    // characters needed.
                    //
                    if(ulNeg)
c0d01ce0:	2900      	cmp	r1, #0
c0d01ce2:	9402      	str	r4, [sp, #8]
c0d01ce4:	d101      	bne.n	c0d01cea <snprintf+0x1ce>
c0d01ce6:	460b      	mov	r3, r1
c0d01ce8:	e000      	b.n	c0d01cec <snprintf+0x1d0>
c0d01cea:	43f3      	mvns	r3, r6
c0d01cec:	9807      	ldr	r0, [sp, #28]
c0d01cee:	1a40      	subs	r0, r0, r1

                    //
                    // If the value is negative and the value is padded with
                    // zeros, then place the minus sign before the padding.
                    //
                    if(ulNeg && (cFill == '0'))
c0d01cf0:	2900      	cmp	r1, #0
c0d01cf2:	9c04      	ldr	r4, [sp, #16]
c0d01cf4:	d00a      	beq.n	c0d01d0c <snprintf+0x1f0>
c0d01cf6:	9903      	ldr	r1, [sp, #12]
c0d01cf8:	b2c9      	uxtb	r1, r1
c0d01cfa:	2600      	movs	r6, #0
c0d01cfc:	2930      	cmp	r1, #48	; 0x30
c0d01cfe:	4634      	mov	r4, r6
c0d01d00:	d104      	bne.n	c0d01d0c <snprintf+0x1f0>
c0d01d02:	a90a      	add	r1, sp, #40	; 0x28
c0d01d04:	222d      	movs	r2, #45	; 0x2d
                    {
                        //
                        // Place the minus sign in the output buffer.
                        //
                        pcBuf[ulPos++] = '-';
c0d01d06:	700a      	strb	r2, [r1, #0]
c0d01d08:	2601      	movs	r6, #1
c0d01d0a:	9c04      	ldr	r4, [sp, #16]

                    //
                    // Provide additional padding at the beginning of the
                    // string conversion if needed.
                    //
                    if((ulCount > 1) && (ulCount < 16))
c0d01d0c:	1e81      	subs	r1, r0, #2
c0d01d0e:	290d      	cmp	r1, #13
c0d01d10:	d80d      	bhi.n	c0d01d2e <snprintf+0x212>
c0d01d12:	1e41      	subs	r1, r0, #1
c0d01d14:	d00b      	beq.n	c0d01d2e <snprintf+0x212>
c0d01d16:	a80a      	add	r0, sp, #40	; 0x28
                    {
                        for(ulCount--; ulCount; ulCount--)
c0d01d18:	1980      	adds	r0, r0, r6
                        {
                            pcBuf[ulPos++] = cFill;
c0d01d1a:	9a03      	ldr	r2, [sp, #12]
c0d01d1c:	b2d2      	uxtb	r2, r2
c0d01d1e:	9303      	str	r3, [sp, #12]
c0d01d20:	f002 ff70 	bl	c0d04c04 <__aeabi_memset>
                        for(ulCount--; ulCount; ulCount--)
c0d01d24:	9807      	ldr	r0, [sp, #28]
c0d01d26:	1830      	adds	r0, r6, r0
c0d01d28:	9903      	ldr	r1, [sp, #12]
c0d01d2a:	1840      	adds	r0, r0, r1
c0d01d2c:	1e46      	subs	r6, r0, #1

                    //
                    // If the value is negative, then place the minus sign
                    // before the number.
                    //
                    if(ulNeg)
c0d01d2e:	2c00      	cmp	r4, #0
c0d01d30:	d103      	bne.n	c0d01d3a <snprintf+0x21e>
c0d01d32:	a80a      	add	r0, sp, #40	; 0x28
c0d01d34:	212d      	movs	r1, #45	; 0x2d
                    {
                        //
                        // Place the minus sign in the output buffer.
                        //
                        pcBuf[ulPos++] = '-';
c0d01d36:	5581      	strb	r1, [r0, r6]
c0d01d38:	1c76      	adds	r6, r6, #1
                    }

                    //
                    // Convert the value into a string.
                    //
                    for(; ulIdx; ulIdx /= ulBase)
c0d01d3a:	2d00      	cmp	r5, #0
c0d01d3c:	d01a      	beq.n	c0d01d74 <snprintf+0x258>
c0d01d3e:	9800      	ldr	r0, [sp, #0]
c0d01d40:	463c      	mov	r4, r7
c0d01d42:	2800      	cmp	r0, #0
c0d01d44:	d002      	beq.n	c0d01d4c <snprintf+0x230>
c0d01d46:	4f5f      	ldr	r7, [pc, #380]	; (c0d01ec4 <snprintf+0x3a8>)
c0d01d48:	447f      	add	r7, pc
c0d01d4a:	e001      	b.n	c0d01d50 <snprintf+0x234>
c0d01d4c:	4f5c      	ldr	r7, [pc, #368]	; (c0d01ec0 <snprintf+0x3a4>)
c0d01d4e:	447f      	add	r7, pc
c0d01d50:	9808      	ldr	r0, [sp, #32]
c0d01d52:	4629      	mov	r1, r5
c0d01d54:	f002 fe0a 	bl	c0d0496c <__udivsi3>
c0d01d58:	4621      	mov	r1, r4
c0d01d5a:	f002 fe43 	bl	c0d049e4 <__aeabi_uidivmod>
c0d01d5e:	5c78      	ldrb	r0, [r7, r1]
c0d01d60:	a90a      	add	r1, sp, #40	; 0x28
                    {
                        if (!ulCap) {
                          pcBuf[ulPos++] = g_pcHex[(ulValue / ulIdx) % ulBase];
c0d01d62:	5588      	strb	r0, [r1, r6]
                    for(; ulIdx; ulIdx /= ulBase)
c0d01d64:	4628      	mov	r0, r5
c0d01d66:	4621      	mov	r1, r4
c0d01d68:	f002 fe00 	bl	c0d0496c <__udivsi3>
c0d01d6c:	1c76      	adds	r6, r6, #1
c0d01d6e:	42ac      	cmp	r4, r5
c0d01d70:	4605      	mov	r5, r0
c0d01d72:	d9ed      	bls.n	c0d01d50 <snprintf+0x234>
c0d01d74:	9805      	ldr	r0, [sp, #20]
                    }

                    //
                    // Write the string.
                    //
                    ulPos = MIN(ulPos, str_size);
c0d01d76:	4286      	cmp	r6, r0
c0d01d78:	d300      	bcc.n	c0d01d7c <snprintf+0x260>
c0d01d7a:	4606      	mov	r6, r0
c0d01d7c:	a90a      	add	r1, sp, #40	; 0x28
c0d01d7e:	9d06      	ldr	r5, [sp, #24]
                    memmove(str, pcBuf, ulPos);
c0d01d80:	4628      	mov	r0, r5
c0d01d82:	4632      	mov	r2, r6
c0d01d84:	f002 ff3a 	bl	c0d04bfc <__aeabi_memmove>
c0d01d88:	9b05      	ldr	r3, [sp, #20]
                    str+= ulPos;
                    str_size -= ulPos;
c0d01d8a:	1b9b      	subs	r3, r3, r6
c0d01d8c:	9c02      	ldr	r4, [sp, #8]
c0d01d8e:	d100      	bne.n	c0d01d92 <snprintf+0x276>
c0d01d90:	e08a      	b.n	c0d01ea8 <snprintf+0x38c>
c0d01d92:	19ad      	adds	r5, r5, r6
c0d01d94:	4628      	mov	r0, r5
c0d01d96:	e06b      	b.n	c0d01e70 <snprintf+0x354>
c0d01d98:	4625      	mov	r5, r4
c0d01d9a:	4a47      	ldr	r2, [pc, #284]	; (c0d01eb8 <snprintf+0x39c>)
c0d01d9c:	447a      	add	r2, pc
c0d01d9e:	e002      	b.n	c0d01da6 <snprintf+0x28a>
c0d01da0:	4625      	mov	r5, r4
c0d01da2:	4a46      	ldr	r2, [pc, #280]	; (c0d01ebc <snprintf+0x3a0>)
c0d01da4:	447a      	add	r2, pc
c0d01da6:	9b04      	ldr	r3, [sp, #16]
                    pcStr = va_arg(vaArgP, char *);
c0d01da8:	9909      	ldr	r1, [sp, #36]	; 0x24
c0d01daa:	1d0c      	adds	r4, r1, #4
c0d01dac:	9409      	str	r4, [sp, #36]	; 0x24
                    switch(cStrlenSet) {
c0d01dae:	b2c0      	uxtb	r0, r0
                    pcStr = va_arg(vaArgP, char *);
c0d01db0:	6809      	ldr	r1, [r1, #0]
                    switch(cStrlenSet) {
c0d01db2:	2802      	cmp	r0, #2
c0d01db4:	d060      	beq.n	c0d01e78 <snprintf+0x35c>
c0d01db6:	2801      	cmp	r0, #1
c0d01db8:	462c      	mov	r4, r5
c0d01dba:	d00a      	beq.n	c0d01dd2 <snprintf+0x2b6>
c0d01dbc:	2800      	cmp	r0, #0
c0d01dbe:	4637      	mov	r7, r6
c0d01dc0:	d107      	bne.n	c0d01dd2 <snprintf+0x2b6>
c0d01dc2:	4625      	mov	r5, r4
c0d01dc4:	2000      	movs	r0, #0
                        for(ulIdx = 0; pcStr[ulIdx] != '\0'; ulIdx++)
c0d01dc6:	5c0c      	ldrb	r4, [r1, r0]
c0d01dc8:	1c40      	adds	r0, r0, #1
c0d01dca:	2c00      	cmp	r4, #0
c0d01dcc:	d1fb      	bne.n	c0d01dc6 <snprintf+0x2aa>
                    switch(ulBase) {
c0d01dce:	1e47      	subs	r7, r0, #1
c0d01dd0:	462c      	mov	r4, r5
c0d01dd2:	2b00      	cmp	r3, #0
c0d01dd4:	d01f      	beq.n	c0d01e16 <snprintf+0x2fa>
                        for (ulCount = 0; ulCount < ulIdx; ulCount++) {
c0d01dd6:	2f00      	cmp	r7, #0
c0d01dd8:	9b05      	ldr	r3, [sp, #20]
c0d01dda:	d01a      	beq.n	c0d01e12 <snprintf+0x2f6>
c0d01ddc:	0078      	lsls	r0, r7, #1
c0d01dde:	1a18      	subs	r0, r3, r0
c0d01de0:	9008      	str	r0, [sp, #32]
                          if (str_size < 2) {
c0d01de2:	2b01      	cmp	r3, #1
c0d01de4:	9e06      	ldr	r6, [sp, #24]
c0d01de6:	d95f      	bls.n	c0d01ea8 <snprintf+0x38c>
c0d01de8:	4618      	mov	r0, r3
c0d01dea:	780b      	ldrb	r3, [r1, #0]
c0d01dec:	4625      	mov	r5, r4
                          nibble1 = (pcStr[ulCount]>>4)&0xF;
c0d01dee:	091c      	lsrs	r4, r3, #4
c0d01df0:	5d14      	ldrb	r4, [r2, r4]
c0d01df2:	7034      	strb	r4, [r6, #0]
c0d01df4:	240f      	movs	r4, #15
                          nibble2 = pcStr[ulCount]&0xF;
c0d01df6:	401c      	ands	r4, r3
c0d01df8:	5d13      	ldrb	r3, [r2, r4]
                                str[1] = g_pcHex[nibble2];
c0d01dfa:	7073      	strb	r3, [r6, #1]
                          if (str_size == 0) {
c0d01dfc:	2802      	cmp	r0, #2
c0d01dfe:	d053      	beq.n	c0d01ea8 <snprintf+0x38c>
c0d01e00:	462c      	mov	r4, r5
c0d01e02:	4603      	mov	r3, r0
c0d01e04:	1e83      	subs	r3, r0, #2
                          str+= 2;
c0d01e06:	1cb6      	adds	r6, r6, #2
c0d01e08:	9606      	str	r6, [sp, #24]
                        for (ulCount = 0; ulCount < ulIdx; ulCount++) {
c0d01e0a:	1c49      	adds	r1, r1, #1
c0d01e0c:	1e7f      	subs	r7, r7, #1
c0d01e0e:	d1e8      	bne.n	c0d01de2 <snprintf+0x2c6>
c0d01e10:	9b08      	ldr	r3, [sp, #32]
c0d01e12:	9806      	ldr	r0, [sp, #24]
c0d01e14:	e02c      	b.n	c0d01e70 <snprintf+0x354>
c0d01e16:	9805      	ldr	r0, [sp, #20]
                        ulIdx = MIN(ulIdx, str_size);
c0d01e18:	4287      	cmp	r7, r0
c0d01e1a:	463e      	mov	r6, r7
c0d01e1c:	d301      	bcc.n	c0d01e22 <snprintf+0x306>
c0d01e1e:	4606      	mov	r6, r0
c0d01e20:	4607      	mov	r7, r0
c0d01e22:	9d06      	ldr	r5, [sp, #24]
                        memmove(str, pcStr, ulIdx);
c0d01e24:	4628      	mov	r0, r5
c0d01e26:	4632      	mov	r2, r6
c0d01e28:	f002 fee8 	bl	c0d04bfc <__aeabi_memmove>
c0d01e2c:	9b05      	ldr	r3, [sp, #20]
                        str_size -= ulIdx;
c0d01e2e:	1b9b      	subs	r3, r3, r6
                        if (str_size == 0) {
c0d01e30:	d03a      	beq.n	c0d01ea8 <snprintf+0x38c>
c0d01e32:	19ed      	adds	r5, r5, r7
c0d01e34:	9907      	ldr	r1, [sp, #28]
                    if(ulCount > ulIdx)
c0d01e36:	42b1      	cmp	r1, r6
c0d01e38:	4628      	mov	r0, r5
c0d01e3a:	d919      	bls.n	c0d01e70 <snprintf+0x354>
                        ulCount -= ulIdx;
c0d01e3c:	1b8d      	subs	r5, r1, r6
                        ulCount = MIN(ulCount, str_size);
c0d01e3e:	429d      	cmp	r5, r3
c0d01e40:	d300      	bcc.n	c0d01e44 <snprintf+0x328>
c0d01e42:	461d      	mov	r5, r3
c0d01e44:	2220      	movs	r2, #32
c0d01e46:	4606      	mov	r6, r0
                        memset(str, ' ', ulCount);
c0d01e48:	4629      	mov	r1, r5
c0d01e4a:	461f      	mov	r7, r3
c0d01e4c:	f002 feda 	bl	c0d04c04 <__aeabi_memset>
c0d01e50:	463b      	mov	r3, r7
                        str_size -= ulCount;
c0d01e52:	1b7b      	subs	r3, r7, r5
                        if (str_size == 0) {
c0d01e54:	d028      	beq.n	c0d01ea8 <snprintf+0x38c>
c0d01e56:	1976      	adds	r6, r6, r5
c0d01e58:	4630      	mov	r0, r6
c0d01e5a:	e009      	b.n	c0d01e70 <snprintf+0x354>
                    ulValue = va_arg(vaArgP, unsigned long);
c0d01e5c:	9809      	ldr	r0, [sp, #36]	; 0x24
c0d01e5e:	1d01      	adds	r1, r0, #4
c0d01e60:	9109      	str	r1, [sp, #36]	; 0x24
c0d01e62:	6800      	ldr	r0, [r0, #0]
c0d01e64:	9906      	ldr	r1, [sp, #24]
c0d01e66:	7008      	strb	r0, [r1, #0]
c0d01e68:	1e5b      	subs	r3, r3, #1
c0d01e6a:	d01d      	beq.n	c0d01ea8 <snprintf+0x38c>
c0d01e6c:	1c49      	adds	r1, r1, #1
c0d01e6e:	4608      	mov	r0, r1
    while(*format)
c0d01e70:	7821      	ldrb	r1, [r4, #0]
c0d01e72:	2900      	cmp	r1, #0
c0d01e74:	d018      	beq.n	c0d01ea8 <snprintf+0x38c>
c0d01e76:	e66d      	b.n	c0d01b54 <snprintf+0x38>
                        if (pcStr[0] == '\0') {
c0d01e78:	7808      	ldrb	r0, [r1, #0]
c0d01e7a:	2800      	cmp	r0, #0
c0d01e7c:	462c      	mov	r4, r5
c0d01e7e:	d002      	beq.n	c0d01e86 <snprintf+0x36a>
c0d01e80:	9806      	ldr	r0, [sp, #24]
c0d01e82:	9b05      	ldr	r3, [sp, #20]
c0d01e84:	e7f4      	b.n	c0d01e70 <snprintf+0x354>
c0d01e86:	9805      	ldr	r0, [sp, #20]
                          ulStrlen = MIN(ulStrlen, str_size);
c0d01e88:	4287      	cmp	r7, r0
c0d01e8a:	d300      	bcc.n	c0d01e8e <snprintf+0x372>
c0d01e8c:	4607      	mov	r7, r0
c0d01e8e:	2220      	movs	r2, #32
c0d01e90:	9d06      	ldr	r5, [sp, #24]
                          memset(str, ' ', ulStrlen);
c0d01e92:	4628      	mov	r0, r5
c0d01e94:	4639      	mov	r1, r7
c0d01e96:	f002 feb5 	bl	c0d04c04 <__aeabi_memset>
c0d01e9a:	9b05      	ldr	r3, [sp, #20]
                          str_size -= ulStrlen;
c0d01e9c:	1bdb      	subs	r3, r3, r7
c0d01e9e:	d1c8      	bne.n	c0d01e32 <snprintf+0x316>
c0d01ea0:	e002      	b.n	c0d01ea8 <snprintf+0x38c>
c0d01ea2:	212a      	movs	r1, #42	; 0x2a
c0d01ea4:	9806      	ldr	r0, [sp, #24]
c0d01ea6:	e7e4      	b.n	c0d01e72 <snprintf+0x356>
c0d01ea8:	2000      	movs	r0, #0
    // End the varargs processing.
    //
    va_end(vaArgP);

    return 0;
}
c0d01eaa:	b00e      	add	sp, #56	; 0x38
c0d01eac:	bcf0      	pop	{r4, r5, r6, r7}
c0d01eae:	bc02      	pop	{r1}
c0d01eb0:	b001      	add	sp, #4
c0d01eb2:	4708      	bx	r1
c0d01eb4:	00003691 	.word	0x00003691
c0d01eb8:	00003597 	.word	0x00003597
c0d01ebc:	0000357f 	.word	0x0000357f
c0d01ec0:	000035d5 	.word	0x000035d5
c0d01ec4:	000035eb 	.word	0x000035eb

c0d01ec8 <parse_length>:
int parse_i64(Parser* parser, int64_t* value) {
    uint64_t* as_u64 = (uint64_t*) value;
    return parse_u64(parser, as_u64);
}

int parse_length(Parser* parser, size_t* value) {
c0d01ec8:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d01eca:	4602      	mov	r2, r0
    return parser->buffer_length < num ? 1 : 0;
c0d01ecc:	6843      	ldr	r3, [r0, #4]
c0d01ece:	2001      	movs	r0, #1
c0d01ed0:	2b00      	cmp	r3, #0
c0d01ed2:	d00d      	beq.n	c0d01ef0 <parse_length+0x28>
    *value = *parser->buffer;
c0d01ed4:	6814      	ldr	r4, [r2, #0]
c0d01ed6:	7825      	ldrb	r5, [r4, #0]
    parser->buffer_length -= num;
c0d01ed8:	1e5b      	subs	r3, r3, #1
    parser->buffer += num;
c0d01eda:	1c66      	adds	r6, r4, #1
c0d01edc:	6016      	str	r6, [r2, #0]
    parser->buffer_length -= num;
c0d01ede:	6053      	str	r3, [r2, #4]
    *value = *parser->buffer;
c0d01ee0:	b26d      	sxtb	r5, r5
c0d01ee2:	237f      	movs	r3, #127	; 0x7f
    uint8_t value_u8;
    BAIL_IF(parse_u8(parser, &value_u8));
    *value = value_u8 & 0x7f;
c0d01ee4:	402b      	ands	r3, r5
c0d01ee6:	600b      	str	r3, [r1, #0]
c0d01ee8:	2300      	movs	r3, #0

    if (value_u8 & 0x80) {
c0d01eea:	2d00      	cmp	r5, #0
c0d01eec:	d401      	bmi.n	c0d01ef2 <parse_length+0x2a>
c0d01eee:	4618      	mov	r0, r3
            BAIL_IF(parse_u8(parser, &value_u8));
            *value = ((value_u8 & 0x7f) << 14) | *value;
        }
    }
    return 0;
}
c0d01ef0:	bdf0      	pop	{r4, r5, r6, r7, pc}
    return parser->buffer_length < num ? 1 : 0;
c0d01ef2:	6855      	ldr	r5, [r2, #4]
c0d01ef4:	2d00      	cmp	r5, #0
c0d01ef6:	d0fb      	beq.n	c0d01ef0 <parse_length+0x28>
c0d01ef8:	2001      	movs	r0, #1
    *value = *parser->buffer;
c0d01efa:	5626      	ldrsb	r6, [r4, r0]
    parser->buffer_length -= num;
c0d01efc:	1e6d      	subs	r5, r5, #1
    parser->buffer += num;
c0d01efe:	1ca7      	adds	r7, r4, #2
c0d01f00:	6017      	str	r7, [r2, #0]
    parser->buffer_length -= num;
c0d01f02:	6055      	str	r5, [r2, #4]
        *value = ((value_u8 & 0x7f) << 7) | *value;
c0d01f04:	0675      	lsls	r5, r6, #25
c0d01f06:	0cad      	lsrs	r5, r5, #18
c0d01f08:	680f      	ldr	r7, [r1, #0]
c0d01f0a:	432f      	orrs	r7, r5
c0d01f0c:	600f      	str	r7, [r1, #0]
        if (value_u8 & 0x80) {
c0d01f0e:	2e00      	cmp	r6, #0
c0d01f10:	d5ed      	bpl.n	c0d01eee <parse_length+0x26>
    return parser->buffer_length < num ? 1 : 0;
c0d01f12:	6855      	ldr	r5, [r2, #4]
c0d01f14:	2d00      	cmp	r5, #0
c0d01f16:	d0eb      	beq.n	c0d01ef0 <parse_length+0x28>
    *value = *parser->buffer;
c0d01f18:	78a0      	ldrb	r0, [r4, #2]
    parser->buffer_length -= num;
c0d01f1a:	1e6d      	subs	r5, r5, #1
    parser->buffer += num;
c0d01f1c:	1ce4      	adds	r4, r4, #3
c0d01f1e:	c230      	stmia	r2!, {r4, r5}
            *value = ((value_u8 & 0x7f) << 14) | *value;
c0d01f20:	680a      	ldr	r2, [r1, #0]
c0d01f22:	0640      	lsls	r0, r0, #25
c0d01f24:	0ac0      	lsrs	r0, r0, #11
c0d01f26:	4310      	orrs	r0, r2
c0d01f28:	6008      	str	r0, [r1, #0]
c0d01f2a:	e7e0      	b.n	c0d01eee <parse_length+0x26>

c0d01f2c <pic_internal>:
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"
__attribute__((naked)) void *pic_internal(void *link_address)
{
  // compute the delta offset between LinkMemAddr & ExecMemAddr
  __asm volatile ("mov r2, pc\n");
c0d01f2c:	467a      	mov	r2, pc
  __asm volatile ("ldr r1, =pic_internal\n");
c0d01f2e:	4902      	ldr	r1, [pc, #8]	; (c0d01f38 <pic_internal+0xc>)
  __asm volatile ("adds r1, r1, #3\n");
c0d01f30:	1cc9      	adds	r1, r1, #3
  __asm volatile ("subs r1, r1, r2\n");
c0d01f32:	1a89      	subs	r1, r1, r2

  // adjust value of the given parameter
  __asm volatile ("subs r0, r0, r1\n");
c0d01f34:	1a40      	subs	r0, r0, r1
  __asm volatile ("bx lr\n");
c0d01f36:	4770      	bx	lr
c0d01f38:	c0d01f2d 	.word	0xc0d01f2d

c0d01f3c <pic>:
extern void _nvram;
extern void _envram;

#if defined(ST31)

void *pic(void *link_address) {
c0d01f3c:	b580      	push	{r7, lr}
  // check if in the LINKED TEXT zone
  if (link_address >= &_nvram && link_address < &_envram) {
c0d01f3e:	4904      	ldr	r1, [pc, #16]	; (c0d01f50 <pic+0x14>)
c0d01f40:	4288      	cmp	r0, r1
c0d01f42:	d304      	bcc.n	c0d01f4e <pic+0x12>
c0d01f44:	4903      	ldr	r1, [pc, #12]	; (c0d01f54 <pic+0x18>)
c0d01f46:	4288      	cmp	r0, r1
c0d01f48:	d201      	bcs.n	c0d01f4e <pic+0x12>
    link_address = pic_internal(link_address);
c0d01f4a:	f7ff ffef 	bl	c0d01f2c <pic_internal>
  }

  return link_address;
c0d01f4e:	bd80      	pop	{r7, pc}
c0d01f50:	c0d00000 	.word	0xc0d00000
c0d01f54:	c0d05b00 	.word	0xc0d05b00

c0d01f58 <print_token_amount>:

int print_token_amount(uint64_t amount,
                       const char *const asset,
                       uint8_t decimals,
                       char *out,
                       const size_t out_length) {
c0d01f58:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d01f5a:	b089      	sub	sp, #36	; 0x24
c0d01f5c:	460e      	mov	r6, r1
c0d01f5e:	990f      	ldr	r1, [sp, #60]	; 0x3c
c0d01f60:	2900      	cmp	r1, #0
c0d01f62:	d458      	bmi.n	c0d02016 <print_token_amount+0xbe>
c0d01f64:	4614      	mov	r4, r2
c0d01f66:	9d0e      	ldr	r5, [sp, #56]	; 0x38
    uint64_t dVal = amount;
    const int outlen = (int) out_length;
    int i = 0;
    int min_chars = decimals + 1;

    if (i < (outlen - 1)) {
c0d01f68:	2902      	cmp	r1, #2
c0d01f6a:	db56      	blt.n	c0d0201a <print_token_amount+0xc2>
c0d01f6c:	4607      	mov	r7, r0
c0d01f6e:	9401      	str	r4, [sp, #4]
c0d01f70:	9308      	str	r3, [sp, #32]
c0d01f72:	1c58      	adds	r0, r3, #1
c0d01f74:	9002      	str	r0, [sp, #8]
c0d01f76:	2000      	movs	r0, #0
c0d01f78:	9504      	str	r5, [sp, #16]
c0d01f7a:	9103      	str	r1, [sp, #12]
c0d01f7c:	9b08      	ldr	r3, [sp, #32]
        do {
            if (i == decimals) {
c0d01f7e:	4298      	cmp	r0, r3
c0d01f80:	d102      	bne.n	c0d01f88 <print_token_amount+0x30>
c0d01f82:	202e      	movs	r0, #46	; 0x2e
                out[i] = '.';
c0d01f84:	54e8      	strb	r0, [r5, r3]
c0d01f86:	9802      	ldr	r0, [sp, #8]
c0d01f88:	9007      	str	r0, [sp, #28]
c0d01f8a:	250a      	movs	r5, #10
c0d01f8c:	2400      	movs	r4, #0
                i += 1;
            }
            out[i] = (dVal % 10) + '0';
            dVal /= 10;
c0d01f8e:	4638      	mov	r0, r7
c0d01f90:	4631      	mov	r1, r6
c0d01f92:	462a      	mov	r2, r5
c0d01f94:	4623      	mov	r3, r4
c0d01f96:	f002 fd3d 	bl	c0d04a14 <__aeabi_uldivmod>
c0d01f9a:	9006      	str	r0, [sp, #24]
c0d01f9c:	9105      	str	r1, [sp, #20]
c0d01f9e:	462a      	mov	r2, r5
c0d01fa0:	9d04      	ldr	r5, [sp, #16]
c0d01fa2:	4623      	mov	r3, r4
c0d01fa4:	f002 fd56 	bl	c0d04a54 <__aeabi_lmul>
c0d01fa8:	9b07      	ldr	r3, [sp, #28]
c0d01faa:	1a38      	subs	r0, r7, r0
c0d01fac:	2130      	movs	r1, #48	; 0x30
            out[i] = (dVal % 10) + '0';
c0d01fae:	4301      	orrs	r1, r0
c0d01fb0:	54e9      	strb	r1, [r5, r3]
c0d01fb2:	2101      	movs	r1, #1
c0d01fb4:	9808      	ldr	r0, [sp, #32]
c0d01fb6:	4283      	cmp	r3, r0
c0d01fb8:	460a      	mov	r2, r1
c0d01fba:	da00      	bge.n	c0d01fbe <print_token_amount+0x66>
c0d01fbc:	4622      	mov	r2, r4
            i += 1;
        } while ((dVal > 0 || i < min_chars) && i < outlen);
c0d01fbe:	3f0a      	subs	r7, #10
c0d01fc0:	41a6      	sbcs	r6, r4
c0d01fc2:	d300      	bcc.n	c0d01fc6 <print_token_amount+0x6e>
c0d01fc4:	4621      	mov	r1, r4
            i += 1;
c0d01fc6:	1c58      	adds	r0, r3, #1
        } while ((dVal > 0 || i < min_chars) && i < outlen);
c0d01fc8:	4211      	tst	r1, r2
c0d01fca:	9903      	ldr	r1, [sp, #12]
c0d01fcc:	d103      	bne.n	c0d01fd6 <print_token_amount+0x7e>
c0d01fce:	4288      	cmp	r0, r1
c0d01fd0:	9f06      	ldr	r7, [sp, #24]
c0d01fd2:	9e05      	ldr	r6, [sp, #20]
c0d01fd4:	dbd2      	blt.n	c0d01f7c <print_token_amount+0x24>
c0d01fd6:	4288      	cmp	r0, r1
c0d01fd8:	da41      	bge.n	c0d0205e <print_token_amount+0x106>
    }
    BAIL_IF(i >= outlen);
    // Reverse order
    int j, k;
    for (j = 0, k = i - 1; j < k; j++, k--) {
c0d01fda:	2b01      	cmp	r3, #1
c0d01fdc:	db22      	blt.n	c0d02024 <print_token_amount+0xcc>
c0d01fde:	2000      	movs	r0, #0
c0d01fe0:	43c1      	mvns	r1, r0
c0d01fe2:	2201      	movs	r2, #1
c0d01fe4:	461f      	mov	r7, r3
        char tmp = out[j];
c0d01fe6:	18ac      	adds	r4, r5, r2
c0d01fe8:	5c65      	ldrb	r5, [r4, r1]
        out[j] = out[k];
c0d01fea:	9e04      	ldr	r6, [sp, #16]
c0d01fec:	5cf6      	ldrb	r6, [r6, r3]
c0d01fee:	5466      	strb	r6, [r4, r1]
        out[k] = tmp;
c0d01ff0:	9c04      	ldr	r4, [sp, #16]
c0d01ff2:	54e5      	strb	r5, [r4, r3]
c0d01ff4:	9d04      	ldr	r5, [sp, #16]
    for (j = 0, k = i - 1; j < k; j++, k--) {
c0d01ff6:	1c54      	adds	r4, r2, #1
c0d01ff8:	1e5b      	subs	r3, r3, #1
c0d01ffa:	429a      	cmp	r2, r3
c0d01ffc:	4622      	mov	r2, r4
c0d01ffe:	dbf2      	blt.n	c0d01fe6 <print_token_amount+0x8e>
c0d02000:	463b      	mov	r3, r7
    }
    // Strip trailing 0s
    for (i -= 1; i > 0; i--) {
c0d02002:	2f01      	cmp	r7, #1
c0d02004:	db10      	blt.n	c0d02028 <print_token_amount+0xd0>
c0d02006:	9c01      	ldr	r4, [sp, #4]
        if (out[i] != '0') break;
c0d02008:	5ce9      	ldrb	r1, [r5, r3]
c0d0200a:	2930      	cmp	r1, #48	; 0x30
c0d0200c:	d10d      	bne.n	c0d0202a <print_token_amount+0xd2>
    for (i -= 1; i > 0; i--) {
c0d0200e:	1e5b      	subs	r3, r3, #1
c0d02010:	dcfa      	bgt.n	c0d02008 <print_token_amount+0xb0>
c0d02012:	4603      	mov	r3, r0
c0d02014:	e009      	b.n	c0d0202a <print_token_amount+0xd2>
c0d02016:	0fc8      	lsrs	r0, r1, #31
c0d02018:	e025      	b.n	c0d02066 <print_token_amount+0x10e>
c0d0201a:	2901      	cmp	r1, #1
c0d0201c:	d11f      	bne.n	c0d0205e <print_token_amount+0x106>
c0d0201e:	2000      	movs	r0, #0
c0d02020:	43c3      	mvns	r3, r0
c0d02022:	e003      	b.n	c0d0202c <print_token_amount+0xd4>
c0d02024:	9c01      	ldr	r4, [sp, #4]
c0d02026:	e001      	b.n	c0d0202c <print_token_amount+0xd4>
c0d02028:	9c01      	ldr	r4, [sp, #4]
c0d0202a:	9903      	ldr	r1, [sp, #12]
    }
    i += 1;

    // Strip trailing .
    if (out[i - 1] == '.') i -= 1;
c0d0202c:	5ce8      	ldrb	r0, [r5, r3]
c0d0202e:	282e      	cmp	r0, #46	; 0x2e
c0d02030:	d000      	beq.n	c0d02034 <print_token_amount+0xdc>
c0d02032:	1c5b      	adds	r3, r3, #1

    if (asset) {
c0d02034:	2c00      	cmp	r4, #0
c0d02036:	d014      	beq.n	c0d02062 <print_token_amount+0x10a>
        const int asset_length = strlen(asset);
c0d02038:	4620      	mov	r0, r4
c0d0203a:	460e      	mov	r6, r1
c0d0203c:	461f      	mov	r7, r3
c0d0203e:	f002 ff03 	bl	c0d04e48 <strlen>
        // Check buffer has space
        BAIL_IF((i + 1 + asset_length + 1) > outlen);
c0d02042:	1c79      	adds	r1, r7, #1
c0d02044:	1842      	adds	r2, r0, r1
c0d02046:	42b2      	cmp	r2, r6
c0d02048:	da09      	bge.n	c0d0205e <print_token_amount+0x106>
c0d0204a:	2220      	movs	r2, #32
        // Qualify amount
        out[i++] = ' ';
c0d0204c:	55ea      	strb	r2, [r5, r7]
        strncpy(out + i, asset, asset_length + 1);
c0d0204e:	1869      	adds	r1, r5, r1
c0d02050:	1c42      	adds	r2, r0, #1
c0d02052:	4608      	mov	r0, r1
c0d02054:	4621      	mov	r1, r4
c0d02056:	f002 ff25 	bl	c0d04ea4 <strncpy>
c0d0205a:	2000      	movs	r0, #0
c0d0205c:	e003      	b.n	c0d02066 <print_token_amount+0x10e>
c0d0205e:	2001      	movs	r0, #1
c0d02060:	e001      	b.n	c0d02066 <print_token_amount+0x10e>
c0d02062:	2000      	movs	r0, #0
    } else {
        out[i] = '\0';
c0d02064:	54e8      	strb	r0, [r5, r3]
    }

    return 0;
}
c0d02066:	b009      	add	sp, #36	; 0x24
c0d02068:	bdf0      	pop	{r4, r5, r6, r7, pc}
	...

c0d0206c <print_amount>:

#define ELF_DECIMALS 8
int print_amount(uint64_t amount, char *out, size_t out_length) {
c0d0206c:	b580      	push	{r7, lr}
c0d0206e:	b082      	sub	sp, #8
    return print_token_amount(amount, "ELF", ELF_DECIMALS, out, out_length);
c0d02070:	9200      	str	r2, [sp, #0]
c0d02072:	9301      	str	r3, [sp, #4]
c0d02074:	4a03      	ldr	r2, [pc, #12]	; (c0d02084 <print_amount+0x18>)
c0d02076:	447a      	add	r2, pc
c0d02078:	2308      	movs	r3, #8
c0d0207a:	f7ff ff6d 	bl	c0d01f58 <print_token_amount>
c0d0207e:	b002      	add	sp, #8
c0d02080:	bd80      	pop	{r7, pc}
c0d02082:	46c0      	nop			; (mov r8, r8)
c0d02084:	000032cd 	.word	0x000032cd

c0d02088 <print_sized_string>:
}

int print_sized_string(const SizedString *string, char *out, size_t out_length) {
c0d02088:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0208a:	b081      	sub	sp, #4
c0d0208c:	4615      	mov	r5, r2
c0d0208e:	460c      	mov	r4, r1
c0d02090:	4606      	mov	r6, r0
    size_t len = MIN(out_length, string->length);
c0d02092:	6800      	ldr	r0, [r0, #0]
c0d02094:	6871      	ldr	r1, [r6, #4]
c0d02096:	2700      	movs	r7, #0
c0d02098:	1a12      	subs	r2, r2, r0
c0d0209a:	463a      	mov	r2, r7
c0d0209c:	418a      	sbcs	r2, r1
c0d0209e:	462a      	mov	r2, r5
c0d020a0:	d300      	bcc.n	c0d020a4 <print_sized_string+0x1c>
c0d020a2:	4602      	mov	r2, r0
    strncpy(out, string->string, len);
c0d020a4:	68b1      	ldr	r1, [r6, #8]
c0d020a6:	4620      	mov	r0, r4
c0d020a8:	f002 fefc 	bl	c0d04ea4 <strncpy>
    if (string->length < out_length) {
c0d020ac:	6831      	ldr	r1, [r6, #0]
c0d020ae:	6870      	ldr	r0, [r6, #4]
c0d020b0:	1b4a      	subs	r2, r1, r5
c0d020b2:	41b8      	sbcs	r0, r7
c0d020b4:	d201      	bcs.n	c0d020ba <print_sized_string+0x32>
c0d020b6:	4638      	mov	r0, r7
c0d020b8:	e005      	b.n	c0d020c6 <print_sized_string+0x3e>
        out[string->length] = '\0';
        return 0;
    } else {
        out[--out_length] = '\0';
c0d020ba:	1e68      	subs	r0, r5, #1
c0d020bc:	5427      	strb	r7, [r4, r0]
        if (out_length != 0) {
c0d020be:	d004      	beq.n	c0d020ca <print_sized_string+0x42>
            /* signal truncation */
            out[out_length - 1] = '~';
c0d020c0:	1ea9      	subs	r1, r5, #2
c0d020c2:	2001      	movs	r0, #1
c0d020c4:	277e      	movs	r7, #126	; 0x7e
c0d020c6:	5467      	strb	r7, [r4, r1]
c0d020c8:	e000      	b.n	c0d020cc <print_sized_string+0x44>
c0d020ca:	2001      	movs	r0, #1
        }
        return 1;
    }
}
c0d020cc:	b001      	add	sp, #4
c0d020ce:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d020d0 <print_string>:

int print_string(const char *in, char *out, size_t out_length) {
c0d020d0:	b5b0      	push	{r4, r5, r7, lr}
c0d020d2:	4614      	mov	r4, r2
c0d020d4:	460d      	mov	r5, r1
c0d020d6:	4601      	mov	r1, r0
    strncpy(out, in, out_length);
c0d020d8:	4628      	mov	r0, r5
c0d020da:	f002 fee3 	bl	c0d04ea4 <strncpy>
    int rc = (out[--out_length] != '\0');
c0d020de:	1e61      	subs	r1, r4, #1
c0d020e0:	5c68      	ldrb	r0, [r5, r1]
    if (rc) {
c0d020e2:	2800      	cmp	r0, #0
c0d020e4:	d007      	beq.n	c0d020f6 <print_string+0x26>
c0d020e6:	2200      	movs	r2, #0
        /* ensure the output is NUL terminated */
        out[out_length] = '\0';
c0d020e8:	546a      	strb	r2, [r5, r1]
        if (out_length != 0) {
c0d020ea:	2900      	cmp	r1, #0
c0d020ec:	d003      	beq.n	c0d020f6 <print_string+0x26>
            /* signal truncation */
            out[out_length - 1] = '~';
c0d020ee:	1961      	adds	r1, r4, r5
c0d020f0:	1e89      	subs	r1, r1, #2
c0d020f2:	227e      	movs	r2, #126	; 0x7e
c0d020f4:	700a      	strb	r2, [r1, #0]
    int rc = (out[--out_length] != '\0');
c0d020f6:	1e41      	subs	r1, r0, #1
c0d020f8:	4188      	sbcs	r0, r1
        }
    }
    return rc;
c0d020fa:	bdb0      	pop	{r4, r5, r7, pc}

c0d020fc <print_summary>:

int print_summary(const char *in,
                  char *out,
                  size_t out_length,
                  size_t left_length,
                  size_t right_length) {
c0d020fc:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d020fe:	b083      	sub	sp, #12
c0d02100:	4606      	mov	r6, r0
c0d02102:	9d08      	ldr	r5, [sp, #32]
    BAIL_IF(out_length <= (left_length + right_length + 2));
c0d02104:	1958      	adds	r0, r3, r5
c0d02106:	1c80      	adds	r0, r0, #2
c0d02108:	4290      	cmp	r0, r2
c0d0210a:	d221      	bcs.n	c0d02150 <print_summary+0x54>
c0d0210c:	461f      	mov	r7, r3
c0d0210e:	4614      	mov	r4, r2
c0d02110:	9001      	str	r0, [sp, #4]
    size_t in_length = strlen(in);
c0d02112:	4630      	mov	r0, r6
c0d02114:	9102      	str	r1, [sp, #8]
c0d02116:	f002 fe97 	bl	c0d04e48 <strlen>
c0d0211a:	9902      	ldr	r1, [sp, #8]
c0d0211c:	4602      	mov	r2, r0
    if ((in_length + 1) > out_length) {
c0d0211e:	1c40      	adds	r0, r0, #1
c0d02120:	42a0      	cmp	r0, r4
c0d02122:	d917      	bls.n	c0d02154 <print_summary+0x58>
        memcpy(out, in, left_length);
c0d02124:	4608      	mov	r0, r1
c0d02126:	460c      	mov	r4, r1
c0d02128:	4631      	mov	r1, r6
c0d0212a:	9200      	str	r2, [sp, #0]
c0d0212c:	463a      	mov	r2, r7
c0d0212e:	f002 fd61 	bl	c0d04bf4 <__aeabi_memcpy>
c0d02132:	202e      	movs	r0, #46	; 0x2e
        out[left_length] = '.';
c0d02134:	55e0      	strb	r0, [r4, r7]
c0d02136:	19e2      	adds	r2, r4, r7
        out[left_length + 1] = '.';
c0d02138:	7050      	strb	r0, [r2, #1]
        memcpy(out + left_length + 2, in + in_length - right_length, right_length);
c0d0213a:	9800      	ldr	r0, [sp, #0]
c0d0213c:	1830      	adds	r0, r6, r0
c0d0213e:	1b41      	subs	r1, r0, r5
c0d02140:	1c90      	adds	r0, r2, #2
c0d02142:	462a      	mov	r2, r5
c0d02144:	f002 fd56 	bl	c0d04bf4 <__aeabi_memcpy>
c0d02148:	2000      	movs	r0, #0
        out[left_length + right_length + 2] = '\0';
c0d0214a:	9901      	ldr	r1, [sp, #4]
c0d0214c:	5460      	strb	r0, [r4, r1]
c0d0214e:	e006      	b.n	c0d0215e <print_summary+0x62>
c0d02150:	2001      	movs	r0, #1
c0d02152:	e004      	b.n	c0d0215e <print_summary+0x62>
    } else {
        print_string(in, out, out_length);
c0d02154:	4630      	mov	r0, r6
c0d02156:	4622      	mov	r2, r4
c0d02158:	f7ff ffba 	bl	c0d020d0 <print_string>
c0d0215c:	2000      	movs	r0, #0
    }

    return 0;
}
c0d0215e:	b003      	add	sp, #12
c0d02160:	bdf0      	pop	{r4, r5, r6, r7, pc}
	...

c0d02164 <encode_base58>:
                                       'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q',
                                       'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c',
                                       'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'm', 'n', 'o', 'p',
                                       'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};

int encode_base58(const void *in, size_t length, char *out, size_t maxoutlen) {
c0d02164:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d02166:	b0a7      	sub	sp, #156	; 0x9c
c0d02168:	460c      	mov	r4, r1
    uint8_t tmp[64];
    uint8_t buffer[64];
    uint8_t j;
    size_t start_at;
    size_t zero_count = 0;
    if (length > sizeof(tmp)) {
c0d0216a:	2940      	cmp	r1, #64	; 0x40
c0d0216c:	d901      	bls.n	c0d02172 <encode_base58+0xe>
c0d0216e:	2002      	movs	r0, #2
c0d02170:	e071      	b.n	c0d02256 <encode_base58+0xf2>
c0d02172:	4601      	mov	r1, r0
c0d02174:	9302      	str	r3, [sp, #8]
c0d02176:	9201      	str	r2, [sp, #4]
c0d02178:	a817      	add	r0, sp, #92	; 0x5c
        return INVALID_PARAMETER;
    }
    memmove(tmp, in, length);
c0d0217a:	4622      	mov	r2, r4
c0d0217c:	f002 fd3a 	bl	c0d04bf4 <__aeabi_memcpy>
c0d02180:	2100      	movs	r1, #0
    while ((zero_count < length) && (tmp[zero_count] == 0)) {
c0d02182:	2c00      	cmp	r4, #0
c0d02184:	d009      	beq.n	c0d0219a <encode_base58+0x36>
c0d02186:	a817      	add	r0, sp, #92	; 0x5c
c0d02188:	5c40      	ldrb	r0, [r0, r1]
c0d0218a:	2800      	cmp	r0, #0
c0d0218c:	d105      	bne.n	c0d0219a <encode_base58+0x36>
        ++zero_count;
c0d0218e:	1c49      	adds	r1, r1, #1
    while ((zero_count < length) && (tmp[zero_count] == 0)) {
c0d02190:	428c      	cmp	r4, r1
c0d02192:	d1f8      	bne.n	c0d02186 <encode_base58+0x22>
    }
    j = 2 * length;
c0d02194:	0065      	lsls	r5, r4, #1
c0d02196:	4628      	mov	r0, r5
c0d02198:	e037      	b.n	c0d0220a <encode_base58+0xa6>
c0d0219a:	0065      	lsls	r5, r4, #1
    start_at = zero_count;
    while (start_at < length) {
c0d0219c:	42a1      	cmp	r1, r4
c0d0219e:	d232      	bcs.n	c0d02206 <encode_base58+0xa2>
c0d021a0:	9100      	str	r1, [sp, #0]
c0d021a2:	460a      	mov	r2, r1
c0d021a4:	462b      	mov	r3, r5
c0d021a6:	9404      	str	r4, [sp, #16]
c0d021a8:	9503      	str	r5, [sp, #12]
        uint16_t remainder = 0;
        size_t div_loop;
        for (div_loop = start_at; div_loop < length; div_loop++) {
c0d021aa:	42a2      	cmp	r2, r4
c0d021ac:	9306      	str	r3, [sp, #24]
c0d021ae:	9205      	str	r2, [sp, #20]
c0d021b0:	d212      	bcs.n	c0d021d8 <encode_base58+0x74>
c0d021b2:	a817      	add	r0, sp, #92	; 0x5c
c0d021b4:	1885      	adds	r5, r0, r2
c0d021b6:	1aa6      	subs	r6, r4, r2
c0d021b8:	2000      	movs	r0, #0
            uint16_t digit256 = (uint16_t) (tmp[div_loop] & 0xff);
c0d021ba:	7829      	ldrb	r1, [r5, #0]
            uint16_t tmp_div = remainder * 256 + digit256;
c0d021bc:	0200      	lsls	r0, r0, #8
c0d021be:	1844      	adds	r4, r0, r1
c0d021c0:	b2a0      	uxth	r0, r4
c0d021c2:	273a      	movs	r7, #58	; 0x3a
            tmp[div_loop] = (uint8_t) (tmp_div / 58);
c0d021c4:	4639      	mov	r1, r7
c0d021c6:	f002 fbd1 	bl	c0d0496c <__udivsi3>
c0d021ca:	7028      	strb	r0, [r5, #0]
c0d021cc:	4347      	muls	r7, r0
c0d021ce:	1be0      	subs	r0, r4, r7
        for (div_loop = start_at; div_loop < length; div_loop++) {
c0d021d0:	1c6d      	adds	r5, r5, #1
c0d021d2:	1e76      	subs	r6, r6, #1
c0d021d4:	d1f1      	bne.n	c0d021ba <encode_base58+0x56>
c0d021d6:	e000      	b.n	c0d021da <encode_base58+0x76>
c0d021d8:	2000      	movs	r0, #0
            remainder = (tmp_div % 58);
        }
        if (tmp[start_at] == 0) {
            ++start_at;
        }
        buffer[--j] = (uint8_t) BASE58_ALPHABET[remainder];
c0d021da:	b280      	uxth	r0, r0
c0d021dc:	491f      	ldr	r1, [pc, #124]	; (c0d0225c <encode_base58+0xf8>)
c0d021de:	4479      	add	r1, pc
c0d021e0:	5c08      	ldrb	r0, [r1, r0]
c0d021e2:	9b06      	ldr	r3, [sp, #24]
c0d021e4:	1e5b      	subs	r3, r3, #1
c0d021e6:	b2d9      	uxtb	r1, r3
c0d021e8:	aa07      	add	r2, sp, #28
c0d021ea:	5450      	strb	r0, [r2, r1]
c0d021ec:	a817      	add	r0, sp, #92	; 0x5c
c0d021ee:	9a05      	ldr	r2, [sp, #20]
        if (tmp[start_at] == 0) {
c0d021f0:	5c80      	ldrb	r0, [r0, r2]
c0d021f2:	2800      	cmp	r0, #0
c0d021f4:	d100      	bne.n	c0d021f8 <encode_base58+0x94>
c0d021f6:	1c52      	adds	r2, r2, #1
c0d021f8:	9c04      	ldr	r4, [sp, #16]
c0d021fa:	9803      	ldr	r0, [sp, #12]
    while (start_at < length) {
c0d021fc:	42a2      	cmp	r2, r4
c0d021fe:	d3d4      	bcc.n	c0d021aa <encode_base58+0x46>
c0d02200:	9c00      	ldr	r4, [sp, #0]
c0d02202:	461d      	mov	r5, r3
c0d02204:	e00a      	b.n	c0d0221c <encode_base58+0xb8>
c0d02206:	4628      	mov	r0, r5
c0d02208:	460c      	mov	r4, r1
c0d0220a:	21fe      	movs	r1, #254	; 0xfe
    }
    while ((j < (2 * length)) && (buffer[j] == BASE58_ALPHABET[0])) {
c0d0220c:	4001      	ands	r1, r0
c0d0220e:	e005      	b.n	c0d0221c <encode_base58+0xb8>
c0d02210:	aa07      	add	r2, sp, #28
c0d02212:	5c51      	ldrb	r1, [r2, r1]
c0d02214:	2931      	cmp	r1, #49	; 0x31
c0d02216:	d103      	bne.n	c0d02220 <encode_base58+0xbc>
        ++j;
c0d02218:	1c6d      	adds	r5, r5, #1
    while ((j < (2 * length)) && (buffer[j] == BASE58_ALPHABET[0])) {
c0d0221a:	b2e9      	uxtb	r1, r5
c0d0221c:	4288      	cmp	r0, r1
c0d0221e:	d8f7      	bhi.n	c0d02210 <encode_base58+0xac>
    }
    while (zero_count-- > 0) {
c0d02220:	2c00      	cmp	r4, #0
c0d02222:	d007      	beq.n	c0d02234 <encode_base58+0xd0>
        buffer[--j] = BASE58_ALPHABET[0];
c0d02224:	1e6d      	subs	r5, r5, #1
c0d02226:	b2e9      	uxtb	r1, r5
c0d02228:	aa07      	add	r2, sp, #28
c0d0222a:	2331      	movs	r3, #49	; 0x31
c0d0222c:	5453      	strb	r3, [r2, r1]
    while (zero_count-- > 0) {
c0d0222e:	1e64      	subs	r4, r4, #1
c0d02230:	d1f8      	bne.n	c0d02224 <encode_base58+0xc0>
c0d02232:	e000      	b.n	c0d02236 <encode_base58+0xd2>
    }
    length = 2 * length - j;
c0d02234:	b2e9      	uxtb	r1, r5
c0d02236:	1a46      	subs	r6, r0, r1
    if (maxoutlen < length + 1) {
c0d02238:	1c70      	adds	r0, r6, #1
c0d0223a:	9a02      	ldr	r2, [sp, #8]
c0d0223c:	4290      	cmp	r0, r2
c0d0223e:	d901      	bls.n	c0d02244 <encode_base58+0xe0>
c0d02240:	2003      	movs	r0, #3
c0d02242:	e008      	b.n	c0d02256 <encode_base58+0xf2>
c0d02244:	a807      	add	r0, sp, #28
        return EXCEPTION_OVERFLOW;
    }
    memmove(out, (buffer + j), length);
c0d02246:	1841      	adds	r1, r0, r1
c0d02248:	9c01      	ldr	r4, [sp, #4]
c0d0224a:	4620      	mov	r0, r4
c0d0224c:	4632      	mov	r2, r6
c0d0224e:	f002 fcd1 	bl	c0d04bf4 <__aeabi_memcpy>
c0d02252:	2000      	movs	r0, #0
    out[length] = '\0';
c0d02254:	55a0      	strb	r0, [r4, r6]
    return 0;
}
c0d02256:	b027      	add	sp, #156	; 0x9c
c0d02258:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d0225a:	46c0      	nop			; (mov r8, r8)
c0d0225c:	00003169 	.word	0x00003169

c0d02260 <print_i64>:

int print_i64(int64_t i64, char *out, size_t out_length) {
c0d02260:	b510      	push	{r4, lr}
c0d02262:	2b00      	cmp	r3, #0
c0d02264:	d003      	beq.n	c0d0226e <print_i64+0xe>
    BAIL_IF(out_length < 1);
    uint64_t u64 = (uint64_t) i64;
    if (i64 < 0) {
c0d02266:	2900      	cmp	r1, #0
c0d02268:	d403      	bmi.n	c0d02272 <print_i64+0x12>
c0d0226a:	460c      	mov	r4, r1
c0d0226c:	e008      	b.n	c0d02280 <print_i64+0x20>
c0d0226e:	2001      	movs	r0, #1
        out++;
        out_length--;
        u64 = (u64 ^ 0xffffffffffffffff) + 1;
    }
    return print_u64(u64, out, out_length);
}
c0d02270:	bd10      	pop	{r4, pc}
c0d02272:	242d      	movs	r4, #45	; 0x2d
        out[0] = '-';
c0d02274:	7014      	strb	r4, [r2, #0]
c0d02276:	2400      	movs	r4, #0
        u64 = (u64 ^ 0xffffffffffffffff) + 1;
c0d02278:	4240      	negs	r0, r0
c0d0227a:	418c      	sbcs	r4, r1
        out_length--;
c0d0227c:	1e5b      	subs	r3, r3, #1
        out++;
c0d0227e:	1c52      	adds	r2, r2, #1
    return print_u64(u64, out, out_length);
c0d02280:	4621      	mov	r1, r4
c0d02282:	f000 f801 	bl	c0d02288 <print_u64>
}
c0d02286:	bd10      	pop	{r4, pc}

c0d02288 <print_u64>:

int print_u64(uint64_t u64, char *out, size_t out_length) {
c0d02288:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0228a:	b085      	sub	sp, #20
c0d0228c:	2b00      	cmp	r3, #0
c0d0228e:	d429      	bmi.n	c0d022e4 <print_u64+0x5c>
    uint64_t dVal = u64;
    int outlen = (int) out_length;
    int i = 0;
    int j = 0;

    if (i < (outlen - 1)) {
c0d02290:	2b02      	cmp	r3, #2
c0d02292:	db29      	blt.n	c0d022e8 <print_u64+0x60>
c0d02294:	4607      	mov	r7, r0
c0d02296:	9201      	str	r2, [sp, #4]
c0d02298:	2500      	movs	r5, #0
c0d0229a:	9300      	str	r3, [sp, #0]
        do {
            if (dVal > 0) {
c0d0229c:	4638      	mov	r0, r7
c0d0229e:	4308      	orrs	r0, r1
c0d022a0:	d027      	beq.n	c0d022f2 <print_u64+0x6a>
c0d022a2:	220a      	movs	r2, #10
c0d022a4:	2300      	movs	r3, #0
                out[i] = (dVal % 10) + '0';
                dVal /= 10;
c0d022a6:	9304      	str	r3, [sp, #16]
c0d022a8:	4638      	mov	r0, r7
c0d022aa:	9102      	str	r1, [sp, #8]
c0d022ac:	9503      	str	r5, [sp, #12]
c0d022ae:	4615      	mov	r5, r2
c0d022b0:	f002 fbb0 	bl	c0d04a14 <__aeabi_uldivmod>
c0d022b4:	4604      	mov	r4, r0
c0d022b6:	460e      	mov	r6, r1
c0d022b8:	462a      	mov	r2, r5
c0d022ba:	9b04      	ldr	r3, [sp, #16]
c0d022bc:	f002 fbca 	bl	c0d04a54 <__aeabi_lmul>
c0d022c0:	9d03      	ldr	r5, [sp, #12]
c0d022c2:	1a38      	subs	r0, r7, r0
c0d022c4:	2130      	movs	r1, #48	; 0x30
                out[i] = (dVal % 10) + '0';
c0d022c6:	4301      	orrs	r1, r0
c0d022c8:	9801      	ldr	r0, [sp, #4]
c0d022ca:	5541      	strb	r1, [r0, r5]
            } else {
                out[i] = '0';
            }
            i++;
c0d022cc:	1c6d      	adds	r5, r5, #1
        } while (dVal > 0 && i < outlen);
c0d022ce:	3f0a      	subs	r7, #10
c0d022d0:	9804      	ldr	r0, [sp, #16]
c0d022d2:	9902      	ldr	r1, [sp, #8]
c0d022d4:	4181      	sbcs	r1, r0
c0d022d6:	d311      	bcc.n	c0d022fc <print_u64+0x74>
c0d022d8:	9b00      	ldr	r3, [sp, #0]
c0d022da:	429d      	cmp	r5, r3
c0d022dc:	4627      	mov	r7, r4
c0d022de:	4631      	mov	r1, r6
c0d022e0:	dbdc      	blt.n	c0d0229c <print_u64+0x14>
c0d022e2:	e00c      	b.n	c0d022fe <print_u64+0x76>
c0d022e4:	0fd8      	lsrs	r0, r3, #31
c0d022e6:	e020      	b.n	c0d0232a <print_u64+0xa2>
c0d022e8:	2b01      	cmp	r3, #1
c0d022ea:	d11d      	bne.n	c0d02328 <print_u64+0xa0>
c0d022ec:	2000      	movs	r0, #0
    }

    BAIL_IF(i >= outlen);

    out[i--] = '\0';
c0d022ee:	7010      	strb	r0, [r2, #0]
c0d022f0:	e01b      	b.n	c0d0232a <print_u64+0xa2>
c0d022f2:	2030      	movs	r0, #48	; 0x30
                out[i] = '0';
c0d022f4:	9901      	ldr	r1, [sp, #4]
c0d022f6:	5548      	strb	r0, [r1, r5]
        } while (dVal > 0 && i < outlen);
c0d022f8:	1c6d      	adds	r5, r5, #1
c0d022fa:	e000      	b.n	c0d022fe <print_u64+0x76>
c0d022fc:	9b00      	ldr	r3, [sp, #0]
c0d022fe:	429d      	cmp	r5, r3
c0d02300:	da12      	bge.n	c0d02328 <print_u64+0xa0>
c0d02302:	2000      	movs	r0, #0
c0d02304:	9e01      	ldr	r6, [sp, #4]
    out[i--] = '\0';
c0d02306:	5570      	strb	r0, [r6, r5]

    for (; j < i; j++, i--) {
c0d02308:	2d02      	cmp	r5, #2
c0d0230a:	db0e      	blt.n	c0d0232a <print_u64+0xa2>
c0d0230c:	1e69      	subs	r1, r5, #1
c0d0230e:	2201      	movs	r2, #1
        int tmp = out[j];
c0d02310:	18b3      	adds	r3, r6, r2
c0d02312:	1e5b      	subs	r3, r3, #1
c0d02314:	781c      	ldrb	r4, [r3, #0]
        out[j] = out[i];
c0d02316:	5c75      	ldrb	r5, [r6, r1]
c0d02318:	701d      	strb	r5, [r3, #0]
        out[i] = tmp;
c0d0231a:	5474      	strb	r4, [r6, r1]
    for (; j < i; j++, i--) {
c0d0231c:	1c53      	adds	r3, r2, #1
c0d0231e:	1e49      	subs	r1, r1, #1
c0d02320:	428a      	cmp	r2, r1
c0d02322:	461a      	mov	r2, r3
c0d02324:	dbf4      	blt.n	c0d02310 <print_u64+0x88>
c0d02326:	e000      	b.n	c0d0232a <print_u64+0xa2>
c0d02328:	2001      	movs	r0, #1
    }

    return 0;
}
c0d0232a:	b005      	add	sp, #20
c0d0232c:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d0232e <print_timestamp>:

int print_timestamp(int64_t timestamp, char *out, size_t out_length) {
c0d0232e:	b5b0      	push	{r4, r5, r7, lr}
c0d02330:	460c      	mov	r4, r1
c0d02332:	4605      	mov	r5, r0
    return rfc3339_format(out, out_length, timestamp);
c0d02334:	4610      	mov	r0, r2
c0d02336:	4619      	mov	r1, r3
c0d02338:	462a      	mov	r2, r5
c0d0233a:	4623      	mov	r3, r4
c0d0233c:	f000 f802 	bl	c0d02344 <rfc3339_format>
c0d02340:	bdb0      	pop	{r4, r5, r7, pc}
	...

c0d02344 <rfc3339_format>:
    return 0;
}

#define EPOCH INT64_C(62135683200) /* 1970-01-01 00:00:00 */

int rfc3339_format(char *dst, size_t len, int64_t seconds) {
c0d02344:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d02346:	b08b      	sub	sp, #44	; 0x2c
c0d02348:	2401      	movs	r4, #1
c0d0234a:	2914      	cmp	r1, #20
c0d0234c:	d200      	bcs.n	c0d02350 <rfc3339_format+0xc>
c0d0234e:	e0e0      	b.n	c0d02512 <rfc3339_format+0x1ce>
c0d02350:	940a      	str	r4, [sp, #40]	; 0x28
c0d02352:	9007      	str	r0, [sp, #28]
c0d02354:	210e      	movs	r1, #14
c0d02356:	4870      	ldr	r0, [pc, #448]	; (c0d02518 <rfc3339_format+0x1d4>)
    size_t dlen;

    dlen = sizeof("YYYY-MM-DD hh:mm:ss") - 1;
    BAIL_IF(dlen >= len);

    sec = seconds + EPOCH;
c0d02358:	1810      	adds	r0, r2, r0
c0d0235a:	4159      	adcs	r1, r3
c0d0235c:	4a6f      	ldr	r2, [pc, #444]	; (c0d0251c <rfc3339_format+0x1d8>)
c0d0235e:	2300      	movs	r3, #0
c0d02360:	9006      	str	r0, [sp, #24]
c0d02362:	9308      	str	r3, [sp, #32]
    rdn = sec / 86400;
c0d02364:	f002 fb56 	bl	c0d04a14 <__aeabi_uldivmod>
c0d02368:	2199      	movs	r1, #153	; 0x99
c0d0236a:	004e      	lsls	r6, r1, #1
c0d0236c:	9005      	str	r0, [sp, #20]
    Z = rdn + 306;
c0d0236e:	1980      	adds	r0, r0, r6
c0d02370:	9009      	str	r0, [sp, #36]	; 0x24
c0d02372:	2764      	movs	r7, #100	; 0x64
    H = 100 * Z - 25;
c0d02374:	463d      	mov	r5, r7
c0d02376:	4345      	muls	r5, r0
c0d02378:	3d19      	subs	r5, #25
c0d0237a:	4969      	ldr	r1, [pc, #420]	; (c0d02520 <rfc3339_format+0x1dc>)
    A = H / 3652425;
c0d0237c:	4628      	mov	r0, r5
c0d0237e:	f002 faf5 	bl	c0d0496c <__udivsi3>
    B = A - (A >> 2);
c0d02382:	0881      	lsrs	r1, r0, #2
c0d02384:	1a44      	subs	r4, r0, r1
    y = (100 * B + H) / 36525;
c0d02386:	4367      	muls	r7, r4
c0d02388:	1978      	adds	r0, r7, r5
c0d0238a:	4966      	ldr	r1, [pc, #408]	; (c0d02524 <rfc3339_format+0x1e0>)
c0d0238c:	f002 faee 	bl	c0d0496c <__udivsi3>
c0d02390:	4602      	mov	r2, r0
    d = B + Z - (1461 * y >> 2);
c0d02392:	9809      	ldr	r0, [sp, #36]	; 0x24
c0d02394:	1820      	adds	r0, r4, r0
c0d02396:	4964      	ldr	r1, [pc, #400]	; (c0d02528 <rfc3339_format+0x1e4>)
c0d02398:	4351      	muls	r1, r2
c0d0239a:	0889      	lsrs	r1, r1, #2
c0d0239c:	1a43      	subs	r3, r0, r1
    m = (535 * d + 48950) >> 14;
c0d0239e:	36e5      	adds	r6, #229	; 0xe5
c0d023a0:	435e      	muls	r6, r3
c0d023a2:	4862      	ldr	r0, [pc, #392]	; (c0d0252c <rfc3339_format+0x1e8>)
c0d023a4:	1830      	adds	r0, r6, r0
c0d023a6:	0b80      	lsrs	r0, r0, #14
    if (m > 12) {
c0d023a8:	4605      	mov	r5, r0
c0d023aa:	3d0c      	subs	r5, #12
c0d023ac:	d800      	bhi.n	c0d023b0 <rfc3339_format+0x6c>
c0d023ae:	4605      	mov	r5, r0
c0d023b0:	280c      	cmp	r0, #12
c0d023b2:	d900      	bls.n	c0d023b6 <rfc3339_format+0x72>
c0d023b4:	1c52      	adds	r2, r2, #1
c0d023b6:	9c0a      	ldr	r4, [sp, #40]	; 0x28
c0d023b8:	485d      	ldr	r0, [pc, #372]	; (c0d02530 <rfc3339_format+0x1ec>)
    BAIL_IF(y > 9999 || m > 12 || d > (31U + DayOffset[m]));
c0d023ba:	4282      	cmp	r2, r0
c0d023bc:	d900      	bls.n	c0d023c0 <rfc3339_format+0x7c>
c0d023be:	e0a8      	b.n	c0d02512 <rfc3339_format+0x1ce>
c0d023c0:	2d0c      	cmp	r5, #12
c0d023c2:	d900      	bls.n	c0d023c6 <rfc3339_format+0x82>
c0d023c4:	e0a5      	b.n	c0d02512 <rfc3339_format+0x1ce>
c0d023c6:	0068      	lsls	r0, r5, #1
c0d023c8:	495b      	ldr	r1, [pc, #364]	; (c0d02538 <rfc3339_format+0x1f4>)
c0d023ca:	4479      	add	r1, pc
c0d023cc:	5a09      	ldrh	r1, [r1, r0]
c0d023ce:	4608      	mov	r0, r1
c0d023d0:	301f      	adds	r0, #31
c0d023d2:	4283      	cmp	r3, r0
c0d023d4:	d900      	bls.n	c0d023d8 <rfc3339_format+0x94>
c0d023d6:	e09c      	b.n	c0d02512 <rfc3339_format+0x1ce>
c0d023d8:	203a      	movs	r0, #58	; 0x3a
c0d023da:	9c07      	ldr	r4, [sp, #28]
    v = sec % 86400;
    p[18] = '0' + (v % 10);
    v /= 10;
    p[17] = '0' + (v % 6);
    v /= 6;
    p[16] = ':';
c0d023dc:	7420      	strb	r0, [r4, #16]
    p[15] = '0' + (v % 10);
    v /= 10;
    p[14] = '0' + (v % 6);
    v /= 6;
    p[13] = ':';
c0d023de:	7360      	strb	r0, [r4, #13]
c0d023e0:	2020      	movs	r0, #32
    p[12] = '0' + (v % 10);
    v /= 10;
    p[11] = '0' + (v % 10);
    p[10] = ' ';
c0d023e2:	72a0      	strb	r0, [r4, #10]
c0d023e4:	202d      	movs	r0, #45	; 0x2d
    p[9] = '0' + (d % 10);
    d /= 10;
    p[8] = '0' + (d % 10);
    p[7] = '-';
c0d023e6:	71e0      	strb	r0, [r4, #7]
    p[6] = '0' + (m % 10);
    m /= 10;
    p[5] = '0' + (m % 10);
    p[4] = '-';
c0d023e8:	7120      	strb	r0, [r4, #4]
    p[1] = '0' + (y % 10);
    y /= 10;
    p[0] = '0' + (y % 10);
    p += 19;

    *p = 0;
c0d023ea:	9808      	ldr	r0, [sp, #32]
c0d023ec:	74e0      	strb	r0, [r4, #19]
    *yp = (uint16_t) y;
c0d023ee:	b290      	uxth	r0, r2
c0d023f0:	900a      	str	r0, [sp, #40]	; 0x28
c0d023f2:	267d      	movs	r6, #125	; 0x7d
c0d023f4:	9103      	str	r1, [sp, #12]
c0d023f6:	00f1      	lsls	r1, r6, #3
c0d023f8:	9204      	str	r2, [sp, #16]
c0d023fa:	9302      	str	r3, [sp, #8]
    y /= 10;
c0d023fc:	f002 fab6 	bl	c0d0496c <__udivsi3>
c0d02400:	270a      	movs	r7, #10
    p[0] = '0' + (y % 10);
c0d02402:	4639      	mov	r1, r7
c0d02404:	f002 faee 	bl	c0d049e4 <__aeabi_uidivmod>
c0d02408:	2630      	movs	r6, #48	; 0x30
c0d0240a:	4331      	orrs	r1, r6
c0d0240c:	7021      	strb	r1, [r4, #0]
c0d0240e:	b2e8      	uxtb	r0, r5
    m /= 10;
c0d02410:	4639      	mov	r1, r7
c0d02412:	f002 faab 	bl	c0d0496c <__udivsi3>
    p[5] = '0' + (m % 10);
c0d02416:	9001      	str	r0, [sp, #4]
c0d02418:	4639      	mov	r1, r7
c0d0241a:	f002 fae3 	bl	c0d049e4 <__aeabi_uidivmod>
c0d0241e:	4331      	orrs	r1, r6
c0d02420:	7161      	strb	r1, [r4, #5]
    y /= 10;
c0d02422:	980a      	ldr	r0, [sp, #40]	; 0x28
c0d02424:	4639      	mov	r1, r7
c0d02426:	f002 faa1 	bl	c0d0496c <__udivsi3>
    p[2] = '0' + (y % 10);
c0d0242a:	9000      	str	r0, [sp, #0]
c0d0242c:	4639      	mov	r1, r7
c0d0242e:	f002 fad9 	bl	c0d049e4 <__aeabi_uidivmod>
c0d02432:	4331      	orrs	r1, r6
c0d02434:	9609      	str	r6, [sp, #36]	; 0x24
c0d02436:	70a1      	strb	r1, [r4, #2]
c0d02438:	2164      	movs	r1, #100	; 0x64
    y /= 10;
c0d0243a:	980a      	ldr	r0, [sp, #40]	; 0x28
c0d0243c:	f002 fa96 	bl	c0d0496c <__udivsi3>
    p[1] = '0' + (y % 10);
c0d02440:	b2c0      	uxtb	r0, r0
c0d02442:	4639      	mov	r1, r7
c0d02444:	f002 face 	bl	c0d049e4 <__aeabi_uidivmod>
c0d02448:	4331      	orrs	r1, r6
c0d0244a:	7061      	strb	r1, [r4, #1]
c0d0244c:	4a33      	ldr	r2, [pc, #204]	; (c0d0251c <rfc3339_format+0x1d8>)
c0d0244e:	9805      	ldr	r0, [sp, #20]
c0d02450:	9b08      	ldr	r3, [sp, #32]
c0d02452:	f002 faff 	bl	c0d04a54 <__aeabi_lmul>
c0d02456:	9906      	ldr	r1, [sp, #24]
c0d02458:	1a08      	subs	r0, r1, r0
    v /= 10;
c0d0245a:	900a      	str	r0, [sp, #40]	; 0x28
c0d0245c:	4639      	mov	r1, r7
c0d0245e:	f002 fa85 	bl	c0d0496c <__udivsi3>
c0d02462:	4606      	mov	r6, r0
    p[17] = '0' + (v % 6);
c0d02464:	b280      	uxth	r0, r0
c0d02466:	2106      	movs	r1, #6
c0d02468:	9106      	str	r1, [sp, #24]
c0d0246a:	f002 fabb 	bl	c0d049e4 <__aeabi_uidivmod>
c0d0246e:	9a09      	ldr	r2, [sp, #36]	; 0x24
c0d02470:	4311      	orrs	r1, r2
c0d02472:	7461      	strb	r1, [r4, #17]
c0d02474:	437e      	muls	r6, r7
c0d02476:	980a      	ldr	r0, [sp, #40]	; 0x28
c0d02478:	1b81      	subs	r1, r0, r6
    p[18] = '0' + (v % 10);
c0d0247a:	4311      	orrs	r1, r2
c0d0247c:	4616      	mov	r6, r2
c0d0247e:	74a1      	strb	r1, [r4, #18]
c0d02480:	213c      	movs	r1, #60	; 0x3c
    v /= 6;
c0d02482:	f002 fa73 	bl	c0d0496c <__udivsi3>
    p[15] = '0' + (v % 10);
c0d02486:	b280      	uxth	r0, r0
c0d02488:	4639      	mov	r1, r7
c0d0248a:	f002 faab 	bl	c0d049e4 <__aeabi_uidivmod>
c0d0248e:	4331      	orrs	r1, r6
c0d02490:	73e1      	strb	r1, [r4, #15]
c0d02492:	204b      	movs	r0, #75	; 0x4b
c0d02494:	00c1      	lsls	r1, r0, #3
    v /= 10;
c0d02496:	980a      	ldr	r0, [sp, #40]	; 0x28
c0d02498:	f002 fa68 	bl	c0d0496c <__udivsi3>
    p[14] = '0' + (v % 6);
c0d0249c:	b2c0      	uxtb	r0, r0
c0d0249e:	9906      	ldr	r1, [sp, #24]
c0d024a0:	f002 faa0 	bl	c0d049e4 <__aeabi_uidivmod>
c0d024a4:	4331      	orrs	r1, r6
c0d024a6:	73a1      	strb	r1, [r4, #14]
c0d024a8:	20e1      	movs	r0, #225	; 0xe1
c0d024aa:	0101      	lsls	r1, r0, #4
    v /= 6;
c0d024ac:	980a      	ldr	r0, [sp, #40]	; 0x28
c0d024ae:	f002 fa5d 	bl	c0d0496c <__udivsi3>
    p[12] = '0' + (v % 10);
c0d024b2:	b2c0      	uxtb	r0, r0
c0d024b4:	4639      	mov	r1, r7
c0d024b6:	f002 fa95 	bl	c0d049e4 <__aeabi_uidivmod>
c0d024ba:	4331      	orrs	r1, r6
c0d024bc:	7321      	strb	r1, [r4, #12]
c0d024be:	491d      	ldr	r1, [pc, #116]	; (c0d02534 <rfc3339_format+0x1f0>)
    v /= 10;
c0d024c0:	980a      	ldr	r0, [sp, #40]	; 0x28
c0d024c2:	f002 fa53 	bl	c0d0496c <__udivsi3>
    p[11] = '0' + (v % 10);
c0d024c6:	b2c0      	uxtb	r0, r0
c0d024c8:	4639      	mov	r1, r7
c0d024ca:	f002 fa8b 	bl	c0d049e4 <__aeabi_uidivmod>
c0d024ce:	4331      	orrs	r1, r6
c0d024d0:	72e1      	strb	r1, [r4, #11]
    *dp = (uint16_t) (d - DayOffset[m]);
c0d024d2:	9803      	ldr	r0, [sp, #12]
c0d024d4:	9902      	ldr	r1, [sp, #8]
c0d024d6:	1a08      	subs	r0, r1, r0
c0d024d8:	900a      	str	r0, [sp, #40]	; 0x28
c0d024da:	b280      	uxth	r0, r0
    d /= 10;
c0d024dc:	4639      	mov	r1, r7
c0d024de:	f002 fa45 	bl	c0d0496c <__udivsi3>
c0d024e2:	4606      	mov	r6, r0
    p[8] = '0' + (d % 10);
c0d024e4:	4639      	mov	r1, r7
c0d024e6:	f002 fa7d 	bl	c0d049e4 <__aeabi_uidivmod>
c0d024ea:	9a09      	ldr	r2, [sp, #36]	; 0x24
c0d024ec:	4311      	orrs	r1, r2
c0d024ee:	7221      	strb	r1, [r4, #8]
c0d024f0:	9801      	ldr	r0, [sp, #4]
c0d024f2:	4378      	muls	r0, r7
c0d024f4:	1a28      	subs	r0, r5, r0
    p[6] = '0' + (m % 10);
c0d024f6:	4310      	orrs	r0, r2
c0d024f8:	71a0      	strb	r0, [r4, #6]
c0d024fa:	9900      	ldr	r1, [sp, #0]
c0d024fc:	4379      	muls	r1, r7
c0d024fe:	9804      	ldr	r0, [sp, #16]
c0d02500:	1a40      	subs	r0, r0, r1
    p[3] = '0' + (y % 10);
c0d02502:	4310      	orrs	r0, r2
c0d02504:	70e0      	strb	r0, [r4, #3]
c0d02506:	4377      	muls	r7, r6
c0d02508:	980a      	ldr	r0, [sp, #40]	; 0x28
c0d0250a:	1bc0      	subs	r0, r0, r7
    p[9] = '0' + (d % 10);
c0d0250c:	4310      	orrs	r0, r2
c0d0250e:	7260      	strb	r0, [r4, #9]
c0d02510:	9c08      	ldr	r4, [sp, #32]
    return 0;
}
c0d02512:	4620      	mov	r0, r4
c0d02514:	b00b      	add	sp, #44	; 0x2c
c0d02516:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d02518:	77934880 	.word	0x77934880
c0d0251c:	00015180 	.word	0x00015180
c0d02520:	0037bb49 	.word	0x0037bb49
c0d02524:	00008ead 	.word	0x00008ead
c0d02528:	000005b5 	.word	0x000005b5
c0d0252c:	0000bf36 	.word	0x0000bf36
c0d02530:	0000270f 	.word	0x0000270f
c0d02534:	00008ca0 	.word	0x00008ca0
c0d02538:	00002fb8 	.word	0x00002fb8

c0d0253c <ux_approve_step_validateinit>:
    sendResponse(set_result_sign_message(), true);
}

//////////////////////////////////////////////////////////////////////

UX_STEP_CB(ux_approve_step,
c0d0253c:	b580      	push	{r7, lr}
    sendResponse(set_result_sign_message(), true);
c0d0253e:	f000 f8bf 	bl	c0d026c0 <set_result_sign_message>
c0d02542:	2040      	movs	r0, #64	; 0x40
c0d02544:	2101      	movs	r1, #1
c0d02546:	f001 fb67 	bl	c0d03c18 <sendResponse>
UX_STEP_CB(ux_approve_step,
c0d0254a:	bd80      	pop	{r7, pc}

c0d0254c <ux_reject_step_validateinit>:
           send_result_sign_message(),
           {
               &C_icon_validate_14,
               "Approve",
           });
UX_STEP_CB(ux_reject_step,
c0d0254c:	b580      	push	{r7, lr}
c0d0254e:	2000      	movs	r0, #0
c0d02550:	4601      	mov	r1, r0
c0d02552:	f001 fb61 	bl	c0d03c18 <sendResponse>
c0d02556:	bd80      	pop	{r7, pc}

c0d02558 <ux_summary_step_init>:
           sendResponse(0, false),
           {
               &C_icon_crossmark,
               "Reject",
           });
UX_STEP_NOCB_INIT(ux_summary_step,
c0d02558:	b5b0      	push	{r4, r5, r7, lr}
c0d0255a:	4604      	mov	r4, r0
c0d0255c:	200c      	movs	r0, #12
c0d0255e:	4360      	muls	r0, r4
c0d02560:	490a      	ldr	r1, [pc, #40]	; (c0d0258c <ux_summary_step_init+0x34>)
c0d02562:	1808      	adds	r0, r1, r0
c0d02564:	8b05      	ldrh	r5, [r0, #24]
c0d02566:	480b      	ldr	r0, [pc, #44]	; (c0d02594 <ux_summary_step_init+0x3c>)
c0d02568:	4478      	add	r0, pc
c0d0256a:	f7ff fce7 	bl	c0d01f3c <pic>
c0d0256e:	7840      	ldrb	r0, [r0, #1]
c0d02570:	4241      	negs	r1, r0
c0d02572:	4141      	adcs	r1, r0
c0d02574:	4628      	mov	r0, r5
c0d02576:	f000 fa35 	bl	c0d029e4 <transaction_summary_display_item>
c0d0257a:	2800      	cmp	r0, #0
c0d0257c:	d103      	bne.n	c0d02586 <ux_summary_step_init+0x2e>
c0d0257e:	4620      	mov	r0, r4
c0d02580:	f001 fe4c 	bl	c0d0421c <ux_layout_paging_init>
c0d02584:	bdb0      	pop	{r4, r5, r7, pc}
c0d02586:	4802      	ldr	r0, [pc, #8]	; (c0d02590 <ux_summary_step_init+0x38>)
c0d02588:	f7fe fc6e 	bl	c0d00e68 <os_longjmp>
c0d0258c:	20000250 	.word	0x20000250
c0d02590:	00006f01 	.word	0x00006f01
c0d02594:	00003554 	.word	0x00003554

c0d02598 <handle_sign_message_parse_message>:
     + 1                               /* reject */        \
     + 1                               /* FLOW_END_STEP */ \
    )
ux_flow_step_t static const *flow_steps[MAX_FLOW_STEPS];

void handle_sign_message_parse_message(volatile unsigned int *tx) {
c0d02598:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0259a:	b081      	sub	sp, #4
    if (!tx || G_command.state != ApduStatePayloadComplete) {
c0d0259c:	2800      	cmp	r0, #0
c0d0259e:	d043      	beq.n	c0d02628 <handle_sign_message_parse_message+0x90>
c0d025a0:	4e23      	ldr	r6, [pc, #140]	; (c0d02630 <handle_sign_message_parse_message+0x98>)
c0d025a2:	7830      	ldrb	r0, [r6, #0]
c0d025a4:	2802      	cmp	r0, #2
c0d025a6:	d13f      	bne.n	c0d02628 <handle_sign_message_parse_message+0x90>
c0d025a8:	2029      	movs	r0, #41	; 0x29
c0d025aa:	0147      	lsls	r7, r0, #5
        THROW(ApduReplySdkInvalidParameter);
    }

    // Handle the transaction message signing
    Parser parser = {G_command.message, G_command.message_length};
c0d025ac:	59f5      	ldr	r5, [r6, r7]
    PrintConfig print_config;
    print_config.expert_mode = (N_storage.settings.display_mode == DisplayModeExpert);
c0d025ae:	4823      	ldr	r0, [pc, #140]	; (c0d0263c <handle_sign_message_parse_message+0xa4>)
c0d025b0:	4478      	add	r0, pc
c0d025b2:	f7ff fcc3 	bl	c0d01f3c <pic>
c0d025b6:	7880      	ldrb	r0, [r0, #2]
    print_config.signer_pubkey = NULL;
    MessageHeader *header = &print_config.header;
    
    PRINTF("GUI:\n%.*H\n", parser.buffer_length, parser.buffer);
c0d025b8:	4634      	mov	r4, r6
c0d025ba:	341e      	adds	r4, #30
c0d025bc:	4820      	ldr	r0, [pc, #128]	; (c0d02640 <handle_sign_message_parse_message+0xa8>)
c0d025be:	4478      	add	r0, pc
c0d025c0:	4629      	mov	r1, r5
c0d025c2:	4622      	mov	r2, r4
c0d025c4:	f7ff f90a 	bl	c0d017dc <mcu_usb_printf>
    // if (parse_message_header(&parser, header) != 0) {
    //     // This is not a valid Aelf message
    //     THROW(ApduReplyAelfInvalidMessage);
    // }

    if (G_command.non_confirm) {
c0d025c8:	7f30      	ldrb	r0, [r6, #28]
c0d025ca:	2800      	cmp	r0, #0
c0d025cc:	d128      	bne.n	c0d02620 <handle_sign_message_parse_message+0x88>
        UNUSED(tx);
        THROW(ApduReplySdkNotSupported);
    }

    // Set the transaction summary
    transaction_summary_reset();
c0d025ce:	f000 f9dd 	bl	c0d0298c <transaction_summary_reset>
    if (process_message_body(parser.buffer, parser.buffer_length, G_command.instruction) != 0) {
c0d025d2:	7872      	ldrb	r2, [r6, #1]
c0d025d4:	4620      	mov	r0, r4
c0d025d6:	4629      	mov	r1, r5
c0d025d8:	f7fe fc21 	bl	c0d00e1e <process_message_body>
c0d025dc:	2800      	cmp	r0, #0
c0d025de:	d01d      	beq.n	c0d0261c <handle_sign_message_parse_message+0x84>
        // Message not processed, throw if blind signing is not enabled
        if (N_storage.settings.allow_blind_sign == BlindSignEnabled) {
c0d025e0:	4818      	ldr	r0, [pc, #96]	; (c0d02644 <handle_sign_message_parse_message+0xac>)
c0d025e2:	4478      	add	r0, pc
c0d025e4:	f7ff fcaa 	bl	c0d01f3c <pic>
c0d025e8:	7800      	ldrb	r0, [r0, #0]
c0d025ea:	2801      	cmp	r0, #1
c0d025ec:	d118      	bne.n	c0d02620 <handle_sign_message_parse_message+0x88>
            SummaryItem *item = transaction_summary_primary_item();
c0d025ee:	f000 f9e3 	bl	c0d029b8 <transaction_summary_primary_item>
            summary_item_set_string(item, "Unrecognized", "format");
c0d025f2:	4915      	ldr	r1, [pc, #84]	; (c0d02648 <handle_sign_message_parse_message+0xb0>)
c0d025f4:	4479      	add	r1, pc
c0d025f6:	4a15      	ldr	r2, [pc, #84]	; (c0d0264c <handle_sign_message_parse_message+0xb4>)
c0d025f8:	447a      	add	r2, pc
c0d025fa:	f000 f9c1 	bl	c0d02980 <summary_item_set_string>

            cx_hash_sha256(G_command.message,
                           G_command.message_length,
c0d025fe:	59f1      	ldr	r1, [r6, r7]
c0d02600:	480d      	ldr	r0, [pc, #52]	; (c0d02638 <handle_sign_message_parse_message+0xa0>)
            cx_hash_sha256(G_command.message,
c0d02602:	1835      	adds	r5, r6, r0
c0d02604:	2320      	movs	r3, #32
c0d02606:	4620      	mov	r0, r4
c0d02608:	462a      	mov	r2, r5
c0d0260a:	f7fd fe0d 	bl	c0d00228 <cx_hash_sha256>
                           (uint8_t *) &G_command.message_hash,
                           HASH_LENGTH);

            item = transaction_summary_general_item();
c0d0260e:	f000 f9db 	bl	c0d029c8 <transaction_summary_general_item>
            summary_item_set_hash(item, "Message Hash", &G_command.message_hash);
c0d02612:	490f      	ldr	r1, [pc, #60]	; (c0d02650 <handle_sign_message_parse_message+0xb8>)
c0d02614:	4479      	add	r1, pc
c0d02616:	462a      	mov	r2, r5
c0d02618:	f000 f9ad 	bl	c0d02976 <summary_item_set_hash>
        } else {
            THROW(ApduReplySdkNotSupported);
        }
    }
}
c0d0261c:	b001      	add	sp, #4
c0d0261e:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d02620:	4804      	ldr	r0, [pc, #16]	; (c0d02634 <handle_sign_message_parse_message+0x9c>)
c0d02622:	1d80      	adds	r0, r0, #6
c0d02624:	f7fe fc20 	bl	c0d00e68 <os_longjmp>
c0d02628:	4802      	ldr	r0, [pc, #8]	; (c0d02634 <handle_sign_message_parse_message+0x9c>)
        THROW(ApduReplySdkInvalidParameter);
c0d0262a:	f7fe fc1d 	bl	c0d00e68 <os_longjmp>
c0d0262e:	46c0      	nop			; (mov r8, r8)
c0d02630:	20000368 	.word	0x20000368
c0d02634:	00006802 	.word	0x00006802
c0d02638:	00000524 	.word	0x00000524
c0d0263c:	0000350c 	.word	0x0000350c
c0d02640:	00002df6 	.word	0x00002df6
c0d02644:	000034da 	.word	0x000034da
c0d02648:	00002dcb 	.word	0x00002dcb
c0d0264c:	00002dd4 	.word	0x00002dd4
c0d02650:	00002dbf 	.word	0x00002dbf

c0d02654 <handle_sign_message_ui>:

void handle_sign_message_ui(volatile unsigned int *flags) {
c0d02654:	b5b0      	push	{r4, r5, r7, lr}
c0d02656:	b086      	sub	sp, #24
c0d02658:	4604      	mov	r4, r0
c0d0265a:	2500      	movs	r5, #0
    // Display the transaction summary
    SummaryItemKind_t summary_step_kinds[MAX_TRANSACTION_SUMMARY_ITEMS];
    size_t num_summary_steps = 0;
c0d0265c:	9501      	str	r5, [sp, #4]
c0d0265e:	a802      	add	r0, sp, #8
c0d02660:	a901      	add	r1, sp, #4
    if (transaction_summary_finalize(summary_step_kinds, &num_summary_steps) == 0) {
c0d02662:	f000 fa6b 	bl	c0d02b3c <transaction_summary_finalize>
c0d02666:	2800      	cmp	r0, #0
c0d02668:	d11e      	bne.n	c0d026a8 <handle_sign_message_ui+0x54>
        size_t num_flow_steps = 0;

        for (size_t i = 0; i < num_summary_steps; i++) {
c0d0266a:	9801      	ldr	r0, [sp, #4]
c0d0266c:	2800      	cmp	r0, #0
c0d0266e:	d006      	beq.n	c0d0267e <handle_sign_message_ui+0x2a>
c0d02670:	490f      	ldr	r1, [pc, #60]	; (c0d026b0 <handle_sign_message_ui+0x5c>)
c0d02672:	4a10      	ldr	r2, [pc, #64]	; (c0d026b4 <handle_sign_message_ui+0x60>)
c0d02674:	447a      	add	r2, pc
c0d02676:	4603      	mov	r3, r0
            flow_steps[num_flow_steps++] = &ux_summary_step;
c0d02678:	c104      	stmia	r1!, {r2}
        for (size_t i = 0; i < num_summary_steps; i++) {
c0d0267a:	1e5b      	subs	r3, r3, #1
c0d0267c:	d1fc      	bne.n	c0d02678 <handle_sign_message_ui+0x24>
        }

        flow_steps[num_flow_steps++] = &ux_approve_step;
c0d0267e:	0080      	lsls	r0, r0, #2
c0d02680:	490b      	ldr	r1, [pc, #44]	; (c0d026b0 <handle_sign_message_ui+0x5c>)
c0d02682:	4a0d      	ldr	r2, [pc, #52]	; (c0d026b8 <handle_sign_message_ui+0x64>)
c0d02684:	447a      	add	r2, pc
c0d02686:	500a      	str	r2, [r1, r0]
c0d02688:	1808      	adds	r0, r1, r0
        flow_steps[num_flow_steps++] = &ux_reject_step;
c0d0268a:	4a0c      	ldr	r2, [pc, #48]	; (c0d026bc <handle_sign_message_ui+0x68>)
c0d0268c:	447a      	add	r2, pc
c0d0268e:	43eb      	mvns	r3, r5
c0d02690:	6042      	str	r2, [r0, #4]
        flow_steps[num_flow_steps++] = FLOW_END_STEP;
c0d02692:	6083      	str	r3, [r0, #8]

        ux_flow_init(0, flow_steps, NULL);
c0d02694:	4628      	mov	r0, r5
c0d02696:	462a      	mov	r2, r5
c0d02698:	f001 fc30 	bl	c0d03efc <ux_flow_init>
    } else {
        THROW(ApduReplyAelfSummaryFinalizeFailed);
    }

    *flags |= IO_ASYNCH_REPLY;
c0d0269c:	6820      	ldr	r0, [r4, #0]
c0d0269e:	2110      	movs	r1, #16
c0d026a0:	4301      	orrs	r1, r0
c0d026a2:	6021      	str	r1, [r4, #0]
}
c0d026a4:	b006      	add	sp, #24
c0d026a6:	bdb0      	pop	{r4, r5, r7, pc}
c0d026a8:	206f      	movs	r0, #111	; 0x6f
c0d026aa:	0200      	lsls	r0, r0, #8
        THROW(ApduReplyAelfSummaryFinalizeFailed);
c0d026ac:	f7fe fbdc 	bl	c0d00e68 <os_longjmp>
c0d026b0:	20000aac 	.word	0x20000aac
c0d026b4:	00002dbc 	.word	0x00002dbc
c0d026b8:	00002d64 	.word	0x00002d64
c0d026bc:	00002d8c 	.word	0x00002d8c

c0d026c0 <set_result_sign_message>:
static uint8_t set_result_sign_message() {
c0d026c0:	b5b0      	push	{r4, r5, r7, lr}
c0d026c2:	b0aa      	sub	sp, #168	; 0xa8
c0d026c4:	ac03      	add	r4, sp, #12
        TRY {
c0d026c6:	4620      	mov	r0, r4
c0d026c8:	f002 fba4 	bl	c0d04e14 <setjmp>
c0d026cc:	85a0      	strh	r0, [r4, #44]	; 0x2c
c0d026ce:	b284      	uxth	r4, r0
c0d026d0:	2c00      	cmp	r4, #0
c0d026d2:	d139      	bne.n	c0d02748 <set_result_sign_message+0x88>
c0d026d4:	a803      	add	r0, sp, #12
c0d026d6:	f000 f927 	bl	c0d02928 <try_context_set>
c0d026da:	900d      	str	r0, [sp, #52]	; 0x34
                                      G_command.derivation_path_length);
c0d026dc:	4d21      	ldr	r5, [pc, #132]	; (c0d02764 <set_result_sign_message+0xa4>)
c0d026de:	7e2a      	ldrb	r2, [r5, #24]
            get_private_key_with_seed(&privateKey,
c0d026e0:	1d29      	adds	r1, r5, #4
c0d026e2:	ac0f      	add	r4, sp, #60	; 0x3c
c0d026e4:	4620      	mov	r0, r4
c0d026e6:	f001 fa1b 	bl	c0d03b20 <get_private_key_with_seed>
c0d026ea:	2029      	movs	r0, #41	; 0x29
c0d026ec:	0140      	lsls	r0, r0, #5
                          G_command.message_length,
c0d026ee:	582b      	ldr	r3, [r5, r0]
c0d026f0:	2040      	movs	r0, #64	; 0x40
  UNUSED(ctx);
  UNUSED(ctx_len);
  UNUSED(mode);
  UNUSED(info);

  CX_THROW(cx_eddsa_sign_no_throw(pvkey, hashID, hash, hash_len, sig, sig_len));
c0d026f2:	9001      	str	r0, [sp, #4]
c0d026f4:	a819      	add	r0, sp, #100	; 0x64
c0d026f6:	9000      	str	r0, [sp, #0]
c0d026f8:	462a      	mov	r2, r5
c0d026fa:	321e      	adds	r2, #30
c0d026fc:	2105      	movs	r1, #5
c0d026fe:	4620      	mov	r0, r4
c0d02700:	f7fd fd8c 	bl	c0d0021c <cx_eddsa_sign_no_throw>
c0d02704:	2800      	cmp	r0, #0
c0d02706:	d11d      	bne.n	c0d02744 <set_result_sign_message+0x84>
c0d02708:	a80f      	add	r0, sp, #60	; 0x3c

  size_t size;
  CX_THROW(cx_ecdomain_parameters_length(pvkey->curve, &size));
c0d0270a:	7800      	ldrb	r0, [r0, #0]
c0d0270c:	a929      	add	r1, sp, #164	; 0xa4
c0d0270e:	f000 f85d 	bl	c0d027cc <cx_ecdomain_parameters_length>
c0d02712:	2800      	cmp	r0, #0
c0d02714:	d116      	bne.n	c0d02744 <set_result_sign_message+0x84>
            memcpy(G_io_apdu_buffer, signature, SIGNATURE_LENGTH);
c0d02716:	4814      	ldr	r0, [pc, #80]	; (c0d02768 <set_result_sign_message+0xa8>)
c0d02718:	a919      	add	r1, sp, #100	; 0x64
c0d0271a:	2240      	movs	r2, #64	; 0x40
c0d0271c:	f002 fa6a 	bl	c0d04bf4 <__aeabi_memcpy>
        FINALLY {
c0d02720:	f000 f8f6 	bl	c0d02910 <try_context_get>
c0d02724:	a903      	add	r1, sp, #12
c0d02726:	4288      	cmp	r0, r1
c0d02728:	d102      	bne.n	c0d02730 <set_result_sign_message+0x70>
c0d0272a:	980d      	ldr	r0, [sp, #52]	; 0x34
c0d0272c:	f000 f8fc 	bl	c0d02928 <try_context_set>
c0d02730:	a80f      	add	r0, sp, #60	; 0x3c
c0d02732:	2128      	movs	r1, #40	; 0x28
            MEMCLEAR(privateKey);
c0d02734:	f002 fa6e 	bl	c0d04c14 <explicit_bzero>
c0d02738:	a803      	add	r0, sp, #12
    END_TRY;
c0d0273a:	8d80      	ldrh	r0, [r0, #44]	; 0x2c
c0d0273c:	2800      	cmp	r0, #0
c0d0273e:	d101      	bne.n	c0d02744 <set_result_sign_message+0x84>
    return SIGNATURE_LENGTH;
c0d02740:	b02a      	add	sp, #168	; 0xa8
c0d02742:	bdb0      	pop	{r4, r5, r7, pc}
c0d02744:	f7fe fb90 	bl	c0d00e68 <os_longjmp>
c0d02748:	a803      	add	r0, sp, #12
c0d0274a:	2100      	movs	r1, #0
        CATCH_OTHER(e) {
c0d0274c:	8581      	strh	r1, [r0, #44]	; 0x2c
c0d0274e:	980d      	ldr	r0, [sp, #52]	; 0x34
c0d02750:	f000 f8ea 	bl	c0d02928 <try_context_set>
c0d02754:	a80f      	add	r0, sp, #60	; 0x3c
c0d02756:	2128      	movs	r1, #40	; 0x28
            MEMCLEAR(privateKey);
c0d02758:	f002 fa5c 	bl	c0d04c14 <explicit_bzero>
            THROW(e);
c0d0275c:	4620      	mov	r0, r4
c0d0275e:	f7fe fb83 	bl	c0d00e68 <os_longjmp>
c0d02762:	46c0      	nop			; (mov r8, r8)
c0d02764:	20000368 	.word	0x20000368
c0d02768:	2000092c 	.word	0x2000092c

c0d0276c <SVC_Call>:
.thumb
.thumb_func
.global SVC_Call

SVC_Call:
    svc 1
c0d0276c:	df01      	svc	1
    cmp r1, #0
c0d0276e:	2900      	cmp	r1, #0
    bne exception
c0d02770:	d100      	bne.n	c0d02774 <exception>
    bx lr
c0d02772:	4770      	bx	lr

c0d02774 <exception>:
exception:
    // THROW(ex);
    mov r0, r1
c0d02774:	4608      	mov	r0, r1
    bl os_longjmp
c0d02776:	f7fe fb77 	bl	c0d00e68 <os_longjmp>

c0d0277a <SVC_cx_call>:
.thumb
.thumb_func
.global SVC_cx_call

SVC_cx_call:
    svc 1
c0d0277a:	df01      	svc	1
    bx lr
c0d0277c:	4770      	bx	lr
	...

c0d02780 <get_api_level>:
#include <string.h>

unsigned int SVC_Call(unsigned int syscall_id, void *parameters);
unsigned int SVC_cx_call(unsigned int syscall_id, unsigned int * parameters);

unsigned int get_api_level(void) {
c0d02780:	b580      	push	{r7, lr}
c0d02782:	b084      	sub	sp, #16
c0d02784:	2000      	movs	r0, #0
  unsigned int parameters [2+1];
  parameters[0] = 0;
  parameters[1] = 0;
c0d02786:	9002      	str	r0, [sp, #8]
  parameters[0] = 0;
c0d02788:	9001      	str	r0, [sp, #4]
c0d0278a:	4803      	ldr	r0, [pc, #12]	; (c0d02798 <get_api_level+0x18>)
c0d0278c:	a901      	add	r1, sp, #4
  return SVC_Call(SYSCALL_get_api_level_ID_IN, parameters);
c0d0278e:	f7ff ffed 	bl	c0d0276c <SVC_Call>
c0d02792:	b004      	add	sp, #16
c0d02794:	bd80      	pop	{r7, pc}
c0d02796:	46c0      	nop			; (mov r8, r8)
c0d02798:	60000138 	.word	0x60000138

c0d0279c <halt>:
}

void halt ( void ) {
c0d0279c:	b580      	push	{r7, lr}
c0d0279e:	b082      	sub	sp, #8
c0d027a0:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0d027a2:	9001      	str	r0, [sp, #4]
c0d027a4:	4802      	ldr	r0, [pc, #8]	; (c0d027b0 <halt+0x14>)
c0d027a6:	4669      	mov	r1, sp
  SVC_Call(SYSCALL_halt_ID_IN, parameters);
c0d027a8:	f7ff ffe0 	bl	c0d0276c <SVC_Call>
  return;
}
c0d027ac:	b002      	add	sp, #8
c0d027ae:	bd80      	pop	{r7, pc}
c0d027b0:	6000023c 	.word	0x6000023c

c0d027b4 <nvm_write>:

void nvm_write ( void * dst_adr, void * src_adr, unsigned int src_len ) {
c0d027b4:	b580      	push	{r7, lr}
c0d027b6:	b086      	sub	sp, #24
  unsigned int parameters [2+3];
  parameters[0] = (unsigned int)dst_adr;
c0d027b8:	ab01      	add	r3, sp, #4
c0d027ba:	c307      	stmia	r3!, {r0, r1, r2}
c0d027bc:	4802      	ldr	r0, [pc, #8]	; (c0d027c8 <nvm_write+0x14>)
c0d027be:	a901      	add	r1, sp, #4
  parameters[1] = (unsigned int)src_adr;
  parameters[2] = (unsigned int)src_len;
  SVC_Call(SYSCALL_nvm_write_ID_IN, parameters);
c0d027c0:	f7ff ffd4 	bl	c0d0276c <SVC_Call>
  return;
}
c0d027c4:	b006      	add	sp, #24
c0d027c6:	bd80      	pop	{r7, pc}
c0d027c8:	6000037f 	.word	0x6000037f

c0d027cc <cx_ecdomain_parameters_length>:
  parameters[0] = (unsigned int)cv;
  parameters[1] = (unsigned int)length;
  return SVC_cx_call(SYSCALL_cx_ecdomain_size_ID_IN, parameters);
}

cx_err_t cx_ecdomain_parameters_length ( cx_curve_t cv, size_t *length ) {
c0d027cc:	b580      	push	{r7, lr}
c0d027ce:	b084      	sub	sp, #16
  unsigned int parameters [2+2];
  parameters[0] = (unsigned int)cv;
  parameters[1] = (unsigned int)length;
c0d027d0:	9101      	str	r1, [sp, #4]
  parameters[0] = (unsigned int)cv;
c0d027d2:	9000      	str	r0, [sp, #0]
c0d027d4:	4802      	ldr	r0, [pc, #8]	; (c0d027e0 <cx_ecdomain_parameters_length+0x14>)
c0d027d6:	4669      	mov	r1, sp
  return SVC_cx_call(SYSCALL_cx_ecdomain_parameters_length_ID_IN, parameters);
c0d027d8:	f7ff ffcf 	bl	c0d0277a <SVC_cx_call>
c0d027dc:	b004      	add	sp, #16
c0d027de:	bd80      	pop	{r7, pc}
c0d027e0:	60012fb4 	.word	0x60012fb4

c0d027e4 <os_perso_isonboarded>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_os_perso_finalize_ID_IN, parameters);
  return;
}

bolos_bool_t os_perso_isonboarded ( void ) {
c0d027e4:	b580      	push	{r7, lr}
c0d027e6:	b082      	sub	sp, #8
c0d027e8:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0d027ea:	9001      	str	r0, [sp, #4]
c0d027ec:	4803      	ldr	r0, [pc, #12]	; (c0d027fc <os_perso_isonboarded+0x18>)
c0d027ee:	4669      	mov	r1, sp
  return (bolos_bool_t) SVC_Call(SYSCALL_os_perso_isonboarded_ID_IN, parameters);
c0d027f0:	f7ff ffbc 	bl	c0d0276c <SVC_Call>
c0d027f4:	b2c0      	uxtb	r0, r0
c0d027f6:	b002      	add	sp, #8
c0d027f8:	bd80      	pop	{r7, pc}
c0d027fa:	46c0      	nop			; (mov r8, r8)
c0d027fc:	60009f4f 	.word	0x60009f4f

c0d02800 <os_perso_derive_node_with_seed_key>:
  parameters[4] = (unsigned int)chain;
  SVC_Call(SYSCALL_os_perso_derive_node_bip32_ID_IN, parameters);
  return;
}

void os_perso_derive_node_with_seed_key ( unsigned int mode, cx_curve_t curve, const unsigned int * path, unsigned int pathLength, unsigned char * privateKey, unsigned char * chain, unsigned char * seed_key, unsigned int seed_key_length ) {
c0d02800:	b510      	push	{r4, lr}
c0d02802:	b08a      	sub	sp, #40	; 0x28
c0d02804:	9c0f      	ldr	r4, [sp, #60]	; 0x3c
  parameters[2] = (unsigned int)path;
  parameters[3] = (unsigned int)pathLength;
  parameters[4] = (unsigned int)privateKey;
  parameters[5] = (unsigned int)chain;
  parameters[6] = (unsigned int)seed_key;
  parameters[7] = (unsigned int)seed_key_length;
c0d02806:	9407      	str	r4, [sp, #28]
c0d02808:	9c0e      	ldr	r4, [sp, #56]	; 0x38
  parameters[6] = (unsigned int)seed_key;
c0d0280a:	9406      	str	r4, [sp, #24]
c0d0280c:	9c0d      	ldr	r4, [sp, #52]	; 0x34
  parameters[5] = (unsigned int)chain;
c0d0280e:	9405      	str	r4, [sp, #20]
c0d02810:	9c0c      	ldr	r4, [sp, #48]	; 0x30
  parameters[4] = (unsigned int)privateKey;
c0d02812:	9404      	str	r4, [sp, #16]
  parameters[3] = (unsigned int)pathLength;
c0d02814:	9303      	str	r3, [sp, #12]
  parameters[2] = (unsigned int)path;
c0d02816:	9202      	str	r2, [sp, #8]
  parameters[1] = (unsigned int)curve;
c0d02818:	9101      	str	r1, [sp, #4]
  parameters[0] = (unsigned int)mode;
c0d0281a:	9000      	str	r0, [sp, #0]
c0d0281c:	4802      	ldr	r0, [pc, #8]	; (c0d02828 <os_perso_derive_node_with_seed_key+0x28>)
c0d0281e:	4669      	mov	r1, sp
  SVC_Call(SYSCALL_os_perso_derive_node_with_seed_key_ID_IN, parameters);
c0d02820:	f7ff ffa4 	bl	c0d0276c <SVC_Call>
  return;
}
c0d02824:	b00a      	add	sp, #40	; 0x28
c0d02826:	bd10      	pop	{r4, pc}
c0d02828:	6000a6d8 	.word	0x6000a6d8

c0d0282c <os_perso_seed_cookie>:
  SVC_Call(SYSCALL_os_perso_derive_eip2333_ID_IN, parameters);
  return;
}

#if defined(HAVE_SEED_COOKIE)
unsigned int os_perso_seed_cookie ( unsigned char * seed_cookie, unsigned int seed_cookie_length ) {
c0d0282c:	b580      	push	{r7, lr}
c0d0282e:	b084      	sub	sp, #16
  unsigned int parameters [2+2];
  parameters[0] = (unsigned int)seed_cookie;
  parameters[1] = (unsigned int)seed_cookie_length;
c0d02830:	9101      	str	r1, [sp, #4]
  parameters[0] = (unsigned int)seed_cookie;
c0d02832:	9000      	str	r0, [sp, #0]
c0d02834:	4802      	ldr	r0, [pc, #8]	; (c0d02840 <os_perso_seed_cookie+0x14>)
c0d02836:	4669      	mov	r1, sp
  return (unsigned int) SVC_Call(SYSCALL_os_perso_seed_cookie_ID_IN, parameters);
c0d02838:	f7ff ff98 	bl	c0d0276c <SVC_Call>
c0d0283c:	b004      	add	sp, #16
c0d0283e:	bd80      	pop	{r7, pc}
c0d02840:	6000a8fc 	.word	0x6000a8fc

c0d02844 <os_global_pin_is_validated>:
  parameters[1] = (unsigned int)length;
  SVC_Call(SYSCALL_os_perso_set_current_identity_pin_ID_IN, parameters);
  return;
}

bolos_bool_t os_global_pin_is_validated ( void ) {
c0d02844:	b580      	push	{r7, lr}
c0d02846:	b082      	sub	sp, #8
c0d02848:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0d0284a:	9001      	str	r0, [sp, #4]
c0d0284c:	4803      	ldr	r0, [pc, #12]	; (c0d0285c <os_global_pin_is_validated+0x18>)
c0d0284e:	4669      	mov	r1, sp
  return (bolos_bool_t) SVC_Call(SYSCALL_os_global_pin_is_validated_ID_IN, parameters);
c0d02850:	f7ff ff8c 	bl	c0d0276c <SVC_Call>
c0d02854:	b2c0      	uxtb	r0, r0
c0d02856:	b002      	add	sp, #8
c0d02858:	bd80      	pop	{r7, pc}
c0d0285a:	46c0      	nop			; (mov r8, r8)
c0d0285c:	6000a03c 	.word	0x6000a03c

c0d02860 <os_ux>:
  SVC_Call(SYSCALL_os_registry_get_ID_IN, parameters);
  return;
}

#if !defined(APP_UX)
unsigned int os_ux ( bolos_ux_params_t * params ) {
c0d02860:	b580      	push	{r7, lr}
c0d02862:	b084      	sub	sp, #16
c0d02864:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)params;
  parameters[1] = 0;
c0d02866:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)params;
c0d02868:	9001      	str	r0, [sp, #4]
c0d0286a:	4803      	ldr	r0, [pc, #12]	; (c0d02878 <os_ux+0x18>)
c0d0286c:	a901      	add	r1, sp, #4
  return (unsigned int) SVC_Call(SYSCALL_os_ux_ID_IN, parameters);
c0d0286e:	f7ff ff7d 	bl	c0d0276c <SVC_Call>
c0d02872:	b004      	add	sp, #16
c0d02874:	bd80      	pop	{r7, pc}
c0d02876:	46c0      	nop			; (mov r8, r8)
c0d02878:	60006458 	.word	0x60006458

c0d0287c <os_flags>:

  // remove the warning caused by -Winvalid-noreturn
  __builtin_unreachable();
}

unsigned int os_flags ( void ) {
c0d0287c:	b580      	push	{r7, lr}
c0d0287e:	b082      	sub	sp, #8
c0d02880:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0d02882:	9001      	str	r0, [sp, #4]
c0d02884:	4802      	ldr	r0, [pc, #8]	; (c0d02890 <os_flags+0x14>)
c0d02886:	4669      	mov	r1, sp
  return (unsigned int) SVC_Call(SYSCALL_os_flags_ID_IN, parameters);
c0d02888:	f7ff ff70 	bl	c0d0276c <SVC_Call>
c0d0288c:	b002      	add	sp, #8
c0d0288e:	bd80      	pop	{r7, pc}
c0d02890:	60006a6e 	.word	0x60006a6e

c0d02894 <os_registry_get_current_app_tag>:
  parameters[4] = (unsigned int)buffer;
  parameters[5] = (unsigned int)maxlength;
  return (unsigned int) SVC_Call(SYSCALL_os_registry_get_tag_ID_IN, parameters);
}

unsigned int os_registry_get_current_app_tag ( unsigned int tag, unsigned char * buffer, unsigned int maxlen ) {
c0d02894:	b580      	push	{r7, lr}
c0d02896:	b086      	sub	sp, #24
  unsigned int parameters [2+3];
  parameters[0] = (unsigned int)tag;
c0d02898:	ab01      	add	r3, sp, #4
c0d0289a:	c307      	stmia	r3!, {r0, r1, r2}
c0d0289c:	4802      	ldr	r0, [pc, #8]	; (c0d028a8 <os_registry_get_current_app_tag+0x14>)
c0d0289e:	a901      	add	r1, sp, #4
  parameters[1] = (unsigned int)buffer;
  parameters[2] = (unsigned int)maxlen;
  return (unsigned int) SVC_Call(SYSCALL_os_registry_get_current_app_tag_ID_IN, parameters);
c0d028a0:	f7ff ff64 	bl	c0d0276c <SVC_Call>
c0d028a4:	b006      	add	sp, #24
c0d028a6:	bd80      	pop	{r7, pc}
c0d028a8:	600074d4 	.word	0x600074d4

c0d028ac <os_sched_exit>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_os_sched_exec_ID_IN, parameters);
  return;
}

void __attribute__((noreturn)) os_sched_exit ( bolos_task_status_t exit_code ) {
c0d028ac:	b084      	sub	sp, #16
c0d028ae:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)exit_code;
  parameters[1] = 0;
c0d028b0:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)exit_code;
c0d028b2:	9001      	str	r0, [sp, #4]
c0d028b4:	4802      	ldr	r0, [pc, #8]	; (c0d028c0 <os_sched_exit+0x14>)
c0d028b6:	a901      	add	r1, sp, #4
  SVC_Call(SYSCALL_os_sched_exit_ID_IN, parameters);
c0d028b8:	f7ff ff58 	bl	c0d0276c <SVC_Call>

  // The os_sched_exit syscall should never return.
  // Just in case, crash the device thanks to an undefined instruction.
  // To avoid the __builtin_unreachable undefined behaviour
  asm volatile ("udf #255");
c0d028bc:	deff      	udf	#255	; 0xff
c0d028be:	46c0      	nop			; (mov r8, r8)
c0d028c0:	60009abe 	.word	0x60009abe

c0d028c4 <io_seph_send>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_os_sched_kill_ID_IN, parameters);
  return;
}

void io_seph_send ( const unsigned char * buffer, unsigned short length ) {
c0d028c4:	b580      	push	{r7, lr}
c0d028c6:	b084      	sub	sp, #16
  unsigned int parameters [2+2];
  parameters[0] = (unsigned int)buffer;
  parameters[1] = (unsigned int)length;
c0d028c8:	9101      	str	r1, [sp, #4]
  parameters[0] = (unsigned int)buffer;
c0d028ca:	9000      	str	r0, [sp, #0]
c0d028cc:	4802      	ldr	r0, [pc, #8]	; (c0d028d8 <io_seph_send+0x14>)
c0d028ce:	4669      	mov	r1, sp
  SVC_Call(SYSCALL_io_seph_send_ID_IN, parameters);
c0d028d0:	f7ff ff4c 	bl	c0d0276c <SVC_Call>
  return;
}
c0d028d4:	b004      	add	sp, #16
c0d028d6:	bd80      	pop	{r7, pc}
c0d028d8:	60008381 	.word	0x60008381

c0d028dc <io_seph_is_status_sent>:

unsigned int io_seph_is_status_sent ( void ) {
c0d028dc:	b580      	push	{r7, lr}
c0d028de:	b082      	sub	sp, #8
c0d028e0:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0d028e2:	9001      	str	r0, [sp, #4]
c0d028e4:	4802      	ldr	r0, [pc, #8]	; (c0d028f0 <io_seph_is_status_sent+0x14>)
c0d028e6:	4669      	mov	r1, sp
  return (unsigned int) SVC_Call(SYSCALL_io_seph_is_status_sent_ID_IN, parameters);
c0d028e8:	f7ff ff40 	bl	c0d0276c <SVC_Call>
c0d028ec:	b002      	add	sp, #8
c0d028ee:	bd80      	pop	{r7, pc}
c0d028f0:	600084bb 	.word	0x600084bb

c0d028f4 <io_seph_recv>:
}

unsigned short io_seph_recv ( unsigned char * buffer, unsigned short maxlength, unsigned int flags ) {
c0d028f4:	b580      	push	{r7, lr}
c0d028f6:	b086      	sub	sp, #24
  unsigned int parameters [2+3];
  parameters[0] = (unsigned int)buffer;
c0d028f8:	ab01      	add	r3, sp, #4
c0d028fa:	c307      	stmia	r3!, {r0, r1, r2}
c0d028fc:	4803      	ldr	r0, [pc, #12]	; (c0d0290c <io_seph_recv+0x18>)
c0d028fe:	a901      	add	r1, sp, #4
  parameters[1] = (unsigned int)maxlength;
  parameters[2] = (unsigned int)flags;
  return (unsigned short) SVC_Call(SYSCALL_io_seph_recv_ID_IN, parameters);
c0d02900:	f7ff ff34 	bl	c0d0276c <SVC_Call>
c0d02904:	b280      	uxth	r0, r0
c0d02906:	b006      	add	sp, #24
c0d02908:	bd80      	pop	{r7, pc}
c0d0290a:	46c0      	nop			; (mov r8, r8)
c0d0290c:	600085e4 	.word	0x600085e4

c0d02910 <try_context_get>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_nvm_erase_page_ID_IN, parameters);
  return;
}

try_context_t * try_context_get ( void ) {
c0d02910:	b580      	push	{r7, lr}
c0d02912:	b082      	sub	sp, #8
c0d02914:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0d02916:	9001      	str	r0, [sp, #4]
c0d02918:	4802      	ldr	r0, [pc, #8]	; (c0d02924 <try_context_get+0x14>)
c0d0291a:	4669      	mov	r1, sp
  return (try_context_t *) SVC_Call(SYSCALL_try_context_get_ID_IN, parameters);
c0d0291c:	f7ff ff26 	bl	c0d0276c <SVC_Call>
c0d02920:	b002      	add	sp, #8
c0d02922:	bd80      	pop	{r7, pc}
c0d02924:	600087b1 	.word	0x600087b1

c0d02928 <try_context_set>:
}

try_context_t * try_context_set ( try_context_t *context ) {
c0d02928:	b580      	push	{r7, lr}
c0d0292a:	b084      	sub	sp, #16
c0d0292c:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)context;
  parameters[1] = 0;
c0d0292e:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)context;
c0d02930:	9001      	str	r0, [sp, #4]
c0d02932:	4803      	ldr	r0, [pc, #12]	; (c0d02940 <try_context_set+0x18>)
c0d02934:	a901      	add	r1, sp, #4
  return (try_context_t *) SVC_Call(SYSCALL_try_context_set_ID_IN, parameters);
c0d02936:	f7ff ff19 	bl	c0d0276c <SVC_Call>
c0d0293a:	b004      	add	sp, #16
c0d0293c:	bd80      	pop	{r7, pc}
c0d0293e:	46c0      	nop			; (mov r8, r8)
c0d02940:	60010b06 	.word	0x60010b06

c0d02944 <os_sched_last_status>:
}

bolos_task_status_t os_sched_last_status ( unsigned int task_idx ) {
c0d02944:	b580      	push	{r7, lr}
c0d02946:	b084      	sub	sp, #16
c0d02948:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)task_idx;
  parameters[1] = 0;
c0d0294a:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)task_idx;
c0d0294c:	9001      	str	r0, [sp, #4]
c0d0294e:	4803      	ldr	r0, [pc, #12]	; (c0d0295c <os_sched_last_status+0x18>)
c0d02950:	a901      	add	r1, sp, #4
  return (bolos_task_status_t) SVC_Call(SYSCALL_os_sched_last_status_ID_IN, parameters);
c0d02952:	f7ff ff0b 	bl	c0d0276c <SVC_Call>
c0d02956:	b2c0      	uxtb	r0, r0
c0d02958:	b004      	add	sp, #16
c0d0295a:	bd80      	pop	{r7, pc}
c0d0295c:	60009c8b 	.word	0x60009c8b

c0d02960 <summary_item_set_amount>:
#include <string.h>

void summary_item_set_amount(SummaryItem* item, const char* title, uint64_t value) {
    item->kind = SummaryItemAmount;
    item->title = title;
    item->u64 = value;
c0d02960:	6082      	str	r2, [r0, #8]
c0d02962:	60c3      	str	r3, [r0, #12]
    item->title = title;
c0d02964:	6001      	str	r1, [r0, #0]
c0d02966:	2101      	movs	r1, #1
    item->kind = SummaryItemAmount;
c0d02968:	7101      	strb	r1, [r0, #4]
}
c0d0296a:	4770      	bx	lr

c0d0296c <summary_item_set_pubkey>:
}

void summary_item_set_pubkey(SummaryItem* item, const char* title, const Pubkey* value) {
    item->kind = SummaryItemPubkey;
    item->title = title;
    item->pubkey = value;
c0d0296c:	6082      	str	r2, [r0, #8]
    item->title = title;
c0d0296e:	6001      	str	r1, [r0, #0]
c0d02970:	2105      	movs	r1, #5
    item->kind = SummaryItemPubkey;
c0d02972:	7101      	strb	r1, [r0, #4]
}
c0d02974:	4770      	bx	lr

c0d02976 <summary_item_set_hash>:

void summary_item_set_hash(SummaryItem* item, const char* title, const Hash* value) {
    item->kind = SummaryItemHash;
    item->title = title;
    item->hash = value;
c0d02976:	6082      	str	r2, [r0, #8]
    item->title = title;
c0d02978:	6001      	str	r1, [r0, #0]
c0d0297a:	2106      	movs	r1, #6
    item->kind = SummaryItemHash;
c0d0297c:	7101      	strb	r1, [r0, #4]
}
c0d0297e:	4770      	bx	lr

c0d02980 <summary_item_set_string>:
}

void summary_item_set_string(SummaryItem* item, const char* title, const char* value) {
    item->kind = SummaryItemString;
    item->title = title;
    item->string = value;
c0d02980:	6082      	str	r2, [r0, #8]
    item->title = title;
c0d02982:	6001      	str	r1, [r0, #0]
c0d02984:	2108      	movs	r1, #8
    item->kind = SummaryItemString;
c0d02986:	7101      	strb	r1, [r0, #4]
}
c0d02988:	4770      	bx	lr
	...

c0d0298c <transaction_summary_reset>:
static TransactionSummary G_transaction_summary;

char G_transaction_summary_title[TITLE_SIZE];
char G_transaction_summary_text[TEXT_BUFFER_LENGTH];

void transaction_summary_reset() {
c0d0298c:	b510      	push	{r4, lr}
c0d0298e:	242d      	movs	r4, #45	; 0x2d
c0d02990:	00e1      	lsls	r1, r4, #3
    explicit_bzero(&G_transaction_summary, sizeof(TransactionSummary));
c0d02992:	4806      	ldr	r0, [pc, #24]	; (c0d029ac <transaction_summary_reset+0x20>)
c0d02994:	f002 f93e 	bl	c0d04c14 <explicit_bzero>
    explicit_bzero(&G_transaction_summary_title, TITLE_SIZE);
c0d02998:	4805      	ldr	r0, [pc, #20]	; (c0d029b0 <transaction_summary_reset+0x24>)
c0d0299a:	2120      	movs	r1, #32
c0d0299c:	f002 f93a 	bl	c0d04c14 <explicit_bzero>
    explicit_bzero(&G_transaction_summary_text, TEXT_BUFFER_LENGTH);
c0d029a0:	4804      	ldr	r0, [pc, #16]	; (c0d029b4 <transaction_summary_reset+0x28>)
c0d029a2:	4621      	mov	r1, r4
c0d029a4:	f002 f936 	bl	c0d04c14 <explicit_bzero>
}
c0d029a8:	bd10      	pop	{r4, pc}
c0d029aa:	46c0      	nop			; (mov r8, r8)
c0d029ac:	20000af8 	.word	0x20000af8
c0d029b0:	20000c60 	.word	0x20000c60
c0d029b4:	20000c80 	.word	0x20000c80

c0d029b8 <transaction_summary_primary_item>:

static bool is_summary_item_used(const SummaryItem* item) {
    return (item->kind != SummaryItemNone);
c0d029b8:	4802      	ldr	r0, [pc, #8]	; (c0d029c4 <transaction_summary_primary_item+0xc>)
c0d029ba:	7901      	ldrb	r1, [r0, #4]
}

static SummaryItem* summary_item_as_unused(SummaryItem* item) {
    if (!is_summary_item_used(item)) {
c0d029bc:	2900      	cmp	r1, #0
c0d029be:	d000      	beq.n	c0d029c2 <transaction_summary_primary_item+0xa>
c0d029c0:	2000      	movs	r0, #0
    return NULL;
}

SummaryItem* transaction_summary_primary_item() {
    SummaryItem* item = &G_transaction_summary.primary;
    return summary_item_as_unused(item);
c0d029c2:	4770      	bx	lr
c0d029c4:	20000af8 	.word	0x20000af8

c0d029c8 <transaction_summary_general_item>:
SummaryItem* transaction_summary_nonce_authority_item() {
    SummaryItem* item = &G_transaction_summary.nonce_authority;
    return summary_item_as_unused(item);
}

SummaryItem* transaction_summary_general_item() {
c0d029c8:	4805      	ldr	r0, [pc, #20]	; (c0d029e0 <transaction_summary_general_item+0x18>)
c0d029ca:	3060      	adds	r0, #96	; 0x60
c0d029cc:	210b      	movs	r1, #11
    return (item->kind != SummaryItemNone);
c0d029ce:	7902      	ldrb	r2, [r0, #4]
c0d029d0:	2a00      	cmp	r2, #0
c0d029d2:	d004      	beq.n	c0d029de <transaction_summary_general_item+0x16>
    for (size_t i = 0; i < NUM_GENERAL_ITEMS; i++) {
c0d029d4:	1e49      	subs	r1, r1, #1
c0d029d6:	3018      	adds	r0, #24
c0d029d8:	2900      	cmp	r1, #0
c0d029da:	d1f8      	bne.n	c0d029ce <transaction_summary_general_item+0x6>
c0d029dc:	2000      	movs	r0, #0
        if (!is_summary_item_used(item)) {
            return item;
        }
    }
    return NULL;
}
c0d029de:	4770      	bx	lr
c0d029e0:	20000af8 	.word	0x20000af8

c0d029e4 <transaction_summary_display_item>:
    }

    return NULL;
}

int transaction_summary_display_item(size_t item_index, enum DisplayFlags flags) {
c0d029e4:	b570      	push	{r4, r5, r6, lr}
c0d029e6:	b08e      	sub	sp, #56	; 0x38
c0d029e8:	460c      	mov	r4, r1
    if (current_index == item_index) {
c0d029ea:	2800      	cmp	r0, #0
c0d029ec:	d016      	beq.n	c0d02a1c <transaction_summary_display_item+0x38>
c0d029ee:	4950      	ldr	r1, [pc, #320]	; (c0d02b30 <transaction_summary_display_item+0x14c>)
c0d029f0:	460d      	mov	r5, r1
c0d029f2:	3560      	adds	r5, #96	; 0x60
c0d029f4:	2201      	movs	r2, #1
c0d029f6:	230b      	movs	r3, #11
    return (item->kind != SummaryItemNone);
c0d029f8:	792e      	ldrb	r6, [r5, #4]
        if (is_summary_item_used(&summary->general[i])) {
c0d029fa:	2e00      	cmp	r6, #0
c0d029fc:	d002      	beq.n	c0d02a04 <transaction_summary_display_item+0x20>
            if (current_index == item_index) {
c0d029fe:	4282      	cmp	r2, r0
c0d02a00:	d01c      	beq.n	c0d02a3c <transaction_summary_display_item+0x58>
            ++current_index;
c0d02a02:	1c52      	adds	r2, r2, #1
    for (size_t i = 0; i < NUM_GENERAL_ITEMS; i++) {
c0d02a04:	1e5b      	subs	r3, r3, #1
c0d02a06:	3518      	adds	r5, #24
c0d02a08:	2b00      	cmp	r3, #0
c0d02a0a:	d1f5      	bne.n	c0d029f8 <transaction_summary_display_item+0x14>
c0d02a0c:	2334      	movs	r3, #52	; 0x34
    return (item->kind != SummaryItemNone);
c0d02a0e:	5ccb      	ldrb	r3, [r1, r3]
    if (is_summary_item_used(&summary->nonce_account)) {
c0d02a10:	2b00      	cmp	r3, #0
c0d02a12:	d006      	beq.n	c0d02a22 <transaction_summary_display_item+0x3e>
        if (current_index == item_index) {
c0d02a14:	4282      	cmp	r2, r0
c0d02a16:	d103      	bne.n	c0d02a20 <transaction_summary_display_item+0x3c>
c0d02a18:	3130      	adds	r1, #48	; 0x30
c0d02a1a:	e00e      	b.n	c0d02a3a <transaction_summary_display_item+0x56>
c0d02a1c:	4d44      	ldr	r5, [pc, #272]	; (c0d02b30 <transaction_summary_display_item+0x14c>)
c0d02a1e:	e00d      	b.n	c0d02a3c <transaction_summary_display_item+0x58>
        ++current_index;
c0d02a20:	1c52      	adds	r2, r2, #1
c0d02a22:	234c      	movs	r3, #76	; 0x4c
    return (item->kind != SummaryItemNone);
c0d02a24:	5ccb      	ldrb	r3, [r1, r3]
    if (is_summary_item_used(&summary->nonce_authority)) {
c0d02a26:	2b00      	cmp	r3, #0
c0d02a28:	d004      	beq.n	c0d02a34 <transaction_summary_display_item+0x50>
        if (current_index == item_index) {
c0d02a2a:	4282      	cmp	r2, r0
c0d02a2c:	d101      	bne.n	c0d02a32 <transaction_summary_display_item+0x4e>
c0d02a2e:	3148      	adds	r1, #72	; 0x48
c0d02a30:	e003      	b.n	c0d02a3a <transaction_summary_display_item+0x56>
        ++current_index;
c0d02a32:	1c52      	adds	r2, r2, #1
c0d02a34:	4282      	cmp	r2, r0
c0d02a36:	d138      	bne.n	c0d02aaa <transaction_summary_display_item+0xc6>
c0d02a38:	3118      	adds	r1, #24
c0d02a3a:	460d      	mov	r5, r1
    switch (item->kind) {
c0d02a3c:	7928      	ldrb	r0, [r5, #4]
c0d02a3e:	2804      	cmp	r0, #4
c0d02a40:	dc0e      	bgt.n	c0d02a60 <transaction_summary_display_item+0x7c>
c0d02a42:	2801      	cmp	r0, #1
c0d02a44:	dd1b      	ble.n	c0d02a7e <transaction_summary_display_item+0x9a>
c0d02a46:	2802      	cmp	r0, #2
c0d02a48:	d031      	beq.n	c0d02aae <transaction_summary_display_item+0xca>
c0d02a4a:	2803      	cmp	r0, #3
c0d02a4c:	d03a      	beq.n	c0d02ac4 <transaction_summary_display_item+0xe0>
c0d02a4e:	2804      	cmp	r0, #4
c0d02a50:	d14d      	bne.n	c0d02aee <transaction_summary_display_item+0x10a>
            BAIL_IF(print_u64(item->u64, G_transaction_summary_text, TEXT_BUFFER_LENGTH));
c0d02a52:	68a8      	ldr	r0, [r5, #8]
c0d02a54:	68e9      	ldr	r1, [r5, #12]
c0d02a56:	4a37      	ldr	r2, [pc, #220]	; (c0d02b34 <transaction_summary_display_item+0x150>)
c0d02a58:	232d      	movs	r3, #45	; 0x2d
c0d02a5a:	f7ff fc15 	bl	c0d02288 <print_u64>
c0d02a5e:	e037      	b.n	c0d02ad0 <transaction_summary_display_item+0xec>
    switch (item->kind) {
c0d02a60:	2806      	cmp	r0, #6
c0d02a62:	dd17      	ble.n	c0d02a94 <transaction_summary_display_item+0xb0>
c0d02a64:	2807      	cmp	r0, #7
c0d02a66:	d036      	beq.n	c0d02ad6 <transaction_summary_display_item+0xf2>
c0d02a68:	2808      	cmp	r0, #8
c0d02a6a:	d03b      	beq.n	c0d02ae4 <transaction_summary_display_item+0x100>
c0d02a6c:	2809      	cmp	r0, #9
c0d02a6e:	d13e      	bne.n	c0d02aee <transaction_summary_display_item+0x10a>
            BAIL_IF(print_timestamp(item->i64, G_transaction_summary_text, TEXT_BUFFER_LENGTH));
c0d02a70:	68a8      	ldr	r0, [r5, #8]
c0d02a72:	68e9      	ldr	r1, [r5, #12]
c0d02a74:	4a2f      	ldr	r2, [pc, #188]	; (c0d02b34 <transaction_summary_display_item+0x150>)
c0d02a76:	232d      	movs	r3, #45	; 0x2d
c0d02a78:	f7ff fc59 	bl	c0d0232e <print_timestamp>
c0d02a7c:	e028      	b.n	c0d02ad0 <transaction_summary_display_item+0xec>
    switch (item->kind) {
c0d02a7e:	2800      	cmp	r0, #0
c0d02a80:	d013      	beq.n	c0d02aaa <transaction_summary_display_item+0xc6>
c0d02a82:	2801      	cmp	r0, #1
c0d02a84:	d133      	bne.n	c0d02aee <transaction_summary_display_item+0x10a>
            BAIL_IF(print_amount(item->u64, G_transaction_summary_text, BASE58_PUBKEY_LENGTH));
c0d02a86:	68a8      	ldr	r0, [r5, #8]
c0d02a88:	68e9      	ldr	r1, [r5, #12]
c0d02a8a:	4a2a      	ldr	r2, [pc, #168]	; (c0d02b34 <transaction_summary_display_item+0x150>)
c0d02a8c:	232d      	movs	r3, #45	; 0x2d
c0d02a8e:	f7ff faed 	bl	c0d0206c <print_amount>
c0d02a92:	e01d      	b.n	c0d02ad0 <transaction_summary_display_item+0xec>
    switch (item->kind) {
c0d02a94:	2805      	cmp	r0, #5
c0d02a96:	d032      	beq.n	c0d02afe <transaction_summary_display_item+0x11a>
c0d02a98:	2806      	cmp	r0, #6
c0d02a9a:	d128      	bne.n	c0d02aee <transaction_summary_display_item+0x10a>
            BAIL_IF(encode_base58(item->hash,
c0d02a9c:	68a8      	ldr	r0, [r5, #8]
c0d02a9e:	2120      	movs	r1, #32
c0d02aa0:	4a24      	ldr	r2, [pc, #144]	; (c0d02b34 <transaction_summary_display_item+0x150>)
c0d02aa2:	232d      	movs	r3, #45	; 0x2d
c0d02aa4:	f7ff fb5e 	bl	c0d02164 <encode_base58>
c0d02aa8:	e012      	b.n	c0d02ad0 <transaction_summary_display_item+0xec>
c0d02aaa:	2001      	movs	r0, #1
c0d02aac:	e025      	b.n	c0d02afa <transaction_summary_display_item+0x116>
            BAIL_IF(print_token_amount(item->token_amount.value,
c0d02aae:	462a      	mov	r2, r5
c0d02ab0:	3208      	adds	r2, #8
c0d02ab2:	ca07      	ldmia	r2, {r0, r1, r2}
c0d02ab4:	7d2b      	ldrb	r3, [r5, #20]
c0d02ab6:	242d      	movs	r4, #45	; 0x2d
c0d02ab8:	9401      	str	r4, [sp, #4]
c0d02aba:	4c1e      	ldr	r4, [pc, #120]	; (c0d02b34 <transaction_summary_display_item+0x150>)
c0d02abc:	9400      	str	r4, [sp, #0]
c0d02abe:	f7ff fa4b 	bl	c0d01f58 <print_token_amount>
c0d02ac2:	e005      	b.n	c0d02ad0 <transaction_summary_display_item+0xec>
            BAIL_IF(print_i64(item->i64, G_transaction_summary_text, TEXT_BUFFER_LENGTH));
c0d02ac4:	68a8      	ldr	r0, [r5, #8]
c0d02ac6:	68e9      	ldr	r1, [r5, #12]
c0d02ac8:	4a1a      	ldr	r2, [pc, #104]	; (c0d02b34 <transaction_summary_display_item+0x150>)
c0d02aca:	232d      	movs	r3, #45	; 0x2d
c0d02acc:	f7ff fbc8 	bl	c0d02260 <print_i64>
c0d02ad0:	2800      	cmp	r0, #0
c0d02ad2:	d112      	bne.n	c0d02afa <transaction_summary_display_item+0x116>
c0d02ad4:	e00b      	b.n	c0d02aee <transaction_summary_display_item+0x10a>
            print_sized_string(&item->sized_string, G_transaction_summary_text, TEXT_BUFFER_LENGTH);
c0d02ad6:	4628      	mov	r0, r5
c0d02ad8:	3008      	adds	r0, #8
c0d02ada:	4916      	ldr	r1, [pc, #88]	; (c0d02b34 <transaction_summary_display_item+0x150>)
c0d02adc:	222d      	movs	r2, #45	; 0x2d
c0d02ade:	f7ff fad3 	bl	c0d02088 <print_sized_string>
c0d02ae2:	e004      	b.n	c0d02aee <transaction_summary_display_item+0x10a>
            print_string(item->string, G_transaction_summary_text, TEXT_BUFFER_LENGTH);
c0d02ae4:	68a8      	ldr	r0, [r5, #8]
c0d02ae6:	4913      	ldr	r1, [pc, #76]	; (c0d02b34 <transaction_summary_display_item+0x150>)
c0d02ae8:	222d      	movs	r2, #45	; 0x2d
c0d02aea:	f7ff faf1 	bl	c0d020d0 <print_string>
    print_string(item->title, G_transaction_summary_title, TITLE_SIZE);
c0d02aee:	6828      	ldr	r0, [r5, #0]
c0d02af0:	4911      	ldr	r1, [pc, #68]	; (c0d02b38 <transaction_summary_display_item+0x154>)
c0d02af2:	2220      	movs	r2, #32
c0d02af4:	f7ff faec 	bl	c0d020d0 <print_string>
c0d02af8:	2000      	movs	r0, #0
    if (item == NULL) {
        return 1;
    }

    return transaction_summary_update_display_for_item(item, flags);
}
c0d02afa:	b00e      	add	sp, #56	; 0x38
c0d02afc:	bd70      	pop	{r4, r5, r6, pc}
            BAIL_IF(encode_base58(item->pubkey, PUBKEY_SIZE, tmp_buf, sizeof(tmp_buf)));
c0d02afe:	68a8      	ldr	r0, [r5, #8]
c0d02b00:	2120      	movs	r1, #32
c0d02b02:	aa02      	add	r2, sp, #8
c0d02b04:	232d      	movs	r3, #45	; 0x2d
c0d02b06:	f7ff fb2d 	bl	c0d02164 <encode_base58>
c0d02b0a:	2800      	cmp	r0, #0
c0d02b0c:	d1f5      	bne.n	c0d02afa <transaction_summary_display_item+0x116>
            if (flags & DisplayFlagLongPubkeys) {
c0d02b0e:	07e0      	lsls	r0, r4, #31
c0d02b10:	d107      	bne.n	c0d02b22 <transaction_summary_display_item+0x13e>
c0d02b12:	2307      	movs	r3, #7
                BAIL_IF(print_summary(tmp_buf,
c0d02b14:	9300      	str	r3, [sp, #0]
c0d02b16:	a802      	add	r0, sp, #8
c0d02b18:	4906      	ldr	r1, [pc, #24]	; (c0d02b34 <transaction_summary_display_item+0x150>)
c0d02b1a:	2211      	movs	r2, #17
c0d02b1c:	f7ff faee 	bl	c0d020fc <print_summary>
c0d02b20:	e7d6      	b.n	c0d02ad0 <transaction_summary_display_item+0xec>
c0d02b22:	a802      	add	r0, sp, #8
                BAIL_IF(print_string(tmp_buf, G_transaction_summary_text, TEXT_BUFFER_LENGTH));
c0d02b24:	4903      	ldr	r1, [pc, #12]	; (c0d02b34 <transaction_summary_display_item+0x150>)
c0d02b26:	222d      	movs	r2, #45	; 0x2d
c0d02b28:	f7ff fad2 	bl	c0d020d0 <print_string>
c0d02b2c:	e7d0      	b.n	c0d02ad0 <transaction_summary_display_item+0xec>
c0d02b2e:	46c0      	nop			; (mov r8, r8)
c0d02b30:	20000af8 	.word	0x20000af8
c0d02b34:	20000c80 	.word	0x20000c80
c0d02b38:	20000c60 	.word	0x20000c60

c0d02b3c <transaction_summary_finalize>:
        if (item.kind != SummaryItemNone) {  \
            item_kinds[index++] = item.kind; \
        }                                    \
    } while (0)

int transaction_summary_finalize(enum SummaryItemKind* item_kinds, size_t* item_kinds_len) {
c0d02b3c:	b570      	push	{r4, r5, r6, lr}
    const TransactionSummary* summary = &G_transaction_summary;
    size_t index = 0;

    if (summary->primary.kind == SummaryItemNone) {
c0d02b3e:	4b13      	ldr	r3, [pc, #76]	; (c0d02b8c <transaction_summary_finalize+0x50>)
c0d02b40:	791a      	ldrb	r2, [r3, #4]
c0d02b42:	2a00      	cmp	r2, #0
c0d02b44:	d020      	beq.n	c0d02b88 <transaction_summary_finalize+0x4c>
        return 1;
    }

    SET_IF_USED(summary->primary, item_kinds, index);
c0d02b46:	7002      	strb	r2, [r0, #0]
c0d02b48:	461c      	mov	r4, r3
c0d02b4a:	3464      	adds	r4, #100	; 0x64
c0d02b4c:	2201      	movs	r2, #1
c0d02b4e:	250b      	movs	r5, #11

    for (size_t i = 0; i < NUM_GENERAL_ITEMS; i++) {
        SET_IF_USED(summary->general[i], item_kinds, index);
c0d02b50:	7826      	ldrb	r6, [r4, #0]
c0d02b52:	2e00      	cmp	r6, #0
c0d02b54:	d001      	beq.n	c0d02b5a <transaction_summary_finalize+0x1e>
c0d02b56:	5486      	strb	r6, [r0, r2]
c0d02b58:	1c52      	adds	r2, r2, #1
    for (size_t i = 0; i < NUM_GENERAL_ITEMS; i++) {
c0d02b5a:	3418      	adds	r4, #24
c0d02b5c:	1e6d      	subs	r5, r5, #1
c0d02b5e:	d1f7      	bne.n	c0d02b50 <transaction_summary_finalize+0x14>
c0d02b60:	2434      	movs	r4, #52	; 0x34
    }

    SET_IF_USED(summary->nonce_account, item_kinds, index);
c0d02b62:	5d1c      	ldrb	r4, [r3, r4]
c0d02b64:	2c00      	cmp	r4, #0
c0d02b66:	d001      	beq.n	c0d02b6c <transaction_summary_finalize+0x30>
c0d02b68:	5484      	strb	r4, [r0, r2]
c0d02b6a:	1c52      	adds	r2, r2, #1
c0d02b6c:	244c      	movs	r4, #76	; 0x4c
    SET_IF_USED(summary->nonce_authority, item_kinds, index);
c0d02b6e:	5d1c      	ldrb	r4, [r3, r4]
c0d02b70:	2c00      	cmp	r4, #0
c0d02b72:	d001      	beq.n	c0d02b78 <transaction_summary_finalize+0x3c>
c0d02b74:	5484      	strb	r4, [r0, r2]
c0d02b76:	1c52      	adds	r2, r2, #1
    SET_IF_USED(summary->fee_payer, item_kinds, index);
c0d02b78:	7f1b      	ldrb	r3, [r3, #28]
c0d02b7a:	2b00      	cmp	r3, #0
c0d02b7c:	d001      	beq.n	c0d02b82 <transaction_summary_finalize+0x46>
c0d02b7e:	5483      	strb	r3, [r0, r2]
c0d02b80:	1c52      	adds	r2, r2, #1

    *item_kinds_len = index;
c0d02b82:	600a      	str	r2, [r1, #0]
c0d02b84:	2000      	movs	r0, #0
    return 0;
}
c0d02b86:	bd70      	pop	{r4, r5, r6, pc}
c0d02b88:	2001      	movs	r0, #1
c0d02b8a:	bd70      	pop	{r4, r5, r6, pc}
c0d02b8c:	20000af8 	.word	0x20000af8

c0d02b90 <USBD_LL_Init>:
  */
USBD_StatusTypeDef  USBD_LL_Init (USBD_HandleTypeDef *pdev)
{ 
  UNUSED(pdev);
  ep_in_stall = 0;
  ep_out_stall = 0;
c0d02b90:	4902      	ldr	r1, [pc, #8]	; (c0d02b9c <USBD_LL_Init+0xc>)
c0d02b92:	2000      	movs	r0, #0
c0d02b94:	6008      	str	r0, [r1, #0]
  ep_in_stall = 0;
c0d02b96:	4902      	ldr	r1, [pc, #8]	; (c0d02ba0 <USBD_LL_Init+0x10>)
c0d02b98:	6008      	str	r0, [r1, #0]
  return USBD_OK;
c0d02b9a:	4770      	bx	lr
c0d02b9c:	20000cb4 	.word	0x20000cb4
c0d02ba0:	20000cb0 	.word	0x20000cb0

c0d02ba4 <USBD_LL_DeInit>:
  * @brief  De-Initializes the Low Level portion of the Device driver.
  * @param  pdev: Device handle
  * @retval USBD Status
  */
USBD_StatusTypeDef  USBD_LL_DeInit (USBD_HandleTypeDef *pdev)
{
c0d02ba4:	b510      	push	{r4, lr}
  UNUSED(pdev);
  // usb off
  G_io_seproxyhal_spi_buffer[0] = SEPROXYHAL_TAG_USB_CONFIG;
c0d02ba6:	4807      	ldr	r0, [pc, #28]	; (c0d02bc4 <USBD_LL_DeInit+0x20>)
c0d02ba8:	2102      	movs	r1, #2
  G_io_seproxyhal_spi_buffer[1] = 0;
  G_io_seproxyhal_spi_buffer[2] = 1;
  G_io_seproxyhal_spi_buffer[3] = SEPROXYHAL_TAG_USB_CONFIG_DISCONNECT;
c0d02baa:	70c1      	strb	r1, [r0, #3]
c0d02bac:	2101      	movs	r1, #1
  G_io_seproxyhal_spi_buffer[2] = 1;
c0d02bae:	7081      	strb	r1, [r0, #2]
c0d02bb0:	2400      	movs	r4, #0
  G_io_seproxyhal_spi_buffer[1] = 0;
c0d02bb2:	7044      	strb	r4, [r0, #1]
c0d02bb4:	214f      	movs	r1, #79	; 0x4f
  G_io_seproxyhal_spi_buffer[0] = SEPROXYHAL_TAG_USB_CONFIG;
c0d02bb6:	7001      	strb	r1, [r0, #0]
c0d02bb8:	2104      	movs	r1, #4
  io_seproxyhal_spi_send(G_io_seproxyhal_spi_buffer, 4);
c0d02bba:	f7ff fe83 	bl	c0d028c4 <io_seph_send>

  return USBD_OK; 
c0d02bbe:	4620      	mov	r0, r4
c0d02bc0:	bd10      	pop	{r4, pc}
c0d02bc2:	46c0      	nop			; (mov r8, r8)
c0d02bc4:	200008ac 	.word	0x200008ac

c0d02bc8 <USBD_LL_Start>:
  * @brief  Starts the Low Level portion of the Device driver. 
  * @param  pdev: Device handle
  * @retval USBD Status
  */
USBD_StatusTypeDef  USBD_LL_Start(USBD_HandleTypeDef *pdev)
{
c0d02bc8:	b570      	push	{r4, r5, r6, lr}
c0d02bca:	b082      	sub	sp, #8
c0d02bcc:	466d      	mov	r5, sp
c0d02bce:	2400      	movs	r4, #0
  // reset address
  buffer[0] = SEPROXYHAL_TAG_USB_CONFIG;
  buffer[1] = 0;
  buffer[2] = 2;
  buffer[3] = SEPROXYHAL_TAG_USB_CONFIG_ADDR;
  buffer[4] = 0;
c0d02bd0:	712c      	strb	r4, [r5, #4]
c0d02bd2:	2003      	movs	r0, #3
  buffer[3] = SEPROXYHAL_TAG_USB_CONFIG_ADDR;
c0d02bd4:	70e8      	strb	r0, [r5, #3]
c0d02bd6:	2002      	movs	r0, #2
  buffer[2] = 2;
c0d02bd8:	70a8      	strb	r0, [r5, #2]
  buffer[1] = 0;
c0d02bda:	706c      	strb	r4, [r5, #1]
c0d02bdc:	264f      	movs	r6, #79	; 0x4f
  buffer[0] = SEPROXYHAL_TAG_USB_CONFIG;
c0d02bde:	702e      	strb	r6, [r5, #0]
c0d02be0:	2105      	movs	r1, #5
  io_seproxyhal_spi_send(buffer, 5);
c0d02be2:	4628      	mov	r0, r5
c0d02be4:	f7ff fe6e 	bl	c0d028c4 <io_seph_send>
c0d02be8:	2001      	movs	r0, #1
  
  // start usb operation
  buffer[0] = SEPROXYHAL_TAG_USB_CONFIG;
  buffer[1] = 0;
  buffer[2] = 1;
  buffer[3] = SEPROXYHAL_TAG_USB_CONFIG_CONNECT;
c0d02bea:	70e8      	strb	r0, [r5, #3]
  buffer[2] = 1;
c0d02bec:	70a8      	strb	r0, [r5, #2]
  buffer[1] = 0;
c0d02bee:	706c      	strb	r4, [r5, #1]
  buffer[0] = SEPROXYHAL_TAG_USB_CONFIG;
c0d02bf0:	702e      	strb	r6, [r5, #0]
c0d02bf2:	2104      	movs	r1, #4
  io_seproxyhal_spi_send(buffer, 4);
c0d02bf4:	4628      	mov	r0, r5
c0d02bf6:	f7ff fe65 	bl	c0d028c4 <io_seph_send>
  return USBD_OK; 
c0d02bfa:	4620      	mov	r0, r4
c0d02bfc:	b002      	add	sp, #8
c0d02bfe:	bd70      	pop	{r4, r5, r6, pc}

c0d02c00 <USBD_LL_Stop>:
  * @brief  Stops the Low Level portion of the Device driver.
  * @param  pdev: Device handle
  * @retval USBD Status
  */
USBD_StatusTypeDef  USBD_LL_Stop (USBD_HandleTypeDef *pdev)
{
c0d02c00:	b510      	push	{r4, lr}
c0d02c02:	b082      	sub	sp, #8
c0d02c04:	a801      	add	r0, sp, #4
c0d02c06:	2102      	movs	r1, #2
  UNUSED(pdev);
  uint8_t buffer[4];
  buffer[0] = SEPROXYHAL_TAG_USB_CONFIG;
  buffer[1] = 0;
  buffer[2] = 1;
  buffer[3] = SEPROXYHAL_TAG_USB_CONFIG_DISCONNECT;
c0d02c08:	70c1      	strb	r1, [r0, #3]
c0d02c0a:	2101      	movs	r1, #1
  buffer[2] = 1;
c0d02c0c:	7081      	strb	r1, [r0, #2]
c0d02c0e:	2400      	movs	r4, #0
  buffer[1] = 0;
c0d02c10:	7044      	strb	r4, [r0, #1]
c0d02c12:	214f      	movs	r1, #79	; 0x4f
  buffer[0] = SEPROXYHAL_TAG_USB_CONFIG;
c0d02c14:	7001      	strb	r1, [r0, #0]
c0d02c16:	2104      	movs	r1, #4
  io_seproxyhal_spi_send(buffer, 4);
c0d02c18:	f7ff fe54 	bl	c0d028c4 <io_seph_send>
  return USBD_OK; 
c0d02c1c:	4620      	mov	r0, r4
c0d02c1e:	b002      	add	sp, #8
c0d02c20:	bd10      	pop	{r4, pc}
	...

c0d02c24 <USBD_LL_OpenEP>:
  */
USBD_StatusTypeDef  USBD_LL_OpenEP  (USBD_HandleTypeDef *pdev, 
                                      uint8_t  ep_addr,                                      
                                      uint8_t  ep_type,
                                      uint16_t ep_mps)
{
c0d02c24:	b570      	push	{r4, r5, r6, lr}
c0d02c26:	b082      	sub	sp, #8
  uint8_t buffer[8];
  UNUSED(pdev);

  ep_in_stall = 0;
c0d02c28:	4814      	ldr	r0, [pc, #80]	; (c0d02c7c <USBD_LL_OpenEP+0x58>)
c0d02c2a:	2400      	movs	r4, #0
c0d02c2c:	6004      	str	r4, [r0, #0]
  ep_out_stall = 0;
c0d02c2e:	4814      	ldr	r0, [pc, #80]	; (c0d02c80 <USBD_LL_OpenEP+0x5c>)
c0d02c30:	6004      	str	r4, [r0, #0]
c0d02c32:	466d      	mov	r5, sp
  buffer[1] = 0;
  buffer[2] = 5;
  buffer[3] = SEPROXYHAL_TAG_USB_CONFIG_ENDPOINTS;
  buffer[4] = 1;
  buffer[5] = ep_addr;
  buffer[6] = 0;
c0d02c34:	71ac      	strb	r4, [r5, #6]
  buffer[5] = ep_addr;
c0d02c36:	7169      	strb	r1, [r5, #5]
c0d02c38:	2001      	movs	r0, #1
  buffer[4] = 1;
c0d02c3a:	7128      	strb	r0, [r5, #4]
c0d02c3c:	2104      	movs	r1, #4
  buffer[3] = SEPROXYHAL_TAG_USB_CONFIG_ENDPOINTS;
c0d02c3e:	70e9      	strb	r1, [r5, #3]
c0d02c40:	2605      	movs	r6, #5
  buffer[2] = 5;
c0d02c42:	70ae      	strb	r6, [r5, #2]
  buffer[1] = 0;
c0d02c44:	706c      	strb	r4, [r5, #1]
c0d02c46:	244f      	movs	r4, #79	; 0x4f
  buffer[0] = SEPROXYHAL_TAG_USB_CONFIG;
c0d02c48:	702c      	strb	r4, [r5, #0]
  switch(ep_type) {
c0d02c4a:	2a01      	cmp	r2, #1
c0d02c4c:	dc05      	bgt.n	c0d02c5a <USBD_LL_OpenEP+0x36>
c0d02c4e:	2a00      	cmp	r2, #0
c0d02c50:	d00a      	beq.n	c0d02c68 <USBD_LL_OpenEP+0x44>
c0d02c52:	2a01      	cmp	r2, #1
c0d02c54:	d10a      	bne.n	c0d02c6c <USBD_LL_OpenEP+0x48>
c0d02c56:	4608      	mov	r0, r1
c0d02c58:	e006      	b.n	c0d02c68 <USBD_LL_OpenEP+0x44>
c0d02c5a:	2a02      	cmp	r2, #2
c0d02c5c:	d003      	beq.n	c0d02c66 <USBD_LL_OpenEP+0x42>
c0d02c5e:	2a03      	cmp	r2, #3
c0d02c60:	d104      	bne.n	c0d02c6c <USBD_LL_OpenEP+0x48>
c0d02c62:	2002      	movs	r0, #2
c0d02c64:	e000      	b.n	c0d02c68 <USBD_LL_OpenEP+0x44>
c0d02c66:	2003      	movs	r0, #3
c0d02c68:	4669      	mov	r1, sp
c0d02c6a:	7188      	strb	r0, [r1, #6]
c0d02c6c:	4668      	mov	r0, sp
      break;
    case USBD_EP_TYPE_INTR:
      buffer[6] = SEPROXYHAL_TAG_USB_CONFIG_TYPE_INTERRUPT;
      break;
  }
  buffer[7] = ep_mps;
c0d02c6e:	71c3      	strb	r3, [r0, #7]
c0d02c70:	2108      	movs	r1, #8
  io_seproxyhal_spi_send(buffer, 8);
c0d02c72:	f7ff fe27 	bl	c0d028c4 <io_seph_send>
c0d02c76:	2000      	movs	r0, #0
  return USBD_OK; 
c0d02c78:	b002      	add	sp, #8
c0d02c7a:	bd70      	pop	{r4, r5, r6, pc}
c0d02c7c:	20000cb0 	.word	0x20000cb0
c0d02c80:	20000cb4 	.word	0x20000cb4

c0d02c84 <USBD_LL_StallEP>:
  * @param  pdev: Device handle
  * @param  ep_addr: Endpoint Number
  * @retval USBD Status
  */
USBD_StatusTypeDef  USBD_LL_StallEP (USBD_HandleTypeDef *pdev, uint8_t ep_addr)   
{ 
c0d02c84:	b5b0      	push	{r4, r5, r7, lr}
c0d02c86:	b082      	sub	sp, #8
c0d02c88:	460d      	mov	r5, r1
c0d02c8a:	4668      	mov	r0, sp
c0d02c8c:	2400      	movs	r4, #0
  buffer[0] = SEPROXYHAL_TAG_USB_EP_PREPARE;
  buffer[1] = 0;
  buffer[2] = 3;
  buffer[3] = ep_addr;
  buffer[4] = SEPROXYHAL_TAG_USB_EP_PREPARE_DIR_STALL;
  buffer[5] = 0;
c0d02c8e:	7144      	strb	r4, [r0, #5]
c0d02c90:	2140      	movs	r1, #64	; 0x40
  buffer[4] = SEPROXYHAL_TAG_USB_EP_PREPARE_DIR_STALL;
c0d02c92:	7101      	strb	r1, [r0, #4]
  buffer[3] = ep_addr;
c0d02c94:	70c5      	strb	r5, [r0, #3]
c0d02c96:	2103      	movs	r1, #3
  buffer[2] = 3;
c0d02c98:	7081      	strb	r1, [r0, #2]
  buffer[1] = 0;
c0d02c9a:	7044      	strb	r4, [r0, #1]
c0d02c9c:	2150      	movs	r1, #80	; 0x50
  buffer[0] = SEPROXYHAL_TAG_USB_EP_PREPARE;
c0d02c9e:	7001      	strb	r1, [r0, #0]
c0d02ca0:	2106      	movs	r1, #6
  io_seproxyhal_spi_send(buffer, 6);
c0d02ca2:	f7ff fe0f 	bl	c0d028c4 <io_seph_send>
  if (ep_addr & 0x80) {
c0d02ca6:	0628      	lsls	r0, r5, #24
c0d02ca8:	d501      	bpl.n	c0d02cae <USBD_LL_StallEP+0x2a>
c0d02caa:	4807      	ldr	r0, [pc, #28]	; (c0d02cc8 <USBD_LL_StallEP+0x44>)
c0d02cac:	e000      	b.n	c0d02cb0 <USBD_LL_StallEP+0x2c>
c0d02cae:	4805      	ldr	r0, [pc, #20]	; (c0d02cc4 <USBD_LL_StallEP+0x40>)
c0d02cb0:	6801      	ldr	r1, [r0, #0]
c0d02cb2:	227f      	movs	r2, #127	; 0x7f
c0d02cb4:	4015      	ands	r5, r2
c0d02cb6:	2201      	movs	r2, #1
c0d02cb8:	40aa      	lsls	r2, r5
c0d02cba:	430a      	orrs	r2, r1
c0d02cbc:	6002      	str	r2, [r0, #0]
    ep_in_stall |= (1<<(ep_addr&0x7F));
  }
  else {
    ep_out_stall |= (1<<(ep_addr&0x7F)); 
  }
  return USBD_OK; 
c0d02cbe:	4620      	mov	r0, r4
c0d02cc0:	b002      	add	sp, #8
c0d02cc2:	bdb0      	pop	{r4, r5, r7, pc}
c0d02cc4:	20000cb4 	.word	0x20000cb4
c0d02cc8:	20000cb0 	.word	0x20000cb0

c0d02ccc <USBD_LL_ClearStallEP>:
  * @param  pdev: Device handle
  * @param  ep_addr: Endpoint Number
  * @retval USBD Status
  */
USBD_StatusTypeDef  USBD_LL_ClearStallEP (USBD_HandleTypeDef *pdev, uint8_t ep_addr)   
{
c0d02ccc:	b5b0      	push	{r4, r5, r7, lr}
c0d02cce:	b082      	sub	sp, #8
c0d02cd0:	460d      	mov	r5, r1
c0d02cd2:	4668      	mov	r0, sp
c0d02cd4:	2400      	movs	r4, #0
  buffer[0] = SEPROXYHAL_TAG_USB_EP_PREPARE;
  buffer[1] = 0;
  buffer[2] = 3;
  buffer[3] = ep_addr;
  buffer[4] = SEPROXYHAL_TAG_USB_EP_PREPARE_DIR_UNSTALL;
  buffer[5] = 0;
c0d02cd6:	7144      	strb	r4, [r0, #5]
c0d02cd8:	2180      	movs	r1, #128	; 0x80
  buffer[4] = SEPROXYHAL_TAG_USB_EP_PREPARE_DIR_UNSTALL;
c0d02cda:	7101      	strb	r1, [r0, #4]
  buffer[3] = ep_addr;
c0d02cdc:	70c5      	strb	r5, [r0, #3]
c0d02cde:	2103      	movs	r1, #3
  buffer[2] = 3;
c0d02ce0:	7081      	strb	r1, [r0, #2]
  buffer[1] = 0;
c0d02ce2:	7044      	strb	r4, [r0, #1]
c0d02ce4:	2150      	movs	r1, #80	; 0x50
  buffer[0] = SEPROXYHAL_TAG_USB_EP_PREPARE;
c0d02ce6:	7001      	strb	r1, [r0, #0]
c0d02ce8:	2106      	movs	r1, #6
  io_seproxyhal_spi_send(buffer, 6);
c0d02cea:	f7ff fdeb 	bl	c0d028c4 <io_seph_send>
  if (ep_addr & 0x80) {
c0d02cee:	0628      	lsls	r0, r5, #24
c0d02cf0:	d501      	bpl.n	c0d02cf6 <USBD_LL_ClearStallEP+0x2a>
c0d02cf2:	4807      	ldr	r0, [pc, #28]	; (c0d02d10 <USBD_LL_ClearStallEP+0x44>)
c0d02cf4:	e000      	b.n	c0d02cf8 <USBD_LL_ClearStallEP+0x2c>
c0d02cf6:	4805      	ldr	r0, [pc, #20]	; (c0d02d0c <USBD_LL_ClearStallEP+0x40>)
c0d02cf8:	6801      	ldr	r1, [r0, #0]
c0d02cfa:	227f      	movs	r2, #127	; 0x7f
c0d02cfc:	4015      	ands	r5, r2
c0d02cfe:	2201      	movs	r2, #1
c0d02d00:	40aa      	lsls	r2, r5
c0d02d02:	4391      	bics	r1, r2
c0d02d04:	6001      	str	r1, [r0, #0]
    ep_in_stall &= ~(1<<(ep_addr&0x7F));
  }
  else {
    ep_out_stall &= ~(1<<(ep_addr&0x7F)); 
  }
  return USBD_OK; 
c0d02d06:	4620      	mov	r0, r4
c0d02d08:	b002      	add	sp, #8
c0d02d0a:	bdb0      	pop	{r4, r5, r7, pc}
c0d02d0c:	20000cb4 	.word	0x20000cb4
c0d02d10:	20000cb0 	.word	0x20000cb0

c0d02d14 <USBD_LL_IsStallEP>:
c0d02d14:	0608      	lsls	r0, r1, #24
c0d02d16:	d501      	bpl.n	c0d02d1c <USBD_LL_IsStallEP+0x8>
c0d02d18:	4805      	ldr	r0, [pc, #20]	; (c0d02d30 <USBD_LL_IsStallEP+0x1c>)
c0d02d1a:	e000      	b.n	c0d02d1e <USBD_LL_IsStallEP+0xa>
c0d02d1c:	4803      	ldr	r0, [pc, #12]	; (c0d02d2c <USBD_LL_IsStallEP+0x18>)
c0d02d1e:	7802      	ldrb	r2, [r0, #0]
c0d02d20:	207f      	movs	r0, #127	; 0x7f
c0d02d22:	4001      	ands	r1, r0
c0d02d24:	2001      	movs	r0, #1
c0d02d26:	4088      	lsls	r0, r1
c0d02d28:	4010      	ands	r0, r2
  }
  else
  {
    return ep_out_stall & (1<<(ep_addr&0x7F));
  }
}
c0d02d2a:	4770      	bx	lr
c0d02d2c:	20000cb4 	.word	0x20000cb4
c0d02d30:	20000cb0 	.word	0x20000cb0

c0d02d34 <USBD_LL_SetUSBAddress>:
  * @param  pdev: Device handle
  * @param  ep_addr: Endpoint Number
  * @retval USBD Status
  */
USBD_StatusTypeDef  USBD_LL_SetUSBAddress (USBD_HandleTypeDef *pdev, uint8_t dev_addr)   
{
c0d02d34:	b510      	push	{r4, lr}
c0d02d36:	b082      	sub	sp, #8
c0d02d38:	4668      	mov	r0, sp
  uint8_t buffer[5];
  buffer[0] = SEPROXYHAL_TAG_USB_CONFIG;
  buffer[1] = 0;
  buffer[2] = 2;
  buffer[3] = SEPROXYHAL_TAG_USB_CONFIG_ADDR;
  buffer[4] = dev_addr;
c0d02d3a:	7101      	strb	r1, [r0, #4]
c0d02d3c:	2103      	movs	r1, #3
  buffer[3] = SEPROXYHAL_TAG_USB_CONFIG_ADDR;
c0d02d3e:	70c1      	strb	r1, [r0, #3]
c0d02d40:	2102      	movs	r1, #2
  buffer[2] = 2;
c0d02d42:	7081      	strb	r1, [r0, #2]
c0d02d44:	2400      	movs	r4, #0
  buffer[1] = 0;
c0d02d46:	7044      	strb	r4, [r0, #1]
c0d02d48:	214f      	movs	r1, #79	; 0x4f
  buffer[0] = SEPROXYHAL_TAG_USB_CONFIG;
c0d02d4a:	7001      	strb	r1, [r0, #0]
c0d02d4c:	2105      	movs	r1, #5
  io_seproxyhal_spi_send(buffer, 5);
c0d02d4e:	f7ff fdb9 	bl	c0d028c4 <io_seph_send>
  return USBD_OK; 
c0d02d52:	4620      	mov	r0, r4
c0d02d54:	b002      	add	sp, #8
c0d02d56:	bd10      	pop	{r4, pc}

c0d02d58 <USBD_LL_Transmit>:
  */
USBD_StatusTypeDef  USBD_LL_Transmit (USBD_HandleTypeDef *pdev, 
                                      uint8_t  ep_addr,                                      
                                      uint8_t  *pbuf,
                                      uint16_t  size)
{
c0d02d58:	b5b0      	push	{r4, r5, r7, lr}
c0d02d5a:	b082      	sub	sp, #8
c0d02d5c:	461c      	mov	r4, r3
c0d02d5e:	4615      	mov	r5, r2
c0d02d60:	4668      	mov	r0, sp
  buffer[0] = SEPROXYHAL_TAG_USB_EP_PREPARE;
  buffer[1] = (3+size)>>8;
  buffer[2] = (3+size);
  buffer[3] = ep_addr;
  buffer[4] = SEPROXYHAL_TAG_USB_EP_PREPARE_DIR_IN;
  buffer[5] = size;
c0d02d62:	7143      	strb	r3, [r0, #5]
c0d02d64:	2220      	movs	r2, #32
  buffer[4] = SEPROXYHAL_TAG_USB_EP_PREPARE_DIR_IN;
c0d02d66:	7102      	strb	r2, [r0, #4]
  buffer[3] = ep_addr;
c0d02d68:	70c1      	strb	r1, [r0, #3]
c0d02d6a:	2150      	movs	r1, #80	; 0x50
  buffer[0] = SEPROXYHAL_TAG_USB_EP_PREPARE;
c0d02d6c:	7001      	strb	r1, [r0, #0]
  buffer[1] = (3+size)>>8;
c0d02d6e:	1cd9      	adds	r1, r3, #3
  buffer[2] = (3+size);
c0d02d70:	7081      	strb	r1, [r0, #2]
  buffer[1] = (3+size)>>8;
c0d02d72:	0a09      	lsrs	r1, r1, #8
c0d02d74:	7041      	strb	r1, [r0, #1]
c0d02d76:	2106      	movs	r1, #6
  io_seproxyhal_spi_send(buffer, 6);
c0d02d78:	f7ff fda4 	bl	c0d028c4 <io_seph_send>
  io_seproxyhal_spi_send(pbuf, size);
c0d02d7c:	4628      	mov	r0, r5
c0d02d7e:	4621      	mov	r1, r4
c0d02d80:	f7ff fda0 	bl	c0d028c4 <io_seph_send>
c0d02d84:	2000      	movs	r0, #0
  return USBD_OK;   
c0d02d86:	b002      	add	sp, #8
c0d02d88:	bdb0      	pop	{r4, r5, r7, pc}

c0d02d8a <USBD_LL_PrepareReceive>:
  * @retval USBD Status
  */
USBD_StatusTypeDef  USBD_LL_PrepareReceive(USBD_HandleTypeDef *pdev, 
                                           uint8_t  ep_addr,
                                           uint16_t  size)
{
c0d02d8a:	b510      	push	{r4, lr}
c0d02d8c:	b082      	sub	sp, #8
c0d02d8e:	4668      	mov	r0, sp
  buffer[0] = SEPROXYHAL_TAG_USB_EP_PREPARE;
  buffer[1] = (3/*+size*/)>>8;
  buffer[2] = (3/*+size*/);
  buffer[3] = ep_addr;
  buffer[4] = SEPROXYHAL_TAG_USB_EP_PREPARE_DIR_OUT;
  buffer[5] = size; // expected size, not transmitted here !
c0d02d90:	7142      	strb	r2, [r0, #5]
c0d02d92:	2230      	movs	r2, #48	; 0x30
  buffer[4] = SEPROXYHAL_TAG_USB_EP_PREPARE_DIR_OUT;
c0d02d94:	7102      	strb	r2, [r0, #4]
  buffer[3] = ep_addr;
c0d02d96:	70c1      	strb	r1, [r0, #3]
c0d02d98:	2103      	movs	r1, #3
  buffer[2] = (3/*+size*/);
c0d02d9a:	7081      	strb	r1, [r0, #2]
c0d02d9c:	2400      	movs	r4, #0
  buffer[1] = (3/*+size*/)>>8;
c0d02d9e:	7044      	strb	r4, [r0, #1]
c0d02da0:	2150      	movs	r1, #80	; 0x50
  buffer[0] = SEPROXYHAL_TAG_USB_EP_PREPARE;
c0d02da2:	7001      	strb	r1, [r0, #0]
c0d02da4:	2106      	movs	r1, #6
  io_seproxyhal_spi_send(buffer, 6);
c0d02da6:	f7ff fd8d 	bl	c0d028c4 <io_seph_send>
  return USBD_OK;   
c0d02daa:	4620      	mov	r0, r4
c0d02dac:	b002      	add	sp, #8
c0d02dae:	bd10      	pop	{r4, pc}

c0d02db0 <USBD_Init>:
* @param  pdesc: Descriptor structure address
* @param  id: Low level core index
* @retval None
*/
USBD_StatusTypeDef USBD_Init(USBD_HandleTypeDef *pdev, USBD_DescriptorsTypeDef *pdesc, uint8_t id)
{
c0d02db0:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d02db2:	b081      	sub	sp, #4
  /* Check whether the USB Host handle is valid */
  if(pdev == NULL)
c0d02db4:	2800      	cmp	r0, #0
c0d02db6:	d014      	beq.n	c0d02de2 <USBD_Init+0x32>
c0d02db8:	4615      	mov	r5, r2
c0d02dba:	460e      	mov	r6, r1
c0d02dbc:	4604      	mov	r4, r0
c0d02dbe:	4607      	mov	r7, r0
c0d02dc0:	37dc      	adds	r7, #220	; 0xdc
c0d02dc2:	2045      	movs	r0, #69	; 0x45
c0d02dc4:	0081      	lsls	r1, r0, #2
  {
    USBD_ErrLog("Invalid Device handle");
    return USBD_FAIL; 
  }

  memset(pdev, 0, sizeof(USBD_HandleTypeDef));
c0d02dc6:	4620      	mov	r0, r4
c0d02dc8:	f001 ff0e 	bl	c0d04be8 <__aeabi_memclr>
  
  /* Assign USBD Descriptors */
  if(pdesc != NULL)
c0d02dcc:	2e00      	cmp	r6, #0
c0d02dce:	d000      	beq.n	c0d02dd2 <USBD_Init+0x22>
  {
    pdev->pDesc = pdesc;
c0d02dd0:	617e      	str	r6, [r7, #20]
  }
  
  /* Set Device initial State */
  pdev->dev_state  = USBD_STATE_DEFAULT;
  pdev->id = id;
c0d02dd2:	7025      	strb	r5, [r4, #0]
c0d02dd4:	2001      	movs	r0, #1
  pdev->dev_state  = USBD_STATE_DEFAULT;
c0d02dd6:	7038      	strb	r0, [r7, #0]
  /* Initialize low level driver */
  USBD_LL_Init(pdev);
c0d02dd8:	4620      	mov	r0, r4
c0d02dda:	f7ff fed9 	bl	c0d02b90 <USBD_LL_Init>
c0d02dde:	2000      	movs	r0, #0
c0d02de0:	e000      	b.n	c0d02de4 <USBD_Init+0x34>
c0d02de2:	2002      	movs	r0, #2
  
  return USBD_OK; 
}
c0d02de4:	b001      	add	sp, #4
c0d02de6:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d02de8 <USBD_DeInit>:
*         Re-Initialize th device library
* @param  pdev: device instance
* @retval status: status
*/
USBD_StatusTypeDef USBD_DeInit(USBD_HandleTypeDef *pdev)
{
c0d02de8:	b5b0      	push	{r4, r5, r7, lr}
c0d02dea:	4604      	mov	r4, r0
c0d02dec:	20dc      	movs	r0, #220	; 0xdc
c0d02dee:	2101      	movs	r1, #1
  /* Set Default State */
  pdev->dev_state  = USBD_STATE_DEFAULT;
c0d02df0:	5421      	strb	r1, [r4, r0]
c0d02df2:	2017      	movs	r0, #23
c0d02df4:	43c5      	mvns	r5, r0
  
  /* Free Class Resources */
  uint8_t intf;
  for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
    if(pdev->interfacesClass[intf].pClass != NULL) {
c0d02df6:	1960      	adds	r0, r4, r5
c0d02df8:	2143      	movs	r1, #67	; 0x43
c0d02dfa:	0089      	lsls	r1, r1, #2
c0d02dfc:	5840      	ldr	r0, [r0, r1]
c0d02dfe:	2800      	cmp	r0, #0
c0d02e00:	d006      	beq.n	c0d02e10 <USBD_DeInit+0x28>
      ((DeInit_t)PIC(pdev->interfacesClass[intf].pClass->DeInit))(pdev, pdev->dev_config);  
c0d02e02:	6840      	ldr	r0, [r0, #4]
c0d02e04:	f7ff f89a 	bl	c0d01f3c <pic>
c0d02e08:	4602      	mov	r2, r0
c0d02e0a:	7921      	ldrb	r1, [r4, #4]
c0d02e0c:	4620      	mov	r0, r4
c0d02e0e:	4790      	blx	r2
  for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
c0d02e10:	3508      	adds	r5, #8
c0d02e12:	d1f0      	bne.n	c0d02df6 <USBD_DeInit+0xe>
    }
  }
  
    /* Stop the low level driver  */
  USBD_LL_Stop(pdev); 
c0d02e14:	4620      	mov	r0, r4
c0d02e16:	f7ff fef3 	bl	c0d02c00 <USBD_LL_Stop>
  
  /* Initialize low level driver */
  USBD_LL_DeInit(pdev);
c0d02e1a:	4620      	mov	r0, r4
c0d02e1c:	f7ff fec2 	bl	c0d02ba4 <USBD_LL_DeInit>
c0d02e20:	2000      	movs	r0, #0
  
  return USBD_OK;
c0d02e22:	bdb0      	pop	{r4, r5, r7, pc}

c0d02e24 <USBD_RegisterClassForInterface>:
  * @retval USBD Status
  */
USBD_StatusTypeDef USBD_RegisterClassForInterface(uint8_t interfaceidx, USBD_HandleTypeDef *pdev, USBD_ClassTypeDef *pclass)
{
  USBD_StatusTypeDef   status = USBD_OK;
  if(pclass != 0)
c0d02e24:	2a00      	cmp	r2, #0
c0d02e26:	d008      	beq.n	c0d02e3a <USBD_RegisterClassForInterface+0x16>
c0d02e28:	4603      	mov	r3, r0
c0d02e2a:	2000      	movs	r0, #0
  {
    if (interfaceidx < USBD_MAX_NUM_INTERFACES) {
c0d02e2c:	2b02      	cmp	r3, #2
c0d02e2e:	d803      	bhi.n	c0d02e38 <USBD_RegisterClassForInterface+0x14>
      /* link the class to the USB Device handle */
      pdev->interfacesClass[interfaceidx].pClass = pclass;
c0d02e30:	00db      	lsls	r3, r3, #3
c0d02e32:	18c9      	adds	r1, r1, r3
c0d02e34:	23f4      	movs	r3, #244	; 0xf4
c0d02e36:	50ca      	str	r2, [r1, r3]
  {
    USBD_ErrLog("Invalid Class handle");
    status = USBD_FAIL; 
  }
  
  return status;
c0d02e38:	4770      	bx	lr
c0d02e3a:	2002      	movs	r0, #2
c0d02e3c:	4770      	bx	lr

c0d02e3e <USBD_Start>:
  *         Start the USB Device Core.
  * @param  pdev: Device Handle
  * @retval USBD Status
  */
USBD_StatusTypeDef  USBD_Start  (USBD_HandleTypeDef *pdev)
{
c0d02e3e:	b580      	push	{r7, lr}
  
  /* Start the low level driver  */
  USBD_LL_Start(pdev); 
c0d02e40:	f7ff fec2 	bl	c0d02bc8 <USBD_LL_Start>
c0d02e44:	2000      	movs	r0, #0
  
  return USBD_OK;  
c0d02e46:	bd80      	pop	{r7, pc}

c0d02e48 <USBD_SetClassConfig>:
* @param  cfgidx: configuration index
* @retval status
*/

USBD_StatusTypeDef USBD_SetClassConfig(USBD_HandleTypeDef  *pdev, uint8_t cfgidx)
{
c0d02e48:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d02e4a:	b081      	sub	sp, #4
c0d02e4c:	460c      	mov	r4, r1
c0d02e4e:	4605      	mov	r5, r0
c0d02e50:	2600      	movs	r6, #0
c0d02e52:	27f4      	movs	r7, #244	; 0xf4
  /* Set configuration  and Start the Class*/
  uint8_t intf;
  for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
    if(usbd_is_valid_intf(pdev, intf)) {
c0d02e54:	4628      	mov	r0, r5
c0d02e56:	4631      	mov	r1, r6
c0d02e58:	f000 f95f 	bl	c0d0311a <usbd_is_valid_intf>
c0d02e5c:	2800      	cmp	r0, #0
c0d02e5e:	d007      	beq.n	c0d02e70 <USBD_SetClassConfig+0x28>
      ((Init_t)PIC(pdev->interfacesClass[intf].pClass->Init))(pdev, cfgidx);
c0d02e60:	59e8      	ldr	r0, [r5, r7]
c0d02e62:	6800      	ldr	r0, [r0, #0]
c0d02e64:	f7ff f86a 	bl	c0d01f3c <pic>
c0d02e68:	4602      	mov	r2, r0
c0d02e6a:	4628      	mov	r0, r5
c0d02e6c:	4621      	mov	r1, r4
c0d02e6e:	4790      	blx	r2
  for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
c0d02e70:	3708      	adds	r7, #8
c0d02e72:	1c76      	adds	r6, r6, #1
c0d02e74:	2e03      	cmp	r6, #3
c0d02e76:	d1ed      	bne.n	c0d02e54 <USBD_SetClassConfig+0xc>
c0d02e78:	2000      	movs	r0, #0
    }
  }

  return USBD_OK; 
c0d02e7a:	b001      	add	sp, #4
c0d02e7c:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d02e7e <USBD_ClrClassConfig>:
* @param  pdev: device instance
* @param  cfgidx: configuration index
* @retval status: USBD_StatusTypeDef
*/
USBD_StatusTypeDef USBD_ClrClassConfig(USBD_HandleTypeDef  *pdev, uint8_t cfgidx)
{
c0d02e7e:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d02e80:	b081      	sub	sp, #4
c0d02e82:	460c      	mov	r4, r1
c0d02e84:	4605      	mov	r5, r0
c0d02e86:	2600      	movs	r6, #0
c0d02e88:	27f4      	movs	r7, #244	; 0xf4
  /* Clear configuration  and De-initialize the Class process*/
  uint8_t intf;
  for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
    if(usbd_is_valid_intf(pdev, intf)) {
c0d02e8a:	4628      	mov	r0, r5
c0d02e8c:	4631      	mov	r1, r6
c0d02e8e:	f000 f944 	bl	c0d0311a <usbd_is_valid_intf>
c0d02e92:	2800      	cmp	r0, #0
c0d02e94:	d007      	beq.n	c0d02ea6 <USBD_ClrClassConfig+0x28>
      ((DeInit_t)PIC(pdev->interfacesClass[intf].pClass->DeInit))(pdev, cfgidx);  
c0d02e96:	59e8      	ldr	r0, [r5, r7]
c0d02e98:	6840      	ldr	r0, [r0, #4]
c0d02e9a:	f7ff f84f 	bl	c0d01f3c <pic>
c0d02e9e:	4602      	mov	r2, r0
c0d02ea0:	4628      	mov	r0, r5
c0d02ea2:	4621      	mov	r1, r4
c0d02ea4:	4790      	blx	r2
  for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
c0d02ea6:	3708      	adds	r7, #8
c0d02ea8:	1c76      	adds	r6, r6, #1
c0d02eaa:	2e03      	cmp	r6, #3
c0d02eac:	d1ed      	bne.n	c0d02e8a <USBD_ClrClassConfig+0xc>
c0d02eae:	2000      	movs	r0, #0
    }
  }
  return USBD_OK;
c0d02eb0:	b001      	add	sp, #4
c0d02eb2:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d02eb4 <USBD_LL_SetupStage>:
*         Handle the setup stage
* @param  pdev: device instance
* @retval status
*/
USBD_StatusTypeDef USBD_LL_SetupStage(USBD_HandleTypeDef *pdev, uint8_t *psetup)
{
c0d02eb4:	b570      	push	{r4, r5, r6, lr}
c0d02eb6:	4604      	mov	r4, r0
c0d02eb8:	4606      	mov	r6, r0
c0d02eba:	36d4      	adds	r6, #212	; 0xd4
  USBD_ParseSetupRequest(&pdev->request, psetup);
c0d02ebc:	4635      	mov	r5, r6
c0d02ebe:	3514      	adds	r5, #20
c0d02ec0:	4628      	mov	r0, r5
c0d02ec2:	f000 fb61 	bl	c0d03588 <USBD_ParseSetupRequest>
c0d02ec6:	20d4      	movs	r0, #212	; 0xd4
c0d02ec8:	2101      	movs	r1, #1
  
  pdev->ep0_state = USBD_EP0_SETUP;
c0d02eca:	5021      	str	r1, [r4, r0]
c0d02ecc:	20ee      	movs	r0, #238	; 0xee
  pdev->ep0_data_len = pdev->request.wLength;
c0d02ece:	5a20      	ldrh	r0, [r4, r0]
c0d02ed0:	6070      	str	r0, [r6, #4]
  
  switch (pdev->request.bmRequest & 0x1F) 
c0d02ed2:	7d31      	ldrb	r1, [r6, #20]
c0d02ed4:	201f      	movs	r0, #31
c0d02ed6:	4008      	ands	r0, r1
c0d02ed8:	2802      	cmp	r0, #2
c0d02eda:	d008      	beq.n	c0d02eee <USBD_LL_SetupStage+0x3a>
c0d02edc:	2801      	cmp	r0, #1
c0d02ede:	d00b      	beq.n	c0d02ef8 <USBD_LL_SetupStage+0x44>
c0d02ee0:	2800      	cmp	r0, #0
c0d02ee2:	d10e      	bne.n	c0d02f02 <USBD_LL_SetupStage+0x4e>
  {
  case USB_REQ_RECIPIENT_DEVICE:   
    USBD_StdDevReq (pdev, &pdev->request);
c0d02ee4:	4620      	mov	r0, r4
c0d02ee6:	4629      	mov	r1, r5
c0d02ee8:	f000 f922 	bl	c0d03130 <USBD_StdDevReq>
c0d02eec:	e00e      	b.n	c0d02f0c <USBD_LL_SetupStage+0x58>
  case USB_REQ_RECIPIENT_INTERFACE:     
    USBD_StdItfReq(pdev, &pdev->request);
    break;
    
  case USB_REQ_RECIPIENT_ENDPOINT:        
    USBD_StdEPReq(pdev, &pdev->request);   
c0d02eee:	4620      	mov	r0, r4
c0d02ef0:	4629      	mov	r1, r5
c0d02ef2:	f000 fac6 	bl	c0d03482 <USBD_StdEPReq>
c0d02ef6:	e009      	b.n	c0d02f0c <USBD_LL_SetupStage+0x58>
    USBD_StdItfReq(pdev, &pdev->request);
c0d02ef8:	4620      	mov	r0, r4
c0d02efa:	4629      	mov	r1, r5
c0d02efc:	f000 fa9d 	bl	c0d0343a <USBD_StdItfReq>
c0d02f00:	e004      	b.n	c0d02f0c <USBD_LL_SetupStage+0x58>
c0d02f02:	2080      	movs	r0, #128	; 0x80
    break;
    
  default:           
    USBD_LL_StallEP(pdev , pdev->request.bmRequest & 0x80);
c0d02f04:	4001      	ands	r1, r0
c0d02f06:	4620      	mov	r0, r4
c0d02f08:	f7ff febc 	bl	c0d02c84 <USBD_LL_StallEP>
c0d02f0c:	2000      	movs	r0, #0
    break;
  }  
  return USBD_OK;  
c0d02f0e:	bd70      	pop	{r4, r5, r6, pc}

c0d02f10 <USBD_LL_DataOutStage>:
* @param  pdev: device instance
* @param  epnum: endpoint index
* @retval status
*/
USBD_StatusTypeDef USBD_LL_DataOutStage(USBD_HandleTypeDef *pdev , uint8_t epnum, uint8_t *pdata)
{
c0d02f10:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d02f12:	b083      	sub	sp, #12
c0d02f14:	9202      	str	r2, [sp, #8]
c0d02f16:	4604      	mov	r4, r0
c0d02f18:	4606      	mov	r6, r0
c0d02f1a:	36dc      	adds	r6, #220	; 0xdc
c0d02f1c:	9101      	str	r1, [sp, #4]
  USBD_EndpointTypeDef    *pep;
  
  if(epnum == 0) 
c0d02f1e:	2900      	cmp	r1, #0
c0d02f20:	d01a      	beq.n	c0d02f58 <USBD_LL_DataOutStage+0x48>
c0d02f22:	2700      	movs	r7, #0
c0d02f24:	25f4      	movs	r5, #244	; 0xf4
  }
  else {

    uint8_t intf;
    for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
      if( usbd_is_valid_intf(pdev, intf) &&  (pdev->interfacesClass[intf].pClass->DataOut != NULL)&&
c0d02f26:	4620      	mov	r0, r4
c0d02f28:	4639      	mov	r1, r7
c0d02f2a:	f000 f8f6 	bl	c0d0311a <usbd_is_valid_intf>
c0d02f2e:	2800      	cmp	r0, #0
c0d02f30:	d00d      	beq.n	c0d02f4e <USBD_LL_DataOutStage+0x3e>
c0d02f32:	5960      	ldr	r0, [r4, r5]
c0d02f34:	6980      	ldr	r0, [r0, #24]
c0d02f36:	2800      	cmp	r0, #0
c0d02f38:	d009      	beq.n	c0d02f4e <USBD_LL_DataOutStage+0x3e>
         (pdev->dev_state == USBD_STATE_CONFIGURED))
c0d02f3a:	7831      	ldrb	r1, [r6, #0]
      if( usbd_is_valid_intf(pdev, intf) &&  (pdev->interfacesClass[intf].pClass->DataOut != NULL)&&
c0d02f3c:	2903      	cmp	r1, #3
c0d02f3e:	d106      	bne.n	c0d02f4e <USBD_LL_DataOutStage+0x3e>
      {
        ((DataOut_t)PIC(pdev->interfacesClass[intf].pClass->DataOut))(pdev, epnum, pdata); 
c0d02f40:	f7fe fffc 	bl	c0d01f3c <pic>
c0d02f44:	4603      	mov	r3, r0
c0d02f46:	4620      	mov	r0, r4
c0d02f48:	9901      	ldr	r1, [sp, #4]
c0d02f4a:	9a02      	ldr	r2, [sp, #8]
c0d02f4c:	4798      	blx	r3
    for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
c0d02f4e:	3508      	adds	r5, #8
c0d02f50:	1c7f      	adds	r7, r7, #1
c0d02f52:	2f03      	cmp	r7, #3
c0d02f54:	d1e7      	bne.n	c0d02f26 <USBD_LL_DataOutStage+0x16>
c0d02f56:	e02e      	b.n	c0d02fb6 <USBD_LL_DataOutStage+0xa6>
c0d02f58:	4620      	mov	r0, r4
c0d02f5a:	3080      	adds	r0, #128	; 0x80
    if ( pdev->ep0_state == USBD_EP0_DATA_OUT)
c0d02f5c:	6d41      	ldr	r1, [r0, #84]	; 0x54
c0d02f5e:	2903      	cmp	r1, #3
c0d02f60:	d129      	bne.n	c0d02fb6 <USBD_LL_DataOutStage+0xa6>
      if(pep->rem_length > pep->maxpacket)
c0d02f62:	6800      	ldr	r0, [r0, #0]
c0d02f64:	6fe1      	ldr	r1, [r4, #124]	; 0x7c
c0d02f66:	4281      	cmp	r1, r0
c0d02f68:	d90a      	bls.n	c0d02f80 <USBD_LL_DataOutStage+0x70>
        pep->rem_length -=  pep->maxpacket;
c0d02f6a:	1a09      	subs	r1, r1, r0
c0d02f6c:	67e1      	str	r1, [r4, #124]	; 0x7c
                            MIN(pep->rem_length ,pep->maxpacket));
c0d02f6e:	4281      	cmp	r1, r0
c0d02f70:	d300      	bcc.n	c0d02f74 <USBD_LL_DataOutStage+0x64>
c0d02f72:	4601      	mov	r1, r0
        USBD_CtlContinueRx (pdev, 
c0d02f74:	b28a      	uxth	r2, r1
c0d02f76:	4620      	mov	r0, r4
c0d02f78:	9902      	ldr	r1, [sp, #8]
c0d02f7a:	f000 fd1f 	bl	c0d039bc <USBD_CtlContinueRx>
c0d02f7e:	e01a      	b.n	c0d02fb6 <USBD_LL_DataOutStage+0xa6>
c0d02f80:	2500      	movs	r5, #0
c0d02f82:	27f4      	movs	r7, #244	; 0xf4
          if(usbd_is_valid_intf(pdev, intf) &&  (pdev->interfacesClass[intf].pClass->EP0_RxReady != NULL)&&
c0d02f84:	4620      	mov	r0, r4
c0d02f86:	4629      	mov	r1, r5
c0d02f88:	f000 f8c7 	bl	c0d0311a <usbd_is_valid_intf>
c0d02f8c:	2800      	cmp	r0, #0
c0d02f8e:	d00b      	beq.n	c0d02fa8 <USBD_LL_DataOutStage+0x98>
c0d02f90:	59e0      	ldr	r0, [r4, r7]
c0d02f92:	6900      	ldr	r0, [r0, #16]
c0d02f94:	2800      	cmp	r0, #0
c0d02f96:	d007      	beq.n	c0d02fa8 <USBD_LL_DataOutStage+0x98>
             (pdev->dev_state == USBD_STATE_CONFIGURED))
c0d02f98:	7831      	ldrb	r1, [r6, #0]
          if(usbd_is_valid_intf(pdev, intf) &&  (pdev->interfacesClass[intf].pClass->EP0_RxReady != NULL)&&
c0d02f9a:	2903      	cmp	r1, #3
c0d02f9c:	d104      	bne.n	c0d02fa8 <USBD_LL_DataOutStage+0x98>
            ((EP0_RxReady_t)PIC(pdev->interfacesClass[intf].pClass->EP0_RxReady))(pdev); 
c0d02f9e:	f7fe ffcd 	bl	c0d01f3c <pic>
c0d02fa2:	4601      	mov	r1, r0
c0d02fa4:	4620      	mov	r0, r4
c0d02fa6:	4788      	blx	r1
        for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
c0d02fa8:	3708      	adds	r7, #8
c0d02faa:	1c6d      	adds	r5, r5, #1
c0d02fac:	2d03      	cmp	r5, #3
c0d02fae:	d1e9      	bne.n	c0d02f84 <USBD_LL_DataOutStage+0x74>
        USBD_CtlSendStatus(pdev);
c0d02fb0:	4620      	mov	r0, r4
c0d02fb2:	f000 fd0a 	bl	c0d039ca <USBD_CtlSendStatus>
c0d02fb6:	2000      	movs	r0, #0
      }
    }
  }  
  return USBD_OK;
c0d02fb8:	b003      	add	sp, #12
c0d02fba:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d02fbc <USBD_LL_DataInStage>:
* @param  pdev: device instance
* @param  epnum: endpoint index
* @retval status
*/
USBD_StatusTypeDef USBD_LL_DataInStage(USBD_HandleTypeDef *pdev ,uint8_t epnum, uint8_t *pdata)
{
c0d02fbc:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d02fbe:	b081      	sub	sp, #4
c0d02fc0:	4604      	mov	r4, r0
c0d02fc2:	4607      	mov	r7, r0
c0d02fc4:	37d4      	adds	r7, #212	; 0xd4
c0d02fc6:	9100      	str	r1, [sp, #0]
  USBD_EndpointTypeDef    *pep;
  UNUSED(pdata);
    
  if(epnum == 0) 
c0d02fc8:	2900      	cmp	r1, #0
c0d02fca:	d01a      	beq.n	c0d03002 <USBD_LL_DataInStage+0x46>
c0d02fcc:	463d      	mov	r5, r7
c0d02fce:	2600      	movs	r6, #0
c0d02fd0:	27f4      	movs	r7, #244	; 0xf4
    }
  }
  else {
    uint8_t intf;
    for (intf = 0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
      if( usbd_is_valid_intf(pdev, intf) && (pdev->interfacesClass[intf].pClass->DataIn != NULL)&&
c0d02fd2:	4620      	mov	r0, r4
c0d02fd4:	4631      	mov	r1, r6
c0d02fd6:	f000 f8a0 	bl	c0d0311a <usbd_is_valid_intf>
c0d02fda:	2800      	cmp	r0, #0
c0d02fdc:	d00c      	beq.n	c0d02ff8 <USBD_LL_DataInStage+0x3c>
c0d02fde:	59e0      	ldr	r0, [r4, r7]
c0d02fe0:	6940      	ldr	r0, [r0, #20]
c0d02fe2:	2800      	cmp	r0, #0
c0d02fe4:	d008      	beq.n	c0d02ff8 <USBD_LL_DataInStage+0x3c>
         (pdev->dev_state == USBD_STATE_CONFIGURED))
c0d02fe6:	7a29      	ldrb	r1, [r5, #8]
      if( usbd_is_valid_intf(pdev, intf) && (pdev->interfacesClass[intf].pClass->DataIn != NULL)&&
c0d02fe8:	2903      	cmp	r1, #3
c0d02fea:	d105      	bne.n	c0d02ff8 <USBD_LL_DataInStage+0x3c>
      {
        ((DataIn_t)PIC(pdev->interfacesClass[intf].pClass->DataIn))(pdev, epnum); 
c0d02fec:	f7fe ffa6 	bl	c0d01f3c <pic>
c0d02ff0:	4602      	mov	r2, r0
c0d02ff2:	4620      	mov	r0, r4
c0d02ff4:	9900      	ldr	r1, [sp, #0]
c0d02ff6:	4790      	blx	r2
    for (intf = 0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
c0d02ff8:	3708      	adds	r7, #8
c0d02ffa:	1c76      	adds	r6, r6, #1
c0d02ffc:	2e03      	cmp	r6, #3
c0d02ffe:	d1e8      	bne.n	c0d02fd2 <USBD_LL_DataInStage+0x16>
c0d03000:	e045      	b.n	c0d0308e <USBD_LL_DataInStage+0xd2>
    if ( pdev->ep0_state == USBD_EP0_DATA_IN)
c0d03002:	6838      	ldr	r0, [r7, #0]
c0d03004:	2802      	cmp	r0, #2
c0d03006:	d13c      	bne.n	c0d03082 <USBD_LL_DataInStage+0xc6>
      if(pep->rem_length > pep->maxpacket)
c0d03008:	69e0      	ldr	r0, [r4, #28]
c0d0300a:	6a25      	ldr	r5, [r4, #32]
c0d0300c:	42a8      	cmp	r0, r5
c0d0300e:	d909      	bls.n	c0d03024 <USBD_LL_DataInStage+0x68>
        pep->rem_length -=  pep->maxpacket;
c0d03010:	1b40      	subs	r0, r0, r5
c0d03012:	61e0      	str	r0, [r4, #28]
        pdev->pData = (uint8_t *)pdev->pData + pep->maxpacket;
c0d03014:	6bf9      	ldr	r1, [r7, #60]	; 0x3c
c0d03016:	1949      	adds	r1, r1, r5
c0d03018:	63f9      	str	r1, [r7, #60]	; 0x3c
        USBD_CtlContinueSendData (pdev, 
c0d0301a:	b282      	uxth	r2, r0
c0d0301c:	4620      	mov	r0, r4
c0d0301e:	f000 fcbf 	bl	c0d039a0 <USBD_CtlContinueSendData>
c0d03022:	e02e      	b.n	c0d03082 <USBD_LL_DataInStage+0xc6>
        if((pep->total_length % pep->maxpacket == 0) &&
c0d03024:	69a6      	ldr	r6, [r4, #24]
c0d03026:	4630      	mov	r0, r6
c0d03028:	4629      	mov	r1, r5
c0d0302a:	f001 fcdb 	bl	c0d049e4 <__aeabi_uidivmod>
c0d0302e:	42ae      	cmp	r6, r5
c0d03030:	d30c      	bcc.n	c0d0304c <USBD_LL_DataInStage+0x90>
c0d03032:	2900      	cmp	r1, #0
c0d03034:	d10a      	bne.n	c0d0304c <USBD_LL_DataInStage+0x90>
             (pep->total_length < pdev->ep0_data_len ))
c0d03036:	6878      	ldr	r0, [r7, #4]
        if((pep->total_length % pep->maxpacket == 0) &&
c0d03038:	4286      	cmp	r6, r0
c0d0303a:	d207      	bcs.n	c0d0304c <USBD_LL_DataInStage+0x90>
c0d0303c:	2500      	movs	r5, #0
          USBD_CtlContinueSendData(pdev , NULL, 0);
c0d0303e:	4620      	mov	r0, r4
c0d03040:	4629      	mov	r1, r5
c0d03042:	462a      	mov	r2, r5
c0d03044:	f000 fcac 	bl	c0d039a0 <USBD_CtlContinueSendData>
          pdev->ep0_data_len = 0;
c0d03048:	607d      	str	r5, [r7, #4]
c0d0304a:	e01a      	b.n	c0d03082 <USBD_LL_DataInStage+0xc6>
c0d0304c:	2500      	movs	r5, #0
c0d0304e:	26f4      	movs	r6, #244	; 0xf4
            if(usbd_is_valid_intf(pdev, intf) && (pdev->interfacesClass[intf].pClass->EP0_TxSent != NULL)&&
c0d03050:	4620      	mov	r0, r4
c0d03052:	4629      	mov	r1, r5
c0d03054:	f000 f861 	bl	c0d0311a <usbd_is_valid_intf>
c0d03058:	2800      	cmp	r0, #0
c0d0305a:	d00b      	beq.n	c0d03074 <USBD_LL_DataInStage+0xb8>
c0d0305c:	59a0      	ldr	r0, [r4, r6]
c0d0305e:	68c0      	ldr	r0, [r0, #12]
c0d03060:	2800      	cmp	r0, #0
c0d03062:	d007      	beq.n	c0d03074 <USBD_LL_DataInStage+0xb8>
               (pdev->dev_state == USBD_STATE_CONFIGURED))
c0d03064:	7a39      	ldrb	r1, [r7, #8]
            if(usbd_is_valid_intf(pdev, intf) && (pdev->interfacesClass[intf].pClass->EP0_TxSent != NULL)&&
c0d03066:	2903      	cmp	r1, #3
c0d03068:	d104      	bne.n	c0d03074 <USBD_LL_DataInStage+0xb8>
              ((EP0_RxReady_t)PIC(pdev->interfacesClass[intf].pClass->EP0_TxSent))(pdev); 
c0d0306a:	f7fe ff67 	bl	c0d01f3c <pic>
c0d0306e:	4601      	mov	r1, r0
c0d03070:	4620      	mov	r0, r4
c0d03072:	4788      	blx	r1
          for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
c0d03074:	3608      	adds	r6, #8
c0d03076:	1c6d      	adds	r5, r5, #1
c0d03078:	2d03      	cmp	r5, #3
c0d0307a:	d1e9      	bne.n	c0d03050 <USBD_LL_DataInStage+0x94>
          USBD_CtlReceiveStatus(pdev);
c0d0307c:	4620      	mov	r0, r4
c0d0307e:	f000 fcb0 	bl	c0d039e2 <USBD_CtlReceiveStatus>
    if (pdev->dev_test_mode == 1)
c0d03082:	7b38      	ldrb	r0, [r7, #12]
c0d03084:	2801      	cmp	r0, #1
c0d03086:	d102      	bne.n	c0d0308e <USBD_LL_DataInStage+0xd2>
c0d03088:	4639      	mov	r1, r7
c0d0308a:	2000      	movs	r0, #0
      pdev->dev_test_mode = 0;
c0d0308c:	7338      	strb	r0, [r7, #12]
c0d0308e:	2000      	movs	r0, #0
      }
    }
  }
  return USBD_OK;
c0d03090:	b001      	add	sp, #4
c0d03092:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d03094 <USBD_LL_Reset>:
* @param  pdev: device instance
* @retval status
*/

USBD_StatusTypeDef USBD_LL_Reset(USBD_HandleTypeDef  *pdev)
{
c0d03094:	b570      	push	{r4, r5, r6, lr}
c0d03096:	4604      	mov	r4, r0
c0d03098:	20dc      	movs	r0, #220	; 0xdc
c0d0309a:	2101      	movs	r1, #1
  pdev->ep_out[0].maxpacket = USB_MAX_EP0_SIZE;
  

  pdev->ep_in[0].maxpacket = USB_MAX_EP0_SIZE;
  /* Upon Reset call user call back */
  pdev->dev_state = USBD_STATE_DEFAULT;
c0d0309c:	5421      	strb	r1, [r4, r0]
c0d0309e:	2080      	movs	r0, #128	; 0x80
c0d030a0:	2140      	movs	r1, #64	; 0x40
  pdev->ep_out[0].maxpacket = USB_MAX_EP0_SIZE;
c0d030a2:	5021      	str	r1, [r4, r0]
  pdev->ep_in[0].maxpacket = USB_MAX_EP0_SIZE;
c0d030a4:	6221      	str	r1, [r4, #32]
c0d030a6:	2500      	movs	r5, #0
c0d030a8:	26f4      	movs	r6, #244	; 0xf4
 
  uint8_t intf;
  for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
    if( usbd_is_valid_intf(pdev, intf))
c0d030aa:	4620      	mov	r0, r4
c0d030ac:	4629      	mov	r1, r5
c0d030ae:	f000 f834 	bl	c0d0311a <usbd_is_valid_intf>
c0d030b2:	2800      	cmp	r0, #0
c0d030b4:	d007      	beq.n	c0d030c6 <USBD_LL_Reset+0x32>
    {
      ((DeInit_t)PIC(pdev->interfacesClass[intf].pClass->DeInit))(pdev, pdev->dev_config); 
c0d030b6:	59a0      	ldr	r0, [r4, r6]
c0d030b8:	6840      	ldr	r0, [r0, #4]
c0d030ba:	f7fe ff3f 	bl	c0d01f3c <pic>
c0d030be:	4602      	mov	r2, r0
c0d030c0:	7921      	ldrb	r1, [r4, #4]
c0d030c2:	4620      	mov	r0, r4
c0d030c4:	4790      	blx	r2
  for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
c0d030c6:	3608      	adds	r6, #8
c0d030c8:	1c6d      	adds	r5, r5, #1
c0d030ca:	2d03      	cmp	r5, #3
c0d030cc:	d1ed      	bne.n	c0d030aa <USBD_LL_Reset+0x16>
c0d030ce:	2000      	movs	r0, #0
    }
  }
  
  return USBD_OK;
c0d030d0:	bd70      	pop	{r4, r5, r6, pc}

c0d030d2 <USBD_LL_SetSpeed>:
* @param  pdev: device instance
* @retval status
*/
USBD_StatusTypeDef USBD_LL_SetSpeed(USBD_HandleTypeDef  *pdev, USBD_SpeedTypeDef speed)
{
  pdev->dev_speed = speed;
c0d030d2:	7401      	strb	r1, [r0, #16]
c0d030d4:	2000      	movs	r0, #0
  return USBD_OK;
c0d030d6:	4770      	bx	lr

c0d030d8 <USBD_LL_Suspend>:
* @param  pdev: device instance
* @retval status
*/

USBD_StatusTypeDef USBD_LL_Suspend(USBD_HandleTypeDef  *pdev)
{
c0d030d8:	2000      	movs	r0, #0
  UNUSED(pdev);
  // Ignored, gently
  //pdev->dev_old_state =  pdev->dev_state;
  //pdev->dev_state  = USBD_STATE_SUSPENDED;
  return USBD_OK;
c0d030da:	4770      	bx	lr

c0d030dc <USBD_LL_Resume>:
* @param  pdev: device instance
* @retval status
*/

USBD_StatusTypeDef USBD_LL_Resume(USBD_HandleTypeDef  *pdev)
{
c0d030dc:	2000      	movs	r0, #0
  UNUSED(pdev);
  // Ignored, gently
  //pdev->dev_state = pdev->dev_old_state;  
  return USBD_OK;
c0d030de:	4770      	bx	lr

c0d030e0 <USBD_LL_SOF>:
* @param  pdev: device instance
* @retval status
*/

USBD_StatusTypeDef USBD_LL_SOF(USBD_HandleTypeDef  *pdev)
{
c0d030e0:	b570      	push	{r4, r5, r6, lr}
c0d030e2:	4604      	mov	r4, r0
c0d030e4:	20dc      	movs	r0, #220	; 0xdc
  if(pdev->dev_state == USBD_STATE_CONFIGURED)
c0d030e6:	5c20      	ldrb	r0, [r4, r0]
c0d030e8:	2803      	cmp	r0, #3
c0d030ea:	d114      	bne.n	c0d03116 <USBD_LL_SOF+0x36>
c0d030ec:	2500      	movs	r5, #0
c0d030ee:	26f4      	movs	r6, #244	; 0xf4
  {
    uint8_t intf;
    for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
      if( usbd_is_valid_intf(pdev, intf) && pdev->interfacesClass[intf].pClass->SOF != NULL)
c0d030f0:	4620      	mov	r0, r4
c0d030f2:	4629      	mov	r1, r5
c0d030f4:	f000 f811 	bl	c0d0311a <usbd_is_valid_intf>
c0d030f8:	2800      	cmp	r0, #0
c0d030fa:	d008      	beq.n	c0d0310e <USBD_LL_SOF+0x2e>
c0d030fc:	59a0      	ldr	r0, [r4, r6]
c0d030fe:	69c0      	ldr	r0, [r0, #28]
c0d03100:	2800      	cmp	r0, #0
c0d03102:	d004      	beq.n	c0d0310e <USBD_LL_SOF+0x2e>
      {
        ((SOF_t)PIC(pdev->interfacesClass[intf].pClass->SOF))(pdev); 
c0d03104:	f7fe ff1a 	bl	c0d01f3c <pic>
c0d03108:	4601      	mov	r1, r0
c0d0310a:	4620      	mov	r0, r4
c0d0310c:	4788      	blx	r1
    for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
c0d0310e:	3608      	adds	r6, #8
c0d03110:	1c6d      	adds	r5, r5, #1
c0d03112:	2d03      	cmp	r5, #3
c0d03114:	d1ec      	bne.n	c0d030f0 <USBD_LL_SOF+0x10>
c0d03116:	2000      	movs	r0, #0
      }
    }
  }
  return USBD_OK;
c0d03118:	bd70      	pop	{r4, r5, r6, pc}

c0d0311a <usbd_is_valid_intf>:
/** @defgroup USBD_REQ_Private_Functions
  * @{
  */ 

unsigned int usbd_is_valid_intf(USBD_HandleTypeDef *pdev , unsigned int intf) {
  return intf < USBD_MAX_NUM_INTERFACES && pdev->interfacesClass[intf].pClass != NULL;
c0d0311a:	2902      	cmp	r1, #2
c0d0311c:	d806      	bhi.n	c0d0312c <usbd_is_valid_intf+0x12>
c0d0311e:	00c9      	lsls	r1, r1, #3
c0d03120:	1840      	adds	r0, r0, r1
c0d03122:	21f4      	movs	r1, #244	; 0xf4
c0d03124:	5840      	ldr	r0, [r0, r1]
c0d03126:	1e41      	subs	r1, r0, #1
c0d03128:	4188      	sbcs	r0, r1
c0d0312a:	4770      	bx	lr
c0d0312c:	2000      	movs	r0, #0
c0d0312e:	4770      	bx	lr

c0d03130 <USBD_StdDevReq>:
* @param  pdev: device instance
* @param  req: usb request
* @retval status
*/
USBD_StatusTypeDef  USBD_StdDevReq (USBD_HandleTypeDef *pdev , USBD_SetupReqTypedef  *req)
{
c0d03130:	b580      	push	{r7, lr}
  USBD_StatusTypeDef ret = USBD_OK;  
  
  switch (req->bRequest) 
c0d03132:	784a      	ldrb	r2, [r1, #1]
c0d03134:	2a04      	cmp	r2, #4
c0d03136:	dd08      	ble.n	c0d0314a <USBD_StdDevReq+0x1a>
c0d03138:	2a07      	cmp	r2, #7
c0d0313a:	dc0f      	bgt.n	c0d0315c <USBD_StdDevReq+0x2c>
c0d0313c:	2a05      	cmp	r2, #5
c0d0313e:	d014      	beq.n	c0d0316a <USBD_StdDevReq+0x3a>
c0d03140:	2a06      	cmp	r2, #6
c0d03142:	d11b      	bne.n	c0d0317c <USBD_StdDevReq+0x4c>
  {
  case USB_REQ_GET_DESCRIPTOR: 
    
    USBD_GetDescriptor (pdev, req) ;
c0d03144:	f000 f821 	bl	c0d0318a <USBD_GetDescriptor>
c0d03148:	e01d      	b.n	c0d03186 <USBD_StdDevReq+0x56>
  switch (req->bRequest) 
c0d0314a:	2a00      	cmp	r2, #0
c0d0314c:	d010      	beq.n	c0d03170 <USBD_StdDevReq+0x40>
c0d0314e:	2a01      	cmp	r2, #1
c0d03150:	d017      	beq.n	c0d03182 <USBD_StdDevReq+0x52>
c0d03152:	2a03      	cmp	r2, #3
c0d03154:	d112      	bne.n	c0d0317c <USBD_StdDevReq+0x4c>
    USBD_GetStatus (pdev , req);
    break;
    
    
  case USB_REQ_SET_FEATURE:   
    USBD_SetFeature (pdev , req);    
c0d03156:	f000 f92a 	bl	c0d033ae <USBD_SetFeature>
c0d0315a:	e014      	b.n	c0d03186 <USBD_StdDevReq+0x56>
  switch (req->bRequest) 
c0d0315c:	2a08      	cmp	r2, #8
c0d0315e:	d00a      	beq.n	c0d03176 <USBD_StdDevReq+0x46>
c0d03160:	2a09      	cmp	r2, #9
c0d03162:	d10b      	bne.n	c0d0317c <USBD_StdDevReq+0x4c>
    USBD_SetConfig (pdev , req);
c0d03164:	f000 f8b1 	bl	c0d032ca <USBD_SetConfig>
c0d03168:	e00d      	b.n	c0d03186 <USBD_StdDevReq+0x56>
    USBD_SetAddress(pdev, req);
c0d0316a:	f000 f88b 	bl	c0d03284 <USBD_SetAddress>
c0d0316e:	e00a      	b.n	c0d03186 <USBD_StdDevReq+0x56>
    USBD_GetStatus (pdev , req);
c0d03170:	f000 f8f9 	bl	c0d03366 <USBD_GetStatus>
c0d03174:	e007      	b.n	c0d03186 <USBD_StdDevReq+0x56>
    USBD_GetConfig (pdev , req);
c0d03176:	f000 f8df 	bl	c0d03338 <USBD_GetConfig>
c0d0317a:	e004      	b.n	c0d03186 <USBD_StdDevReq+0x56>
  case USB_REQ_CLEAR_FEATURE:                                   
    USBD_ClrFeature (pdev , req);
    break;
    
  default:  
    USBD_CtlError(pdev , req);
c0d0317c:	f000 fb6e 	bl	c0d0385c <USBD_CtlError>
c0d03180:	e001      	b.n	c0d03186 <USBD_StdDevReq+0x56>
    USBD_ClrFeature (pdev , req);
c0d03182:	f000 f931 	bl	c0d033e8 <USBD_ClrFeature>
c0d03186:	2000      	movs	r0, #0
    break;
  }
  
  return ret;
c0d03188:	bd80      	pop	{r7, pc}

c0d0318a <USBD_GetDescriptor>:
* @param  req: usb request
* @retval status
*/
void USBD_GetDescriptor(USBD_HandleTypeDef *pdev , 
                               USBD_SetupReqTypedef *req)
{
c0d0318a:	b5b0      	push	{r4, r5, r7, lr}
c0d0318c:	b082      	sub	sp, #8
c0d0318e:	460d      	mov	r5, r1
c0d03190:	4604      	mov	r4, r0
c0d03192:	a801      	add	r0, sp, #4
c0d03194:	2100      	movs	r1, #0
  uint16_t len = 0;
c0d03196:	8001      	strh	r1, [r0, #0]
c0d03198:	4620      	mov	r0, r4
c0d0319a:	30f0      	adds	r0, #240	; 0xf0
  uint8_t *pbuf = NULL;
  
    
  switch (req->wValue >> 8)
c0d0319c:	886b      	ldrh	r3, [r5, #2]
c0d0319e:	0a1a      	lsrs	r2, r3, #8
c0d031a0:	2a05      	cmp	r2, #5
c0d031a2:	dc11      	bgt.n	c0d031c8 <USBD_GetDescriptor+0x3e>
c0d031a4:	2a01      	cmp	r2, #1
c0d031a6:	d01a      	beq.n	c0d031de <USBD_GetDescriptor+0x54>
c0d031a8:	2a02      	cmp	r2, #2
c0d031aa:	d021      	beq.n	c0d031f0 <USBD_GetDescriptor+0x66>
c0d031ac:	2a03      	cmp	r2, #3
c0d031ae:	d132      	bne.n	c0d03216 <USBD_GetDescriptor+0x8c>
      }
    }
    break;
    
  case USB_DESC_TYPE_STRING:
    switch ((uint8_t)(req->wValue))
c0d031b0:	b2d9      	uxtb	r1, r3
c0d031b2:	2902      	cmp	r1, #2
c0d031b4:	dc34      	bgt.n	c0d03220 <USBD_GetDescriptor+0x96>
c0d031b6:	2900      	cmp	r1, #0
c0d031b8:	d058      	beq.n	c0d0326c <USBD_GetDescriptor+0xe2>
c0d031ba:	2901      	cmp	r1, #1
c0d031bc:	d05c      	beq.n	c0d03278 <USBD_GetDescriptor+0xee>
c0d031be:	2902      	cmp	r1, #2
c0d031c0:	d129      	bne.n	c0d03216 <USBD_GetDescriptor+0x8c>
    case USBD_IDX_MFC_STR:
      pbuf = ((GetManufacturerStrDescriptor_t)PIC(pdev->pDesc->GetManufacturerStrDescriptor))(pdev->dev_speed, &len);
      break;
      
    case USBD_IDX_PRODUCT_STR:
      pbuf = ((GetProductStrDescriptor_t)PIC(pdev->pDesc->GetProductStrDescriptor))(pdev->dev_speed, &len);
c0d031c2:	6800      	ldr	r0, [r0, #0]
c0d031c4:	68c0      	ldr	r0, [r0, #12]
c0d031c6:	e00c      	b.n	c0d031e2 <USBD_GetDescriptor+0x58>
  switch (req->wValue >> 8)
c0d031c8:	2a06      	cmp	r2, #6
c0d031ca:	d019      	beq.n	c0d03200 <USBD_GetDescriptor+0x76>
c0d031cc:	2a07      	cmp	r2, #7
c0d031ce:	d01f      	beq.n	c0d03210 <USBD_GetDescriptor+0x86>
c0d031d0:	2a0f      	cmp	r2, #15
c0d031d2:	d120      	bne.n	c0d03216 <USBD_GetDescriptor+0x8c>
    if(pdev->pDesc->GetBOSDescriptor != NULL) {
c0d031d4:	6800      	ldr	r0, [r0, #0]
c0d031d6:	69c0      	ldr	r0, [r0, #28]
c0d031d8:	2800      	cmp	r0, #0
c0d031da:	d102      	bne.n	c0d031e2 <USBD_GetDescriptor+0x58>
c0d031dc:	e01b      	b.n	c0d03216 <USBD_GetDescriptor+0x8c>
    pbuf = ((GetDeviceDescriptor_t)PIC(pdev->pDesc->GetDeviceDescriptor))(pdev->dev_speed, &len);
c0d031de:	6800      	ldr	r0, [r0, #0]
c0d031e0:	6800      	ldr	r0, [r0, #0]
c0d031e2:	f7fe feab 	bl	c0d01f3c <pic>
c0d031e6:	4602      	mov	r2, r0
c0d031e8:	7c20      	ldrb	r0, [r4, #16]
c0d031ea:	a901      	add	r1, sp, #4
c0d031ec:	4790      	blx	r2
c0d031ee:	e02b      	b.n	c0d03248 <USBD_GetDescriptor+0xbe>
    if(pdev->interfacesClass[0].pClass != NULL) {
c0d031f0:	6840      	ldr	r0, [r0, #4]
c0d031f2:	2800      	cmp	r0, #0
c0d031f4:	d029      	beq.n	c0d0324a <USBD_GetDescriptor+0xc0>
      if(pdev->dev_speed == USBD_SPEED_HIGH )   
c0d031f6:	7c21      	ldrb	r1, [r4, #16]
c0d031f8:	2900      	cmp	r1, #0
c0d031fa:	d01f      	beq.n	c0d0323c <USBD_GetDescriptor+0xb2>
        pbuf   = (uint8_t *)((GetFSConfigDescriptor_t)PIC(pdev->interfacesClass[0].pClass->GetFSConfigDescriptor))(&len);
c0d031fc:	6ac0      	ldr	r0, [r0, #44]	; 0x2c
c0d031fe:	e01e      	b.n	c0d0323e <USBD_GetDescriptor+0xb4>
#endif   
    }
    break;
  case USB_DESC_TYPE_DEVICE_QUALIFIER:                   

    if(pdev->dev_speed == USBD_SPEED_HIGH && pdev->interfacesClass[0].pClass != NULL )   
c0d03200:	7c21      	ldrb	r1, [r4, #16]
c0d03202:	2900      	cmp	r1, #0
c0d03204:	d107      	bne.n	c0d03216 <USBD_GetDescriptor+0x8c>
c0d03206:	6840      	ldr	r0, [r0, #4]
c0d03208:	2800      	cmp	r0, #0
c0d0320a:	d004      	beq.n	c0d03216 <USBD_GetDescriptor+0x8c>
    {
      pbuf   = (uint8_t *)((GetDeviceQualifierDescriptor_t)PIC(pdev->interfacesClass[0].pClass->GetDeviceQualifierDescriptor))(&len);
c0d0320c:	6b40      	ldr	r0, [r0, #52]	; 0x34
c0d0320e:	e016      	b.n	c0d0323e <USBD_GetDescriptor+0xb4>
    {
      goto default_error;
    } 

  case USB_DESC_TYPE_OTHER_SPEED_CONFIGURATION:
    if(pdev->dev_speed == USBD_SPEED_HIGH && pdev->interfacesClass[0].pClass != NULL)   
c0d03210:	7c21      	ldrb	r1, [r4, #16]
c0d03212:	2900      	cmp	r1, #0
c0d03214:	d00d      	beq.n	c0d03232 <USBD_GetDescriptor+0xa8>
      goto default_error;
    }

  default: 
  default_error:
     USBD_CtlError(pdev , req);
c0d03216:	4620      	mov	r0, r4
c0d03218:	4629      	mov	r1, r5
c0d0321a:	f000 fb1f 	bl	c0d0385c <USBD_CtlError>
c0d0321e:	e023      	b.n	c0d03268 <USBD_GetDescriptor+0xde>
    switch ((uint8_t)(req->wValue))
c0d03220:	2903      	cmp	r1, #3
c0d03222:	d026      	beq.n	c0d03272 <USBD_GetDescriptor+0xe8>
c0d03224:	2904      	cmp	r1, #4
c0d03226:	d02a      	beq.n	c0d0327e <USBD_GetDescriptor+0xf4>
c0d03228:	2905      	cmp	r1, #5
c0d0322a:	d1f4      	bne.n	c0d03216 <USBD_GetDescriptor+0x8c>
      pbuf = ((GetInterfaceStrDescriptor_t)PIC(pdev->pDesc->GetInterfaceStrDescriptor))(pdev->dev_speed, &len);
c0d0322c:	6800      	ldr	r0, [r0, #0]
c0d0322e:	6980      	ldr	r0, [r0, #24]
c0d03230:	e7d7      	b.n	c0d031e2 <USBD_GetDescriptor+0x58>
    if(pdev->dev_speed == USBD_SPEED_HIGH && pdev->interfacesClass[0].pClass != NULL)   
c0d03232:	6840      	ldr	r0, [r0, #4]
c0d03234:	2800      	cmp	r0, #0
c0d03236:	d0ee      	beq.n	c0d03216 <USBD_GetDescriptor+0x8c>
      pbuf   = (uint8_t *)((GetOtherSpeedConfigDescriptor_t)PIC(pdev->interfacesClass[0].pClass->GetOtherSpeedConfigDescriptor))(&len);
c0d03238:	6b00      	ldr	r0, [r0, #48]	; 0x30
c0d0323a:	e000      	b.n	c0d0323e <USBD_GetDescriptor+0xb4>
        pbuf   = (uint8_t *)((GetHSConfigDescriptor_t)PIC(pdev->interfacesClass[0].pClass->GetHSConfigDescriptor))(&len);
c0d0323c:	6a80      	ldr	r0, [r0, #40]	; 0x28
c0d0323e:	f7fe fe7d 	bl	c0d01f3c <pic>
c0d03242:	4601      	mov	r1, r0
c0d03244:	a801      	add	r0, sp, #4
c0d03246:	4788      	blx	r1
c0d03248:	4601      	mov	r1, r0
c0d0324a:	a801      	add	r0, sp, #4
    return;
  }
  
  if((len != 0)&& (req->wLength != 0))
c0d0324c:	8802      	ldrh	r2, [r0, #0]
c0d0324e:	2a00      	cmp	r2, #0
c0d03250:	d00a      	beq.n	c0d03268 <USBD_GetDescriptor+0xde>
c0d03252:	88e8      	ldrh	r0, [r5, #6]
c0d03254:	2800      	cmp	r0, #0
c0d03256:	d007      	beq.n	c0d03268 <USBD_GetDescriptor+0xde>
  {
    
    len = MIN(len , req->wLength);
c0d03258:	4282      	cmp	r2, r0
c0d0325a:	d300      	bcc.n	c0d0325e <USBD_GetDescriptor+0xd4>
c0d0325c:	4602      	mov	r2, r0
c0d0325e:	a801      	add	r0, sp, #4
c0d03260:	8002      	strh	r2, [r0, #0]
    
    // prepare abort if host does not read the whole data
    //USBD_CtlReceiveStatus(pdev);

    // start transfer
    USBD_CtlSendData (pdev, 
c0d03262:	4620      	mov	r0, r4
c0d03264:	f000 fb86 	bl	c0d03974 <USBD_CtlSendData>
                      pbuf,
                      len);
  }
  
}
c0d03268:	b002      	add	sp, #8
c0d0326a:	bdb0      	pop	{r4, r5, r7, pc}
     pbuf = ((GetLangIDStrDescriptor_t)PIC(pdev->pDesc->GetLangIDStrDescriptor))(pdev->dev_speed, &len);        
c0d0326c:	6800      	ldr	r0, [r0, #0]
c0d0326e:	6840      	ldr	r0, [r0, #4]
c0d03270:	e7b7      	b.n	c0d031e2 <USBD_GetDescriptor+0x58>
      pbuf = ((GetSerialStrDescriptor_t)PIC(pdev->pDesc->GetSerialStrDescriptor))(pdev->dev_speed, &len);
c0d03272:	6800      	ldr	r0, [r0, #0]
c0d03274:	6900      	ldr	r0, [r0, #16]
c0d03276:	e7b4      	b.n	c0d031e2 <USBD_GetDescriptor+0x58>
      pbuf = ((GetManufacturerStrDescriptor_t)PIC(pdev->pDesc->GetManufacturerStrDescriptor))(pdev->dev_speed, &len);
c0d03278:	6800      	ldr	r0, [r0, #0]
c0d0327a:	6880      	ldr	r0, [r0, #8]
c0d0327c:	e7b1      	b.n	c0d031e2 <USBD_GetDescriptor+0x58>
      pbuf = ((GetConfigurationStrDescriptor_t)PIC(pdev->pDesc->GetConfigurationStrDescriptor))(pdev->dev_speed, &len);
c0d0327e:	6800      	ldr	r0, [r0, #0]
c0d03280:	6940      	ldr	r0, [r0, #20]
c0d03282:	e7ae      	b.n	c0d031e2 <USBD_GetDescriptor+0x58>

c0d03284 <USBD_SetAddress>:
* @param  req: usb request
* @retval status
*/
void USBD_SetAddress(USBD_HandleTypeDef *pdev , 
                            USBD_SetupReqTypedef *req)
{
c0d03284:	b570      	push	{r4, r5, r6, lr}
c0d03286:	4604      	mov	r4, r0
  uint8_t  dev_addr; 
  
  if ((req->wIndex == 0) && (req->wLength == 0)) 
c0d03288:	8888      	ldrh	r0, [r1, #4]
c0d0328a:	2800      	cmp	r0, #0
c0d0328c:	d107      	bne.n	c0d0329e <USBD_SetAddress+0x1a>
c0d0328e:	88c8      	ldrh	r0, [r1, #6]
c0d03290:	2800      	cmp	r0, #0
c0d03292:	d104      	bne.n	c0d0329e <USBD_SetAddress+0x1a>
c0d03294:	4626      	mov	r6, r4
c0d03296:	36dc      	adds	r6, #220	; 0xdc
  {
    dev_addr = (uint8_t)(req->wValue) & 0x7F;     
    
    if (pdev->dev_state == USBD_STATE_CONFIGURED) 
c0d03298:	7830      	ldrb	r0, [r6, #0]
c0d0329a:	2803      	cmp	r0, #3
c0d0329c:	d103      	bne.n	c0d032a6 <USBD_SetAddress+0x22>
c0d0329e:	4620      	mov	r0, r4
c0d032a0:	f000 fadc 	bl	c0d0385c <USBD_CtlError>
  } 
  else 
  {
     USBD_CtlError(pdev , req);                        
  } 
}
c0d032a4:	bd70      	pop	{r4, r5, r6, pc}
c0d032a6:	7888      	ldrb	r0, [r1, #2]
c0d032a8:	257f      	movs	r5, #127	; 0x7f
c0d032aa:	4005      	ands	r5, r0
      pdev->dev_address = dev_addr;
c0d032ac:	70b5      	strb	r5, [r6, #2]
      USBD_LL_SetUSBAddress(pdev, dev_addr);               
c0d032ae:	4620      	mov	r0, r4
c0d032b0:	4629      	mov	r1, r5
c0d032b2:	f7ff fd3f 	bl	c0d02d34 <USBD_LL_SetUSBAddress>
      USBD_CtlSendStatus(pdev);                         
c0d032b6:	4620      	mov	r0, r4
c0d032b8:	f000 fb87 	bl	c0d039ca <USBD_CtlSendStatus>
      if (dev_addr != 0) 
c0d032bc:	2d00      	cmp	r5, #0
c0d032be:	d001      	beq.n	c0d032c4 <USBD_SetAddress+0x40>
c0d032c0:	2002      	movs	r0, #2
c0d032c2:	e000      	b.n	c0d032c6 <USBD_SetAddress+0x42>
c0d032c4:	2001      	movs	r0, #1
c0d032c6:	7030      	strb	r0, [r6, #0]
}
c0d032c8:	bd70      	pop	{r4, r5, r6, pc}

c0d032ca <USBD_SetConfig>:
* @param  req: usb request
* @retval status
*/
void USBD_SetConfig(USBD_HandleTypeDef *pdev , 
                           USBD_SetupReqTypedef *req)
{
c0d032ca:	b570      	push	{r4, r5, r6, lr}
c0d032cc:	460d      	mov	r5, r1
c0d032ce:	4604      	mov	r4, r0
  
  uint8_t  cfgidx;
  
  cfgidx = (uint8_t)(req->wValue);                 
c0d032d0:	788e      	ldrb	r6, [r1, #2]
  
  if (cfgidx > USBD_MAX_NUM_CONFIGURATION ) 
c0d032d2:	2e02      	cmp	r6, #2
c0d032d4:	d21c      	bcs.n	c0d03310 <USBD_SetConfig+0x46>
c0d032d6:	20dc      	movs	r0, #220	; 0xdc
  {            
     USBD_CtlError(pdev , req);                              
  } 
  else 
  {
    switch (pdev->dev_state) 
c0d032d8:	5c21      	ldrb	r1, [r4, r0]
c0d032da:	4620      	mov	r0, r4
c0d032dc:	30dc      	adds	r0, #220	; 0xdc
c0d032de:	2903      	cmp	r1, #3
c0d032e0:	d006      	beq.n	c0d032f0 <USBD_SetConfig+0x26>
c0d032e2:	2902      	cmp	r1, #2
c0d032e4:	d114      	bne.n	c0d03310 <USBD_SetConfig+0x46>
    {
    case USBD_STATE_ADDRESSED:
      if (cfgidx) 
c0d032e6:	2e00      	cmp	r6, #0
c0d032e8:	d022      	beq.n	c0d03330 <USBD_SetConfig+0x66>
c0d032ea:	2103      	movs	r1, #3
      {                                                                               
        pdev->dev_config = cfgidx;
        pdev->dev_state = USBD_STATE_CONFIGURED;
c0d032ec:	7001      	strb	r1, [r0, #0]
c0d032ee:	e008      	b.n	c0d03302 <USBD_SetConfig+0x38>
      }
      USBD_CtlSendStatus(pdev);
      break;
      
    case USBD_STATE_CONFIGURED:
      if (cfgidx == 0) 
c0d032f0:	2e00      	cmp	r6, #0
c0d032f2:	d012      	beq.n	c0d0331a <USBD_SetConfig+0x50>
        pdev->dev_state = USBD_STATE_ADDRESSED;
        pdev->dev_config = cfgidx;          
        USBD_ClrClassConfig(pdev , cfgidx);
        USBD_CtlSendStatus(pdev);
      } 
      else  if (cfgidx != pdev->dev_config) 
c0d032f4:	6860      	ldr	r0, [r4, #4]
c0d032f6:	42b0      	cmp	r0, r6
c0d032f8:	d01a      	beq.n	c0d03330 <USBD_SetConfig+0x66>
      {
        /* Clear old configuration */
        USBD_ClrClassConfig(pdev , pdev->dev_config);
c0d032fa:	b2c1      	uxtb	r1, r0
c0d032fc:	4620      	mov	r0, r4
c0d032fe:	f7ff fdbe 	bl	c0d02e7e <USBD_ClrClassConfig>
c0d03302:	6066      	str	r6, [r4, #4]
c0d03304:	4620      	mov	r0, r4
c0d03306:	4631      	mov	r1, r6
c0d03308:	f7ff fd9e 	bl	c0d02e48 <USBD_SetClassConfig>
c0d0330c:	2802      	cmp	r0, #2
c0d0330e:	d10f      	bne.n	c0d03330 <USBD_SetConfig+0x66>
c0d03310:	4620      	mov	r0, r4
c0d03312:	4629      	mov	r1, r5
c0d03314:	f000 faa2 	bl	c0d0385c <USBD_CtlError>
    default:          
       USBD_CtlError(pdev , req);                     
      break;
    }
  }
}
c0d03318:	bd70      	pop	{r4, r5, r6, pc}
c0d0331a:	2100      	movs	r1, #0
        pdev->dev_config = cfgidx;          
c0d0331c:	6061      	str	r1, [r4, #4]
c0d0331e:	2102      	movs	r1, #2
        pdev->dev_state = USBD_STATE_ADDRESSED;
c0d03320:	7001      	strb	r1, [r0, #0]
        USBD_ClrClassConfig(pdev , cfgidx);
c0d03322:	4620      	mov	r0, r4
c0d03324:	4631      	mov	r1, r6
c0d03326:	f7ff fdaa 	bl	c0d02e7e <USBD_ClrClassConfig>
        USBD_CtlSendStatus(pdev);
c0d0332a:	4620      	mov	r0, r4
c0d0332c:	f000 fb4d 	bl	c0d039ca <USBD_CtlSendStatus>
c0d03330:	4620      	mov	r0, r4
c0d03332:	f000 fb4a 	bl	c0d039ca <USBD_CtlSendStatus>
}
c0d03336:	bd70      	pop	{r4, r5, r6, pc}

c0d03338 <USBD_GetConfig>:
* @param  req: usb request
* @retval status
*/
void USBD_GetConfig(USBD_HandleTypeDef *pdev , 
                           USBD_SetupReqTypedef *req)
{
c0d03338:	b580      	push	{r7, lr}

  if (req->wLength != 1) 
c0d0333a:	88ca      	ldrh	r2, [r1, #6]
c0d0333c:	2a01      	cmp	r2, #1
c0d0333e:	d10a      	bne.n	c0d03356 <USBD_GetConfig+0x1e>
c0d03340:	22dc      	movs	r2, #220	; 0xdc
  {                   
     USBD_CtlError(pdev , req);
  }
  else 
  {
    switch (pdev->dev_state )  
c0d03342:	5c82      	ldrb	r2, [r0, r2]
c0d03344:	2a03      	cmp	r2, #3
c0d03346:	d009      	beq.n	c0d0335c <USBD_GetConfig+0x24>
c0d03348:	2a02      	cmp	r2, #2
c0d0334a:	d104      	bne.n	c0d03356 <USBD_GetConfig+0x1e>
c0d0334c:	2100      	movs	r1, #0
    {
    case USBD_STATE_ADDRESSED:                     
      pdev->dev_default_config = 0;
c0d0334e:	6081      	str	r1, [r0, #8]
c0d03350:	4601      	mov	r1, r0
c0d03352:	3108      	adds	r1, #8
c0d03354:	e003      	b.n	c0d0335e <USBD_GetConfig+0x26>
c0d03356:	f000 fa81 	bl	c0d0385c <USBD_CtlError>
    default:
       USBD_CtlError(pdev , req);
      break;
    }
  }
}
c0d0335a:	bd80      	pop	{r7, pc}
                        (uint8_t *)&pdev->dev_config,
c0d0335c:	1d01      	adds	r1, r0, #4
c0d0335e:	2201      	movs	r2, #1
c0d03360:	f000 fb08 	bl	c0d03974 <USBD_CtlSendData>
}
c0d03364:	bd80      	pop	{r7, pc}

c0d03366 <USBD_GetStatus>:
* @param  req: usb request
* @retval status
*/
void USBD_GetStatus(USBD_HandleTypeDef *pdev , 
                           USBD_SetupReqTypedef *req)
{
c0d03366:	b5b0      	push	{r4, r5, r7, lr}
c0d03368:	4604      	mov	r4, r0
c0d0336a:	20dc      	movs	r0, #220	; 0xdc
  
    
  switch (pdev->dev_state) 
c0d0336c:	5c20      	ldrb	r0, [r4, r0]
c0d0336e:	22fe      	movs	r2, #254	; 0xfe
c0d03370:	4002      	ands	r2, r0
c0d03372:	2a02      	cmp	r2, #2
c0d03374:	d10f      	bne.n	c0d03396 <USBD_GetStatus+0x30>
c0d03376:	4620      	mov	r0, r4
c0d03378:	30dc      	adds	r0, #220	; 0xdc
c0d0337a:	2101      	movs	r1, #1
  {
  case USBD_STATE_ADDRESSED:
  case USBD_STATE_CONFIGURED:
    
#if ( USBD_SELF_POWERED == 1)
    pdev->dev_config_status = USB_CONFIG_SELF_POWERED;                                  
c0d0337c:	60e1      	str	r1, [r4, #12]
c0d0337e:	4625      	mov	r5, r4
c0d03380:	350c      	adds	r5, #12
#else
    pdev->dev_config_status = 0;                                   
#endif
                      
    if (pdev->dev_remote_wakeup) USBD_CtlReceiveStatus(pdev);
c0d03382:	6880      	ldr	r0, [r0, #8]
c0d03384:	2800      	cmp	r0, #0
c0d03386:	d00a      	beq.n	c0d0339e <USBD_GetStatus+0x38>
c0d03388:	4620      	mov	r0, r4
c0d0338a:	f000 fb2a 	bl	c0d039e2 <USBD_CtlReceiveStatus>
    {
       pdev->dev_config_status |= USB_CONFIG_REMOTE_WAKEUP;                                
c0d0338e:	68e1      	ldr	r1, [r4, #12]
c0d03390:	2002      	movs	r0, #2
    if (pdev->dev_remote_wakeup) USBD_CtlReceiveStatus(pdev);
c0d03392:	4308      	orrs	r0, r1
c0d03394:	e004      	b.n	c0d033a0 <USBD_GetStatus+0x3a>
                      (uint8_t *)& pdev->dev_config_status,
                      2);
    break;
    
  default :
    USBD_CtlError(pdev , req);                        
c0d03396:	4620      	mov	r0, r4
c0d03398:	f000 fa60 	bl	c0d0385c <USBD_CtlError>
    break;
  }
}
c0d0339c:	bdb0      	pop	{r4, r5, r7, pc}
c0d0339e:	2003      	movs	r0, #3
       pdev->dev_config_status |= USB_CONFIG_REMOTE_WAKEUP;                                
c0d033a0:	60e0      	str	r0, [r4, #12]
c0d033a2:	2202      	movs	r2, #2
    USBD_CtlSendData (pdev, 
c0d033a4:	4620      	mov	r0, r4
c0d033a6:	4629      	mov	r1, r5
c0d033a8:	f000 fae4 	bl	c0d03974 <USBD_CtlSendData>
}
c0d033ac:	bdb0      	pop	{r4, r5, r7, pc}

c0d033ae <USBD_SetFeature>:
* @param  req: usb request
* @retval status
*/
void USBD_SetFeature(USBD_HandleTypeDef *pdev , 
                            USBD_SetupReqTypedef *req)
{
c0d033ae:	b5b0      	push	{r4, r5, r7, lr}
c0d033b0:	4604      	mov	r4, r0

  if (req->wValue == USB_FEATURE_REMOTE_WAKEUP)
c0d033b2:	8848      	ldrh	r0, [r1, #2]
c0d033b4:	2801      	cmp	r0, #1
c0d033b6:	d116      	bne.n	c0d033e6 <USBD_SetFeature+0x38>
c0d033b8:	460d      	mov	r5, r1
c0d033ba:	20e4      	movs	r0, #228	; 0xe4
c0d033bc:	2101      	movs	r1, #1
  {
    pdev->dev_remote_wakeup = 1;  
c0d033be:	5021      	str	r1, [r4, r0]
    if(usbd_is_valid_intf(pdev, LOBYTE(req->wIndex))) {
c0d033c0:	7928      	ldrb	r0, [r5, #4]
  return intf < USBD_MAX_NUM_INTERFACES && pdev->interfacesClass[intf].pClass != NULL;
c0d033c2:	2802      	cmp	r0, #2
c0d033c4:	d80c      	bhi.n	c0d033e0 <USBD_SetFeature+0x32>
c0d033c6:	00c0      	lsls	r0, r0, #3
c0d033c8:	1820      	adds	r0, r4, r0
c0d033ca:	21f4      	movs	r1, #244	; 0xf4
c0d033cc:	5840      	ldr	r0, [r0, r1]
    if(usbd_is_valid_intf(pdev, LOBYTE(req->wIndex))) {
c0d033ce:	2800      	cmp	r0, #0
c0d033d0:	d006      	beq.n	c0d033e0 <USBD_SetFeature+0x32>
      ((Setup_t)PIC(pdev->interfacesClass[LOBYTE(req->wIndex)].pClass->Setup)) (pdev, req);   
c0d033d2:	6880      	ldr	r0, [r0, #8]
c0d033d4:	f7fe fdb2 	bl	c0d01f3c <pic>
c0d033d8:	4602      	mov	r2, r0
c0d033da:	4620      	mov	r0, r4
c0d033dc:	4629      	mov	r1, r5
c0d033de:	4790      	blx	r2
    }
    USBD_CtlSendStatus(pdev);
c0d033e0:	4620      	mov	r0, r4
c0d033e2:	f000 faf2 	bl	c0d039ca <USBD_CtlSendStatus>
  }

}
c0d033e6:	bdb0      	pop	{r4, r5, r7, pc}

c0d033e8 <USBD_ClrFeature>:
* @param  req: usb request
* @retval status
*/
void USBD_ClrFeature(USBD_HandleTypeDef *pdev , 
                            USBD_SetupReqTypedef *req)
{
c0d033e8:	b5b0      	push	{r4, r5, r7, lr}
c0d033ea:	460d      	mov	r5, r1
c0d033ec:	4604      	mov	r4, r0
c0d033ee:	20dc      	movs	r0, #220	; 0xdc
  switch (pdev->dev_state)
c0d033f0:	5c20      	ldrb	r0, [r4, r0]
c0d033f2:	21fe      	movs	r1, #254	; 0xfe
c0d033f4:	4001      	ands	r1, r0
c0d033f6:	2902      	cmp	r1, #2
c0d033f8:	d11a      	bne.n	c0d03430 <USBD_ClrFeature+0x48>
  {
  case USBD_STATE_ADDRESSED:
  case USBD_STATE_CONFIGURED:
    if (req->wValue == USB_FEATURE_REMOTE_WAKEUP) 
c0d033fa:	8868      	ldrh	r0, [r5, #2]
c0d033fc:	2801      	cmp	r0, #1
c0d033fe:	d11b      	bne.n	c0d03438 <USBD_ClrFeature+0x50>
c0d03400:	4620      	mov	r0, r4
c0d03402:	30dc      	adds	r0, #220	; 0xdc
c0d03404:	2100      	movs	r1, #0
    {
      pdev->dev_remote_wakeup = 0; 
c0d03406:	6081      	str	r1, [r0, #8]
      if(usbd_is_valid_intf(pdev, LOBYTE(req->wIndex))) {
c0d03408:	7928      	ldrb	r0, [r5, #4]
  return intf < USBD_MAX_NUM_INTERFACES && pdev->interfacesClass[intf].pClass != NULL;
c0d0340a:	2802      	cmp	r0, #2
c0d0340c:	d80c      	bhi.n	c0d03428 <USBD_ClrFeature+0x40>
c0d0340e:	00c0      	lsls	r0, r0, #3
c0d03410:	1820      	adds	r0, r4, r0
c0d03412:	21f4      	movs	r1, #244	; 0xf4
c0d03414:	5840      	ldr	r0, [r0, r1]
      if(usbd_is_valid_intf(pdev, LOBYTE(req->wIndex))) {
c0d03416:	2800      	cmp	r0, #0
c0d03418:	d006      	beq.n	c0d03428 <USBD_ClrFeature+0x40>
        ((Setup_t)PIC(pdev->interfacesClass[LOBYTE(req->wIndex)].pClass->Setup)) (pdev, req);   
c0d0341a:	6880      	ldr	r0, [r0, #8]
c0d0341c:	f7fe fd8e 	bl	c0d01f3c <pic>
c0d03420:	4602      	mov	r2, r0
c0d03422:	4620      	mov	r0, r4
c0d03424:	4629      	mov	r1, r5
c0d03426:	4790      	blx	r2
      }
      USBD_CtlSendStatus(pdev);
c0d03428:	4620      	mov	r0, r4
c0d0342a:	f000 face 	bl	c0d039ca <USBD_CtlSendStatus>
    
  default :
     USBD_CtlError(pdev , req);
    break;
  }
}
c0d0342e:	bdb0      	pop	{r4, r5, r7, pc}
     USBD_CtlError(pdev , req);
c0d03430:	4620      	mov	r0, r4
c0d03432:	4629      	mov	r1, r5
c0d03434:	f000 fa12 	bl	c0d0385c <USBD_CtlError>
}
c0d03438:	bdb0      	pop	{r4, r5, r7, pc}

c0d0343a <USBD_StdItfReq>:
{
c0d0343a:	b5b0      	push	{r4, r5, r7, lr}
c0d0343c:	460d      	mov	r5, r1
c0d0343e:	4604      	mov	r4, r0
c0d03440:	20dc      	movs	r0, #220	; 0xdc
  switch (pdev->dev_state) 
c0d03442:	5c20      	ldrb	r0, [r4, r0]
c0d03444:	2803      	cmp	r0, #3
c0d03446:	d116      	bne.n	c0d03476 <USBD_StdItfReq+0x3c>
    if (usbd_is_valid_intf(pdev, LOBYTE(req->wIndex))) 
c0d03448:	7928      	ldrb	r0, [r5, #4]
  return intf < USBD_MAX_NUM_INTERFACES && pdev->interfacesClass[intf].pClass != NULL;
c0d0344a:	2802      	cmp	r0, #2
c0d0344c:	d813      	bhi.n	c0d03476 <USBD_StdItfReq+0x3c>
c0d0344e:	00c0      	lsls	r0, r0, #3
c0d03450:	1820      	adds	r0, r4, r0
c0d03452:	21f4      	movs	r1, #244	; 0xf4
c0d03454:	5840      	ldr	r0, [r0, r1]
    if (usbd_is_valid_intf(pdev, LOBYTE(req->wIndex))) 
c0d03456:	2800      	cmp	r0, #0
c0d03458:	d00d      	beq.n	c0d03476 <USBD_StdItfReq+0x3c>
      ((Setup_t)PIC(pdev->interfacesClass[LOBYTE(req->wIndex)].pClass->Setup)) (pdev, req);
c0d0345a:	6880      	ldr	r0, [r0, #8]
c0d0345c:	f7fe fd6e 	bl	c0d01f3c <pic>
c0d03460:	4602      	mov	r2, r0
c0d03462:	4620      	mov	r0, r4
c0d03464:	4629      	mov	r1, r5
c0d03466:	4790      	blx	r2
      if((req->wLength == 0)&& (ret == USBD_OK))
c0d03468:	88e8      	ldrh	r0, [r5, #6]
c0d0346a:	2800      	cmp	r0, #0
c0d0346c:	d107      	bne.n	c0d0347e <USBD_StdItfReq+0x44>
         USBD_CtlSendStatus(pdev);
c0d0346e:	4620      	mov	r0, r4
c0d03470:	f000 faab 	bl	c0d039ca <USBD_CtlSendStatus>
c0d03474:	e003      	b.n	c0d0347e <USBD_StdItfReq+0x44>
c0d03476:	4620      	mov	r0, r4
c0d03478:	4629      	mov	r1, r5
c0d0347a:	f000 f9ef 	bl	c0d0385c <USBD_CtlError>
c0d0347e:	2000      	movs	r0, #0
  return USBD_OK;
c0d03480:	bdb0      	pop	{r4, r5, r7, pc}

c0d03482 <USBD_StdEPReq>:
{
c0d03482:	b5b0      	push	{r4, r5, r7, lr}
c0d03484:	b082      	sub	sp, #8
c0d03486:	460d      	mov	r5, r1
c0d03488:	4604      	mov	r4, r0
  ep_addr  = LOBYTE(req->wIndex);
c0d0348a:	7909      	ldrb	r1, [r1, #4]
c0d0348c:	207f      	movs	r0, #127	; 0x7f
  if ((ep_addr & 0x7F) > IO_USB_MAX_ENDPOINTS) {
c0d0348e:	4008      	ands	r0, r1
c0d03490:	2807      	cmp	r0, #7
c0d03492:	d304      	bcc.n	c0d0349e <USBD_StdEPReq+0x1c>
c0d03494:	4620      	mov	r0, r4
c0d03496:	4629      	mov	r1, r5
c0d03498:	f000 f9e0 	bl	c0d0385c <USBD_CtlError>
c0d0349c:	e071      	b.n	c0d03582 <USBD_StdEPReq+0x100>
  if ((req->bmRequest & 0x60) == 0x20 && usbd_is_valid_intf(pdev, LOBYTE(req->wIndex)))
c0d0349e:	2902      	cmp	r1, #2
c0d034a0:	d812      	bhi.n	c0d034c8 <USBD_StdEPReq+0x46>
c0d034a2:	782a      	ldrb	r2, [r5, #0]
c0d034a4:	2360      	movs	r3, #96	; 0x60
c0d034a6:	4013      	ands	r3, r2
c0d034a8:	2b20      	cmp	r3, #32
c0d034aa:	d10d      	bne.n	c0d034c8 <USBD_StdEPReq+0x46>
  return intf < USBD_MAX_NUM_INTERFACES && pdev->interfacesClass[intf].pClass != NULL;
c0d034ac:	00ca      	lsls	r2, r1, #3
c0d034ae:	18a2      	adds	r2, r4, r2
c0d034b0:	23f4      	movs	r3, #244	; 0xf4
c0d034b2:	58d2      	ldr	r2, [r2, r3]
  if ((req->bmRequest & 0x60) == 0x20 && usbd_is_valid_intf(pdev, LOBYTE(req->wIndex)))
c0d034b4:	2a00      	cmp	r2, #0
c0d034b6:	d007      	beq.n	c0d034c8 <USBD_StdEPReq+0x46>
    ((Setup_t)PIC(pdev->interfacesClass[LOBYTE(req->wIndex)].pClass->Setup)) (pdev, req);
c0d034b8:	6890      	ldr	r0, [r2, #8]
c0d034ba:	f7fe fd3f 	bl	c0d01f3c <pic>
c0d034be:	4602      	mov	r2, r0
c0d034c0:	4620      	mov	r0, r4
c0d034c2:	4629      	mov	r1, r5
c0d034c4:	4790      	blx	r2
c0d034c6:	e05c      	b.n	c0d03582 <USBD_StdEPReq+0x100>
  switch (req->bRequest) 
c0d034c8:	786a      	ldrb	r2, [r5, #1]
c0d034ca:	2a00      	cmp	r2, #0
c0d034cc:	d00a      	beq.n	c0d034e4 <USBD_StdEPReq+0x62>
c0d034ce:	2a01      	cmp	r2, #1
c0d034d0:	d011      	beq.n	c0d034f6 <USBD_StdEPReq+0x74>
c0d034d2:	2a03      	cmp	r2, #3
c0d034d4:	d155      	bne.n	c0d03582 <USBD_StdEPReq+0x100>
c0d034d6:	20dc      	movs	r0, #220	; 0xdc
    switch (pdev->dev_state) 
c0d034d8:	5c20      	ldrb	r0, [r4, r0]
c0d034da:	2803      	cmp	r0, #3
c0d034dc:	d01a      	beq.n	c0d03514 <USBD_StdEPReq+0x92>
c0d034de:	2802      	cmp	r0, #2
c0d034e0:	d00f      	beq.n	c0d03502 <USBD_StdEPReq+0x80>
c0d034e2:	e7d7      	b.n	c0d03494 <USBD_StdEPReq+0x12>
c0d034e4:	22dc      	movs	r2, #220	; 0xdc
    switch (pdev->dev_state) 
c0d034e6:	5ca2      	ldrb	r2, [r4, r2]
c0d034e8:	2a03      	cmp	r2, #3
c0d034ea:	d02e      	beq.n	c0d0354a <USBD_StdEPReq+0xc8>
c0d034ec:	2a02      	cmp	r2, #2
c0d034ee:	d1d1      	bne.n	c0d03494 <USBD_StdEPReq+0x12>
      if ((ep_addr & 0x7F) != 0x00) 
c0d034f0:	2800      	cmp	r0, #0
c0d034f2:	d10b      	bne.n	c0d0350c <USBD_StdEPReq+0x8a>
c0d034f4:	e045      	b.n	c0d03582 <USBD_StdEPReq+0x100>
c0d034f6:	22dc      	movs	r2, #220	; 0xdc
    switch (pdev->dev_state) 
c0d034f8:	5ca2      	ldrb	r2, [r4, r2]
c0d034fa:	2a03      	cmp	r2, #3
c0d034fc:	d031      	beq.n	c0d03562 <USBD_StdEPReq+0xe0>
c0d034fe:	2a02      	cmp	r2, #2
c0d03500:	d1c8      	bne.n	c0d03494 <USBD_StdEPReq+0x12>
c0d03502:	2080      	movs	r0, #128	; 0x80
c0d03504:	460a      	mov	r2, r1
c0d03506:	4302      	orrs	r2, r0
c0d03508:	2a80      	cmp	r2, #128	; 0x80
c0d0350a:	d03a      	beq.n	c0d03582 <USBD_StdEPReq+0x100>
c0d0350c:	4620      	mov	r0, r4
c0d0350e:	f7ff fbb9 	bl	c0d02c84 <USBD_LL_StallEP>
c0d03512:	e036      	b.n	c0d03582 <USBD_StdEPReq+0x100>
      if (req->wValue == USB_FEATURE_EP_HALT)
c0d03514:	8868      	ldrh	r0, [r5, #2]
c0d03516:	2800      	cmp	r0, #0
c0d03518:	d107      	bne.n	c0d0352a <USBD_StdEPReq+0xa8>
c0d0351a:	2080      	movs	r0, #128	; 0x80
c0d0351c:	4308      	orrs	r0, r1
c0d0351e:	2880      	cmp	r0, #128	; 0x80
c0d03520:	d003      	beq.n	c0d0352a <USBD_StdEPReq+0xa8>
          USBD_LL_StallEP(pdev , ep_addr);
c0d03522:	4620      	mov	r0, r4
c0d03524:	f7ff fbae 	bl	c0d02c84 <USBD_LL_StallEP>
      if(usbd_is_valid_intf(pdev, LOBYTE(req->wIndex))) {
c0d03528:	7929      	ldrb	r1, [r5, #4]
  return intf < USBD_MAX_NUM_INTERFACES && pdev->interfacesClass[intf].pClass != NULL;
c0d0352a:	2902      	cmp	r1, #2
c0d0352c:	d826      	bhi.n	c0d0357c <USBD_StdEPReq+0xfa>
c0d0352e:	00c8      	lsls	r0, r1, #3
c0d03530:	1820      	adds	r0, r4, r0
c0d03532:	21f4      	movs	r1, #244	; 0xf4
c0d03534:	5840      	ldr	r0, [r0, r1]
c0d03536:	2800      	cmp	r0, #0
c0d03538:	d020      	beq.n	c0d0357c <USBD_StdEPReq+0xfa>
c0d0353a:	6880      	ldr	r0, [r0, #8]
c0d0353c:	f7fe fcfe 	bl	c0d01f3c <pic>
c0d03540:	4602      	mov	r2, r0
c0d03542:	4620      	mov	r0, r4
c0d03544:	4629      	mov	r1, r5
c0d03546:	4790      	blx	r2
c0d03548:	e018      	b.n	c0d0357c <USBD_StdEPReq+0xfa>
        unsigned short status = USBD_LL_IsStallEP(pdev, ep_addr)? 1 : 0;        
c0d0354a:	4620      	mov	r0, r4
c0d0354c:	f7ff fbe2 	bl	c0d02d14 <USBD_LL_IsStallEP>
c0d03550:	1e41      	subs	r1, r0, #1
c0d03552:	4188      	sbcs	r0, r1
c0d03554:	a901      	add	r1, sp, #4
c0d03556:	8008      	strh	r0, [r1, #0]
c0d03558:	2202      	movs	r2, #2
        USBD_CtlSendData (pdev,
c0d0355a:	4620      	mov	r0, r4
c0d0355c:	f000 fa0a 	bl	c0d03974 <USBD_CtlSendData>
c0d03560:	e00f      	b.n	c0d03582 <USBD_StdEPReq+0x100>
      if (req->wValue == USB_FEATURE_EP_HALT)
c0d03562:	886a      	ldrh	r2, [r5, #2]
c0d03564:	2a00      	cmp	r2, #0
c0d03566:	d10c      	bne.n	c0d03582 <USBD_StdEPReq+0x100>
        if ((ep_addr & 0x7F) != 0x00) 
c0d03568:	2800      	cmp	r0, #0
c0d0356a:	d007      	beq.n	c0d0357c <USBD_StdEPReq+0xfa>
          USBD_LL_ClearStallEP(pdev , ep_addr);
c0d0356c:	4620      	mov	r0, r4
c0d0356e:	f7ff fbad 	bl	c0d02ccc <USBD_LL_ClearStallEP>
          if(usbd_is_valid_intf(pdev, LOBYTE(req->wIndex))) {
c0d03572:	7928      	ldrb	r0, [r5, #4]
  return intf < USBD_MAX_NUM_INTERFACES && pdev->interfacesClass[intf].pClass != NULL;
c0d03574:	2802      	cmp	r0, #2
c0d03576:	d801      	bhi.n	c0d0357c <USBD_StdEPReq+0xfa>
c0d03578:	00c0      	lsls	r0, r0, #3
c0d0357a:	e7d9      	b.n	c0d03530 <USBD_StdEPReq+0xae>
c0d0357c:	4620      	mov	r0, r4
c0d0357e:	f000 fa24 	bl	c0d039ca <USBD_CtlSendStatus>
c0d03582:	2000      	movs	r0, #0
}
c0d03584:	b002      	add	sp, #8
c0d03586:	bdb0      	pop	{r4, r5, r7, pc}

c0d03588 <USBD_ParseSetupRequest>:
* @retval None
*/

void USBD_ParseSetupRequest(USBD_SetupReqTypedef *req, uint8_t *pdata)
{
  req->bmRequest     = *(uint8_t *)  (pdata);
c0d03588:	780a      	ldrb	r2, [r1, #0]
c0d0358a:	7002      	strb	r2, [r0, #0]
  req->bRequest      = *(uint8_t *)  (pdata +  1);
c0d0358c:	784a      	ldrb	r2, [r1, #1]
c0d0358e:	7042      	strb	r2, [r0, #1]
  req->wValue        = SWAPBYTE      (pdata +  2);
c0d03590:	788a      	ldrb	r2, [r1, #2]
c0d03592:	78cb      	ldrb	r3, [r1, #3]
c0d03594:	021b      	lsls	r3, r3, #8
c0d03596:	189a      	adds	r2, r3, r2
c0d03598:	8042      	strh	r2, [r0, #2]
  req->wIndex        = SWAPBYTE      (pdata +  4);
c0d0359a:	790a      	ldrb	r2, [r1, #4]
c0d0359c:	794b      	ldrb	r3, [r1, #5]
c0d0359e:	021b      	lsls	r3, r3, #8
c0d035a0:	189a      	adds	r2, r3, r2
c0d035a2:	8082      	strh	r2, [r0, #4]
  req->wLength       = SWAPBYTE      (pdata +  6);
c0d035a4:	798a      	ldrb	r2, [r1, #6]
c0d035a6:	79c9      	ldrb	r1, [r1, #7]
c0d035a8:	0209      	lsls	r1, r1, #8
c0d035aa:	1889      	adds	r1, r1, r2
c0d035ac:	80c1      	strh	r1, [r0, #6]

}
c0d035ae:	4770      	bx	lr

c0d035b0 <USBD_CtlStall>:
* @param  pdev: device instance
* @param  req: usb request
* @retval None
*/
void USBD_CtlStall( USBD_HandleTypeDef *pdev)
{
c0d035b0:	b510      	push	{r4, lr}
c0d035b2:	4604      	mov	r4, r0
c0d035b4:	2180      	movs	r1, #128	; 0x80
  USBD_LL_StallEP(pdev , 0x80);
c0d035b6:	f7ff fb65 	bl	c0d02c84 <USBD_LL_StallEP>
c0d035ba:	2100      	movs	r1, #0
  USBD_LL_StallEP(pdev , 0);
c0d035bc:	4620      	mov	r0, r4
c0d035be:	f7ff fb61 	bl	c0d02c84 <USBD_LL_StallEP>
}
c0d035c2:	bd10      	pop	{r4, pc}

c0d035c4 <USBD_HID_Setup>:
  * @param  req: usb requests
  * @retval status
  */
uint8_t  USBD_HID_Setup (USBD_HandleTypeDef *pdev, 
                                USBD_SetupReqTypedef *req)
{
c0d035c4:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d035c6:	b083      	sub	sp, #12
c0d035c8:	460e      	mov	r6, r1
c0d035ca:	4605      	mov	r5, r0
c0d035cc:	a802      	add	r0, sp, #8
c0d035ce:	2400      	movs	r4, #0
  uint16_t len = 0;
c0d035d0:	8004      	strh	r4, [r0, #0]
c0d035d2:	a801      	add	r0, sp, #4
  uint8_t  *pbuf = NULL;

  uint8_t val = 0;
c0d035d4:	7004      	strb	r4, [r0, #0]

  switch (req->bmRequest & USB_REQ_TYPE_MASK)
c0d035d6:	7809      	ldrb	r1, [r1, #0]
c0d035d8:	2060      	movs	r0, #96	; 0x60
c0d035da:	4008      	ands	r0, r1
c0d035dc:	d010      	beq.n	c0d03600 <USBD_HID_Setup+0x3c>
c0d035de:	2820      	cmp	r0, #32
c0d035e0:	d137      	bne.n	c0d03652 <USBD_HID_Setup+0x8e>
  {
  case USB_REQ_TYPE_CLASS :  
    switch (req->bRequest)
c0d035e2:	7870      	ldrb	r0, [r6, #1]
c0d035e4:	4601      	mov	r1, r0
c0d035e6:	390a      	subs	r1, #10
c0d035e8:	2902      	cmp	r1, #2
c0d035ea:	d332      	bcc.n	c0d03652 <USBD_HID_Setup+0x8e>
c0d035ec:	2802      	cmp	r0, #2
c0d035ee:	d01b      	beq.n	c0d03628 <USBD_HID_Setup+0x64>
c0d035f0:	2803      	cmp	r0, #3
c0d035f2:	d019      	beq.n	c0d03628 <USBD_HID_Setup+0x64>
                        (uint8_t *)&val,
                        1);      
      break;      
      
    default:
      USBD_CtlError (pdev, req);
c0d035f4:	4628      	mov	r0, r5
c0d035f6:	4631      	mov	r1, r6
c0d035f8:	f000 f930 	bl	c0d0385c <USBD_CtlError>
c0d035fc:	2402      	movs	r4, #2
c0d035fe:	e028      	b.n	c0d03652 <USBD_HID_Setup+0x8e>
      return USBD_FAIL; 
    }
    break;
    
  case USB_REQ_TYPE_STANDARD:
    switch (req->bRequest)
c0d03600:	7870      	ldrb	r0, [r6, #1]
c0d03602:	280b      	cmp	r0, #11
c0d03604:	d013      	beq.n	c0d0362e <USBD_HID_Setup+0x6a>
c0d03606:	280a      	cmp	r0, #10
c0d03608:	d00e      	beq.n	c0d03628 <USBD_HID_Setup+0x64>
c0d0360a:	2806      	cmp	r0, #6
c0d0360c:	d121      	bne.n	c0d03652 <USBD_HID_Setup+0x8e>
    {
    case USB_REQ_GET_DESCRIPTOR: 
      // 0x22
      if( req->wValue >> 8 == HID_REPORT_DESC)
c0d0360e:	78f0      	ldrb	r0, [r6, #3]
c0d03610:	2400      	movs	r4, #0
c0d03612:	2821      	cmp	r0, #33	; 0x21
c0d03614:	d00f      	beq.n	c0d03636 <USBD_HID_Setup+0x72>
c0d03616:	2822      	cmp	r0, #34	; 0x22
      
      //USBD_CtlReceiveStatus(pdev);
      
      USBD_CtlSendData (pdev, 
                        pbuf,
                        len);
c0d03618:	4622      	mov	r2, r4
c0d0361a:	4621      	mov	r1, r4
      if( req->wValue >> 8 == HID_REPORT_DESC)
c0d0361c:	d116      	bne.n	c0d0364c <USBD_HID_Setup+0x88>
c0d0361e:	af02      	add	r7, sp, #8
        pbuf =  USBD_HID_GetReportDescriptor_impl(&len);
c0d03620:	4638      	mov	r0, r7
c0d03622:	f000 f849 	bl	c0d036b8 <USBD_HID_GetReportDescriptor_impl>
c0d03626:	e00a      	b.n	c0d0363e <USBD_HID_Setup+0x7a>
c0d03628:	a901      	add	r1, sp, #4
c0d0362a:	2201      	movs	r2, #1
c0d0362c:	e00e      	b.n	c0d0364c <USBD_HID_Setup+0x88>
      break;

    case USB_REQ_SET_INTERFACE :
      //hhid->AltSetting = (uint8_t)(req->wValue);
      USBD_CtlSendStatus(pdev);
c0d0362e:	4628      	mov	r0, r5
c0d03630:	f000 f9cb 	bl	c0d039ca <USBD_CtlSendStatus>
c0d03634:	e00d      	b.n	c0d03652 <USBD_HID_Setup+0x8e>
c0d03636:	af02      	add	r7, sp, #8
        pbuf = USBD_HID_GetHidDescriptor_impl(&len);
c0d03638:	4638      	mov	r0, r7
c0d0363a:	f000 f829 	bl	c0d03690 <USBD_HID_GetHidDescriptor_impl>
c0d0363e:	4601      	mov	r1, r0
c0d03640:	883a      	ldrh	r2, [r7, #0]
c0d03642:	88f0      	ldrh	r0, [r6, #6]
c0d03644:	4282      	cmp	r2, r0
c0d03646:	d300      	bcc.n	c0d0364a <USBD_HID_Setup+0x86>
c0d03648:	4602      	mov	r2, r0
c0d0364a:	803a      	strh	r2, [r7, #0]
c0d0364c:	4628      	mov	r0, r5
c0d0364e:	f000 f991 	bl	c0d03974 <USBD_CtlSendData>
      
    }
  }

  return USBD_OK;
}
c0d03652:	4620      	mov	r0, r4
c0d03654:	b003      	add	sp, #12
c0d03656:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d03658 <USBD_HID_Init>:
  * @param  cfgidx: Configuration index
  * @retval status
  */
uint8_t  USBD_HID_Init (USBD_HandleTypeDef *pdev, 
                               uint8_t cfgidx)
{
c0d03658:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0365a:	b081      	sub	sp, #4
c0d0365c:	4604      	mov	r4, r0
c0d0365e:	2182      	movs	r1, #130	; 0x82
c0d03660:	2603      	movs	r6, #3
c0d03662:	2540      	movs	r5, #64	; 0x40
  UNUSED(cfgidx);

  /* Open EP IN */
  USBD_LL_OpenEP(pdev,
c0d03664:	4632      	mov	r2, r6
c0d03666:	462b      	mov	r3, r5
c0d03668:	f7ff fadc 	bl	c0d02c24 <USBD_LL_OpenEP>
c0d0366c:	2702      	movs	r7, #2
                 HID_EPIN_ADDR,
                 USBD_EP_TYPE_INTR,
                 HID_EPIN_SIZE);
  
  /* Open EP OUT */
  USBD_LL_OpenEP(pdev,
c0d0366e:	4620      	mov	r0, r4
c0d03670:	4639      	mov	r1, r7
c0d03672:	4632      	mov	r2, r6
c0d03674:	462b      	mov	r3, r5
c0d03676:	f7ff fad5 	bl	c0d02c24 <USBD_LL_OpenEP>
                 HID_EPOUT_ADDR,
                 USBD_EP_TYPE_INTR,
                 HID_EPOUT_SIZE);

        /* Prepare Out endpoint to receive 1st packet */ 
  USBD_LL_PrepareReceive(pdev, HID_EPOUT_ADDR, HID_EPOUT_SIZE);
c0d0367a:	4620      	mov	r0, r4
c0d0367c:	4639      	mov	r1, r7
c0d0367e:	462a      	mov	r2, r5
c0d03680:	f7ff fb83 	bl	c0d02d8a <USBD_LL_PrepareReceive>
c0d03684:	2000      	movs	r0, #0
  USBD_LL_Transmit (pdev, 
                    HID_EPIN_ADDR,                                      
                    NULL,
                    0);
  */
  return USBD_OK;
c0d03686:	b001      	add	sp, #4
c0d03688:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d0368a <USBD_HID_DeInit>:
  * @param  cfgidx: Configuration index
  * @retval status
  */
uint8_t  USBD_HID_DeInit (USBD_HandleTypeDef *pdev, 
                                 uint8_t cfgidx)
{
c0d0368a:	2000      	movs	r0, #0
  
  // /* Close HID EP OUT */
  // USBD_LL_CloseEP(pdev,
  //                 HID_EPOUT_ADDR);
  
  return USBD_OK;
c0d0368c:	4770      	bx	lr
	...

c0d03690 <USBD_HID_GetHidDescriptor_impl>:
{
  *length = sizeof (USBD_CfgDesc);
  return (uint8_t*)USBD_CfgDesc;
}

uint8_t* USBD_HID_GetHidDescriptor_impl(uint16_t* len) {
c0d03690:	4601      	mov	r1, r0
c0d03692:	20ec      	movs	r0, #236	; 0xec
  switch (USBD_Device.request.wIndex&0xFF) {
c0d03694:	4a06      	ldr	r2, [pc, #24]	; (c0d036b0 <USBD_HID_GetHidDescriptor_impl+0x20>)
c0d03696:	5c12      	ldrb	r2, [r2, r0]
c0d03698:	2000      	movs	r0, #0
c0d0369a:	2a00      	cmp	r2, #0
c0d0369c:	d001      	beq.n	c0d036a2 <USBD_HID_GetHidDescriptor_impl+0x12>
c0d0369e:	4603      	mov	r3, r0
c0d036a0:	e000      	b.n	c0d036a4 <USBD_HID_GetHidDescriptor_impl+0x14>
c0d036a2:	2309      	movs	r3, #9
c0d036a4:	800b      	strh	r3, [r1, #0]
c0d036a6:	2a00      	cmp	r2, #0
c0d036a8:	d101      	bne.n	c0d036ae <USBD_HID_GetHidDescriptor_impl+0x1e>
c0d036aa:	4802      	ldr	r0, [pc, #8]	; (c0d036b4 <USBD_HID_GetHidDescriptor_impl+0x24>)
c0d036ac:	4478      	add	r0, pc
      return (uint8_t*)USBD_HID_Desc_kbd; 
#endif // HAVE_USB_HIDKBD
  }
  *len = 0;
  return 0;
}
c0d036ae:	4770      	bx	lr
c0d036b0:	20000cb8 	.word	0x20000cb8
c0d036b4:	00001d94 	.word	0x00001d94

c0d036b8 <USBD_HID_GetReportDescriptor_impl>:

uint8_t* USBD_HID_GetReportDescriptor_impl(uint16_t* len) {
c0d036b8:	4601      	mov	r1, r0
c0d036ba:	20ec      	movs	r0, #236	; 0xec
  switch (USBD_Device.request.wIndex&0xFF) {
c0d036bc:	4a06      	ldr	r2, [pc, #24]	; (c0d036d8 <USBD_HID_GetReportDescriptor_impl+0x20>)
c0d036be:	5c12      	ldrb	r2, [r2, r0]
c0d036c0:	2000      	movs	r0, #0
c0d036c2:	2a00      	cmp	r2, #0
c0d036c4:	d001      	beq.n	c0d036ca <USBD_HID_GetReportDescriptor_impl+0x12>
c0d036c6:	4603      	mov	r3, r0
c0d036c8:	e000      	b.n	c0d036cc <USBD_HID_GetReportDescriptor_impl+0x14>
c0d036ca:	2322      	movs	r3, #34	; 0x22
c0d036cc:	800b      	strh	r3, [r1, #0]
c0d036ce:	2a00      	cmp	r2, #0
c0d036d0:	d101      	bne.n	c0d036d6 <USBD_HID_GetReportDescriptor_impl+0x1e>
c0d036d2:	4802      	ldr	r0, [pc, #8]	; (c0d036dc <USBD_HID_GetReportDescriptor_impl+0x24>)
c0d036d4:	4478      	add	r0, pc
    return (uint8_t*)HID_ReportDesc_kbd;
#endif // HAVE_USB_HIDKBD
  }
  *len = 0;
  return 0;
}
c0d036d6:	4770      	bx	lr
c0d036d8:	20000cb8 	.word	0x20000cb8
c0d036dc:	00001d75 	.word	0x00001d75

c0d036e0 <USBD_HID_DataIn_impl>:
}
#endif // HAVE_IO_U2F

uint8_t  USBD_HID_DataIn_impl (USBD_HandleTypeDef *pdev, 
                              uint8_t epnum)
{
c0d036e0:	b580      	push	{r7, lr}
  UNUSED(pdev);
  switch (epnum) {
c0d036e2:	2902      	cmp	r1, #2
c0d036e4:	d103      	bne.n	c0d036ee <USBD_HID_DataIn_impl+0xe>
    // HID gen endpoint
    case (HID_EPIN_ADDR&0x7F):
      io_usb_hid_sent(io_usb_send_apdu_data);
c0d036e6:	4803      	ldr	r0, [pc, #12]	; (c0d036f4 <USBD_HID_DataIn_impl+0x14>)
c0d036e8:	4478      	add	r0, pc
c0d036ea:	f7fd ffff 	bl	c0d016ec <io_usb_hid_sent>
c0d036ee:	2000      	movs	r0, #0
      break;
  }

  return USBD_OK;
c0d036f0:	bd80      	pop	{r7, pc}
c0d036f2:	46c0      	nop			; (mov r8, r8)
c0d036f4:	ffffd8dd 	.word	0xffffd8dd

c0d036f8 <USBD_HID_DataOut_impl>:
}

uint8_t  USBD_HID_DataOut_impl (USBD_HandleTypeDef *pdev, 
                              uint8_t epnum, uint8_t* buffer)
{
c0d036f8:	b5b0      	push	{r4, r5, r7, lr}
  // only the data hid endpoint will receive data
  switch (epnum) {
c0d036fa:	2902      	cmp	r1, #2
c0d036fc:	d11a      	bne.n	c0d03734 <USBD_HID_DataOut_impl+0x3c>
c0d036fe:	4614      	mov	r4, r2
c0d03700:	2102      	movs	r1, #2
c0d03702:	2240      	movs	r2, #64	; 0x40

  // HID gen endpoint
  case (HID_EPOUT_ADDR&0x7F):
    // prepare receiving the next chunk (masked time)
    USBD_LL_PrepareReceive(pdev, HID_EPOUT_ADDR , HID_EPOUT_SIZE);
c0d03704:	f7ff fb41 	bl	c0d02d8a <USBD_LL_PrepareReceive>

#ifndef HAVE_USB_HIDKBD
    // avoid troubles when an apdu has not been replied yet
    if (G_io_app.apdu_media == IO_APDU_MEDIA_NONE) {      
c0d03708:	4d0b      	ldr	r5, [pc, #44]	; (c0d03738 <USBD_HID_DataOut_impl+0x40>)
c0d0370a:	79a8      	ldrb	r0, [r5, #6]
c0d0370c:	2800      	cmp	r0, #0
c0d0370e:	d111      	bne.n	c0d03734 <USBD_HID_DataOut_impl+0x3c>
c0d03710:	2002      	movs	r0, #2
      // add to the hid transport
      switch(io_usb_hid_receive(io_usb_send_apdu_data, buffer, io_seproxyhal_get_ep_rx_size(HID_EPOUT_ADDR))) {
c0d03712:	f7fd fbf5 	bl	c0d00f00 <io_seproxyhal_get_ep_rx_size>
c0d03716:	4602      	mov	r2, r0
c0d03718:	4809      	ldr	r0, [pc, #36]	; (c0d03740 <USBD_HID_DataOut_impl+0x48>)
c0d0371a:	4478      	add	r0, pc
c0d0371c:	4621      	mov	r1, r4
c0d0371e:	f7fd ff2f 	bl	c0d01580 <io_usb_hid_receive>
c0d03722:	2802      	cmp	r0, #2
c0d03724:	d106      	bne.n	c0d03734 <USBD_HID_DataOut_impl+0x3c>
c0d03726:	2007      	movs	r0, #7
        default:
          break;

        case IO_USB_APDU_RECEIVED:
          G_io_app.apdu_media = IO_APDU_MEDIA_USB_HID; // for application code
          G_io_app.apdu_state = APDU_USB_HID; // for next call to io_exchange
c0d03728:	7028      	strb	r0, [r5, #0]
c0d0372a:	2001      	movs	r0, #1
          G_io_app.apdu_media = IO_APDU_MEDIA_USB_HID; // for application code
c0d0372c:	71a8      	strb	r0, [r5, #6]
          G_io_app.apdu_length = G_io_usb_hid_total_length;
c0d0372e:	4803      	ldr	r0, [pc, #12]	; (c0d0373c <USBD_HID_DataOut_impl+0x44>)
c0d03730:	6800      	ldr	r0, [r0, #0]
c0d03732:	8068      	strh	r0, [r5, #2]
c0d03734:	2000      	movs	r0, #0
    }
#endif // HAVE_USB_HIDKBD
    break;
  }

  return USBD_OK;
c0d03736:	bdb0      	pop	{r4, r5, r7, pc}
c0d03738:	20000a30 	.word	0x20000a30
c0d0373c:	20000a9c 	.word	0x20000a9c
c0d03740:	ffffd8ab 	.word	0xffffd8ab

c0d03744 <USBD_WEBUSB_Init>:

#ifdef HAVE_WEBUSB

uint8_t  USBD_WEBUSB_Init (USBD_HandleTypeDef *pdev, 
                               uint8_t cfgidx)
{
c0d03744:	b570      	push	{r4, r5, r6, lr}
c0d03746:	4604      	mov	r4, r0
c0d03748:	2183      	movs	r1, #131	; 0x83
c0d0374a:	2503      	movs	r5, #3
c0d0374c:	2640      	movs	r6, #64	; 0x40
  UNUSED(cfgidx);

  /* Open EP IN */
  USBD_LL_OpenEP(pdev,
c0d0374e:	462a      	mov	r2, r5
c0d03750:	4633      	mov	r3, r6
c0d03752:	f7ff fa67 	bl	c0d02c24 <USBD_LL_OpenEP>
                 WEBUSB_EPIN_ADDR,
                 USBD_EP_TYPE_INTR,
                 WEBUSB_EPIN_SIZE);
  
  /* Open EP OUT */
  USBD_LL_OpenEP(pdev,
c0d03756:	4620      	mov	r0, r4
c0d03758:	4629      	mov	r1, r5
c0d0375a:	462a      	mov	r2, r5
c0d0375c:	4633      	mov	r3, r6
c0d0375e:	f7ff fa61 	bl	c0d02c24 <USBD_LL_OpenEP>
                 WEBUSB_EPOUT_ADDR,
                 USBD_EP_TYPE_INTR,
                 WEBUSB_EPOUT_SIZE);

        /* Prepare Out endpoint to receive 1st packet */ 
  USBD_LL_PrepareReceive(pdev, WEBUSB_EPOUT_ADDR, WEBUSB_EPOUT_SIZE);
c0d03762:	4620      	mov	r0, r4
c0d03764:	4629      	mov	r1, r5
c0d03766:	4632      	mov	r2, r6
c0d03768:	f7ff fb0f 	bl	c0d02d8a <USBD_LL_PrepareReceive>
c0d0376c:	2000      	movs	r0, #0

  return USBD_OK;
c0d0376e:	bd70      	pop	{r4, r5, r6, pc}

c0d03770 <USBD_WEBUSB_DeInit>:
}

uint8_t  USBD_WEBUSB_DeInit (USBD_HandleTypeDef *pdev, 
                                 uint8_t cfgidx) {
c0d03770:	2000      	movs	r0, #0
  UNUSED(pdev);
  UNUSED(cfgidx);
  return USBD_OK;
c0d03772:	4770      	bx	lr

c0d03774 <USBD_WEBUSB_Setup>:
}

uint8_t  USBD_WEBUSB_Setup (USBD_HandleTypeDef *pdev, 
                                USBD_SetupReqTypedef *req)
{
c0d03774:	2000      	movs	r0, #0
  UNUSED(pdev);
  UNUSED(req);
  return USBD_OK;
c0d03776:	4770      	bx	lr

c0d03778 <USBD_WEBUSB_DataIn>:
}

uint8_t  USBD_WEBUSB_DataIn (USBD_HandleTypeDef *pdev, 
                              uint8_t epnum)
{
c0d03778:	b580      	push	{r7, lr}
  UNUSED(pdev);
  switch (epnum) {
c0d0377a:	2903      	cmp	r1, #3
c0d0377c:	d103      	bne.n	c0d03786 <USBD_WEBUSB_DataIn+0xe>
    // HID gen endpoint
    case (WEBUSB_EPIN_ADDR&0x7F):
      io_usb_hid_sent(io_usb_send_apdu_data_ep0x83);
c0d0377e:	4803      	ldr	r0, [pc, #12]	; (c0d0378c <USBD_WEBUSB_DataIn+0x14>)
c0d03780:	4478      	add	r0, pc
c0d03782:	f7fd ffb3 	bl	c0d016ec <io_usb_hid_sent>
c0d03786:	2000      	movs	r0, #0
      break;
  }
  return USBD_OK;
c0d03788:	bd80      	pop	{r7, pc}
c0d0378a:	46c0      	nop			; (mov r8, r8)
c0d0378c:	ffffd855 	.word	0xffffd855

c0d03790 <USBD_WEBUSB_DataOut>:
}

uint8_t USBD_WEBUSB_DataOut (USBD_HandleTypeDef *pdev, 
                              uint8_t epnum, uint8_t* buffer)
{
c0d03790:	b5b0      	push	{r4, r5, r7, lr}
  // only the data hid endpoint will receive data
  switch (epnum) {
c0d03792:	2903      	cmp	r1, #3
c0d03794:	d11a      	bne.n	c0d037cc <USBD_WEBUSB_DataOut+0x3c>
c0d03796:	4614      	mov	r4, r2
c0d03798:	2103      	movs	r1, #3
c0d0379a:	2240      	movs	r2, #64	; 0x40

  // HID gen endpoint
  case (WEBUSB_EPOUT_ADDR&0x7F):
    // prepare receiving the next chunk (masked time)
    USBD_LL_PrepareReceive(pdev, WEBUSB_EPOUT_ADDR, WEBUSB_EPOUT_SIZE);
c0d0379c:	f7ff faf5 	bl	c0d02d8a <USBD_LL_PrepareReceive>

    // avoid troubles when an apdu has not been replied yet
    if (G_io_app.apdu_media == IO_APDU_MEDIA_NONE) {      
c0d037a0:	4d0b      	ldr	r5, [pc, #44]	; (c0d037d0 <USBD_WEBUSB_DataOut+0x40>)
c0d037a2:	79a8      	ldrb	r0, [r5, #6]
c0d037a4:	2800      	cmp	r0, #0
c0d037a6:	d111      	bne.n	c0d037cc <USBD_WEBUSB_DataOut+0x3c>
c0d037a8:	2003      	movs	r0, #3
      // add to the hid transport
      switch(io_usb_hid_receive(io_usb_send_apdu_data_ep0x83, buffer, io_seproxyhal_get_ep_rx_size(WEBUSB_EPOUT_ADDR))) {
c0d037aa:	f7fd fba9 	bl	c0d00f00 <io_seproxyhal_get_ep_rx_size>
c0d037ae:	4602      	mov	r2, r0
c0d037b0:	4809      	ldr	r0, [pc, #36]	; (c0d037d8 <USBD_WEBUSB_DataOut+0x48>)
c0d037b2:	4478      	add	r0, pc
c0d037b4:	4621      	mov	r1, r4
c0d037b6:	f7fd fee3 	bl	c0d01580 <io_usb_hid_receive>
c0d037ba:	2802      	cmp	r0, #2
c0d037bc:	d106      	bne.n	c0d037cc <USBD_WEBUSB_DataOut+0x3c>
c0d037be:	200b      	movs	r0, #11
        default:
          break;

        case IO_USB_APDU_RECEIVED:
          G_io_app.apdu_media = IO_APDU_MEDIA_USB_WEBUSB; // for application code
          G_io_app.apdu_state = APDU_USB_WEBUSB; // for next call to io_exchange
c0d037c0:	7028      	strb	r0, [r5, #0]
c0d037c2:	2005      	movs	r0, #5
          G_io_app.apdu_media = IO_APDU_MEDIA_USB_WEBUSB; // for application code
c0d037c4:	71a8      	strb	r0, [r5, #6]
          G_io_app.apdu_length = G_io_usb_hid_total_length;
c0d037c6:	4803      	ldr	r0, [pc, #12]	; (c0d037d4 <USBD_WEBUSB_DataOut+0x44>)
c0d037c8:	6800      	ldr	r0, [r0, #0]
c0d037ca:	8068      	strh	r0, [r5, #2]
c0d037cc:	2000      	movs	r0, #0
      }
    }
    break;
  }

  return USBD_OK;
c0d037ce:	bdb0      	pop	{r4, r5, r7, pc}
c0d037d0:	20000a30 	.word	0x20000a30
c0d037d4:	20000a9c 	.word	0x20000a9c
c0d037d8:	ffffd823 	.word	0xffffd823

c0d037dc <USBD_DeviceDescriptor>:
{
c0d037dc:	2012      	movs	r0, #18
  *length = sizeof(USBD_DeviceDesc);
c0d037de:	8008      	strh	r0, [r1, #0]
  return (uint8_t*)USBD_DeviceDesc;
c0d037e0:	4801      	ldr	r0, [pc, #4]	; (c0d037e8 <USBD_DeviceDescriptor+0xc>)
c0d037e2:	4478      	add	r0, pc
c0d037e4:	4770      	bx	lr
c0d037e6:	46c0      	nop			; (mov r8, r8)
c0d037e8:	00001eaa 	.word	0x00001eaa

c0d037ec <USBD_LangIDStrDescriptor>:
{
c0d037ec:	2004      	movs	r0, #4
  *length = sizeof(USBD_LangIDDesc);  
c0d037ee:	8008      	strh	r0, [r1, #0]
  return (uint8_t*)USBD_LangIDDesc;
c0d037f0:	4801      	ldr	r0, [pc, #4]	; (c0d037f8 <USBD_LangIDStrDescriptor+0xc>)
c0d037f2:	4478      	add	r0, pc
c0d037f4:	4770      	bx	lr
c0d037f6:	46c0      	nop			; (mov r8, r8)
c0d037f8:	00001eac 	.word	0x00001eac

c0d037fc <USBD_ManufacturerStrDescriptor>:
{
c0d037fc:	200e      	movs	r0, #14
  *length = sizeof(USBD_MANUFACTURER_STRING);
c0d037fe:	8008      	strh	r0, [r1, #0]
  return (uint8_t*)USBD_MANUFACTURER_STRING;
c0d03800:	4801      	ldr	r0, [pc, #4]	; (c0d03808 <USBD_ManufacturerStrDescriptor+0xc>)
c0d03802:	4478      	add	r0, pc
c0d03804:	4770      	bx	lr
c0d03806:	46c0      	nop			; (mov r8, r8)
c0d03808:	00001ea0 	.word	0x00001ea0

c0d0380c <USBD_ProductStrDescriptor>:
{
c0d0380c:	200e      	movs	r0, #14
  *length = sizeof(USBD_PRODUCT_FS_STRING);
c0d0380e:	8008      	strh	r0, [r1, #0]
  return (uint8_t*)USBD_PRODUCT_FS_STRING;
c0d03810:	4801      	ldr	r0, [pc, #4]	; (c0d03818 <USBD_ProductStrDescriptor+0xc>)
c0d03812:	4478      	add	r0, pc
c0d03814:	4770      	bx	lr
c0d03816:	46c0      	nop			; (mov r8, r8)
c0d03818:	00001e9e 	.word	0x00001e9e

c0d0381c <USBD_SerialStrDescriptor>:
{
c0d0381c:	200a      	movs	r0, #10
  *length = sizeof(USB_SERIAL_STRING);
c0d0381e:	8008      	strh	r0, [r1, #0]
  return (uint8_t*)USB_SERIAL_STRING;
c0d03820:	4801      	ldr	r0, [pc, #4]	; (c0d03828 <USBD_SerialStrDescriptor+0xc>)
c0d03822:	4478      	add	r0, pc
c0d03824:	4770      	bx	lr
c0d03826:	46c0      	nop			; (mov r8, r8)
c0d03828:	00001e9c 	.word	0x00001e9c

c0d0382c <USBD_ConfigStrDescriptor>:
{
c0d0382c:	200e      	movs	r0, #14
  *length = sizeof(USBD_CONFIGURATION_FS_STRING);
c0d0382e:	8008      	strh	r0, [r1, #0]
  return (uint8_t*)USBD_CONFIGURATION_FS_STRING;
c0d03830:	4801      	ldr	r0, [pc, #4]	; (c0d03838 <USBD_ConfigStrDescriptor+0xc>)
c0d03832:	4478      	add	r0, pc
c0d03834:	4770      	bx	lr
c0d03836:	46c0      	nop			; (mov r8, r8)
c0d03838:	00001e7e 	.word	0x00001e7e

c0d0383c <USBD_InterfaceStrDescriptor>:
{
c0d0383c:	200e      	movs	r0, #14
  *length = sizeof(USBD_INTERFACE_FS_STRING);
c0d0383e:	8008      	strh	r0, [r1, #0]
  return (uint8_t*)USBD_INTERFACE_FS_STRING;
c0d03840:	4801      	ldr	r0, [pc, #4]	; (c0d03848 <USBD_InterfaceStrDescriptor+0xc>)
c0d03842:	4478      	add	r0, pc
c0d03844:	4770      	bx	lr
c0d03846:	46c0      	nop			; (mov r8, r8)
c0d03848:	00001e6e 	.word	0x00001e6e

c0d0384c <USBD_BOSDescriptor>:
};

#endif // HAVE_WEBUSB

static uint8_t *USBD_BOSDescriptor(USBD_SpeedTypeDef speed, uint16_t *length)
{
c0d0384c:	2039      	movs	r0, #57	; 0x39
  UNUSED(speed);
#ifdef HAVE_WEBUSB
  *length = sizeof(C_usb_bos);
c0d0384e:	8008      	strh	r0, [r1, #0]
  return (uint8_t*)C_usb_bos;
c0d03850:	4801      	ldr	r0, [pc, #4]	; (c0d03858 <USBD_BOSDescriptor+0xc>)
c0d03852:	4478      	add	r0, pc
c0d03854:	4770      	bx	lr
c0d03856:	46c0      	nop			; (mov r8, r8)
c0d03858:	00001c19 	.word	0x00001c19

c0d0385c <USBD_CtlError>:
  '4', 0x00, '6', 0x00, '7', 0x00, '6', 0x00, '5', 0x00, '7', 0x00,
  '2', 0x00, '}', 0x00, 0x00, 0x00, 0x00, 0x00 // propertyData, double unicode nul terminated
};

// upon unsupported request, check for webusb request
void USBD_CtlError( USBD_HandleTypeDef *pdev , USBD_SetupReqTypedef *req) {
c0d0385c:	b580      	push	{r7, lr}
    USBD_CtlSendData (pdev, (unsigned char*)C_webusb_url_descriptor, MIN(req->wLength, sizeof(C_webusb_url_descriptor)));
  }
  else 
#endif // WEBUSB_URL_SIZE_B
    // SETUP (LE): 0x80 0x06 0x03 0x77 0x00 0x00 0xXX 0xXX
    if ((req->bmRequest & 0x80) 
c0d0385e:	780a      	ldrb	r2, [r1, #0]
c0d03860:	b252      	sxtb	r2, r2
    && req->bRequest == USB_REQ_GET_DESCRIPTOR 
c0d03862:	2a00      	cmp	r2, #0
c0d03864:	d402      	bmi.n	c0d0386c <USBD_CtlError+0x10>
      && req->bRequest == WINUSB_VENDOR_CODE
      && req->wIndex == MS_OS_20_DESCRIPTOR_INDEX) {
    USBD_CtlSendData(pdev, (unsigned char*)C_winusb_request_descriptor, MIN(req->wLength, sizeof(C_winusb_request_descriptor)));
  }
  else {
    USBD_CtlStall(pdev);
c0d03866:	f7ff fea3 	bl	c0d035b0 <USBD_CtlStall>
  }
}
c0d0386a:	bd80      	pop	{r7, pc}
    && req->bRequest == USB_REQ_GET_DESCRIPTOR 
c0d0386c:	784a      	ldrb	r2, [r1, #1]
    && (req->wValue>>8) == USB_DESC_TYPE_STRING 
c0d0386e:	2a77      	cmp	r2, #119	; 0x77
c0d03870:	d00c      	beq.n	c0d0388c <USBD_CtlError+0x30>
c0d03872:	2a06      	cmp	r2, #6
c0d03874:	d1f7      	bne.n	c0d03866 <USBD_CtlError+0xa>
c0d03876:	884a      	ldrh	r2, [r1, #2]
c0d03878:	4b14      	ldr	r3, [pc, #80]	; (c0d038cc <USBD_CtlError+0x70>)
    && (req->wValue & 0xFF) == 0xEE) {
c0d0387a:	429a      	cmp	r2, r3
c0d0387c:	d1f3      	bne.n	c0d03866 <USBD_CtlError+0xa>
    USBD_CtlSendData(pdev, (unsigned char*)C_winusb_string_descriptor, MIN(req->wLength, sizeof(C_winusb_string_descriptor)));
c0d0387e:	88ca      	ldrh	r2, [r1, #6]
c0d03880:	2a12      	cmp	r2, #18
c0d03882:	d300      	bcc.n	c0d03886 <USBD_CtlError+0x2a>
c0d03884:	2212      	movs	r2, #18
c0d03886:	4912      	ldr	r1, [pc, #72]	; (c0d038d0 <USBD_CtlError+0x74>)
c0d03888:	4479      	add	r1, pc
c0d0388a:	e01c      	b.n	c0d038c6 <USBD_CtlError+0x6a>
    && req->wIndex == WINUSB_GET_COMPATIBLE_ID_FEATURE) {
c0d0388c:	888a      	ldrh	r2, [r1, #4]
  else if ((req->bmRequest & 0x80) 
c0d0388e:	2a04      	cmp	r2, #4
c0d03890:	d106      	bne.n	c0d038a0 <USBD_CtlError+0x44>
    USBD_CtlSendData(pdev, (unsigned char*)C_winusb_wcid, MIN(req->wLength, sizeof(C_winusb_wcid)));
c0d03892:	88ca      	ldrh	r2, [r1, #6]
c0d03894:	2a28      	cmp	r2, #40	; 0x28
c0d03896:	d300      	bcc.n	c0d0389a <USBD_CtlError+0x3e>
c0d03898:	2228      	movs	r2, #40	; 0x28
c0d0389a:	490e      	ldr	r1, [pc, #56]	; (c0d038d4 <USBD_CtlError+0x78>)
c0d0389c:	4479      	add	r1, pc
c0d0389e:	e012      	b.n	c0d038c6 <USBD_CtlError+0x6a>
    && req->wIndex == WINUSB_GET_EXTENDED_PROPERTIES_OS_FEATURE 
c0d038a0:	888a      	ldrh	r2, [r1, #4]
  else if ((req->bmRequest & 0x80) 
c0d038a2:	2a05      	cmp	r2, #5
c0d038a4:	d106      	bne.n	c0d038b4 <USBD_CtlError+0x58>
    USBD_CtlSendData(pdev, (unsigned char*)C_winusb_guid, MIN(req->wLength, sizeof(C_winusb_guid)));
c0d038a6:	88ca      	ldrh	r2, [r1, #6]
c0d038a8:	2a92      	cmp	r2, #146	; 0x92
c0d038aa:	d300      	bcc.n	c0d038ae <USBD_CtlError+0x52>
c0d038ac:	2292      	movs	r2, #146	; 0x92
c0d038ae:	490a      	ldr	r1, [pc, #40]	; (c0d038d8 <USBD_CtlError+0x7c>)
c0d038b0:	4479      	add	r1, pc
c0d038b2:	e008      	b.n	c0d038c6 <USBD_CtlError+0x6a>
      && req->wIndex == MS_OS_20_DESCRIPTOR_INDEX) {
c0d038b4:	888a      	ldrh	r2, [r1, #4]
  else if ((req->bmRequest & 0x80)
c0d038b6:	2a07      	cmp	r2, #7
c0d038b8:	d1d5      	bne.n	c0d03866 <USBD_CtlError+0xa>
    USBD_CtlSendData(pdev, (unsigned char*)C_winusb_request_descriptor, MIN(req->wLength, sizeof(C_winusb_request_descriptor)));
c0d038ba:	88ca      	ldrh	r2, [r1, #6]
c0d038bc:	2ab2      	cmp	r2, #178	; 0xb2
c0d038be:	d300      	bcc.n	c0d038c2 <USBD_CtlError+0x66>
c0d038c0:	22b2      	movs	r2, #178	; 0xb2
c0d038c2:	4906      	ldr	r1, [pc, #24]	; (c0d038dc <USBD_CtlError+0x80>)
c0d038c4:	4479      	add	r1, pc
c0d038c6:	f000 f855 	bl	c0d03974 <USBD_CtlSendData>
}
c0d038ca:	bd80      	pop	{r7, pc}
c0d038cc:	000003ee 	.word	0x000003ee
c0d038d0:	00001c3c 	.word	0x00001c3c
c0d038d4:	00001e2c 	.word	0x00001e2c
c0d038d8:	00001c26 	.word	0x00001c26
c0d038dc:	00001ca4 	.word	0x00001ca4

c0d038e0 <USB_power>:
  // nothing to do ?
  return 0;
}
#endif // HAVE_USB_CLASS_CCID

void USB_power(unsigned char enabled) {
c0d038e0:	b5b0      	push	{r4, r5, r7, lr}
c0d038e2:	4604      	mov	r4, r0
c0d038e4:	2045      	movs	r0, #69	; 0x45
c0d038e6:	0085      	lsls	r5, r0, #2
  memset(&USBD_Device, 0, sizeof(USBD_Device));
c0d038e8:	4815      	ldr	r0, [pc, #84]	; (c0d03940 <USB_power+0x60>)
c0d038ea:	4629      	mov	r1, r5
c0d038ec:	f001 f97c 	bl	c0d04be8 <__aeabi_memclr>

  // init timeouts and other global fields
  memset(G_io_app.usb_ep_xfer_len, 0, sizeof(G_io_app.usb_ep_xfer_len));
  memset(G_io_app.usb_ep_timeouts, 0, sizeof(G_io_app.usb_ep_timeouts));
c0d038f0:	4814      	ldr	r0, [pc, #80]	; (c0d03944 <USB_power+0x64>)
c0d038f2:	300c      	adds	r0, #12
c0d038f4:	2112      	movs	r1, #18
c0d038f6:	f001 f977 	bl	c0d04be8 <__aeabi_memclr>

  if (enabled) {
c0d038fa:	2c00      	cmp	r4, #0
c0d038fc:	d01b      	beq.n	c0d03936 <USB_power+0x56>
    memset(&USBD_Device, 0, sizeof(USBD_Device));
c0d038fe:	4c10      	ldr	r4, [pc, #64]	; (c0d03940 <USB_power+0x60>)
c0d03900:	4620      	mov	r0, r4
c0d03902:	4629      	mov	r1, r5
c0d03904:	f001 f970 	bl	c0d04be8 <__aeabi_memclr>
    /* Init Device Library */
    USBD_Init(&USBD_Device, (USBD_DescriptorsTypeDef*)&HID_Desc, 0);
c0d03908:	490f      	ldr	r1, [pc, #60]	; (c0d03948 <USB_power+0x68>)
c0d0390a:	4479      	add	r1, pc
c0d0390c:	2500      	movs	r5, #0
c0d0390e:	4620      	mov	r0, r4
c0d03910:	462a      	mov	r2, r5
c0d03912:	f7ff fa4d 	bl	c0d02db0 <USBD_Init>
    
    /* Register the HID class */
    USBD_RegisterClassForInterface(HID_INTF,  &USBD_Device, (USBD_ClassTypeDef*)&USBD_HID);
c0d03916:	4a0d      	ldr	r2, [pc, #52]	; (c0d0394c <USB_power+0x6c>)
c0d03918:	447a      	add	r2, pc
c0d0391a:	4628      	mov	r0, r5
c0d0391c:	4621      	mov	r1, r4
c0d0391e:	f7ff fa81 	bl	c0d02e24 <USBD_RegisterClassForInterface>
c0d03922:	2001      	movs	r0, #1
#ifdef HAVE_USB_CLASS_CCID
    USBD_RegisterClassForInterface(CCID_INTF, &USBD_Device, (USBD_ClassTypeDef*)&USBD_CCID);
#endif // HAVE_USB_CLASS_CCID

#ifdef HAVE_WEBUSB
    USBD_RegisterClassForInterface(WEBUSB_INTF, &USBD_Device, (USBD_ClassTypeDef*)&USBD_WEBUSB);
c0d03924:	4a0a      	ldr	r2, [pc, #40]	; (c0d03950 <USB_power+0x70>)
c0d03926:	447a      	add	r2, pc
c0d03928:	4621      	mov	r1, r4
c0d0392a:	f7ff fa7b 	bl	c0d02e24 <USBD_RegisterClassForInterface>
#endif // HAVE_WEBUSB

    /* Start Device Process */
    USBD_Start(&USBD_Device);
c0d0392e:	4620      	mov	r0, r4
c0d03930:	f7ff fa85 	bl	c0d02e3e <USBD_Start>
  }
  else {
    USBD_DeInit(&USBD_Device);
  }
}
c0d03934:	bdb0      	pop	{r4, r5, r7, pc}
    USBD_DeInit(&USBD_Device);
c0d03936:	4802      	ldr	r0, [pc, #8]	; (c0d03940 <USB_power+0x60>)
c0d03938:	f7ff fa56 	bl	c0d02de8 <USBD_DeInit>
}
c0d0393c:	bdb0      	pop	{r4, r5, r7, pc}
c0d0393e:	46c0      	nop			; (mov r8, r8)
c0d03940:	20000cb8 	.word	0x20000cb8
c0d03944:	20000a30 	.word	0x20000a30
c0d03948:	00001b9a 	.word	0x00001b9a
c0d0394c:	00001d04 	.word	0x00001d04
c0d03950:	00001d2e 	.word	0x00001d2e

c0d03954 <USBD_GetCfgDesc_impl>:
{
c0d03954:	2140      	movs	r1, #64	; 0x40
  *length = sizeof (USBD_CfgDesc);
c0d03956:	8001      	strh	r1, [r0, #0]
  return (uint8_t*)USBD_CfgDesc;
c0d03958:	4801      	ldr	r0, [pc, #4]	; (c0d03960 <USBD_GetCfgDesc_impl+0xc>)
c0d0395a:	4478      	add	r0, pc
c0d0395c:	4770      	bx	lr
c0d0395e:	46c0      	nop			; (mov r8, r8)
c0d03960:	00001d96 	.word	0x00001d96

c0d03964 <USBD_GetDeviceQualifierDesc_impl>:
{
c0d03964:	210a      	movs	r1, #10
  *length = sizeof (USBD_DeviceQualifierDesc);
c0d03966:	8001      	strh	r1, [r0, #0]
  return (uint8_t*)USBD_DeviceQualifierDesc;
c0d03968:	4801      	ldr	r0, [pc, #4]	; (c0d03970 <USBD_GetDeviceQualifierDesc_impl+0xc>)
c0d0396a:	4478      	add	r0, pc
c0d0396c:	4770      	bx	lr
c0d0396e:	46c0      	nop			; (mov r8, r8)
c0d03970:	00001dc6 	.word	0x00001dc6

c0d03974 <USBD_CtlSendData>:
* @retval status
*/
USBD_StatusTypeDef  USBD_CtlSendData (USBD_HandleTypeDef  *pdev, 
                               uint8_t *pbuf,
                               uint16_t len)
{
c0d03974:	b5b0      	push	{r4, r5, r7, lr}
c0d03976:	460c      	mov	r4, r1
c0d03978:	21d4      	movs	r1, #212	; 0xd4
c0d0397a:	2302      	movs	r3, #2
  /* Set EP0 State */
  pdev->ep0_state          = USBD_EP0_DATA_IN;                                      
c0d0397c:	5043      	str	r3, [r0, r1]
  pdev->ep_in[0].total_length = len;
c0d0397e:	6182      	str	r2, [r0, #24]
  pdev->ep_in[0].rem_length   = len;
c0d03980:	61c2      	str	r2, [r0, #28]
c0d03982:	4601      	mov	r1, r0
c0d03984:	31d4      	adds	r1, #212	; 0xd4
  // store the continuation data if needed
  pdev->pData = pbuf;
c0d03986:	63cc      	str	r4, [r1, #60]	; 0x3c
 /* Start the transfer */
  USBD_LL_Transmit (pdev, 0x00, pbuf, MIN(len, pdev->ep_in[0].maxpacket));  
c0d03988:	6a01      	ldr	r1, [r0, #32]
c0d0398a:	4291      	cmp	r1, r2
c0d0398c:	d800      	bhi.n	c0d03990 <USBD_CtlSendData+0x1c>
c0d0398e:	460a      	mov	r2, r1
c0d03990:	b293      	uxth	r3, r2
c0d03992:	2500      	movs	r5, #0
c0d03994:	4629      	mov	r1, r5
c0d03996:	4622      	mov	r2, r4
c0d03998:	f7ff f9de 	bl	c0d02d58 <USBD_LL_Transmit>
  
  return USBD_OK;
c0d0399c:	4628      	mov	r0, r5
c0d0399e:	bdb0      	pop	{r4, r5, r7, pc}

c0d039a0 <USBD_CtlContinueSendData>:
* @retval status
*/
USBD_StatusTypeDef  USBD_CtlContinueSendData (USBD_HandleTypeDef  *pdev, 
                                       uint8_t *pbuf,
                                       uint16_t len)
{
c0d039a0:	b5b0      	push	{r4, r5, r7, lr}
c0d039a2:	460c      	mov	r4, r1
 /* Start the next transfer */
  USBD_LL_Transmit (pdev, 0x00, pbuf, MIN(len, pdev->ep_in[0].maxpacket));   
c0d039a4:	6a01      	ldr	r1, [r0, #32]
c0d039a6:	4291      	cmp	r1, r2
c0d039a8:	d800      	bhi.n	c0d039ac <USBD_CtlContinueSendData+0xc>
c0d039aa:	460a      	mov	r2, r1
c0d039ac:	b293      	uxth	r3, r2
c0d039ae:	2500      	movs	r5, #0
c0d039b0:	4629      	mov	r1, r5
c0d039b2:	4622      	mov	r2, r4
c0d039b4:	f7ff f9d0 	bl	c0d02d58 <USBD_LL_Transmit>
  return USBD_OK;
c0d039b8:	4628      	mov	r0, r5
c0d039ba:	bdb0      	pop	{r4, r5, r7, pc}

c0d039bc <USBD_CtlContinueRx>:
* @retval status
*/
USBD_StatusTypeDef  USBD_CtlContinueRx (USBD_HandleTypeDef  *pdev, 
                                          uint8_t *pbuf,                                          
                                          uint16_t len)
{
c0d039bc:	b510      	push	{r4, lr}
c0d039be:	2400      	movs	r4, #0
  UNUSED(pbuf);
  USBD_LL_PrepareReceive (pdev,
c0d039c0:	4621      	mov	r1, r4
c0d039c2:	f7ff f9e2 	bl	c0d02d8a <USBD_LL_PrepareReceive>
                          0,                                            
                          len);
  return USBD_OK;
c0d039c6:	4620      	mov	r0, r4
c0d039c8:	bd10      	pop	{r4, pc}

c0d039ca <USBD_CtlSendStatus>:
*         send zero lzngth packet on the ctl pipe
* @param  pdev: device instance
* @retval status
*/
USBD_StatusTypeDef  USBD_CtlSendStatus (USBD_HandleTypeDef  *pdev)
{
c0d039ca:	b510      	push	{r4, lr}
c0d039cc:	21d4      	movs	r1, #212	; 0xd4
c0d039ce:	2204      	movs	r2, #4

  /* Set EP0 State */
  pdev->ep0_state = USBD_EP0_STATUS_IN;
c0d039d0:	5042      	str	r2, [r0, r1]
c0d039d2:	2400      	movs	r4, #0
  
 /* Start the transfer */
  USBD_LL_Transmit (pdev, 0x00, NULL, 0);   
c0d039d4:	4621      	mov	r1, r4
c0d039d6:	4622      	mov	r2, r4
c0d039d8:	4623      	mov	r3, r4
c0d039da:	f7ff f9bd 	bl	c0d02d58 <USBD_LL_Transmit>
  
  return USBD_OK;
c0d039de:	4620      	mov	r0, r4
c0d039e0:	bd10      	pop	{r4, pc}

c0d039e2 <USBD_CtlReceiveStatus>:
*         receive zero lzngth packet on the ctl pipe
* @param  pdev: device instance
* @retval status
*/
USBD_StatusTypeDef  USBD_CtlReceiveStatus (USBD_HandleTypeDef  *pdev)
{
c0d039e2:	b510      	push	{r4, lr}
c0d039e4:	21d4      	movs	r1, #212	; 0xd4
c0d039e6:	2205      	movs	r2, #5
  /* Set EP0 State */
  pdev->ep0_state = USBD_EP0_STATUS_OUT; 
c0d039e8:	5042      	str	r2, [r0, r1]
c0d039ea:	2400      	movs	r4, #0
  
 /* Start the transfer */  
  USBD_LL_PrepareReceive ( pdev,
c0d039ec:	4621      	mov	r1, r4
c0d039ee:	4622      	mov	r2, r4
c0d039f0:	f7ff f9cb 	bl	c0d02d8a <USBD_LL_PrepareReceive>
                    0,
                    0);  

  return USBD_OK;
c0d039f4:	4620      	mov	r0, r4
c0d039f6:	bd10      	pop	{r4, pc}

c0d039f8 <get_public_key>:
#include <stdbool.h>
#include <stdlib.h>
#include "utils.h"
#include "menu.h"

void get_public_key(uint8_t *publicKeyArray, const uint32_t *derivationPath, size_t pathLength) {
c0d039f8:	b5b0      	push	{r4, r5, r7, lr}
c0d039fa:	b0aa      	sub	sp, #168	; 0xa8
c0d039fc:	4604      	mov	r4, r0
c0d039fe:	a820      	add	r0, sp, #128	; 0x80
    cx_ecfp_private_key_t privateKey;
    cx_ecfp_public_key_t publicKey;

    get_private_key(&privateKey, derivationPath, pathLength);
c0d03a00:	f000 f847 	bl	c0d03a92 <get_private_key>
c0d03a04:	ad01      	add	r5, sp, #4
    BEGIN_TRY {
        TRY {
c0d03a06:	4628      	mov	r0, r5
c0d03a08:	f001 fa04 	bl	c0d04e14 <setjmp>
c0d03a0c:	85a8      	strh	r0, [r5, #44]	; 0x2c
c0d03a0e:	b285      	uxth	r5, r0
c0d03a10:	2d00      	cmp	r5, #0
c0d03a12:	d131      	bne.n	c0d03a78 <get_public_key+0x80>
c0d03a14:	a801      	add	r0, sp, #4
c0d03a16:	f7fe ff87 	bl	c0d02928 <try_context_set>
c0d03a1a:	900b      	str	r0, [sp, #44]	; 0x2c
c0d03a1c:	2071      	movs	r0, #113	; 0x71
c0d03a1e:	a90d      	add	r1, sp, #52	; 0x34
c0d03a20:	aa20      	add	r2, sp, #128	; 0x80
c0d03a22:	2301      	movs	r3, #1
 * @throws                 CX_EC_INVALID_POINT
 * @throws                 CX_EC_INFINITE_POINT
 */
static inline int cx_ecfp_generate_pair ( cx_curve_t curve, cx_ecfp_public_key_t * pubkey, cx_ecfp_private_key_t * privkey, int keepprivate )
{
  CX_THROW(cx_ecfp_generate_pair_no_throw(curve, pubkey, privkey, keepprivate));
c0d03a24:	f7fc fbee 	bl	c0d00204 <cx_ecfp_generate_pair_no_throw>
c0d03a28:	2800      	cmp	r0, #0
c0d03a2a:	d123      	bne.n	c0d03a74 <get_public_key+0x7c>
        }
        CATCH_OTHER(e) {
            MEMCLEAR(privateKey);
            THROW(e);
        }
        FINALLY {
c0d03a2c:	f7fe ff70 	bl	c0d02910 <try_context_get>
c0d03a30:	a901      	add	r1, sp, #4
c0d03a32:	4288      	cmp	r0, r1
c0d03a34:	d102      	bne.n	c0d03a3c <get_public_key+0x44>
c0d03a36:	980b      	ldr	r0, [sp, #44]	; 0x2c
c0d03a38:	f7fe ff76 	bl	c0d02928 <try_context_set>
c0d03a3c:	a820      	add	r0, sp, #128	; 0x80
c0d03a3e:	2528      	movs	r5, #40	; 0x28
            MEMCLEAR(privateKey);
c0d03a40:	4629      	mov	r1, r5
c0d03a42:	f001 f8e7 	bl	c0d04c14 <explicit_bzero>
c0d03a46:	a801      	add	r0, sp, #4
        }
    }
    END_TRY;
c0d03a48:	8d80      	ldrh	r0, [r0, #44]	; 0x2c
c0d03a4a:	2800      	cmp	r0, #0
c0d03a4c:	d112      	bne.n	c0d03a74 <get_public_key+0x7c>
c0d03a4e:	a80d      	add	r0, sp, #52	; 0x34

    for (int i = 0; i < PUBKEY_LENGTH; i++) {
c0d03a50:	3048      	adds	r0, #72	; 0x48
c0d03a52:	2100      	movs	r1, #0
        publicKeyArray[i] = publicKey.W[PUBKEY_LENGTH + PRIVATEKEY_LENGTH - i];
c0d03a54:	7802      	ldrb	r2, [r0, #0]
c0d03a56:	5462      	strb	r2, [r4, r1]
    for (int i = 0; i < PUBKEY_LENGTH; i++) {
c0d03a58:	1e40      	subs	r0, r0, #1
c0d03a5a:	1c49      	adds	r1, r1, #1
c0d03a5c:	2920      	cmp	r1, #32
c0d03a5e:	d1f9      	bne.n	c0d03a54 <get_public_key+0x5c>
c0d03a60:	a80d      	add	r0, sp, #52	; 0x34
    }
    if ((publicKey.W[PUBKEY_LENGTH] & 1) != 0) {
c0d03a62:	5d40      	ldrb	r0, [r0, r5]
c0d03a64:	07c0      	lsls	r0, r0, #31
c0d03a66:	d003      	beq.n	c0d03a70 <get_public_key+0x78>
        publicKeyArray[PUBKEY_LENGTH - 1] |= 0x80;
c0d03a68:	7fe0      	ldrb	r0, [r4, #31]
c0d03a6a:	2180      	movs	r1, #128	; 0x80
c0d03a6c:	4301      	orrs	r1, r0
c0d03a6e:	77e1      	strb	r1, [r4, #31]
    }
}
c0d03a70:	b02a      	add	sp, #168	; 0xa8
c0d03a72:	bdb0      	pop	{r4, r5, r7, pc}
c0d03a74:	f7fd f9f8 	bl	c0d00e68 <os_longjmp>
c0d03a78:	a801      	add	r0, sp, #4
c0d03a7a:	2100      	movs	r1, #0
        CATCH_OTHER(e) {
c0d03a7c:	8581      	strh	r1, [r0, #44]	; 0x2c
c0d03a7e:	980b      	ldr	r0, [sp, #44]	; 0x2c
c0d03a80:	f7fe ff52 	bl	c0d02928 <try_context_set>
c0d03a84:	a820      	add	r0, sp, #128	; 0x80
c0d03a86:	2128      	movs	r1, #40	; 0x28
            MEMCLEAR(privateKey);
c0d03a88:	f001 f8c4 	bl	c0d04c14 <explicit_bzero>
            THROW(e);
c0d03a8c:	4628      	mov	r0, r5
c0d03a8e:	f7fd f9eb 	bl	c0d00e68 <os_longjmp>

c0d03a92 <get_private_key>:
    return ((buffer[0] << 24) | (buffer[1] << 16) | (buffer[2] << 8) | (buffer[3]));
}

void get_private_key(cx_ecfp_private_key_t *privateKey,
                     const uint32_t *derivationPath,
                     size_t pathLength) {
c0d03a92:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d03a94:	b099      	sub	sp, #100	; 0x64
c0d03a96:	4615      	mov	r5, r2
c0d03a98:	460e      	mov	r6, r1
c0d03a9a:	9004      	str	r0, [sp, #16]
c0d03a9c:	af05      	add	r7, sp, #20
    uint8_t privateKeyData[PRIVATEKEY_LENGTH];
    BEGIN_TRY {
        TRY {
c0d03a9e:	4638      	mov	r0, r7
c0d03aa0:	f001 f9b8 	bl	c0d04e14 <setjmp>
c0d03aa4:	85b8      	strh	r0, [r7, #44]	; 0x2c
c0d03aa6:	b287      	uxth	r7, r0
c0d03aa8:	2f00      	cmp	r7, #0
c0d03aaa:	d12c      	bne.n	c0d03b06 <get_private_key+0x74>
c0d03aac:	a805      	add	r0, sp, #20
c0d03aae:	f7fe ff3b 	bl	c0d02928 <try_context_set>
c0d03ab2:	900f      	str	r0, [sp, #60]	; 0x3c
c0d03ab4:	2000      	movs	r0, #0
            os_perso_derive_node_bip32_seed_key(HDW_ED25519_SLIP10,
c0d03ab6:	9003      	str	r0, [sp, #12]
c0d03ab8:	9002      	str	r0, [sp, #8]
c0d03aba:	9001      	str	r0, [sp, #4]
c0d03abc:	af11      	add	r7, sp, #68	; 0x44
c0d03abe:	9700      	str	r7, [sp, #0]
c0d03ac0:	2001      	movs	r0, #1
c0d03ac2:	2471      	movs	r4, #113	; 0x71
c0d03ac4:	4621      	mov	r1, r4
c0d03ac6:	4632      	mov	r2, r6
c0d03ac8:	462b      	mov	r3, r5
c0d03aca:	f7fe fe99 	bl	c0d02800 <os_perso_derive_node_with_seed_key>
c0d03ace:	2220      	movs	r2, #32
  CX_THROW(cx_ecfp_init_private_key_no_throw(curve, rawkey, key_len, pvkey));
c0d03ad0:	4620      	mov	r0, r4
c0d03ad2:	4639      	mov	r1, r7
c0d03ad4:	9b04      	ldr	r3, [sp, #16]
c0d03ad6:	f7fc fb9b 	bl	c0d00210 <cx_ecfp_init_private_key_no_throw>
c0d03ada:	2800      	cmp	r0, #0
c0d03adc:	d111      	bne.n	c0d03b02 <get_private_key+0x70>
        }
        CATCH_OTHER(e) {
            MEMCLEAR(privateKeyData);
            THROW(e);
        }
        FINALLY {
c0d03ade:	f7fe ff17 	bl	c0d02910 <try_context_get>
c0d03ae2:	a905      	add	r1, sp, #20
c0d03ae4:	4288      	cmp	r0, r1
c0d03ae6:	d102      	bne.n	c0d03aee <get_private_key+0x5c>
c0d03ae8:	980f      	ldr	r0, [sp, #60]	; 0x3c
c0d03aea:	f7fe ff1d 	bl	c0d02928 <try_context_set>
c0d03aee:	a811      	add	r0, sp, #68	; 0x44
c0d03af0:	2120      	movs	r1, #32
            MEMCLEAR(privateKeyData);
c0d03af2:	f001 f88f 	bl	c0d04c14 <explicit_bzero>
c0d03af6:	a805      	add	r0, sp, #20
        }
    }
    END_TRY;
c0d03af8:	8d80      	ldrh	r0, [r0, #44]	; 0x2c
c0d03afa:	2800      	cmp	r0, #0
c0d03afc:	d101      	bne.n	c0d03b02 <get_private_key+0x70>
}
c0d03afe:	b019      	add	sp, #100	; 0x64
c0d03b00:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d03b02:	f7fd f9b1 	bl	c0d00e68 <os_longjmp>
c0d03b06:	a805      	add	r0, sp, #20
c0d03b08:	2100      	movs	r1, #0
        CATCH_OTHER(e) {
c0d03b0a:	8581      	strh	r1, [r0, #44]	; 0x2c
c0d03b0c:	980f      	ldr	r0, [sp, #60]	; 0x3c
c0d03b0e:	f7fe ff0b 	bl	c0d02928 <try_context_set>
c0d03b12:	a811      	add	r0, sp, #68	; 0x44
c0d03b14:	2120      	movs	r1, #32
            MEMCLEAR(privateKeyData);
c0d03b16:	f001 f87d 	bl	c0d04c14 <explicit_bzero>
            THROW(e);
c0d03b1a:	4638      	mov	r0, r7
c0d03b1c:	f7fd f9a4 	bl	c0d00e68 <os_longjmp>

c0d03b20 <get_private_key_with_seed>:

void get_private_key_with_seed(cx_ecfp_private_key_t *privateKey,
                               const uint32_t *derivationPath,
                               uint8_t pathLength) {
c0d03b20:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d03b22:	b099      	sub	sp, #100	; 0x64
c0d03b24:	4617      	mov	r7, r2
c0d03b26:	460d      	mov	r5, r1
c0d03b28:	9004      	str	r0, [sp, #16]
c0d03b2a:	ae05      	add	r6, sp, #20
    uint8_t privateKeyData[PRIVATEKEY_LENGTH];
    BEGIN_TRY {
        TRY {
c0d03b2c:	4630      	mov	r0, r6
c0d03b2e:	f001 f971 	bl	c0d04e14 <setjmp>
c0d03b32:	85b0      	strh	r0, [r6, #44]	; 0x2c
c0d03b34:	b286      	uxth	r6, r0
c0d03b36:	2e00      	cmp	r6, #0
c0d03b38:	d130      	bne.n	c0d03b9c <get_private_key_with_seed+0x7c>
c0d03b3a:	463e      	mov	r6, r7
c0d03b3c:	a805      	add	r0, sp, #20
c0d03b3e:	f7fe fef3 	bl	c0d02928 <try_context_set>
c0d03b42:	900f      	str	r0, [sp, #60]	; 0x3c
c0d03b44:	200c      	movs	r0, #12
            os_perso_derive_node_bip32_seed_key(HDW_ED25519_SLIP10,
c0d03b46:	9003      	str	r0, [sp, #12]
c0d03b48:	481b      	ldr	r0, [pc, #108]	; (c0d03bb8 <get_private_key_with_seed+0x98>)
c0d03b4a:	4478      	add	r0, pc
c0d03b4c:	9002      	str	r0, [sp, #8]
c0d03b4e:	2000      	movs	r0, #0
c0d03b50:	9001      	str	r0, [sp, #4]
c0d03b52:	af11      	add	r7, sp, #68	; 0x44
c0d03b54:	9700      	str	r7, [sp, #0]
c0d03b56:	2001      	movs	r0, #1
c0d03b58:	2471      	movs	r4, #113	; 0x71
c0d03b5a:	4621      	mov	r1, r4
c0d03b5c:	462a      	mov	r2, r5
c0d03b5e:	4633      	mov	r3, r6
c0d03b60:	f7fe fe4e 	bl	c0d02800 <os_perso_derive_node_with_seed_key>
c0d03b64:	2220      	movs	r2, #32
c0d03b66:	4620      	mov	r0, r4
c0d03b68:	4639      	mov	r1, r7
c0d03b6a:	9b04      	ldr	r3, [sp, #16]
c0d03b6c:	f7fc fb50 	bl	c0d00210 <cx_ecfp_init_private_key_no_throw>
c0d03b70:	2800      	cmp	r0, #0
c0d03b72:	d111      	bne.n	c0d03b98 <get_private_key_with_seed+0x78>
        }
        CATCH_OTHER(e) {
            MEMCLEAR(privateKeyData);
            THROW(e);
        }
        FINALLY {
c0d03b74:	f7fe fecc 	bl	c0d02910 <try_context_get>
c0d03b78:	a905      	add	r1, sp, #20
c0d03b7a:	4288      	cmp	r0, r1
c0d03b7c:	d102      	bne.n	c0d03b84 <get_private_key_with_seed+0x64>
c0d03b7e:	980f      	ldr	r0, [sp, #60]	; 0x3c
c0d03b80:	f7fe fed2 	bl	c0d02928 <try_context_set>
c0d03b84:	a811      	add	r0, sp, #68	; 0x44
c0d03b86:	2120      	movs	r1, #32
            MEMCLEAR(privateKeyData);
c0d03b88:	f001 f844 	bl	c0d04c14 <explicit_bzero>
c0d03b8c:	a805      	add	r0, sp, #20
        }
    }
    END_TRY;
c0d03b8e:	8d80      	ldrh	r0, [r0, #44]	; 0x2c
c0d03b90:	2800      	cmp	r0, #0
c0d03b92:	d101      	bne.n	c0d03b98 <get_private_key_with_seed+0x78>
}
c0d03b94:	b019      	add	sp, #100	; 0x64
c0d03b96:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d03b98:	f7fd f966 	bl	c0d00e68 <os_longjmp>
c0d03b9c:	a805      	add	r0, sp, #20
c0d03b9e:	2100      	movs	r1, #0
        CATCH_OTHER(e) {
c0d03ba0:	8581      	strh	r1, [r0, #44]	; 0x2c
c0d03ba2:	980f      	ldr	r0, [sp, #60]	; 0x3c
c0d03ba4:	f7fe fec0 	bl	c0d02928 <try_context_set>
c0d03ba8:	a811      	add	r0, sp, #68	; 0x44
c0d03baa:	2120      	movs	r1, #32
            MEMCLEAR(privateKeyData);
c0d03bac:	f001 f832 	bl	c0d04c14 <explicit_bzero>
            THROW(e);
c0d03bb0:	4630      	mov	r0, r6
c0d03bb2:	f7fd f959 	bl	c0d00e68 <os_longjmp>
c0d03bb6:	46c0      	nop			; (mov r8, r8)
c0d03bb8:	00001bf0 	.word	0x00001bf0

c0d03bbc <read_derivation_path>:

int read_derivation_path(const uint8_t *data_buffer,
                         size_t data_size,
                         uint32_t *derivation_path,
                         uint32_t *derivation_path_length) {
c0d03bbc:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d03bbe:	4604      	mov	r4, r0
c0d03bc0:	4814      	ldr	r0, [pc, #80]	; (c0d03c14 <read_derivation_path+0x58>)
    if (!data_buffer || !derivation_path || !derivation_path_length) {
c0d03bc2:	2c00      	cmp	r4, #0
c0d03bc4:	d023      	beq.n	c0d03c0e <read_derivation_path+0x52>
c0d03bc6:	2a00      	cmp	r2, #0
c0d03bc8:	d021      	beq.n	c0d03c0e <read_derivation_path+0x52>
c0d03bca:	2b00      	cmp	r3, #0
c0d03bcc:	d01f      	beq.n	c0d03c0e <read_derivation_path+0x52>
c0d03bce:	20d5      	movs	r0, #213	; 0xd5
c0d03bd0:	01c0      	lsls	r0, r0, #7
c0d03bd2:	1cc6      	adds	r6, r0, #3
        return ApduReplySdkInvalidParameter;
    }
    if (!data_size) {
c0d03bd4:	2900      	cmp	r1, #0
c0d03bd6:	d01b      	beq.n	c0d03c10 <read_derivation_path+0x54>
        return ApduReplyAelfInvalidMessageSize;
    }
    const size_t len = data_buffer[0];
c0d03bd8:	7825      	ldrb	r5, [r4, #0]
    data_buffer += 1;
    if (len < 1 || len > MAX_BIP32_PATH_LENGTH) {
c0d03bda:	1e6f      	subs	r7, r5, #1
c0d03bdc:	2f04      	cmp	r7, #4
c0d03bde:	d816      	bhi.n	c0d03c0e <read_derivation_path+0x52>
        return ApduReplyAelfInvalidMessage;
    }
    if (1 + 4 * len > data_size) {
c0d03be0:	00a8      	lsls	r0, r5, #2
c0d03be2:	1c40      	adds	r0, r0, #1
c0d03be4:	4288      	cmp	r0, r1
c0d03be6:	4630      	mov	r0, r6
c0d03be8:	d811      	bhi.n	c0d03c0e <read_derivation_path+0x52>
    data_buffer += 1;
c0d03bea:	1c60      	adds	r0, r4, #1
c0d03bec:	4629      	mov	r1, r5
        return ApduReplyAelfInvalidMessageSize;
    }

    for (size_t i = 0; i < len; i++) {
        derivation_path[i] = ((data_buffer[0] << 24u) | (data_buffer[1] << 16u) |
c0d03bee:	7804      	ldrb	r4, [r0, #0]
c0d03bf0:	0624      	lsls	r4, r4, #24
c0d03bf2:	7846      	ldrb	r6, [r0, #1]
c0d03bf4:	0436      	lsls	r6, r6, #16
c0d03bf6:	1934      	adds	r4, r6, r4
                              (data_buffer[2] << 8u) | (data_buffer[3]));
c0d03bf8:	7886      	ldrb	r6, [r0, #2]
c0d03bfa:	0236      	lsls	r6, r6, #8
        derivation_path[i] = ((data_buffer[0] << 24u) | (data_buffer[1] << 16u) |
c0d03bfc:	19a4      	adds	r4, r4, r6
                              (data_buffer[2] << 8u) | (data_buffer[3]));
c0d03bfe:	78c6      	ldrb	r6, [r0, #3]
c0d03c00:	19a4      	adds	r4, r4, r6
        derivation_path[i] = ((data_buffer[0] << 24u) | (data_buffer[1] << 16u) |
c0d03c02:	c210      	stmia	r2!, {r4}
    for (size_t i = 0; i < len; i++) {
c0d03c04:	1d00      	adds	r0, r0, #4
c0d03c06:	1e49      	subs	r1, r1, #1
c0d03c08:	d1f1      	bne.n	c0d03bee <read_derivation_path+0x32>
        data_buffer += 4;
    }

    *derivation_path_length = len;
c0d03c0a:	601d      	str	r5, [r3, #0]
c0d03c0c:	2000      	movs	r0, #0

    return 0;
}
c0d03c0e:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d03c10:	4630      	mov	r0, r6
c0d03c12:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d03c14:	00006802 	.word	0x00006802

c0d03c18 <sendResponse>:

void sendResponse(uint8_t tx, bool approve) {
c0d03c18:	b510      	push	{r4, lr}
    G_io_apdu_buffer[tx++] = approve ? 0x90 : 0x69;
    G_io_apdu_buffer[tx++] = approve ? 0x00 : 0x85;
c0d03c1a:	2900      	cmp	r1, #0
c0d03c1c:	d102      	bne.n	c0d03c24 <sendResponse+0xc>
c0d03c1e:	227a      	movs	r2, #122	; 0x7a
c0d03c20:	43d3      	mvns	r3, r2
c0d03c22:	e000      	b.n	c0d03c26 <sendResponse+0xe>
c0d03c24:	2300      	movs	r3, #0
    G_io_apdu_buffer[tx++] = approve ? 0x90 : 0x69;
c0d03c26:	1c42      	adds	r2, r0, #1
    G_io_apdu_buffer[tx++] = approve ? 0x00 : 0x85;
c0d03c28:	b2d4      	uxtb	r4, r2
    G_io_apdu_buffer[tx++] = approve ? 0x90 : 0x69;
c0d03c2a:	4a08      	ldr	r2, [pc, #32]	; (c0d03c4c <sendResponse+0x34>)
    G_io_apdu_buffer[tx++] = approve ? 0x00 : 0x85;
c0d03c2c:	5513      	strb	r3, [r2, r4]
    G_io_apdu_buffer[tx++] = approve ? 0x90 : 0x69;
c0d03c2e:	2900      	cmp	r1, #0
c0d03c30:	d101      	bne.n	c0d03c36 <sendResponse+0x1e>
c0d03c32:	2169      	movs	r1, #105	; 0x69
c0d03c34:	e001      	b.n	c0d03c3a <sendResponse+0x22>
c0d03c36:	216f      	movs	r1, #111	; 0x6f
c0d03c38:	43c9      	mvns	r1, r1
c0d03c3a:	5411      	strb	r1, [r2, r0]
    G_io_apdu_buffer[tx++] = approve ? 0x00 : 0x85;
c0d03c3c:	1c80      	adds	r0, r0, #2
    // Send back the response, do not restart the event loop
    io_exchange(CHANNEL_APDU | IO_RETURN_AFTER_TX, tx);
c0d03c3e:	b2c1      	uxtb	r1, r0
c0d03c40:	2020      	movs	r0, #32
c0d03c42:	f7fd fb35 	bl	c0d012b0 <io_exchange>
    // Display back the original UX
    ui_idle();
c0d03c46:	f7fd f8c7 	bl	c0d00dd8 <ui_idle>
}
c0d03c4a:	bd10      	pop	{r4, pc}
c0d03c4c:	2000092c 	.word	0x2000092c

c0d03c50 <ux_flow_is_first>:
	}
	return 1;
}

// to hide the left tick or not
unsigned int ux_flow_is_first(void) {
c0d03c50:	b510      	push	{r4, lr}
  // no previous ?
  unsigned int top_stack_slot = G_ux.stack_count - 1;
c0d03c52:	4911      	ldr	r1, [pc, #68]	; (c0d03c98 <ux_flow_is_first+0x48>)
c0d03c54:	780a      	ldrb	r2, [r1, #0]
c0d03c56:	2001      	movs	r0, #1
		|| G_ux.flow_stack[top_stack_slot].length == 0) {
c0d03c58:	2a01      	cmp	r2, #1
c0d03c5a:	d81b      	bhi.n	c0d03c94 <ux_flow_is_first+0x44>
	unsigned int top_stack_slot = G_ux.stack_count - 1;
c0d03c5c:	1e52      	subs	r2, r2, #1
c0d03c5e:	230c      	movs	r3, #12
		|| G_ux.flow_stack[top_stack_slot].length == 0) {
c0d03c60:	4353      	muls	r3, r2
c0d03c62:	18cb      	adds	r3, r1, r3
c0d03c64:	8b9a      	ldrh	r2, [r3, #28]
  if (!ux_flow_check_valid() || G_ux.flow_stack[top_stack_slot].steps == NULL ||
c0d03c66:	2a00      	cmp	r2, #0
c0d03c68:	d014      	beq.n	c0d03c94 <ux_flow_is_first+0x44>
c0d03c6a:	6959      	ldr	r1, [r3, #20]
c0d03c6c:	2900      	cmp	r1, #0
c0d03c6e:	d011      	beq.n	c0d03c94 <ux_flow_is_first+0x44>
      (G_ux.flow_stack[top_stack_slot].index == 0 &&
c0d03c70:	8b1b      	ldrh	r3, [r3, #24]
c0d03c72:	2b00      	cmp	r3, #0
c0d03c74:	d105      	bne.n	c0d03c82 <ux_flow_is_first+0x32>
       G_ux.flow_stack[top_stack_slot].steps[G_ux.flow_stack[top_stack_slot].length - 1] != FLOW_LOOP)) {
c0d03c76:	0094      	lsls	r4, r2, #2
c0d03c78:	1864      	adds	r4, r4, r1
c0d03c7a:	1f24      	subs	r4, r4, #4
c0d03c7c:	6824      	ldr	r4, [r4, #0]
  if (!ux_flow_check_valid() || G_ux.flow_stack[top_stack_slot].steps == NULL ||
c0d03c7e:	1ce4      	adds	r4, r4, #3
c0d03c80:	d108      	bne.n	c0d03c94 <ux_flow_is_first+0x44>
    return 1;
  }

  // previous is a flow barrier ?
  if (G_ux.flow_stack[top_stack_slot].length > 0 &&
c0d03c82:	4293      	cmp	r3, r2
c0d03c84:	d205      	bcs.n	c0d03c92 <ux_flow_is_first+0x42>
      G_ux.flow_stack[top_stack_slot].index < G_ux.flow_stack[top_stack_slot].length &&
      G_ux.flow_stack[top_stack_slot].steps[G_ux.flow_stack[top_stack_slot].index - 1] == FLOW_BARRIER) {
c0d03c86:	009a      	lsls	r2, r3, #2
c0d03c88:	1851      	adds	r1, r2, r1
c0d03c8a:	1f09      	subs	r1, r1, #4
c0d03c8c:	6809      	ldr	r1, [r1, #0]
  if (G_ux.flow_stack[top_stack_slot].length > 0 &&
c0d03c8e:	1c89      	adds	r1, r1, #2
c0d03c90:	d000      	beq.n	c0d03c94 <ux_flow_is_first+0x44>
c0d03c92:	2000      	movs	r0, #0
    return 1;
  }

  // not the first, for sure
  return 0;
}
c0d03c94:	bd10      	pop	{r4, pc}
c0d03c96:	46c0      	nop			; (mov r8, r8)
c0d03c98:	20000250 	.word	0x20000250

c0d03c9c <ux_flow_is_last>:

unsigned int ux_flow_is_last(void){
c0d03c9c:	b510      	push	{r4, lr}
	// last ?
  	unsigned int top_stack_slot = G_ux.stack_count - 1;
c0d03c9e:	490e      	ldr	r1, [pc, #56]	; (c0d03cd8 <ux_flow_is_last+0x3c>)
c0d03ca0:	780a      	ldrb	r2, [r1, #0]
c0d03ca2:	2001      	movs	r0, #1
		|| G_ux.flow_stack[top_stack_slot].length == 0) {
c0d03ca4:	2a01      	cmp	r2, #1
c0d03ca6:	d816      	bhi.n	c0d03cd6 <ux_flow_is_last+0x3a>
	unsigned int top_stack_slot = G_ux.stack_count - 1;
c0d03ca8:	1e52      	subs	r2, r2, #1
c0d03caa:	230c      	movs	r3, #12
		|| G_ux.flow_stack[top_stack_slot].length == 0) {
c0d03cac:	4353      	muls	r3, r2
c0d03cae:	18cb      	adds	r3, r1, r3
c0d03cb0:	8b9a      	ldrh	r2, [r3, #28]

	if (!ux_flow_check_valid()
		|| G_ux.flow_stack[top_stack_slot].steps == NULL
c0d03cb2:	2a00      	cmp	r2, #0
c0d03cb4:	d00f      	beq.n	c0d03cd6 <ux_flow_is_last+0x3a>
c0d03cb6:	6959      	ldr	r1, [r3, #20]
		|| G_ux.flow_stack[top_stack_slot].length == 0
c0d03cb8:	2900      	cmp	r1, #0
c0d03cba:	d00c      	beq.n	c0d03cd6 <ux_flow_is_last+0x3a>
		|| G_ux.flow_stack[top_stack_slot].index >= G_ux.flow_stack[top_stack_slot].length -1) {
c0d03cbc:	8b1b      	ldrh	r3, [r3, #24]
c0d03cbe:	1e54      	subs	r4, r2, #1
	if (!ux_flow_check_valid()
c0d03cc0:	429c      	cmp	r4, r3
c0d03cc2:	dd08      	ble.n	c0d03cd6 <ux_flow_is_last+0x3a>
		return 1;
	}

	// followed by a flow barrier ?
	if (G_ux.flow_stack[top_stack_slot].length > 0
		&& G_ux.flow_stack[top_stack_slot].index < G_ux.flow_stack[top_stack_slot].length - 2
c0d03cc4:	1e92      	subs	r2, r2, #2
		&& G_ux.flow_stack[top_stack_slot].steps[G_ux.flow_stack[top_stack_slot].index+1] == FLOW_BARRIER) {
c0d03cc6:	429a      	cmp	r2, r3
c0d03cc8:	dd04      	ble.n	c0d03cd4 <ux_flow_is_last+0x38>
c0d03cca:	009a      	lsls	r2, r3, #2
c0d03ccc:	1851      	adds	r1, r2, r1
c0d03cce:	6849      	ldr	r1, [r1, #4]
	if (G_ux.flow_stack[top_stack_slot].length > 0
c0d03cd0:	1c89      	adds	r1, r1, #2
c0d03cd2:	d000      	beq.n	c0d03cd6 <ux_flow_is_last+0x3a>
c0d03cd4:	2000      	movs	r0, #0
		return 1;
	}

	// is not last
	return 0;
}
c0d03cd6:	bd10      	pop	{r4, pc}
c0d03cd8:	20000250 	.word	0x20000250

c0d03cdc <ux_flow_direction>:

ux_flow_direction_t ux_flow_direction(void) {
  	unsigned int top_stack_slot = G_ux.stack_count - 1;
c0d03cdc:	4809      	ldr	r0, [pc, #36]	; (c0d03d04 <ux_flow_direction+0x28>)
c0d03cde:	7801      	ldrb	r1, [r0, #0]

	if (G_ux.stack_count) {
c0d03ce0:	2900      	cmp	r1, #0
c0d03ce2:	d00c      	beq.n	c0d03cfe <ux_flow_direction+0x22>
c0d03ce4:	220c      	movs	r2, #12
  	unsigned int top_stack_slot = G_ux.stack_count - 1;
c0d03ce6:	434a      	muls	r2, r1
		if (G_ux.flow_stack[top_stack_slot].index > G_ux.flow_stack[top_stack_slot].prev_index) {
c0d03ce8:	1811      	adds	r1, r2, r0
c0d03cea:	89c8      	ldrh	r0, [r1, #14]
c0d03cec:	8989      	ldrh	r1, [r1, #12]
c0d03cee:	4281      	cmp	r1, r0
c0d03cf0:	d901      	bls.n	c0d03cf6 <ux_flow_direction+0x1a>
c0d03cf2:	2001      	movs	r0, #1
c0d03cf4:	e004      	b.n	c0d03d00 <ux_flow_direction+0x24>
		return FLOW_DIRECTION_FORWARD;
		}
		else if (G_ux.flow_stack[top_stack_slot].index < G_ux.flow_stack[top_stack_slot].prev_index) {
c0d03cf6:	4281      	cmp	r1, r0
c0d03cf8:	d201      	bcs.n	c0d03cfe <ux_flow_direction+0x22>
c0d03cfa:	20ff      	movs	r0, #255	; 0xff
c0d03cfc:	e000      	b.n	c0d03d00 <ux_flow_direction+0x24>
c0d03cfe:	2000      	movs	r0, #0
			return FLOW_DIRECTION_BACKWARD;
		}
	}
  return FLOW_DIRECTION_START;
}
c0d03d00:	b240      	sxtb	r0, r0
c0d03d02:	4770      	bx	lr
c0d03d04:	20000250 	.word	0x20000250

c0d03d08 <ux_flow_next_internal>:
			           STEPSPIC(STEPPIC(G_ux.flow_stack[stack_slot].steps[G_ux.flow_stack[stack_slot].index])->validate_flow),
			           (const ux_flow_step_t*) PIC(STEPPIC(G_ux.flow_stack[stack_slot].steps[G_ux.flow_stack[stack_slot].index])->params));
	}
}

static void ux_flow_next_internal(unsigned int display_step) {
c0d03d08:	b570      	push	{r4, r5, r6, lr}
c0d03d0a:	4601      	mov	r1, r0
  	unsigned int top_stack_slot = G_ux.stack_count - 1;
c0d03d0c:	4a15      	ldr	r2, [pc, #84]	; (c0d03d64 <ux_flow_next_internal+0x5c>)
c0d03d0e:	7810      	ldrb	r0, [r2, #0]
		|| G_ux.flow_stack[top_stack_slot].length == 0) {
c0d03d10:	2801      	cmp	r0, #1
c0d03d12:	d826      	bhi.n	c0d03d62 <ux_flow_next_internal+0x5a>
c0d03d14:	1e40      	subs	r0, r0, #1
c0d03d16:	230c      	movs	r3, #12
c0d03d18:	4343      	muls	r3, r0
c0d03d1a:	18d2      	adds	r2, r2, r3
c0d03d1c:	8b95      	ldrh	r5, [r2, #28]

	// last reached already (need validation, not next)
	if (!ux_flow_check_valid()
		|| G_ux.flow_stack[top_stack_slot].steps == NULL
c0d03d1e:	2d00      	cmp	r5, #0
c0d03d20:	d01f      	beq.n	c0d03d62 <ux_flow_next_internal+0x5a>
c0d03d22:	6954      	ldr	r4, [r2, #20]
		|| G_ux.flow_stack[top_stack_slot].length <= 1
c0d03d24:	2c00      	cmp	r4, #0
c0d03d26:	d01c      	beq.n	c0d03d62 <ux_flow_next_internal+0x5a>
c0d03d28:	2d01      	cmp	r5, #1
c0d03d2a:	d01a      	beq.n	c0d03d62 <ux_flow_next_internal+0x5a>
		|| G_ux.flow_stack[top_stack_slot].index >= G_ux.flow_stack[top_stack_slot].length -1) {
c0d03d2c:	8b13      	ldrh	r3, [r2, #24]
c0d03d2e:	1e6e      	subs	r6, r5, #1
	if (!ux_flow_check_valid()
c0d03d30:	429e      	cmp	r6, r3
c0d03d32:	dd16      	ble.n	c0d03d62 <ux_flow_next_internal+0x5a>
c0d03d34:	4616      	mov	r6, r2
c0d03d36:	3618      	adds	r6, #24
		return;
	}

	// followed by a flow barrier ? => need validation instead of next
	if (G_ux.flow_stack[top_stack_slot].index <= G_ux.flow_stack[top_stack_slot].length - 2) {
c0d03d38:	1ead      	subs	r5, r5, #2
c0d03d3a:	429d      	cmp	r5, r3
c0d03d3c:	db0a      	blt.n	c0d03d54 <ux_flow_next_internal+0x4c>
		if (G_ux.flow_stack[top_stack_slot].steps[G_ux.flow_stack[top_stack_slot].index+1] == FLOW_BARRIER) {
c0d03d3e:	009d      	lsls	r5, r3, #2
c0d03d40:	192c      	adds	r4, r5, r4
c0d03d42:	6864      	ldr	r4, [r4, #4]
c0d03d44:	1ca5      	adds	r5, r4, #2
c0d03d46:	d00c      	beq.n	c0d03d62 <ux_flow_next_internal+0x5a>
c0d03d48:	1ce4      	adds	r4, r4, #3
c0d03d4a:	d103      	bne.n	c0d03d54 <ux_flow_next_internal+0x4c>
c0d03d4c:	2100      	movs	r1, #0
		}

		// followed by a flow barrier ? => need validation instead of next
		if (G_ux.flow_stack[top_stack_slot].steps[G_ux.flow_stack[top_stack_slot].index+1] == FLOW_LOOP) {
			// display first step, fake direction as forward
			G_ux.flow_stack[top_stack_slot].prev_index = G_ux.flow_stack[top_stack_slot].index = 0;
c0d03d4e:	8031      	strh	r1, [r6, #0]
c0d03d50:	8351      	strh	r1, [r2, #26]
c0d03d52:	e004      	b.n	c0d03d5e <ux_flow_next_internal+0x56>
		}
	}

	// advance flow pointer and display it (skip META STEPS)
	G_ux.flow_stack[top_stack_slot].prev_index = G_ux.flow_stack[top_stack_slot].index;
	G_ux.flow_stack[top_stack_slot].index++;
c0d03d54:	1c5c      	adds	r4, r3, #1
c0d03d56:	8034      	strh	r4, [r6, #0]
	G_ux.flow_stack[top_stack_slot].prev_index = G_ux.flow_stack[top_stack_slot].index;
c0d03d58:	8353      	strh	r3, [r2, #26]
	if (display_step) {
c0d03d5a:	2900      	cmp	r1, #0
c0d03d5c:	d001      	beq.n	c0d03d62 <ux_flow_next_internal+0x5a>
c0d03d5e:	f000 f839 	bl	c0d03dd4 <ux_flow_engine_init_step>
		ux_flow_engine_init_step(top_stack_slot);
	}
}
c0d03d62:	bd70      	pop	{r4, r5, r6, pc}
c0d03d64:	20000250 	.word	0x20000250

c0d03d68 <ux_flow_next>:

void ux_flow_next_no_display(void) {
	ux_flow_next_internal(0);
}

void ux_flow_next(void) {
c0d03d68:	b580      	push	{r7, lr}
c0d03d6a:	2001      	movs	r0, #1
	ux_flow_next_internal(1);
c0d03d6c:	f7ff ffcc 	bl	c0d03d08 <ux_flow_next_internal>
}
c0d03d70:	bd80      	pop	{r7, pc}
	...

c0d03d74 <ux_flow_prev>:

void ux_flow_prev(void) {
c0d03d74:	b5b0      	push	{r4, r5, r7, lr}
	unsigned int top_stack_slot = G_ux.stack_count - 1;
c0d03d76:	4916      	ldr	r1, [pc, #88]	; (c0d03dd0 <ux_flow_prev+0x5c>)
c0d03d78:	7808      	ldrb	r0, [r1, #0]
		|| G_ux.flow_stack[top_stack_slot].length == 0) {
c0d03d7a:	2801      	cmp	r0, #1
c0d03d7c:	d826      	bhi.n	c0d03dcc <ux_flow_prev+0x58>
c0d03d7e:	1e40      	subs	r0, r0, #1
c0d03d80:	220c      	movs	r2, #12
c0d03d82:	4342      	muls	r2, r0
c0d03d84:	1889      	adds	r1, r1, r2
c0d03d86:	8b8a      	ldrh	r2, [r1, #28]

	// first reached already
	if (!ux_flow_check_valid()
		|| G_ux.flow_stack[top_stack_slot].steps == NULL
c0d03d88:	2a00      	cmp	r2, #0
c0d03d8a:	d01f      	beq.n	c0d03dcc <ux_flow_prev+0x58>
c0d03d8c:	694c      	ldr	r4, [r1, #20]
		|| G_ux.flow_stack[top_stack_slot].length <= 1
c0d03d8e:	2c00      	cmp	r4, #0
c0d03d90:	d01c      	beq.n	c0d03dcc <ux_flow_prev+0x58>
c0d03d92:	2a01      	cmp	r2, #1
c0d03d94:	d01a      	beq.n	c0d03dcc <ux_flow_prev+0x58>
		|| (G_ux.flow_stack[top_stack_slot].index == 0
c0d03d96:	8b0d      	ldrh	r5, [r1, #24]
c0d03d98:	460b      	mov	r3, r1
c0d03d9a:	3318      	adds	r3, #24
			  && G_ux.flow_stack[top_stack_slot].steps[G_ux.flow_stack[top_stack_slot].length-1] != FLOW_LOOP)) {
c0d03d9c:	2d00      	cmp	r5, #0
c0d03d9e:	d009      	beq.n	c0d03db4 <ux_flow_prev+0x40>
		ux_flow_engine_init_step(top_stack_slot);
		return;
	}

	// previous item is a flow barrier ?
	if (G_ux.flow_stack[top_stack_slot].steps[G_ux.flow_stack[top_stack_slot].index-1] == FLOW_BARRIER) {
c0d03da0:	00aa      	lsls	r2, r5, #2
c0d03da2:	1912      	adds	r2, r2, r4
c0d03da4:	1f12      	subs	r2, r2, #4
c0d03da6:	6812      	ldr	r2, [r2, #0]
c0d03da8:	1c92      	adds	r2, r2, #2
c0d03daa:	d00f      	beq.n	c0d03dcc <ux_flow_prev+0x58>
		return;
	}

	// advance flow pointer and display it (skip META STEPS)
	G_ux.flow_stack[top_stack_slot].prev_index = G_ux.flow_stack[top_stack_slot].index;
	G_ux.flow_stack[top_stack_slot].index--;
c0d03dac:	1e6a      	subs	r2, r5, #1
c0d03dae:	801a      	strh	r2, [r3, #0]
	G_ux.flow_stack[top_stack_slot].prev_index = G_ux.flow_stack[top_stack_slot].index;
c0d03db0:	834d      	strh	r5, [r1, #26]
c0d03db2:	e009      	b.n	c0d03dc8 <ux_flow_prev+0x54>
			  && G_ux.flow_stack[top_stack_slot].steps[G_ux.flow_stack[top_stack_slot].length-1] != FLOW_LOOP)) {
c0d03db4:	0095      	lsls	r5, r2, #2
c0d03db6:	192c      	adds	r4, r5, r4
c0d03db8:	1f24      	subs	r4, r4, #4
c0d03dba:	6824      	ldr	r4, [r4, #0]
	if (!ux_flow_check_valid()
c0d03dbc:	1ce4      	adds	r4, r4, #3
c0d03dbe:	d105      	bne.n	c0d03dcc <ux_flow_prev+0x58>
		G_ux.flow_stack[top_stack_slot].index = G_ux.flow_stack[top_stack_slot].length-2;
c0d03dc0:	1e94      	subs	r4, r2, #2
c0d03dc2:	801c      	strh	r4, [r3, #0]
		G_ux.flow_stack[top_stack_slot].prev_index = G_ux.flow_stack[top_stack_slot].index+1;
c0d03dc4:	1e52      	subs	r2, r2, #1
c0d03dc6:	834a      	strh	r2, [r1, #26]
c0d03dc8:	f000 f804 	bl	c0d03dd4 <ux_flow_engine_init_step>

	ux_flow_engine_init_step(top_stack_slot);
}
c0d03dcc:	bdb0      	pop	{r4, r5, r7, pc}
c0d03dce:	46c0      	nop			; (mov r8, r8)
c0d03dd0:	20000250 	.word	0x20000250

c0d03dd4 <ux_flow_engine_init_step>:
static void ux_flow_engine_init_step(unsigned int stack_slot) {
c0d03dd4:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d03dd6:	b081      	sub	sp, #4
c0d03dd8:	4604      	mov	r4, r0
c0d03dda:	200c      	movs	r0, #12
	if (G_ux.flow_stack[stack_slot].steps[G_ux.flow_stack[stack_slot].index] == FLOW_END_STEP) {
c0d03ddc:	4360      	muls	r0, r4
c0d03dde:	491a      	ldr	r1, [pc, #104]	; (c0d03e48 <ux_flow_engine_init_step+0x74>)
c0d03de0:	180e      	adds	r6, r1, r0
c0d03de2:	6970      	ldr	r0, [r6, #20]
c0d03de4:	8b31      	ldrh	r1, [r6, #24]
c0d03de6:	0089      	lsls	r1, r1, #2
c0d03de8:	5840      	ldr	r0, [r0, r1]
c0d03dea:	2103      	movs	r1, #3
c0d03dec:	43c9      	mvns	r1, r1
c0d03dee:	4288      	cmp	r0, r1
c0d03df0:	d827      	bhi.n	c0d03e42 <ux_flow_engine_init_step+0x6e>
c0d03df2:	4637      	mov	r7, r6
c0d03df4:	3718      	adds	r7, #24
c0d03df6:	3614      	adds	r6, #20
	if (STEPPIC(G_ux.flow_stack[stack_slot].steps[G_ux.flow_stack[stack_slot].index])->init) {
c0d03df8:	f7fe f8a0 	bl	c0d01f3c <pic>
c0d03dfc:	6831      	ldr	r1, [r6, #0]
c0d03dfe:	883a      	ldrh	r2, [r7, #0]
c0d03e00:	0092      	lsls	r2, r2, #2
c0d03e02:	5889      	ldr	r1, [r1, r2]
c0d03e04:	6805      	ldr	r5, [r0, #0]
c0d03e06:	4608      	mov	r0, r1
c0d03e08:	f7fe f898 	bl	c0d01f3c <pic>
c0d03e0c:	2d00      	cmp	r5, #0
c0d03e0e:	d006      	beq.n	c0d03e1e <ux_flow_engine_init_step+0x4a>
		INITPIC(STEPPIC(G_ux.flow_stack[stack_slot].steps[G_ux.flow_stack[stack_slot].index])->init)(stack_slot);
c0d03e10:	6800      	ldr	r0, [r0, #0]
c0d03e12:	f7fe f893 	bl	c0d01f3c <pic>
c0d03e16:	4601      	mov	r1, r0
c0d03e18:	4620      	mov	r0, r4
c0d03e1a:	4788      	blx	r1
c0d03e1c:	e011      	b.n	c0d03e42 <ux_flow_engine_init_step+0x6e>
			           STEPSPIC(STEPPIC(G_ux.flow_stack[stack_slot].steps[G_ux.flow_stack[stack_slot].index])->validate_flow),
c0d03e1e:	6880      	ldr	r0, [r0, #8]
c0d03e20:	f7fe f88c 	bl	c0d01f3c <pic>
c0d03e24:	4605      	mov	r5, r0
			           (const ux_flow_step_t*) PIC(STEPPIC(G_ux.flow_stack[stack_slot].steps[G_ux.flow_stack[stack_slot].index])->params));
c0d03e26:	6830      	ldr	r0, [r6, #0]
c0d03e28:	8839      	ldrh	r1, [r7, #0]
c0d03e2a:	0089      	lsls	r1, r1, #2
c0d03e2c:	5840      	ldr	r0, [r0, r1]
c0d03e2e:	f7fe f885 	bl	c0d01f3c <pic>
c0d03e32:	6840      	ldr	r0, [r0, #4]
c0d03e34:	f7fe f882 	bl	c0d01f3c <pic>
c0d03e38:	4602      	mov	r2, r0
		ux_flow_init(stack_slot,
c0d03e3a:	4620      	mov	r0, r4
c0d03e3c:	4629      	mov	r1, r5
c0d03e3e:	f000 f85d 	bl	c0d03efc <ux_flow_init>
}
c0d03e42:	b001      	add	sp, #4
c0d03e44:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d03e46:	46c0      	nop			; (mov r8, r8)
c0d03e48:	20000250 	.word	0x20000250

c0d03e4c <ux_flow_validate>:

void ux_flow_validate(void) {
c0d03e4c:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d03e4e:	b081      	sub	sp, #4
  	unsigned int top_stack_slot = G_ux.stack_count - 1;
c0d03e50:	4829      	ldr	r0, [pc, #164]	; (c0d03ef8 <ux_flow_validate+0xac>)
c0d03e52:	7801      	ldrb	r1, [r0, #0]
		|| G_ux.flow_stack[top_stack_slot].length == 0) {
c0d03e54:	2901      	cmp	r1, #1
c0d03e56:	d825      	bhi.n	c0d03ea4 <ux_flow_validate+0x58>
c0d03e58:	1e4c      	subs	r4, r1, #1
c0d03e5a:	210c      	movs	r1, #12
c0d03e5c:	4361      	muls	r1, r4
c0d03e5e:	1845      	adds	r5, r0, r1
c0d03e60:	8ba9      	ldrh	r1, [r5, #28]

	// no flow ?
	if (!ux_flow_check_valid()
	  || G_ux.flow_stack[top_stack_slot].steps == NULL
c0d03e62:	2900      	cmp	r1, #0
c0d03e64:	d01e      	beq.n	c0d03ea4 <ux_flow_validate+0x58>
c0d03e66:	6968      	ldr	r0, [r5, #20]
		|| G_ux.flow_stack[top_stack_slot].length == 0
c0d03e68:	2800      	cmp	r0, #0
c0d03e6a:	d01b      	beq.n	c0d03ea4 <ux_flow_validate+0x58>
		|| G_ux.flow_stack[top_stack_slot].index >= G_ux.flow_stack[top_stack_slot].length) {
c0d03e6c:	8b2a      	ldrh	r2, [r5, #24]
	if (!ux_flow_check_valid()
c0d03e6e:	428a      	cmp	r2, r1
c0d03e70:	d218      	bcs.n	c0d03ea4 <ux_flow_validate+0x58>
c0d03e72:	462f      	mov	r7, r5
c0d03e74:	3714      	adds	r7, #20
c0d03e76:	462e      	mov	r6, r5
c0d03e78:	3618      	adds	r6, #24
		return;
	}

	// no validation flow ?
	if (STEPPIC(G_ux.flow_stack[top_stack_slot].steps[G_ux.flow_stack[top_stack_slot].index])->validate_flow != NULL) {
c0d03e7a:	0091      	lsls	r1, r2, #2
c0d03e7c:	5840      	ldr	r0, [r0, r1]
c0d03e7e:	f7fe f85d 	bl	c0d01f3c <pic>
c0d03e82:	6880      	ldr	r0, [r0, #8]
c0d03e84:	2800      	cmp	r0, #0
c0d03e86:	d00f      	beq.n	c0d03ea8 <ux_flow_validate+0x5c>
		// execute validation flow
		ux_flow_init(top_stack_slot, STEPSPIC(STEPPIC(G_ux.flow_stack[top_stack_slot].steps[G_ux.flow_stack[top_stack_slot].index])->validate_flow), NULL);
c0d03e88:	6838      	ldr	r0, [r7, #0]
c0d03e8a:	8831      	ldrh	r1, [r6, #0]
c0d03e8c:	0089      	lsls	r1, r1, #2
c0d03e8e:	5840      	ldr	r0, [r0, r1]
c0d03e90:	f7fe f854 	bl	c0d01f3c <pic>
c0d03e94:	6880      	ldr	r0, [r0, #8]
c0d03e96:	f7fe f851 	bl	c0d01f3c <pic>
c0d03e9a:	4601      	mov	r1, r0
c0d03e9c:	2200      	movs	r2, #0
c0d03e9e:	4620      	mov	r0, r4
c0d03ea0:	f000 f82c 	bl	c0d03efc <ux_flow_init>
				// execute reached step
				ux_flow_engine_init_step(top_stack_slot);
			}
		}
	}
}
c0d03ea4:	b001      	add	sp, #4
c0d03ea6:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d03ea8:	4628      	mov	r0, r5
c0d03eaa:	301c      	adds	r0, #28
		if (G_ux.flow_stack[top_stack_slot].length > 0
c0d03eac:	8800      	ldrh	r0, [r0, #0]
			&& G_ux.flow_stack[top_stack_slot].index <= G_ux.flow_stack[top_stack_slot].length - 2) {
c0d03eae:	2800      	cmp	r0, #0
c0d03eb0:	d0f8      	beq.n	c0d03ea4 <ux_flow_validate+0x58>
c0d03eb2:	1e80      	subs	r0, r0, #2
c0d03eb4:	8832      	ldrh	r2, [r6, #0]
		if (G_ux.flow_stack[top_stack_slot].length > 0
c0d03eb6:	4290      	cmp	r0, r2
c0d03eb8:	dbf4      	blt.n	c0d03ea4 <ux_flow_validate+0x58>
			if (G_ux.flow_stack[top_stack_slot].steps[G_ux.flow_stack[top_stack_slot].index+1] == FLOW_BARRIER) {
c0d03eba:	6839      	ldr	r1, [r7, #0]
c0d03ebc:	0093      	lsls	r3, r2, #2
c0d03ebe:	185b      	adds	r3, r3, r1
c0d03ec0:	685b      	ldr	r3, [r3, #4]
c0d03ec2:	1cdf      	adds	r7, r3, #3
c0d03ec4:	d010      	beq.n	c0d03ee8 <ux_flow_validate+0x9c>
c0d03ec6:	1c9b      	adds	r3, r3, #2
c0d03ec8:	d1ec      	bne.n	c0d03ea4 <ux_flow_validate+0x58>
c0d03eca:	4613      	mov	r3, r2
					&& G_ux.flow_stack[top_stack_slot].steps[G_ux.flow_stack[top_stack_slot].index+1] == FLOW_BARRIER) {
c0d03ecc:	0092      	lsls	r2, r2, #2
c0d03ece:	1852      	adds	r2, r2, r1
c0d03ed0:	6852      	ldr	r2, [r2, #4]
				while (G_ux.flow_stack[top_stack_slot].length > 0
c0d03ed2:	1c92      	adds	r2, r2, #2
c0d03ed4:	d104      	bne.n	c0d03ee0 <ux_flow_validate+0x94>
					G_ux.flow_stack[top_stack_slot].index++;
c0d03ed6:	1c5b      	adds	r3, r3, #1
c0d03ed8:	8033      	strh	r3, [r6, #0]
					&& G_ux.flow_stack[top_stack_slot].index <= G_ux.flow_stack[top_stack_slot].length - 2
c0d03eda:	b29a      	uxth	r2, r3
					&& G_ux.flow_stack[top_stack_slot].steps[G_ux.flow_stack[top_stack_slot].index+1] == FLOW_BARRIER) {
c0d03edc:	4290      	cmp	r0, r2
c0d03ede:	daf5      	bge.n	c0d03ecc <ux_flow_validate+0x80>
				G_ux.flow_stack[top_stack_slot].index++;
c0d03ee0:	1c58      	adds	r0, r3, #1
c0d03ee2:	8030      	strh	r0, [r6, #0]
				G_ux.flow_stack[top_stack_slot].prev_index = G_ux.flow_stack[top_stack_slot].index;
c0d03ee4:	836b      	strh	r3, [r5, #26]
c0d03ee6:	e002      	b.n	c0d03eee <ux_flow_validate+0xa2>
c0d03ee8:	2000      	movs	r0, #0
				G_ux.flow_stack[top_stack_slot].prev_index = G_ux.flow_stack[top_stack_slot].index = 0;
c0d03eea:	8030      	strh	r0, [r6, #0]
c0d03eec:	8368      	strh	r0, [r5, #26]
c0d03eee:	4620      	mov	r0, r4
c0d03ef0:	f7ff ff70 	bl	c0d03dd4 <ux_flow_engine_init_step>
c0d03ef4:	e7d6      	b.n	c0d03ea4 <ux_flow_validate+0x58>
c0d03ef6:	46c0      	nop			; (mov r8, r8)
c0d03ef8:	20000250 	.word	0x20000250

c0d03efc <ux_flow_init>:
}

/**
 * Last step is marked with a FLOW_END_STEP value
 */
void ux_flow_init(unsigned int stack_slot, const ux_flow_step_t* const * steps, const ux_flow_step_t* const start_step) {
c0d03efc:	b570      	push	{r4, r5, r6, lr}
	if (stack_slot >= UX_STACK_SLOT_COUNT) {
c0d03efe:	2800      	cmp	r0, #0
c0d03f00:	d000      	beq.n	c0d03f04 <ux_flow_init+0x8>
		}

		// init step
		ux_flow_engine_init_step(stack_slot);
	}
}
c0d03f02:	bd70      	pop	{r4, r5, r6, pc}
c0d03f04:	4614      	mov	r4, r2
c0d03f06:	460d      	mov	r5, r1
	G_ux.flow_stack[stack_slot].steps = NULL;
c0d03f08:	4e19      	ldr	r6, [pc, #100]	; (c0d03f70 <ux_flow_init+0x74>)
c0d03f0a:	1d30      	adds	r0, r6, #4
c0d03f0c:	211a      	movs	r1, #26
c0d03f0e:	f000 fe6b 	bl	c0d04be8 <__aeabi_memclr>
	if (steps) {
c0d03f12:	2d00      	cmp	r5, #0
c0d03f14:	d0f5      	beq.n	c0d03f02 <ux_flow_init+0x6>
		G_ux.flow_stack[stack_slot].steps = STEPSPIC(steps);
c0d03f16:	4628      	mov	r0, r5
c0d03f18:	f7fe f810 	bl	c0d01f3c <pic>
c0d03f1c:	6170      	str	r0, [r6, #20]
		while(G_ux.flow_stack[stack_slot].steps[G_ux.flow_stack[stack_slot].length] != FLOW_END_STEP) {
c0d03f1e:	8bb1      	ldrh	r1, [r6, #28]
c0d03f20:	008a      	lsls	r2, r1, #2
c0d03f22:	5882      	ldr	r2, [r0, r2]
c0d03f24:	1c52      	adds	r2, r2, #1
c0d03f26:	d006      	beq.n	c0d03f36 <ux_flow_init+0x3a>
			G_ux.flow_stack[stack_slot].length++;
c0d03f28:	1c49      	adds	r1, r1, #1
		while(G_ux.flow_stack[stack_slot].steps[G_ux.flow_stack[stack_slot].length] != FLOW_END_STEP) {
c0d03f2a:	b28a      	uxth	r2, r1
c0d03f2c:	0092      	lsls	r2, r2, #2
c0d03f2e:	5882      	ldr	r2, [r0, r2]
c0d03f30:	1c52      	adds	r2, r2, #1
c0d03f32:	d1f9      	bne.n	c0d03f28 <ux_flow_init+0x2c>
c0d03f34:	83b1      	strh	r1, [r6, #28]
		if (start_step != NULL) {
c0d03f36:	2c00      	cmp	r4, #0
c0d03f38:	d016      	beq.n	c0d03f68 <ux_flow_init+0x6c>
			const ux_flow_step_t* const start_step2  = STEPPIC(start_step);
c0d03f3a:	4620      	mov	r0, r4
c0d03f3c:	f7fd fffe 	bl	c0d01f3c <pic>
c0d03f40:	4604      	mov	r4, r0
			while(G_ux.flow_stack[stack_slot].steps[G_ux.flow_stack[stack_slot].index] != FLOW_END_STEP
c0d03f42:	6970      	ldr	r0, [r6, #20]
c0d03f44:	8b31      	ldrh	r1, [r6, #24]
c0d03f46:	0089      	lsls	r1, r1, #2
c0d03f48:	5840      	ldr	r0, [r0, r1]
				 && STEPPIC(G_ux.flow_stack[stack_slot].steps[G_ux.flow_stack[stack_slot].index]) != start_step2) {
c0d03f4a:	1c41      	adds	r1, r0, #1
c0d03f4c:	d00c      	beq.n	c0d03f68 <ux_flow_init+0x6c>
c0d03f4e:	f7fd fff5 	bl	c0d01f3c <pic>
			while(G_ux.flow_stack[stack_slot].steps[G_ux.flow_stack[stack_slot].index] != FLOW_END_STEP
c0d03f52:	42a0      	cmp	r0, r4
c0d03f54:	d008      	beq.n	c0d03f68 <ux_flow_init+0x6c>
				G_ux.flow_stack[stack_slot].prev_index = G_ux.flow_stack[stack_slot].index;
c0d03f56:	8b30      	ldrh	r0, [r6, #24]
c0d03f58:	8370      	strh	r0, [r6, #26]
				G_ux.flow_stack[stack_slot].index++;
c0d03f5a:	1c40      	adds	r0, r0, #1
c0d03f5c:	8330      	strh	r0, [r6, #24]
			while(G_ux.flow_stack[stack_slot].steps[G_ux.flow_stack[stack_slot].index] != FLOW_END_STEP
c0d03f5e:	6971      	ldr	r1, [r6, #20]
c0d03f60:	b280      	uxth	r0, r0
c0d03f62:	0080      	lsls	r0, r0, #2
c0d03f64:	5808      	ldr	r0, [r1, r0]
c0d03f66:	e7f0      	b.n	c0d03f4a <ux_flow_init+0x4e>
c0d03f68:	2000      	movs	r0, #0
		ux_flow_engine_init_step(stack_slot);
c0d03f6a:	f7ff ff33 	bl	c0d03dd4 <ux_flow_engine_init_step>
}
c0d03f6e:	bd70      	pop	{r4, r5, r6, pc}
c0d03f70:	20000250 	.word	0x20000250

c0d03f74 <ux_flow_button_callback>:
  if (stack_slot < UX_STACK_SLOT_COUNT) {
    memset(&G_ux.flow_stack[stack_slot], 0, sizeof(G_ux.flow_stack[stack_slot]));
  }
}

unsigned int ux_flow_button_callback(unsigned int button_mask, unsigned int button_mask_counter) {
c0d03f74:	b580      	push	{r7, lr}
c0d03f76:	490a      	ldr	r1, [pc, #40]	; (c0d03fa0 <ux_flow_button_callback+0x2c>)
  UNUSED(button_mask_counter);
  switch(button_mask) {
c0d03f78:	4288      	cmp	r0, r1
c0d03f7a:	d008      	beq.n	c0d03f8e <ux_flow_button_callback+0x1a>
c0d03f7c:	4909      	ldr	r1, [pc, #36]	; (c0d03fa4 <ux_flow_button_callback+0x30>)
c0d03f7e:	4288      	cmp	r0, r1
c0d03f80:	d008      	beq.n	c0d03f94 <ux_flow_button_callback+0x20>
c0d03f82:	4909      	ldr	r1, [pc, #36]	; (c0d03fa8 <ux_flow_button_callback+0x34>)
c0d03f84:	4288      	cmp	r0, r1
c0d03f86:	d108      	bne.n	c0d03f9a <ux_flow_button_callback+0x26>
    case BUTTON_EVT_RELEASED|BUTTON_LEFT:
      ux_flow_prev();
c0d03f88:	f7ff fef4 	bl	c0d03d74 <ux_flow_prev>
c0d03f8c:	e005      	b.n	c0d03f9a <ux_flow_button_callback+0x26>
      break;
    case BUTTON_EVT_RELEASED|BUTTON_RIGHT:
      ux_flow_next();
      break;
    case BUTTON_EVT_RELEASED|BUTTON_LEFT|BUTTON_RIGHT:
      ux_flow_validate();
c0d03f8e:	f7ff ff5d 	bl	c0d03e4c <ux_flow_validate>
c0d03f92:	e002      	b.n	c0d03f9a <ux_flow_button_callback+0x26>
c0d03f94:	2001      	movs	r0, #1
	ux_flow_next_internal(1);
c0d03f96:	f7ff feb7 	bl	c0d03d08 <ux_flow_next_internal>
c0d03f9a:	2000      	movs	r0, #0
      break;
  }
  return 0;
c0d03f9c:	bd80      	pop	{r7, pc}
c0d03f9e:	46c0      	nop			; (mov r8, r8)
c0d03fa0:	80000003 	.word	0x80000003
c0d03fa4:	80000002 	.word	0x80000002
c0d03fa8:	80000001 	.word	0x80000001

c0d03fac <ux_stack_get_step_params>:
}

void* ux_stack_get_step_params(unsigned int stack_slot) {
c0d03fac:	b510      	push	{r4, lr}
c0d03fae:	4601      	mov	r1, r0
c0d03fb0:	2000      	movs	r0, #0
	if (stack_slot >= UX_STACK_SLOT_COUNT) {
c0d03fb2:	2900      	cmp	r1, #0
c0d03fb4:	d10f      	bne.n	c0d03fd6 <ux_stack_get_step_params+0x2a>
c0d03fb6:	4c08      	ldr	r4, [pc, #32]	; (c0d03fd8 <ux_stack_get_step_params+0x2c>)
c0d03fb8:	8ba1      	ldrh	r1, [r4, #28]
c0d03fba:	8b22      	ldrh	r2, [r4, #24]
c0d03fbc:	428a      	cmp	r2, r1
c0d03fbe:	d20a      	bcs.n	c0d03fd6 <ux_stack_get_step_params+0x2a>

	if (G_ux.flow_stack[stack_slot].index >= G_ux.flow_stack[stack_slot].length) {
		return NULL;
	}

	return (void*)PIC(STEPPIC(STEPSPIC(G_ux.flow_stack[stack_slot].steps)[G_ux.flow_stack[stack_slot].index])->params);
c0d03fc0:	6960      	ldr	r0, [r4, #20]
c0d03fc2:	f7fd ffbb 	bl	c0d01f3c <pic>
c0d03fc6:	8b21      	ldrh	r1, [r4, #24]
c0d03fc8:	0089      	lsls	r1, r1, #2
c0d03fca:	5840      	ldr	r0, [r0, r1]
c0d03fcc:	f7fd ffb6 	bl	c0d01f3c <pic>
c0d03fd0:	6840      	ldr	r0, [r0, #4]
c0d03fd2:	f7fd ffb3 	bl	c0d01f3c <pic>
}
c0d03fd6:	bd10      	pop	{r4, pc}
c0d03fd8:	20000250 	.word	0x20000250

c0d03fdc <ux_stack_get_current_step_params>:

void* ux_stack_get_current_step_params(void) {
c0d03fdc:	b580      	push	{r7, lr}
	unsigned int top_stack_slot = G_ux.stack_count - 1;
c0d03fde:	4803      	ldr	r0, [pc, #12]	; (c0d03fec <ux_stack_get_current_step_params+0x10>)
c0d03fe0:	7800      	ldrb	r0, [r0, #0]
c0d03fe2:	1e40      	subs	r0, r0, #1

	return ux_stack_get_step_params(top_stack_slot);
c0d03fe4:	f7ff ffe2 	bl	c0d03fac <ux_stack_get_step_params>
c0d03fe8:	bd80      	pop	{r7, pc}
c0d03fea:	46c0      	nop			; (mov r8, r8)
c0d03fec:	20000250 	.word	0x20000250

c0d03ff0 <ux_layout_bb_init_common>:
#else
  #error "BAGL_WIDTH/BAGL_HEIGHT not defined"
#endif
};

void ux_layout_bb_init_common(unsigned int stack_slot) {
c0d03ff0:	b510      	push	{r4, lr}
c0d03ff2:	4604      	mov	r4, r0
  ux_stack_init(stack_slot);
c0d03ff4:	f000 fc64 	bl	c0d048c0 <ux_stack_init>
c0d03ff8:	2024      	movs	r0, #36	; 0x24
  G_ux.stack[stack_slot].element_arrays[0].element_array = ux_layout_bb_elements;
c0d03ffa:	4360      	muls	r0, r4
c0d03ffc:	4908      	ldr	r1, [pc, #32]	; (c0d04020 <ux_layout_bb_init_common+0x30>)
c0d03ffe:	1808      	adds	r0, r1, r0
c0d04000:	21c8      	movs	r1, #200	; 0xc8
c0d04002:	2205      	movs	r2, #5
  G_ux.stack[stack_slot].element_arrays[0].element_array_count = ARRAYLEN(ux_layout_bb_elements);
c0d04004:	5442      	strb	r2, [r0, r1]
c0d04006:	21c4      	movs	r1, #196	; 0xc4
  G_ux.stack[stack_slot].element_arrays[0].element_array = ux_layout_bb_elements;
c0d04008:	4a06      	ldr	r2, [pc, #24]	; (c0d04024 <ux_layout_bb_init_common+0x34>)
c0d0400a:	447a      	add	r2, pc
c0d0400c:	5042      	str	r2, [r0, r1]
c0d0400e:	21d4      	movs	r1, #212	; 0xd4
  G_ux.stack[stack_slot].element_arrays_count = 1;
  G_ux.stack[stack_slot].button_push_callback = ux_flow_button_callback;
c0d04010:	4a05      	ldr	r2, [pc, #20]	; (c0d04028 <ux_layout_bb_init_common+0x38>)
c0d04012:	447a      	add	r2, pc
c0d04014:	5042      	str	r2, [r0, r1]
c0d04016:	21c1      	movs	r1, #193	; 0xc1
c0d04018:	2201      	movs	r2, #1
  G_ux.stack[stack_slot].element_arrays_count = 1;
c0d0401a:	5442      	strb	r2, [r0, r1]
}
c0d0401c:	bd10      	pop	{r4, pc}
c0d0401e:	46c0      	nop			; (mov r8, r8)
c0d04020:	20000250 	.word	0x20000250
c0d04024:	0000173e 	.word	0x0000173e
c0d04028:	ffffff5f 	.word	0xffffff5f

c0d0402c <ux_layout_bn_prepro>:
 * 1 bold text line
 * 1 text lines
 * Uses layout from ux_layout_bb
 */

const bagl_element_t* ux_layout_bn_prepro(const bagl_element_t* element) {
c0d0402c:	b580      	push	{r7, lr}
  const bagl_element_t* e = ux_layout_strings_prepro(element);
c0d0402e:	f000 fb61 	bl	c0d046f4 <ux_layout_strings_prepro>
  if (e && G_ux.tmp_element.component.userid == 0x11) {
c0d04032:	2800      	cmp	r0, #0
c0d04034:	d007      	beq.n	c0d04046 <ux_layout_bn_prepro+0x1a>
c0d04036:	22a1      	movs	r2, #161	; 0xa1
c0d04038:	4903      	ldr	r1, [pc, #12]	; (c0d04048 <ux_layout_bn_prepro+0x1c>)
c0d0403a:	5c8a      	ldrb	r2, [r1, r2]
c0d0403c:	2a11      	cmp	r2, #17
c0d0403e:	d102      	bne.n	c0d04046 <ux_layout_bn_prepro+0x1a>
c0d04040:	22b8      	movs	r2, #184	; 0xb8
c0d04042:	4b02      	ldr	r3, [pc, #8]	; (c0d0404c <ux_layout_bn_prepro+0x20>)
    G_ux.tmp_element.component.font_id = BAGL_FONT_OPEN_SANS_REGULAR_11px|BAGL_FONT_ALIGNMENT_CENTER;
c0d04044:	528b      	strh	r3, [r1, r2]
  }
  return e;
c0d04046:	bd80      	pop	{r7, pc}
c0d04048:	20000250 	.word	0x20000250
c0d0404c:	0000800a 	.word	0x0000800a

c0d04050 <ux_layout_bn_init>:
}

void ux_layout_bn_init(unsigned int stack_slot) { 
c0d04050:	b510      	push	{r4, lr}
c0d04052:	4604      	mov	r4, r0
  ux_layout_bb_init_common(stack_slot);
c0d04054:	f7ff ffcc 	bl	c0d03ff0 <ux_layout_bb_init_common>
c0d04058:	2024      	movs	r0, #36	; 0x24
  G_ux.stack[stack_slot].screen_before_element_display_callback = ux_layout_bn_prepro;
c0d0405a:	4360      	muls	r0, r4
c0d0405c:	4904      	ldr	r1, [pc, #16]	; (c0d04070 <ux_layout_bn_init+0x20>)
c0d0405e:	1808      	adds	r0, r1, r0
c0d04060:	21d0      	movs	r1, #208	; 0xd0
c0d04062:	4a04      	ldr	r2, [pc, #16]	; (c0d04074 <ux_layout_bn_init+0x24>)
c0d04064:	447a      	add	r2, pc
c0d04066:	5042      	str	r2, [r0, r1]
  ux_stack_display(stack_slot);
c0d04068:	4620      	mov	r0, r4
c0d0406a:	f000 fc03 	bl	c0d04874 <ux_stack_display>
}
c0d0406e:	bd10      	pop	{r4, pc}
c0d04070:	20000250 	.word	0x20000250
c0d04074:	ffffffc5 	.word	0xffffffc5

c0d04078 <ux_layout_nnbnn_prepro>:
#else
  #error "BAGL_WIDTH/BAGL_HEIGHT not defined"
#endif
};

const bagl_element_t* ux_layout_nnbnn_prepro(const bagl_element_t* element) {
c0d04078:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0407a:	b081      	sub	sp, #4
c0d0407c:	4606      	mov	r6, r0
  // don't display if null
  const ux_layout_strings_params_t* params = (const ux_layout_strings_params_t*)ux_stack_get_current_step_params();
c0d0407e:	f7ff ffad 	bl	c0d03fdc <ux_stack_get_current_step_params>
c0d04082:	4605      	mov	r5, r0

	// ocpy element before any mod
      memmove(&G_ux.tmp_element, element, sizeof(bagl_element_t));
c0d04084:	4f10      	ldr	r7, [pc, #64]	; (c0d040c8 <ux_layout_nnbnn_prepro+0x50>)
c0d04086:	463c      	mov	r4, r7
c0d04088:	34a0      	adds	r4, #160	; 0xa0
c0d0408a:	2220      	movs	r2, #32
c0d0408c:	4620      	mov	r0, r4
c0d0408e:	4631      	mov	r1, r6
c0d04090:	f000 fdb4 	bl	c0d04bfc <__aeabi_memmove>

  // for dashboard, setup the current application's name
  switch (element->component.userid) {
c0d04094:	7870      	ldrb	r0, [r6, #1]
c0d04096:	4601      	mov	r1, r0
c0d04098:	3910      	subs	r1, #16
c0d0409a:	2905      	cmp	r1, #5
c0d0409c:	d207      	bcs.n	c0d040ae <ux_layout_nnbnn_prepro+0x36>
c0d0409e:	20a1      	movs	r0, #161	; 0xa1
    case 0x10:
    case 0x11:
    case 0x12:
    case 0x13:
    case 0x14:
      G_ux.tmp_element.text = params->lines[G_ux.tmp_element.component.userid&0xF];
c0d040a0:	5c38      	ldrb	r0, [r7, r0]
c0d040a2:	0700      	lsls	r0, r0, #28
c0d040a4:	0e80      	lsrs	r0, r0, #26
c0d040a6:	5828      	ldr	r0, [r5, r0]
c0d040a8:	21bc      	movs	r1, #188	; 0xbc
c0d040aa:	5078      	str	r0, [r7, r1]
c0d040ac:	e009      	b.n	c0d040c2 <ux_layout_nnbnn_prepro+0x4a>
  switch (element->component.userid) {
c0d040ae:	2802      	cmp	r0, #2
c0d040b0:	d003      	beq.n	c0d040ba <ux_layout_nnbnn_prepro+0x42>
c0d040b2:	2801      	cmp	r0, #1
c0d040b4:	d105      	bne.n	c0d040c2 <ux_layout_nnbnn_prepro+0x4a>
  		if (!params->lines[1]) {
c0d040b6:	6868      	ldr	r0, [r5, #4]
c0d040b8:	e000      	b.n	c0d040bc <ux_layout_nnbnn_prepro+0x44>
  		if (!params->lines[3]) {
c0d040ba:	68e8      	ldr	r0, [r5, #12]
c0d040bc:	2800      	cmp	r0, #0
c0d040be:	d100      	bne.n	c0d040c2 <ux_layout_nnbnn_prepro+0x4a>
c0d040c0:	2400      	movs	r4, #0
      break;
  }
  return &G_ux.tmp_element;
}
c0d040c2:	4620      	mov	r0, r4
c0d040c4:	b001      	add	sp, #4
c0d040c6:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d040c8:	20000250 	.word	0x20000250

c0d040cc <ux_layout_nnbnn_init>:

void ux_layout_nnbnn_init(unsigned int stack_slot) {
c0d040cc:	b510      	push	{r4, lr}
c0d040ce:	4604      	mov	r4, r0
  ux_stack_init(stack_slot);
c0d040d0:	f000 fbf6 	bl	c0d048c0 <ux_stack_init>
c0d040d4:	2024      	movs	r0, #36	; 0x24
  G_ux.stack[stack_slot].element_arrays[0].element_array = ux_layout_nnbnn_elements;
c0d040d6:	4360      	muls	r0, r4
c0d040d8:	490b      	ldr	r1, [pc, #44]	; (c0d04108 <ux_layout_nnbnn_init+0x3c>)
c0d040da:	1808      	adds	r0, r1, r0
c0d040dc:	21c8      	movs	r1, #200	; 0xc8
c0d040de:	2206      	movs	r2, #6
  G_ux.stack[stack_slot].element_arrays[0].element_array_count = ARRAYLEN(ux_layout_nnbnn_elements);
c0d040e0:	5442      	strb	r2, [r0, r1]
c0d040e2:	21c4      	movs	r1, #196	; 0xc4
  G_ux.stack[stack_slot].element_arrays[0].element_array = ux_layout_nnbnn_elements;
c0d040e4:	4a09      	ldr	r2, [pc, #36]	; (c0d0410c <ux_layout_nnbnn_init+0x40>)
c0d040e6:	447a      	add	r2, pc
c0d040e8:	5042      	str	r2, [r0, r1]
c0d040ea:	21d4      	movs	r1, #212	; 0xd4
  G_ux.stack[stack_slot].element_arrays_count = 1;
  G_ux.stack[stack_slot].screen_before_element_display_callback = ux_layout_nnbnn_prepro;
  G_ux.stack[stack_slot].button_push_callback = ux_flow_button_callback;
c0d040ec:	4a08      	ldr	r2, [pc, #32]	; (c0d04110 <ux_layout_nnbnn_init+0x44>)
c0d040ee:	447a      	add	r2, pc
c0d040f0:	5042      	str	r2, [r0, r1]
c0d040f2:	21d0      	movs	r1, #208	; 0xd0
  G_ux.stack[stack_slot].screen_before_element_display_callback = ux_layout_nnbnn_prepro;
c0d040f4:	4a07      	ldr	r2, [pc, #28]	; (c0d04114 <ux_layout_nnbnn_init+0x48>)
c0d040f6:	447a      	add	r2, pc
c0d040f8:	5042      	str	r2, [r0, r1]
c0d040fa:	21c1      	movs	r1, #193	; 0xc1
c0d040fc:	2201      	movs	r2, #1
  G_ux.stack[stack_slot].element_arrays_count = 1;
c0d040fe:	5442      	strb	r2, [r0, r1]
  ux_stack_display(stack_slot);
c0d04100:	4620      	mov	r0, r4
c0d04102:	f000 fbb7 	bl	c0d04874 <ux_stack_display>
}
c0d04106:	bd10      	pop	{r4, pc}
c0d04108:	20000250 	.word	0x20000250
c0d0410c:	00001702 	.word	0x00001702
c0d04110:	fffffe83 	.word	0xfffffe83
c0d04114:	ffffff7f 	.word	0xffffff7f

c0d04118 <ux_layout_paging_redisplay_common>:

  return ux_layout_paging_prepro_common(element, params->get_title(), params->get_text());
}

// redisplay current page
void ux_layout_paging_redisplay_common(unsigned int stack_slot, const char* text, button_push_callback_t button_callback, bagl_element_callback_t prepro) {
c0d04118:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0411a:	b081      	sub	sp, #4
c0d0411c:	9300      	str	r3, [sp, #0]
c0d0411e:	4616      	mov	r6, r2
c0d04120:	460f      	mov	r7, r1
c0d04122:	4605      	mov	r5, r0
#if (BAGL_WIDTH==128 && BAGL_HEIGHT==64)
  slot->element_arrays[0].element_array = ux_layout_paging_elements;
  slot->element_arrays[0].element_array_count = ARRAYLEN(ux_layout_paging_elements);
  slot->element_arrays_count = 1;
#else
  ux_layout_bb_init_common(stack_slot);
c0d04124:	f7ff ff64 	bl	c0d03ff0 <ux_layout_bb_init_common>
#endif // (BAGL_WIDTH==128 && BAGL_HEIGHT==64)

  // request offsets and lengths of lines for the current page
  ux_layout_paging_compute(text, 
                           G_ux.layout_paging.current, 
c0d04128:	4c09      	ldr	r4, [pc, #36]	; (c0d04150 <ux_layout_paging_redisplay_common+0x38>)
c0d0412a:	6861      	ldr	r1, [r4, #4]
c0d0412c:	1d22      	adds	r2, r4, #4
c0d0412e:	230a      	movs	r3, #10
  ux_layout_paging_compute(text, 
c0d04130:	4638      	mov	r0, r7
c0d04132:	f000 f955 	bl	c0d043e0 <ux_layout_paging_compute>
c0d04136:	2024      	movs	r0, #36	; 0x24
                           &G_ux.layout_paging,
                           LINE_FONT);

  slot->screen_before_element_display_callback = prepro;
c0d04138:	4368      	muls	r0, r5
c0d0413a:	1820      	adds	r0, r4, r0
c0d0413c:	21d4      	movs	r1, #212	; 0xd4
  slot->button_push_callback = button_callback;
c0d0413e:	5046      	str	r6, [r0, r1]
c0d04140:	21d0      	movs	r1, #208	; 0xd0
  slot->screen_before_element_display_callback = prepro;
c0d04142:	9a00      	ldr	r2, [sp, #0]
c0d04144:	5042      	str	r2, [r0, r1]
  ux_stack_display(stack_slot);
c0d04146:	4628      	mov	r0, r5
c0d04148:	f000 fb94 	bl	c0d04874 <ux_stack_display>
}
c0d0414c:	b001      	add	sp, #4
c0d0414e:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d04150:	20000250 	.word	0x20000250

c0d04154 <ux_layout_paging_redisplay_by_addr>:

static unsigned int ux_layout_paging_button_callback_by_addr(unsigned int button_mask, unsigned int button_mask_counter);
static unsigned int ux_layout_paging_button_callback_by_func(unsigned int button_mask, unsigned int button_mask_counter);


void ux_layout_paging_redisplay_by_addr(unsigned int stack_slot) {
c0d04154:	b510      	push	{r4, lr}
c0d04156:	4604      	mov	r4, r0
  const ux_layout_paging_params_t* params = (const ux_layout_paging_params_t*)ux_stack_get_current_step_params();
c0d04158:	f7ff ff40 	bl	c0d03fdc <ux_stack_get_current_step_params>
  ux_layout_paging_redisplay_common(stack_slot, params->text, ux_layout_paging_button_callback_by_addr, ux_layout_paging_prepro_by_addr);
c0d0415c:	6841      	ldr	r1, [r0, #4]
c0d0415e:	4a04      	ldr	r2, [pc, #16]	; (c0d04170 <ux_layout_paging_redisplay_by_addr+0x1c>)
c0d04160:	447a      	add	r2, pc
c0d04162:	4b04      	ldr	r3, [pc, #16]	; (c0d04174 <ux_layout_paging_redisplay_by_addr+0x20>)
c0d04164:	447b      	add	r3, pc
c0d04166:	4620      	mov	r0, r4
c0d04168:	f7ff ffd6 	bl	c0d04118 <ux_layout_paging_redisplay_common>
}
c0d0416c:	bd10      	pop	{r4, pc}
c0d0416e:	46c0      	nop			; (mov r8, r8)
c0d04170:	00000015 	.word	0x00000015
c0d04174:	00000025 	.word	0x00000025

c0d04178 <ux_layout_paging_button_callback_by_addr>:
      break;
  }
  return 0;
}

static unsigned int ux_layout_paging_button_callback_by_addr(unsigned int button_mask, unsigned int button_mask_counter) {
c0d04178:	b580      	push	{r7, lr}
  return ux_layout_paging_button_callback_common(button_mask, button_mask_counter, ux_layout_paging_redisplay_by_addr);
c0d0417a:	4903      	ldr	r1, [pc, #12]	; (c0d04188 <ux_layout_paging_button_callback_by_addr+0x10>)
c0d0417c:	4479      	add	r1, pc
c0d0417e:	f000 f8f9 	bl	c0d04374 <ux_layout_paging_button_callback_common>
c0d04182:	2000      	movs	r0, #0
c0d04184:	bd80      	pop	{r7, pc}
c0d04186:	46c0      	nop			; (mov r8, r8)
c0d04188:	ffffffd5 	.word	0xffffffd5

c0d0418c <ux_layout_paging_prepro_by_addr>:
static const bagl_element_t* ux_layout_paging_prepro_by_addr(const bagl_element_t* element) {
c0d0418c:	b510      	push	{r4, lr}
c0d0418e:	4604      	mov	r4, r0
  const ux_layout_paging_params_t* params = (const ux_layout_paging_params_t*)ux_stack_get_current_step_params();
c0d04190:	f7ff ff24 	bl	c0d03fdc <ux_stack_get_current_step_params>
  return ux_layout_paging_prepro_common(element, params->title, params->text);
c0d04194:	c806      	ldmia	r0!, {r1, r2}
c0d04196:	4620      	mov	r0, r4
c0d04198:	f000 f84e 	bl	c0d04238 <ux_layout_paging_prepro_common>
c0d0419c:	bd10      	pop	{r4, pc}
	...

c0d041a0 <ux_layout_paging_init_common>:
static unsigned int ux_layout_paging_button_callback_by_func(unsigned int button_mask, unsigned int button_mask_counter) {
  return ux_layout_paging_button_callback_common(button_mask, button_mask_counter, ux_layout_paging_redisplay_by_func);
}


void ux_layout_paging_init_common(unsigned int stack_slot, const char* text, ux_layout_paging_redisplay_t redisplay) {
c0d041a0:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d041a2:	b083      	sub	sp, #12
c0d041a4:	9200      	str	r2, [sp, #0]
c0d041a6:	460e      	mov	r6, r1
c0d041a8:	9002      	str	r0, [sp, #8]

  // At this very moment, we don't want to get rid of the format, but keep
  // the one which has just been set (in case of direction backward or forward).
  unsigned int backup_format = G_ux.layout_paging.format;
c0d041aa:	4c1a      	ldr	r4, [pc, #104]	; (c0d04214 <ux_layout_paging_init_common+0x74>)
c0d041ac:	7b27      	ldrb	r7, [r4, #12]
c0d041ae:	2500      	movs	r5, #0
c0d041b0:	43e8      	mvns	r0, r5

  // depending flow browsing direction, select the correct page to display
  switch(ux_flow_direction()) {
c0d041b2:	9001      	str	r0, [sp, #4]
c0d041b4:	f7ff fd92 	bl	c0d03cdc <ux_flow_direction>
c0d041b8:	2801      	cmp	r0, #1
c0d041ba:	d004      	beq.n	c0d041c6 <ux_layout_paging_init_common+0x26>
c0d041bc:	1c40      	adds	r0, r0, #1
c0d041be:	d106      	bne.n	c0d041ce <ux_layout_paging_init_common+0x2e>
    case FLOW_DIRECTION_BACKWARD:
      ux_layout_paging_reset();
      // ask the paging to start at the last page.
      // This step must be performed after the 'ux_layout_paging_reset' call,
      // thus we cannot mutualize the call with the one in the 'forward' case.
      G_ux.layout_paging.current = -1UL;
c0d041c0:	9801      	ldr	r0, [sp, #4]
c0d041c2:	6060      	str	r0, [r4, #4]
c0d041c4:	e000      	b.n	c0d041c8 <ux_layout_paging_init_common+0x28>
  ux_layout_xx_paging_init(stack_slot, PAGING_FORMAT_BB);
}

// function callable externally which reset the paging (to be called before init when willing to redisplay the first page)
void ux_layout_paging_reset(void) {
  memset(&G_ux.layout_paging, 0, sizeof(G_ux.layout_paging));
c0d041c6:	6065      	str	r5, [r4, #4]
c0d041c8:	60a5      	str	r5, [r4, #8]
c0d041ca:	60e5      	str	r5, [r4, #12]
c0d041cc:	6125      	str	r5, [r4, #16]
  G_ux.layout_paging.format = backup_format;
c0d041ce:	7327      	strb	r7, [r4, #12]
  ux_stack_init(stack_slot);
c0d041d0:	9802      	ldr	r0, [sp, #8]
c0d041d2:	f000 fb75 	bl	c0d048c0 <ux_stack_init>
c0d041d6:	2041      	movs	r0, #65	; 0x41
c0d041d8:	0080      	lsls	r0, r0, #2
c0d041da:	5820      	ldr	r0, [r4, r0]
  if ((text == NULL) && (G_ux.externalText == NULL)) {
c0d041dc:	4330      	orrs	r0, r6
c0d041de:	d101      	bne.n	c0d041e4 <ux_layout_paging_init_common+0x44>
c0d041e0:	4e0d      	ldr	r6, [pc, #52]	; (c0d04218 <ux_layout_paging_init_common+0x78>)
c0d041e2:	447e      	add	r6, pc
c0d041e4:	9f00      	ldr	r7, [sp, #0]
  G_ux.layout_paging.format = backup_format;
c0d041e6:	1d22      	adds	r2, r4, #4
c0d041e8:	230a      	movs	r3, #10
  G_ux.layout_paging.count = ux_layout_paging_compute(text, -1UL, &G_ux.layout_paging, LINE_FONT); // at least one page
c0d041ea:	4630      	mov	r0, r6
c0d041ec:	9901      	ldr	r1, [sp, #4]
c0d041ee:	f000 f8f7 	bl	c0d043e0 <ux_layout_paging_compute>
c0d041f2:	60a0      	str	r0, [r4, #8]
  if (G_ux.layout_paging.count == 0) {
c0d041f4:	2800      	cmp	r0, #0
c0d041f6:	d005      	beq.n	c0d04204 <ux_layout_paging_init_common+0x64>
  if (G_ux.layout_paging.count && G_ux.layout_paging.current > G_ux.layout_paging.count-1UL) {
c0d041f8:	1e40      	subs	r0, r0, #1
c0d041fa:	6861      	ldr	r1, [r4, #4]
c0d041fc:	4281      	cmp	r1, r0
c0d041fe:	d905      	bls.n	c0d0420c <ux_layout_paging_init_common+0x6c>
    G_ux.layout_paging.current = G_ux.layout_paging.count-1;
c0d04200:	6060      	str	r0, [r4, #4]
c0d04202:	e003      	b.n	c0d0420c <ux_layout_paging_init_common+0x6c>
  memset(&G_ux.layout_paging, 0, sizeof(G_ux.layout_paging));
c0d04204:	6065      	str	r5, [r4, #4]
c0d04206:	60a5      	str	r5, [r4, #8]
c0d04208:	60e5      	str	r5, [r4, #12]
c0d0420a:	6125      	str	r5, [r4, #16]
  redisplay(stack_slot);
c0d0420c:	9802      	ldr	r0, [sp, #8]
c0d0420e:	47b8      	blx	r7
}
c0d04210:	b003      	add	sp, #12
c0d04212:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d04214:	20000250 	.word	0x20000250
c0d04218:	000011dc 	.word	0x000011dc

c0d0421c <ux_layout_paging_init>:
void ux_layout_paging_init(unsigned int stack_slot) {
c0d0421c:	b510      	push	{r4, lr}
c0d0421e:	4604      	mov	r4, r0
  const ux_layout_paging_params_t* params = (const ux_layout_paging_params_t*)ux_stack_get_step_params(stack_slot);
c0d04220:	f7ff fec4 	bl	c0d03fac <ux_stack_get_step_params>
  ux_layout_paging_init_common(stack_slot, params->text, ux_layout_paging_redisplay_by_addr);
c0d04224:	6841      	ldr	r1, [r0, #4]
c0d04226:	4a03      	ldr	r2, [pc, #12]	; (c0d04234 <ux_layout_paging_init+0x18>)
c0d04228:	447a      	add	r2, pc
c0d0422a:	4620      	mov	r0, r4
c0d0422c:	f7ff ffb8 	bl	c0d041a0 <ux_layout_paging_init_common>
}
c0d04230:	bd10      	pop	{r4, pc}
c0d04232:	46c0      	nop			; (mov r8, r8)
c0d04234:	ffffff29 	.word	0xffffff29

c0d04238 <ux_layout_paging_prepro_common>:
                                                            const char* text) {
c0d04238:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0423a:	b083      	sub	sp, #12
c0d0423c:	4615      	mov	r5, r2
c0d0423e:	460e      	mov	r6, r1
c0d04240:	4607      	mov	r7, r0
  memmove(&G_ux.tmp_element, element, sizeof(bagl_element_t));
c0d04242:	4c46      	ldr	r4, [pc, #280]	; (c0d0435c <ux_layout_paging_prepro_common+0x124>)
c0d04244:	34a0      	adds	r4, #160	; 0xa0
c0d04246:	2220      	movs	r2, #32
c0d04248:	4620      	mov	r0, r4
c0d0424a:	4639      	mov	r1, r7
c0d0424c:	f000 fcd6 	bl	c0d04bfc <__aeabi_memmove>
  switch (element->component.userid) {
c0d04250:	7878      	ldrb	r0, [r7, #1]
c0d04252:	2810      	cmp	r0, #16
c0d04254:	dc18      	bgt.n	c0d04288 <ux_layout_paging_prepro_common+0x50>
c0d04256:	2801      	cmp	r0, #1
c0d04258:	d02d      	beq.n	c0d042b6 <ux_layout_paging_prepro_common+0x7e>
c0d0425a:	2802      	cmp	r0, #2
c0d0425c:	d034      	beq.n	c0d042c8 <ux_layout_paging_prepro_common+0x90>
c0d0425e:	2810      	cmp	r0, #16
c0d04260:	d178      	bne.n	c0d04354 <ux_layout_paging_prepro_common+0x11c>
      if (title) {
c0d04262:	2e00      	cmp	r6, #0
c0d04264:	d058      	beq.n	c0d04318 <ux_layout_paging_prepro_common+0xe0>
c0d04266:	493d      	ldr	r1, [pc, #244]	; (c0d0435c <ux_layout_paging_prepro_common+0x124>)
        SPRINTF(G_ux.string_buffer, (G_ux.layout_paging.count>1)?"%s (%d/%d)":"%s", STRPIC(title), G_ux.layout_paging.current+1, G_ux.layout_paging.count);
c0d04268:	688d      	ldr	r5, [r1, #8]
c0d0426a:	4630      	mov	r0, r6
c0d0426c:	460e      	mov	r6, r1
c0d0426e:	f7fd fe65 	bl	c0d01f3c <pic>
c0d04272:	4603      	mov	r3, r0
c0d04274:	6870      	ldr	r0, [r6, #4]
c0d04276:	68b1      	ldr	r1, [r6, #8]
c0d04278:	1c40      	adds	r0, r0, #1
c0d0427a:	9000      	str	r0, [sp, #0]
c0d0427c:	9101      	str	r1, [sp, #4]
c0d0427e:	2d01      	cmp	r5, #1
c0d04280:	d855      	bhi.n	c0d0432e <ux_layout_paging_prepro_common+0xf6>
c0d04282:	4a39      	ldr	r2, [pc, #228]	; (c0d04368 <ux_layout_paging_prepro_common+0x130>)
c0d04284:	447a      	add	r2, pc
c0d04286:	e054      	b.n	c0d04332 <ux_layout_paging_prepro_common+0xfa>
  switch (element->component.userid) {
c0d04288:	4601      	mov	r1, r0
c0d0428a:	3911      	subs	r1, #17
c0d0428c:	2903      	cmp	r1, #3
c0d0428e:	d261      	bcs.n	c0d04354 <ux_layout_paging_prepro_common+0x11c>
c0d04290:	210f      	movs	r1, #15
      unsigned int lineidx = (element->component.userid&0xF)-1;
c0d04292:	4008      	ands	r0, r1
        lineidx < UX_LAYOUT_PAGING_LINE_COUNT && 
c0d04294:	2801      	cmp	r0, #1
c0d04296:	d15d      	bne.n	c0d04354 <ux_layout_paging_prepro_common+0x11c>
c0d04298:	4830      	ldr	r0, [pc, #192]	; (c0d0435c <ux_layout_paging_prepro_common+0x124>)
c0d0429a:	8a06      	ldrh	r6, [r0, #16]
c0d0429c:	2e00      	cmp	r6, #0
c0d0429e:	d059      	beq.n	c0d04354 <ux_layout_paging_prepro_common+0x11c>
        SPRINTF(G_ux.string_buffer, 
c0d042a0:	2e7f      	cmp	r6, #127	; 0x7f
c0d042a2:	d300      	bcc.n	c0d042a6 <ux_layout_paging_prepro_common+0x6e>
c0d042a4:	267f      	movs	r6, #127	; 0x7f
c0d042a6:	9102      	str	r1, [sp, #8]
c0d042a8:	2d00      	cmp	r5, #0
c0d042aa:	d019      	beq.n	c0d042e0 <ux_layout_paging_prepro_common+0xa8>
c0d042ac:	4628      	mov	r0, r5
c0d042ae:	f7fd fe45 	bl	c0d01f3c <pic>
c0d042b2:	4f2a      	ldr	r7, [pc, #168]	; (c0d0435c <ux_layout_paging_prepro_common+0x124>)
c0d042b4:	e018      	b.n	c0d042e8 <ux_layout_paging_prepro_common+0xb0>
      if (ux_flow_is_first() && G_ux.layout_paging.current == 0) {
c0d042b6:	f7ff fccb 	bl	c0d03c50 <ux_flow_is_first>
c0d042ba:	2800      	cmp	r0, #0
c0d042bc:	d04a      	beq.n	c0d04354 <ux_layout_paging_prepro_common+0x11c>
c0d042be:	4827      	ldr	r0, [pc, #156]	; (c0d0435c <ux_layout_paging_prepro_common+0x124>)
c0d042c0:	6840      	ldr	r0, [r0, #4]
c0d042c2:	2800      	cmp	r0, #0
c0d042c4:	d00a      	beq.n	c0d042dc <ux_layout_paging_prepro_common+0xa4>
c0d042c6:	e045      	b.n	c0d04354 <ux_layout_paging_prepro_common+0x11c>
      if (ux_flow_is_last() && G_ux.layout_paging.current == G_ux.layout_paging.count -1 ) {
c0d042c8:	f7ff fce8 	bl	c0d03c9c <ux_flow_is_last>
c0d042cc:	2800      	cmp	r0, #0
c0d042ce:	d041      	beq.n	c0d04354 <ux_layout_paging_prepro_common+0x11c>
c0d042d0:	4922      	ldr	r1, [pc, #136]	; (c0d0435c <ux_layout_paging_prepro_common+0x124>)
c0d042d2:	6848      	ldr	r0, [r1, #4]
c0d042d4:	6889      	ldr	r1, [r1, #8]
c0d042d6:	1e49      	subs	r1, r1, #1
c0d042d8:	4288      	cmp	r0, r1
c0d042da:	d13b      	bne.n	c0d04354 <ux_layout_paging_prepro_common+0x11c>
c0d042dc:	2400      	movs	r4, #0
c0d042de:	e039      	b.n	c0d04354 <ux_layout_paging_prepro_common+0x11c>
c0d042e0:	2041      	movs	r0, #65	; 0x41
c0d042e2:	0080      	lsls	r0, r0, #2
c0d042e4:	4f1d      	ldr	r7, [pc, #116]	; (c0d0435c <ux_layout_paging_prepro_common+0x124>)
        SPRINTF(G_ux.string_buffer, 
c0d042e6:	5838      	ldr	r0, [r7, r0]
c0d042e8:	89f9      	ldrh	r1, [r7, #14]
c0d042ea:	1840      	adds	r0, r0, r1
c0d042ec:	9000      	str	r0, [sp, #0]
c0d042ee:	463d      	mov	r5, r7
c0d042f0:	3520      	adds	r5, #32
c0d042f2:	2180      	movs	r1, #128	; 0x80
c0d042f4:	4a1e      	ldr	r2, [pc, #120]	; (c0d04370 <ux_layout_paging_prepro_common+0x138>)
c0d042f6:	447a      	add	r2, pc
c0d042f8:	4628      	mov	r0, r5
c0d042fa:	4633      	mov	r3, r6
c0d042fc:	f7fd fc0e 	bl	c0d01b1c <snprintf>
c0d04300:	20bc      	movs	r0, #188	; 0xbc
        G_ux.tmp_element.text = G_ux.string_buffer;
c0d04302:	503d      	str	r5, [r7, r0]
        G_ux.tmp_element.component.font_id = ((G_ux.layout_paging.format & PAGING_FORMAT_NB) == PAGING_FORMAT_NB) ?
c0d04304:	7b39      	ldrb	r1, [r7, #12]
c0d04306:	9802      	ldr	r0, [sp, #8]
c0d04308:	4001      	ands	r1, r0
c0d0430a:	4815      	ldr	r0, [pc, #84]	; (c0d04360 <ux_layout_paging_prepro_common+0x128>)
c0d0430c:	290f      	cmp	r1, #15
c0d0430e:	d000      	beq.n	c0d04312 <ux_layout_paging_prepro_common+0xda>
c0d04310:	1c80      	adds	r0, r0, #2
c0d04312:	21b8      	movs	r1, #184	; 0xb8
c0d04314:	5278      	strh	r0, [r7, r1]
c0d04316:	e01d      	b.n	c0d04354 <ux_layout_paging_prepro_common+0x11c>
c0d04318:	4e10      	ldr	r6, [pc, #64]	; (c0d0435c <ux_layout_paging_prepro_common+0x124>)
        SPRINTF(G_ux.string_buffer, "%d/%d", G_ux.layout_paging.current+1, G_ux.layout_paging.count);
c0d0431a:	6871      	ldr	r1, [r6, #4]
c0d0431c:	68b0      	ldr	r0, [r6, #8]
c0d0431e:	9000      	str	r0, [sp, #0]
c0d04320:	4630      	mov	r0, r6
c0d04322:	3020      	adds	r0, #32
c0d04324:	1c4b      	adds	r3, r1, #1
c0d04326:	2180      	movs	r1, #128	; 0x80
c0d04328:	4a10      	ldr	r2, [pc, #64]	; (c0d0436c <ux_layout_paging_prepro_common+0x134>)
c0d0432a:	447a      	add	r2, pc
c0d0432c:	e004      	b.n	c0d04338 <ux_layout_paging_prepro_common+0x100>
c0d0432e:	4a0d      	ldr	r2, [pc, #52]	; (c0d04364 <ux_layout_paging_prepro_common+0x12c>)
c0d04330:	447a      	add	r2, pc
        SPRINTF(G_ux.string_buffer, (G_ux.layout_paging.count>1)?"%s (%d/%d)":"%s", STRPIC(title), G_ux.layout_paging.current+1, G_ux.layout_paging.count);
c0d04332:	4630      	mov	r0, r6
c0d04334:	3020      	adds	r0, #32
c0d04336:	2180      	movs	r1, #128	; 0x80
c0d04338:	f7fd fbf0 	bl	c0d01b1c <snprintf>
      G_ux.tmp_element.text = G_ux.string_buffer;
c0d0433c:	4630      	mov	r0, r6
c0d0433e:	3020      	adds	r0, #32
c0d04340:	21bc      	movs	r1, #188	; 0xbc
c0d04342:	5070      	str	r0, [r6, r1]
c0d04344:	4806      	ldr	r0, [pc, #24]	; (c0d04360 <ux_layout_paging_prepro_common+0x128>)
      G_ux.tmp_element.component.font_id = ((G_ux.layout_paging.format & PAGING_FORMAT_BN) == PAGING_FORMAT_BN) ? 
c0d04346:	7b31      	ldrb	r1, [r6, #12]
c0d04348:	0909      	lsrs	r1, r1, #4
c0d0434a:	290e      	cmp	r1, #14
c0d0434c:	d800      	bhi.n	c0d04350 <ux_layout_paging_prepro_common+0x118>
c0d0434e:	1c80      	adds	r0, r0, #2
c0d04350:	21b8      	movs	r1, #184	; 0xb8
c0d04352:	5270      	strh	r0, [r6, r1]
}
c0d04354:	4620      	mov	r0, r4
c0d04356:	b003      	add	sp, #12
c0d04358:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d0435a:	46c0      	nop			; (mov r8, r8)
c0d0435c:	20000250 	.word	0x20000250
c0d04360:	ffff8008 	.word	0xffff8008
c0d04364:	00001578 	.word	0x00001578
c0d04368:	0000162f 	.word	0x0000162f
c0d0436c:	0000158c 	.word	0x0000158c
c0d04370:	000015c6 	.word	0x000015c6

c0d04374 <ux_layout_paging_button_callback_common>:
static unsigned int ux_layout_paging_button_callback_common(unsigned int button_mask, unsigned int button_mask_counter, ux_layout_paging_redisplay_t redisplay) {
c0d04374:	b580      	push	{r7, lr}
c0d04376:	4a16      	ldr	r2, [pc, #88]	; (c0d043d0 <ux_layout_paging_button_callback_common+0x5c>)
  switch(button_mask) {
c0d04378:	4290      	cmp	r0, r2
c0d0437a:	d00b      	beq.n	c0d04394 <ux_layout_paging_button_callback_common+0x20>
c0d0437c:	4a15      	ldr	r2, [pc, #84]	; (c0d043d4 <ux_layout_paging_button_callback_common+0x60>)
c0d0437e:	4290      	cmp	r0, r2
c0d04380:	d013      	beq.n	c0d043aa <ux_layout_paging_button_callback_common+0x36>
c0d04382:	4a15      	ldr	r2, [pc, #84]	; (c0d043d8 <ux_layout_paging_button_callback_common+0x64>)
c0d04384:	4290      	cmp	r0, r2
c0d04386:	d10f      	bne.n	c0d043a8 <ux_layout_paging_button_callback_common+0x34>
  if (G_ux.layout_paging.current == 0) {
c0d04388:	4814      	ldr	r0, [pc, #80]	; (c0d043dc <ux_layout_paging_button_callback_common+0x68>)
c0d0438a:	6842      	ldr	r2, [r0, #4]
c0d0438c:	2a00      	cmp	r2, #0
c0d0438e:	d01b      	beq.n	c0d043c8 <ux_layout_paging_button_callback_common+0x54>
    G_ux.layout_paging.current--;
c0d04390:	1e52      	subs	r2, r2, #1
c0d04392:	e014      	b.n	c0d043be <ux_layout_paging_button_callback_common+0x4a>
      if (G_ux.layout_paging.count == 0 
c0d04394:	4911      	ldr	r1, [pc, #68]	; (c0d043dc <ux_layout_paging_button_callback_common+0x68>)
c0d04396:	6888      	ldr	r0, [r1, #8]
        || G_ux.layout_paging.count-1 == G_ux.layout_paging.current) {
c0d04398:	2800      	cmp	r0, #0
c0d0439a:	d003      	beq.n	c0d043a4 <ux_layout_paging_button_callback_common+0x30>
c0d0439c:	6849      	ldr	r1, [r1, #4]
c0d0439e:	1e40      	subs	r0, r0, #1
      if (G_ux.layout_paging.count == 0 
c0d043a0:	4288      	cmp	r0, r1
c0d043a2:	d101      	bne.n	c0d043a8 <ux_layout_paging_button_callback_common+0x34>
        ux_flow_validate();
c0d043a4:	f7ff fd52 	bl	c0d03e4c <ux_flow_validate>
  return 0;
c0d043a8:	bd80      	pop	{r7, pc}
  if (G_ux.layout_paging.current == G_ux.layout_paging.count-1) {
c0d043aa:	480c      	ldr	r0, [pc, #48]	; (c0d043dc <ux_layout_paging_button_callback_common+0x68>)
c0d043ac:	6842      	ldr	r2, [r0, #4]
c0d043ae:	6883      	ldr	r3, [r0, #8]
c0d043b0:	1e5b      	subs	r3, r3, #1
c0d043b2:	429a      	cmp	r2, r3
c0d043b4:	d102      	bne.n	c0d043bc <ux_layout_paging_button_callback_common+0x48>
    ux_flow_next();
c0d043b6:	f7ff fcd7 	bl	c0d03d68 <ux_flow_next>
  return 0;
c0d043ba:	bd80      	pop	{r7, pc}
    G_ux.layout_paging.current++;
c0d043bc:	1c52      	adds	r2, r2, #1
c0d043be:	6042      	str	r2, [r0, #4]
c0d043c0:	7800      	ldrb	r0, [r0, #0]
c0d043c2:	1e40      	subs	r0, r0, #1
c0d043c4:	4788      	blx	r1
  return 0;
c0d043c6:	bd80      	pop	{r7, pc}
    ux_flow_prev();
c0d043c8:	f7ff fcd4 	bl	c0d03d74 <ux_flow_prev>
  return 0;
c0d043cc:	bd80      	pop	{r7, pc}
c0d043ce:	46c0      	nop			; (mov r8, r8)
c0d043d0:	80000003 	.word	0x80000003
c0d043d4:	80000002 	.word	0x80000002
c0d043d8:	80000001 	.word	0x80000001
c0d043dc:	20000250 	.word	0x20000250

c0d043e0 <ux_layout_paging_compute>:
// return the number of pages to be displayed when current page to show is -1
unsigned int ux_layout_paging_compute(const char* text_to_split, 
                                      unsigned int page_to_display,
                                      ux_layout_paging_state_t* paging_state,
                                      bagl_font_id_e font
                                      ) {
c0d043e0:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d043e2:	b08d      	sub	sp, #52	; 0x34
c0d043e4:	2300      	movs	r3, #0
  UNUSED(font);
#endif

  // reset length and offset of lines
  memset(paging_state->offsets, 0, sizeof(paging_state->offsets));
  memset(paging_state->lengths, 0, sizeof(paging_state->lengths));
c0d043e6:	8193      	strh	r3, [r2, #12]
c0d043e8:	9302      	str	r3, [sp, #8]
  memset(paging_state->offsets, 0, sizeof(paging_state->offsets));
c0d043ea:	8153      	strh	r3, [r2, #10]

  // a page has been asked, but no page exists
  if (page_to_display >= paging_state->count && page_to_display != -1UL) {
c0d043ec:	1c4b      	adds	r3, r1, #1
c0d043ee:	9305      	str	r3, [sp, #20]
c0d043f0:	d003      	beq.n	c0d043fa <ux_layout_paging_compute+0x1a>
c0d043f2:	6853      	ldr	r3, [r2, #4]
c0d043f4:	428b      	cmp	r3, r1
c0d043f6:	d800      	bhi.n	c0d043fa <ux_layout_paging_compute+0x1a>
c0d043f8:	e0ae      	b.n	c0d04558 <ux_layout_paging_compute+0x178>
c0d043fa:	9104      	str	r1, [sp, #16]
c0d043fc:	9203      	str	r2, [sp, #12]
  }

  // compute offset/length of text of each line for the current page
  unsigned int page = 0;
  unsigned int line = 0;
  const char* start = (text_to_split ? STRPIC(text_to_split) : G_ux.externalText);
c0d043fe:	2800      	cmp	r0, #0
c0d04400:	d002      	beq.n	c0d04408 <ux_layout_paging_compute+0x28>
c0d04402:	f7fd fd9b 	bl	c0d01f3c <pic>
c0d04406:	e003      	b.n	c0d04410 <ux_layout_paging_compute+0x30>
c0d04408:	2041      	movs	r0, #65	; 0x41
c0d0440a:	0080      	lsls	r0, r0, #2
c0d0440c:	4954      	ldr	r1, [pc, #336]	; (c0d04560 <ux_layout_paging_compute+0x180>)
c0d0440e:	5808      	ldr	r0, [r1, r0]
c0d04410:	4604      	mov	r4, r0
  const char* start2 = start;
  const char* end = start + strlen(start);
c0d04412:	f000 fd19 	bl	c0d04e48 <strlen>
c0d04416:	4601      	mov	r1, r0
c0d04418:	2001      	movs	r0, #1
  while (start < end) {
c0d0441a:	9002      	str	r0, [sp, #8]
c0d0441c:	2901      	cmp	r1, #1
c0d0441e:	da00      	bge.n	c0d04422 <ux_layout_paging_compute+0x42>
c0d04420:	e09a      	b.n	c0d04558 <ux_layout_paging_compute+0x178>
c0d04422:	1866      	adds	r6, r4, r1
c0d04424:	484e      	ldr	r0, [pc, #312]	; (c0d04560 <ux_layout_paging_compute+0x180>)
c0d04426:	7b02      	ldrb	r2, [r0, #12]
c0d04428:	200f      	movs	r0, #15
c0d0442a:	900c      	str	r0, [sp, #48]	; 0x30
c0d0442c:	4002      	ands	r2, r0
c0d0442e:	2000      	movs	r0, #0
c0d04430:	9007      	str	r0, [sp, #28]
c0d04432:	9401      	str	r4, [sp, #4]
c0d04434:	9608      	str	r6, [sp, #32]
    unsigned int len = 0;
    unsigned int linew = 0; 
    const char* last_word_delim = start;
    // not reached end of content
    while (start + len < end
c0d04436:	42b4      	cmp	r4, r6
c0d04438:	4620      	mov	r0, r4
c0d0443a:	d800      	bhi.n	c0d0443e <ux_layout_paging_compute+0x5e>
c0d0443c:	4630      	mov	r0, r6
c0d0443e:	1b00      	subs	r0, r0, r4
c0d04440:	9006      	str	r0, [sp, #24]
c0d04442:	2300      	movs	r3, #0
c0d04444:	4620      	mov	r0, r4
c0d04446:	9409      	str	r4, [sp, #36]	; 0x24
c0d04448:	18e5      	adds	r5, r4, r3
c0d0444a:	42b5      	cmp	r5, r6
c0d0444c:	d239      	bcs.n	c0d044c2 <ux_layout_paging_compute+0xe2>
c0d0444e:	461f      	mov	r7, r3
c0d04450:	900a      	str	r0, [sp, #40]	; 0x28
      ) {
      // compute new line length
#ifdef HAVE_FONTS
      linew = bagl_compute_line_width(font, 0, start, len+1, BAGL_ENCODING_LATIN1);
#else // HAVE_FONTS
      linew = se_compute_line_width_light(start, len + 1, G_ux.layout_paging.format);
c0d04452:	1c5b      	adds	r3, r3, #1
  while (text_length--) {
c0d04454:	0618      	lsls	r0, r3, #24
c0d04456:	d024      	beq.n	c0d044a2 <ux_layout_paging_compute+0xc2>
c0d04458:	2100      	movs	r1, #0
c0d0445a:	930b      	str	r3, [sp, #44]	; 0x2c
c0d0445c:	461e      	mov	r6, r3
    if (current_char < NANOS_FIRST_CHAR || current_char > NANOS_LAST_CHAR) {
c0d0445e:	7820      	ldrb	r0, [r4, #0]
c0d04460:	b240      	sxtb	r0, r0
    current_char = *text;
c0d04462:	b2c3      	uxtb	r3, r0
    if (current_char < NANOS_FIRST_CHAR || current_char > NANOS_LAST_CHAR) {
c0d04464:	2b20      	cmp	r3, #32
c0d04466:	d30c      	bcc.n	c0d04482 <ux_layout_paging_compute+0xa2>
c0d04468:	2800      	cmp	r0, #0
c0d0446a:	d40a      	bmi.n	c0d04482 <ux_layout_paging_compute+0xa2>
c0d0446c:	483d      	ldr	r0, [pc, #244]	; (c0d04564 <ux_layout_paging_compute+0x184>)
c0d0446e:	4478      	add	r0, pc
c0d04470:	1818      	adds	r0, r3, r0
c0d04472:	3820      	subs	r0, #32
c0d04474:	7803      	ldrb	r3, [r0, #0]
      if ((text_format & PAGING_FORMAT_NB) == PAGING_FORMAT_NB) {
c0d04476:	2a0f      	cmp	r2, #15
c0d04478:	d108      	bne.n	c0d0448c <ux_layout_paging_compute+0xac>
        line_width += nanos_characters_width[current_char - NANOS_FIRST_CHAR] & 0x0F;
c0d0447a:	980c      	ldr	r0, [sp, #48]	; 0x30
c0d0447c:	4003      	ands	r3, r0
c0d0447e:	18c9      	adds	r1, r1, r3
c0d04480:	e006      	b.n	c0d04490 <ux_layout_paging_compute+0xb0>
      if (current_char == '\n' || current_char == '\r') {
c0d04482:	2b0a      	cmp	r3, #10
c0d04484:	d008      	beq.n	c0d04498 <ux_layout_paging_compute+0xb8>
c0d04486:	2b0d      	cmp	r3, #13
c0d04488:	d102      	bne.n	c0d04490 <ux_layout_paging_compute+0xb0>
c0d0448a:	e005      	b.n	c0d04498 <ux_layout_paging_compute+0xb8>
        line_width += (nanos_characters_width[current_char - NANOS_FIRST_CHAR] >> 0x04) & 0x0F;
c0d0448c:	0918      	lsrs	r0, r3, #4
c0d0448e:	1809      	adds	r1, r1, r0
c0d04490:	1e76      	subs	r6, r6, #1
    text++;
c0d04492:	1c64      	adds	r4, r4, #1
  while (text_length--) {
c0d04494:	0630      	lsls	r0, r6, #24
c0d04496:	d1e2      	bne.n	c0d0445e <ux_layout_paging_compute+0x7e>
#endif //HAVE_FONTS
      //if (start[len] )
      if (linew > PIXEL_PER_LINE) {
c0d04498:	2972      	cmp	r1, #114	; 0x72
c0d0449a:	9e08      	ldr	r6, [sp, #32]
c0d0449c:	9c09      	ldr	r4, [sp, #36]	; 0x24
c0d0449e:	9b0b      	ldr	r3, [sp, #44]	; 0x2c
c0d044a0:	d811      	bhi.n	c0d044c6 <ux_layout_paging_compute+0xe6>
        // we got a full line
        break;
      }
      unsigned char c = start[len];
c0d044a2:	7829      	ldrb	r1, [r5, #0]
  return c == ' ' || c == '\n' || c == '\t' || c == '-' || c == '_';
c0d044a4:	4608      	mov	r0, r1
c0d044a6:	3809      	subs	r0, #9
c0d044a8:	2802      	cmp	r0, #2
c0d044aa:	d306      	bcc.n	c0d044ba <ux_layout_paging_compute+0xda>
c0d044ac:	2920      	cmp	r1, #32
c0d044ae:	d004      	beq.n	c0d044ba <ux_layout_paging_compute+0xda>
c0d044b0:	292d      	cmp	r1, #45	; 0x2d
c0d044b2:	d002      	beq.n	c0d044ba <ux_layout_paging_compute+0xda>
      if (is_word_delim(c)) {
c0d044b4:	295f      	cmp	r1, #95	; 0x5f
c0d044b6:	d000      	beq.n	c0d044ba <ux_layout_paging_compute+0xda>
c0d044b8:	9d0a      	ldr	r5, [sp, #40]	; 0x28
c0d044ba:	4628      	mov	r0, r5
c0d044bc:	290a      	cmp	r1, #10
c0d044be:	d1c3      	bne.n	c0d04448 <ux_layout_paging_compute+0x68>
c0d044c0:	e003      	b.n	c0d044ca <ux_layout_paging_compute+0xea>
c0d044c2:	9b06      	ldr	r3, [sp, #24]
c0d044c4:	e001      	b.n	c0d044ca <ux_layout_paging_compute+0xea>
c0d044c6:	463b      	mov	r3, r7
c0d044c8:	980a      	ldr	r0, [sp, #40]	; 0x28
        break;
      }
    }

    // if not splitting line onto a word delimiter, then cut at the previous word_delim, adjust len accordingly (and a wor delim has been found already)
    if (start + len < end && last_word_delim != start && len) {
c0d044ca:	18e1      	adds	r1, r4, r3
c0d044cc:	42b1      	cmp	r1, r6
c0d044ce:	d215      	bcs.n	c0d044fc <ux_layout_paging_compute+0x11c>
c0d044d0:	2b00      	cmp	r3, #0
c0d044d2:	d013      	beq.n	c0d044fc <ux_layout_paging_compute+0x11c>
c0d044d4:	42a0      	cmp	r0, r4
c0d044d6:	d011      	beq.n	c0d044fc <ux_layout_paging_compute+0x11c>
c0d044d8:	4607      	mov	r7, r0
c0d044da:	461d      	mov	r5, r3
      // if line split within a word
      if ((!is_word_delim(start[len-1]) && !is_word_delim(start[len]))) {
c0d044dc:	1e48      	subs	r0, r1, #1
c0d044de:	7803      	ldrb	r3, [r0, #0]
  return c == ' ' || c == '\n' || c == '\t' || c == '-' || c == '_';
c0d044e0:	2b2c      	cmp	r3, #44	; 0x2c
c0d044e2:	dc06      	bgt.n	c0d044f2 <ux_layout_paging_compute+0x112>
c0d044e4:	4618      	mov	r0, r3
c0d044e6:	3809      	subs	r0, #9
c0d044e8:	2802      	cmp	r0, #2
c0d044ea:	d306      	bcc.n	c0d044fa <ux_layout_paging_compute+0x11a>
c0d044ec:	2b20      	cmp	r3, #32
c0d044ee:	d004      	beq.n	c0d044fa <ux_layout_paging_compute+0x11a>
c0d044f0:	e018      	b.n	c0d04524 <ux_layout_paging_compute+0x144>
c0d044f2:	2b2d      	cmp	r3, #45	; 0x2d
c0d044f4:	d001      	beq.n	c0d044fa <ux_layout_paging_compute+0x11a>
c0d044f6:	2b5f      	cmp	r3, #95	; 0x5f
c0d044f8:	d114      	bne.n	c0d04524 <ux_layout_paging_compute+0x144>
c0d044fa:	462b      	mov	r3, r5
        len = last_word_delim - start;
      }
    }

    // fill up the paging structure
    if (page_to_display != -1UL && page_to_display == page && page_to_display < paging_state->count) {
c0d044fc:	9805      	ldr	r0, [sp, #20]
c0d044fe:	2800      	cmp	r0, #0
c0d04500:	9904      	ldr	r1, [sp, #16]
c0d04502:	d006      	beq.n	c0d04512 <ux_layout_paging_compute+0x132>
c0d04504:	9807      	ldr	r0, [sp, #28]
c0d04506:	4288      	cmp	r0, r1
c0d04508:	d103      	bne.n	c0d04512 <ux_layout_paging_compute+0x132>
c0d0450a:	9803      	ldr	r0, [sp, #12]
c0d0450c:	6840      	ldr	r0, [r0, #4]
c0d0450e:	4288      	cmp	r0, r1
c0d04510:	d81d      	bhi.n	c0d0454e <ux_layout_paging_compute+0x16e>
        return 1;
      }
    }

    // prepare for next line
    start += len;
c0d04512:	18e4      	adds	r4, r4, r3
    line++;
    if (
#if UX_LAYOUT_PAGING_LINE_COUNT > 1
      line >= UX_LAYOUT_PAGING_LINE_COUNT && 
#endif // UX_LAYOUT_PAGING_LINE_COUNT
      start < end) {
c0d04514:	42b4      	cmp	r4, r6
c0d04516:	d202      	bcs.n	c0d0451e <ux_layout_paging_compute+0x13e>
c0d04518:	9807      	ldr	r0, [sp, #28]
c0d0451a:	1c40      	adds	r0, r0, #1
c0d0451c:	9007      	str	r0, [sp, #28]
  while (start < end) {
c0d0451e:	42b4      	cmp	r4, r6
c0d04520:	d389      	bcc.n	c0d04436 <ux_layout_paging_compute+0x56>
c0d04522:	e010      	b.n	c0d04546 <ux_layout_paging_compute+0x166>
      if ((!is_word_delim(start[len-1]) && !is_word_delim(start[len]))) {
c0d04524:	7809      	ldrb	r1, [r1, #0]
  return c == ' ' || c == '\n' || c == '\t' || c == '-' || c == '_';
c0d04526:	292c      	cmp	r1, #44	; 0x2c
c0d04528:	462b      	mov	r3, r5
c0d0452a:	dc06      	bgt.n	c0d0453a <ux_layout_paging_compute+0x15a>
c0d0452c:	4608      	mov	r0, r1
c0d0452e:	3809      	subs	r0, #9
c0d04530:	2802      	cmp	r0, #2
c0d04532:	d3e3      	bcc.n	c0d044fc <ux_layout_paging_compute+0x11c>
c0d04534:	2920      	cmp	r1, #32
c0d04536:	d0e1      	beq.n	c0d044fc <ux_layout_paging_compute+0x11c>
c0d04538:	e003      	b.n	c0d04542 <ux_layout_paging_compute+0x162>
c0d0453a:	292d      	cmp	r1, #45	; 0x2d
c0d0453c:	d0de      	beq.n	c0d044fc <ux_layout_paging_compute+0x11c>
c0d0453e:	295f      	cmp	r1, #95	; 0x5f
c0d04540:	d0dc      	beq.n	c0d044fc <ux_layout_paging_compute+0x11c>
        len = last_word_delim - start;
c0d04542:	1b3b      	subs	r3, r7, r4
c0d04544:	e7da      	b.n	c0d044fc <ux_layout_paging_compute+0x11c>
      line = 0;
    }
  }

  // return total number of page detected
  return page+1;
c0d04546:	9807      	ldr	r0, [sp, #28]
c0d04548:	1c40      	adds	r0, r0, #1
c0d0454a:	9002      	str	r0, [sp, #8]
c0d0454c:	e004      	b.n	c0d04558 <ux_layout_paging_compute+0x178>
c0d0454e:	9903      	ldr	r1, [sp, #12]
      paging_state->lengths[line] = len;
c0d04550:	818b      	strh	r3, [r1, #12]
      paging_state->offsets[line] = start - start2;
c0d04552:	9801      	ldr	r0, [sp, #4]
c0d04554:	1a20      	subs	r0, r4, r0
c0d04556:	8148      	strh	r0, [r1, #10]
}
c0d04558:	9802      	ldr	r0, [sp, #8]
c0d0455a:	b00d      	add	sp, #52	; 0x34
c0d0455c:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d0455e:	46c0      	nop			; (mov r8, r8)
c0d04560:	20000250 	.word	0x20000250
c0d04564:	00001453 	.word	0x00001453

c0d04568 <ux_layout_pb_prepro>:
#else
  #error "BAGL_WIDTH/BAGL_HEIGHT not defined"
#endif
};

const bagl_element_t* ux_layout_pb_prepro(const bagl_element_t* element) {
c0d04568:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0456a:	b081      	sub	sp, #4
c0d0456c:	4606      	mov	r6, r0
  // don't display if null
  const ux_layout_pb_params_t* params = (const ux_layout_pb_params_t*)ux_stack_get_current_step_params();
c0d0456e:	f7ff fd35 	bl	c0d03fdc <ux_stack_get_current_step_params>
c0d04572:	4605      	mov	r5, r0

	// copy element before any mod
	memmove(&G_ux.tmp_element, element, sizeof(bagl_element_t));
c0d04574:	4f11      	ldr	r7, [pc, #68]	; (c0d045bc <ux_layout_pb_prepro+0x54>)
c0d04576:	463c      	mov	r4, r7
c0d04578:	34a0      	adds	r4, #160	; 0xa0
c0d0457a:	2220      	movs	r2, #32
c0d0457c:	4620      	mov	r0, r4
c0d0457e:	4631      	mov	r1, r6
c0d04580:	f000 fb3c 	bl	c0d04bfc <__aeabi_memmove>

  // for dashboard, setup the current application's name
  switch (element->component.userid) {
c0d04584:	7870      	ldrb	r0, [r6, #1]
c0d04586:	280f      	cmp	r0, #15
c0d04588:	dc06      	bgt.n	c0d04598 <ux_layout_pb_prepro+0x30>
c0d0458a:	2801      	cmp	r0, #1
c0d0458c:	d00a      	beq.n	c0d045a4 <ux_layout_pb_prepro+0x3c>
c0d0458e:	2802      	cmp	r0, #2
c0d04590:	d111      	bne.n	c0d045b6 <ux_layout_pb_prepro+0x4e>
  			return NULL;
  		}
  		break;

  	case 0x02:
  		if (ux_flow_is_last()) {
c0d04592:	f7ff fb83 	bl	c0d03c9c <ux_flow_is_last>
c0d04596:	e007      	b.n	c0d045a8 <ux_layout_pb_prepro+0x40>
  switch (element->component.userid) {
c0d04598:	2810      	cmp	r0, #16
c0d0459a:	d009      	beq.n	c0d045b0 <ux_layout_pb_prepro+0x48>
c0d0459c:	2811      	cmp	r0, #17
c0d0459e:	d10a      	bne.n	c0d045b6 <ux_layout_pb_prepro+0x4e>
    case 0x10:
  		G_ux.tmp_element.text = (const char*)params->icon;
      break;

    case 0x11:
  		G_ux.tmp_element.text = params->line1;
c0d045a0:	6868      	ldr	r0, [r5, #4]
c0d045a2:	e006      	b.n	c0d045b2 <ux_layout_pb_prepro+0x4a>
  		if (ux_flow_is_first()) {
c0d045a4:	f7ff fb54 	bl	c0d03c50 <ux_flow_is_first>
c0d045a8:	2800      	cmp	r0, #0
c0d045aa:	d004      	beq.n	c0d045b6 <ux_layout_pb_prepro+0x4e>
c0d045ac:	2400      	movs	r4, #0
c0d045ae:	e002      	b.n	c0d045b6 <ux_layout_pb_prepro+0x4e>
  		G_ux.tmp_element.text = (const char*)params->icon;
c0d045b0:	6828      	ldr	r0, [r5, #0]
c0d045b2:	21bc      	movs	r1, #188	; 0xbc
c0d045b4:	5078      	str	r0, [r7, r1]
      break;
  }
  return &G_ux.tmp_element;
}
c0d045b6:	4620      	mov	r0, r4
c0d045b8:	b001      	add	sp, #4
c0d045ba:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d045bc:	20000250 	.word	0x20000250

c0d045c0 <ux_layout_pb_init>:

void ux_layout_pb_init(unsigned int stack_slot) {
c0d045c0:	b510      	push	{r4, lr}
c0d045c2:	4604      	mov	r4, r0
  ux_stack_init(stack_slot);
c0d045c4:	f000 f97c 	bl	c0d048c0 <ux_stack_init>
c0d045c8:	2024      	movs	r0, #36	; 0x24
  G_ux.stack[stack_slot].element_arrays[0].element_array = ux_layout_pb_elements;
c0d045ca:	4360      	muls	r0, r4
c0d045cc:	490b      	ldr	r1, [pc, #44]	; (c0d045fc <ux_layout_pb_init+0x3c>)
c0d045ce:	1808      	adds	r0, r1, r0
c0d045d0:	21c8      	movs	r1, #200	; 0xc8
c0d045d2:	2205      	movs	r2, #5
  G_ux.stack[stack_slot].element_arrays[0].element_array_count = ARRAYLEN(ux_layout_pb_elements);
c0d045d4:	5442      	strb	r2, [r0, r1]
c0d045d6:	21c4      	movs	r1, #196	; 0xc4
  G_ux.stack[stack_slot].element_arrays[0].element_array = ux_layout_pb_elements;
c0d045d8:	4a09      	ldr	r2, [pc, #36]	; (c0d04600 <ux_layout_pb_init+0x40>)
c0d045da:	447a      	add	r2, pc
c0d045dc:	5042      	str	r2, [r0, r1]
c0d045de:	21d4      	movs	r1, #212	; 0xd4
  G_ux.stack[stack_slot].element_arrays_count = 1;
  G_ux.stack[stack_slot].screen_before_element_display_callback = ux_layout_pb_prepro;
  G_ux.stack[stack_slot].button_push_callback = ux_flow_button_callback;
c0d045e0:	4a08      	ldr	r2, [pc, #32]	; (c0d04604 <ux_layout_pb_init+0x44>)
c0d045e2:	447a      	add	r2, pc
c0d045e4:	5042      	str	r2, [r0, r1]
c0d045e6:	21d0      	movs	r1, #208	; 0xd0
  G_ux.stack[stack_slot].screen_before_element_display_callback = ux_layout_pb_prepro;
c0d045e8:	4a07      	ldr	r2, [pc, #28]	; (c0d04608 <ux_layout_pb_init+0x48>)
c0d045ea:	447a      	add	r2, pc
c0d045ec:	5042      	str	r2, [r0, r1]
c0d045ee:	21c1      	movs	r1, #193	; 0xc1
c0d045f0:	2201      	movs	r2, #1
  G_ux.stack[stack_slot].element_arrays_count = 1;
c0d045f2:	5442      	strb	r2, [r0, r1]
  ux_stack_display(stack_slot);
c0d045f4:	4620      	mov	r0, r4
c0d045f6:	f000 f93d 	bl	c0d04874 <ux_stack_display>
}
c0d045fa:	bd10      	pop	{r4, pc}
c0d045fc:	20000250 	.word	0x20000250
c0d04600:	0000134a 	.word	0x0000134a
c0d04604:	fffff98f 	.word	0xfffff98f
c0d04608:	ffffff7b 	.word	0xffffff7b

c0d0460c <ux_layout_pbb_prepro>:
#else
  #error "BAGL_WIDTH/BAGL_HEIGHT not defined"
#endif
};

const bagl_element_t* ux_layout_pbb_prepro(const bagl_element_t* element) {
c0d0460c:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0460e:	b081      	sub	sp, #4
c0d04610:	4606      	mov	r6, r0
  // don't display if null
  const ux_layout_icon_strings_params_t* params = (const ux_layout_icon_strings_params_t*)ux_stack_get_current_step_params();
c0d04612:	f7ff fce3 	bl	c0d03fdc <ux_stack_get_current_step_params>
c0d04616:	4605      	mov	r5, r0

	// ocpy element before any mod
	memmove(&G_ux.tmp_element, element, sizeof(bagl_element_t));
c0d04618:	4f14      	ldr	r7, [pc, #80]	; (c0d0466c <ux_layout_pbb_prepro+0x60>)
c0d0461a:	463c      	mov	r4, r7
c0d0461c:	34a0      	adds	r4, #160	; 0xa0
c0d0461e:	2220      	movs	r2, #32
c0d04620:	4620      	mov	r0, r4
c0d04622:	4631      	mov	r1, r6
c0d04624:	f000 faea 	bl	c0d04bfc <__aeabi_memmove>

  // for dashboard, setup the current application's name
  switch (element->component.userid) {
c0d04628:	7870      	ldrb	r0, [r6, #1]
c0d0462a:	280f      	cmp	r0, #15
c0d0462c:	dc07      	bgt.n	c0d0463e <ux_layout_pbb_prepro+0x32>
c0d0462e:	2801      	cmp	r0, #1
c0d04630:	d011      	beq.n	c0d04656 <ux_layout_pbb_prepro+0x4a>
c0d04632:	2802      	cmp	r0, #2
c0d04634:	d012      	beq.n	c0d0465c <ux_layout_pbb_prepro+0x50>
c0d04636:	280f      	cmp	r0, #15
c0d04638:	d115      	bne.n	c0d04666 <ux_layout_pbb_prepro+0x5a>
  			return NULL;
  		}
  		break;

    case 0x0F:
  		G_ux.tmp_element.text = (const char*)params->icon;
c0d0463a:	6828      	ldr	r0, [r5, #0]
c0d0463c:	e008      	b.n	c0d04650 <ux_layout_pbb_prepro+0x44>
  switch (element->component.userid) {
c0d0463e:	3810      	subs	r0, #16
c0d04640:	2802      	cmp	r0, #2
c0d04642:	d210      	bcs.n	c0d04666 <ux_layout_pbb_prepro+0x5a>
c0d04644:	20a1      	movs	r0, #161	; 0xa1
      break;

    case 0x10:
    case 0x11:
      G_ux.tmp_element.text = params->lines[G_ux.tmp_element.component.userid&0xF];
c0d04646:	5c38      	ldrb	r0, [r7, r0]
c0d04648:	0700      	lsls	r0, r0, #28
c0d0464a:	0e80      	lsrs	r0, r0, #26
c0d0464c:	1828      	adds	r0, r5, r0
c0d0464e:	6840      	ldr	r0, [r0, #4]
c0d04650:	21bc      	movs	r1, #188	; 0xbc
c0d04652:	5078      	str	r0, [r7, r1]
c0d04654:	e007      	b.n	c0d04666 <ux_layout_pbb_prepro+0x5a>
  		if (ux_flow_is_first()) {
c0d04656:	f7ff fafb 	bl	c0d03c50 <ux_flow_is_first>
c0d0465a:	e001      	b.n	c0d04660 <ux_layout_pbb_prepro+0x54>
  		if (ux_flow_is_last()) {
c0d0465c:	f7ff fb1e 	bl	c0d03c9c <ux_flow_is_last>
c0d04660:	2800      	cmp	r0, #0
c0d04662:	d000      	beq.n	c0d04666 <ux_layout_pbb_prepro+0x5a>
c0d04664:	2400      	movs	r4, #0
      break;

  }
  return &G_ux.tmp_element;
}
c0d04666:	4620      	mov	r0, r4
c0d04668:	b001      	add	sp, #4
c0d0466a:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d0466c:	20000250 	.word	0x20000250

c0d04670 <ux_layout_pbb_init_common>:


void ux_layout_pbb_init_common(unsigned int stack_slot) {
c0d04670:	b510      	push	{r4, lr}
c0d04672:	4604      	mov	r4, r0
  ux_stack_init(stack_slot);
c0d04674:	f000 f924 	bl	c0d048c0 <ux_stack_init>
c0d04678:	2024      	movs	r0, #36	; 0x24
  G_ux.stack[stack_slot].element_arrays[0].element_array = ux_layout_pbb_elements;
c0d0467a:	4360      	muls	r0, r4
c0d0467c:	4908      	ldr	r1, [pc, #32]	; (c0d046a0 <ux_layout_pbb_init_common+0x30>)
c0d0467e:	1808      	adds	r0, r1, r0
c0d04680:	21c8      	movs	r1, #200	; 0xc8
c0d04682:	2206      	movs	r2, #6
  G_ux.stack[stack_slot].element_arrays[0].element_array_count = ARRAYLEN(ux_layout_pbb_elements);
c0d04684:	5442      	strb	r2, [r0, r1]
c0d04686:	21c4      	movs	r1, #196	; 0xc4
  G_ux.stack[stack_slot].element_arrays[0].element_array = ux_layout_pbb_elements;
c0d04688:	4a06      	ldr	r2, [pc, #24]	; (c0d046a4 <ux_layout_pbb_init_common+0x34>)
c0d0468a:	447a      	add	r2, pc
c0d0468c:	5042      	str	r2, [r0, r1]
c0d0468e:	21d4      	movs	r1, #212	; 0xd4
  G_ux.stack[stack_slot].element_arrays_count = 1;
  G_ux.stack[stack_slot].button_push_callback = ux_flow_button_callback;
c0d04690:	4a05      	ldr	r2, [pc, #20]	; (c0d046a8 <ux_layout_pbb_init_common+0x38>)
c0d04692:	447a      	add	r2, pc
c0d04694:	5042      	str	r2, [r0, r1]
c0d04696:	21c1      	movs	r1, #193	; 0xc1
c0d04698:	2201      	movs	r2, #1
  G_ux.stack[stack_slot].element_arrays_count = 1;
c0d0469a:	5442      	strb	r2, [r0, r1]
}
c0d0469c:	bd10      	pop	{r4, pc}
c0d0469e:	46c0      	nop			; (mov r8, r8)
c0d046a0:	20000250 	.word	0x20000250
c0d046a4:	0000133a 	.word	0x0000133a
c0d046a8:	fffff8df 	.word	0xfffff8df

c0d046ac <ux_layout_pnn_prepro>:

/*********************************************************************************
 * 4 text lines
 */

const bagl_element_t* ux_layout_pnn_prepro(const bagl_element_t* element) {
c0d046ac:	b580      	push	{r7, lr}
  const bagl_element_t* e = ux_layout_pbb_prepro(element);
c0d046ae:	f7ff ffad 	bl	c0d0460c <ux_layout_pbb_prepro>
  if (e && G_ux.tmp_element.component.userid >= 0x10) {
c0d046b2:	2800      	cmp	r0, #0
c0d046b4:	d007      	beq.n	c0d046c6 <ux_layout_pnn_prepro+0x1a>
c0d046b6:	22a1      	movs	r2, #161	; 0xa1
c0d046b8:	4903      	ldr	r1, [pc, #12]	; (c0d046c8 <ux_layout_pnn_prepro+0x1c>)
c0d046ba:	5c8a      	ldrb	r2, [r1, r2]
c0d046bc:	2a10      	cmp	r2, #16
c0d046be:	d302      	bcc.n	c0d046c6 <ux_layout_pnn_prepro+0x1a>
c0d046c0:	22b8      	movs	r2, #184	; 0xb8
c0d046c2:	230a      	movs	r3, #10
    // The centering depends on the screensize.
#if (BAGL_WIDTH==128 && BAGL_HEIGHT==64)
    G_ux.tmp_element.component.font_id = BAGL_FONT_OPEN_SANS_REGULAR_11px|BAGL_FONT_ALIGNMENT_CENTER;
#elif (BAGL_WIDTH==128 && BAGL_HEIGHT==32)
    G_ux.tmp_element.component.font_id = BAGL_FONT_OPEN_SANS_REGULAR_11px;
c0d046c4:	528b      	strh	r3, [r1, r2]
#else
  #error "BAGL_WIDTH/BAGL_HEIGHT not defined"
#endif
  }
  return e;
c0d046c6:	bd80      	pop	{r7, pc}
c0d046c8:	20000250 	.word	0x20000250

c0d046cc <ux_layout_pnn_init>:
}

void ux_layout_pnn_init(unsigned int stack_slot) { 
c0d046cc:	b510      	push	{r4, lr}
c0d046ce:	4604      	mov	r4, r0
  ux_layout_pbb_init_common(stack_slot);
c0d046d0:	f7ff ffce 	bl	c0d04670 <ux_layout_pbb_init_common>
c0d046d4:	2024      	movs	r0, #36	; 0x24
  G_ux.stack[stack_slot].screen_before_element_display_callback = ux_layout_pnn_prepro;
c0d046d6:	4360      	muls	r0, r4
c0d046d8:	4904      	ldr	r1, [pc, #16]	; (c0d046ec <ux_layout_pnn_init+0x20>)
c0d046da:	1808      	adds	r0, r1, r0
c0d046dc:	21d0      	movs	r1, #208	; 0xd0
c0d046de:	4a04      	ldr	r2, [pc, #16]	; (c0d046f0 <ux_layout_pnn_init+0x24>)
c0d046e0:	447a      	add	r2, pc
c0d046e2:	5042      	str	r2, [r0, r1]
  ux_stack_display(stack_slot);
c0d046e4:	4620      	mov	r0, r4
c0d046e6:	f000 f8c5 	bl	c0d04874 <ux_stack_display>
}
c0d046ea:	bd10      	pop	{r4, pc}
c0d046ec:	20000250 	.word	0x20000250
c0d046f0:	ffffffc9 	.word	0xffffffc9

c0d046f4 <ux_layout_strings_prepro>:
    G_ux.stack[stack_slot].ticker_value = ms;
    G_ux.stack[stack_slot].ticker_interval = ms; // restart
  }
}

const bagl_element_t* ux_layout_strings_prepro(const bagl_element_t* element) {
c0d046f4:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d046f6:	b081      	sub	sp, #4
c0d046f8:	4606      	mov	r6, r0
  // don't display if null
  const ux_layout_strings_params_t* params = (const ux_layout_strings_params_t*)ux_stack_get_current_step_params();
c0d046fa:	f7ff fc6f 	bl	c0d03fdc <ux_stack_get_current_step_params>
c0d046fe:	4605      	mov	r5, r0
  // ocpy element before any mod
  memmove(&G_ux.tmp_element, element, sizeof(bagl_element_t));
c0d04700:	4f11      	ldr	r7, [pc, #68]	; (c0d04748 <ux_layout_strings_prepro+0x54>)
c0d04702:	463c      	mov	r4, r7
c0d04704:	34a0      	adds	r4, #160	; 0xa0
c0d04706:	2220      	movs	r2, #32
c0d04708:	4620      	mov	r0, r4
c0d0470a:	4631      	mov	r1, r6
c0d0470c:	f000 fa76 	bl	c0d04bfc <__aeabi_memmove>

  // for dashboard, setup the current application's name
  switch (element->component.userid) {
c0d04710:	7870      	ldrb	r0, [r6, #1]
c0d04712:	2802      	cmp	r0, #2
c0d04714:	d004      	beq.n	c0d04720 <ux_layout_strings_prepro+0x2c>
c0d04716:	2801      	cmp	r0, #1
c0d04718:	d108      	bne.n	c0d0472c <ux_layout_strings_prepro+0x38>
    case 0x01:
      if (ux_flow_is_first()) {
c0d0471a:	f7ff fa99 	bl	c0d03c50 <ux_flow_is_first>
c0d0471e:	e001      	b.n	c0d04724 <ux_layout_strings_prepro+0x30>
        return NULL;
      }
      break;

    case 0x02:
      if (ux_flow_is_last()) {
c0d04720:	f7ff fabc 	bl	c0d03c9c <ux_flow_is_last>
c0d04724:	2800      	cmp	r0, #0
c0d04726:	d00b      	beq.n	c0d04740 <ux_layout_strings_prepro+0x4c>
c0d04728:	2400      	movs	r4, #0
c0d0472a:	e009      	b.n	c0d04740 <ux_layout_strings_prepro+0x4c>
c0d0472c:	20a1      	movs	r0, #161	; 0xa1
        return NULL;
      }
      break;

    default:
      if (G_ux.tmp_element.component.userid&0xF0) {
c0d0472e:	5c38      	ldrb	r0, [r7, r0]
c0d04730:	0601      	lsls	r1, r0, #24
c0d04732:	0f09      	lsrs	r1, r1, #28
c0d04734:	d004      	beq.n	c0d04740 <ux_layout_strings_prepro+0x4c>
        G_ux.tmp_element.text = params->lines[G_ux.tmp_element.component.userid&0xF];
c0d04736:	0700      	lsls	r0, r0, #28
c0d04738:	0e80      	lsrs	r0, r0, #26
c0d0473a:	5828      	ldr	r0, [r5, r0]
c0d0473c:	21bc      	movs	r1, #188	; 0xbc
c0d0473e:	5078      	str	r0, [r7, r1]
      }
      break;
  }
  return &G_ux.tmp_element;
}
c0d04740:	4620      	mov	r0, r4
c0d04742:	b001      	add	sp, #4
c0d04744:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d04746:	46c0      	nop			; (mov r8, r8)
c0d04748:	20000250 	.word	0x20000250

c0d0474c <ux_menulist_button>:

#ifndef TARGET_BLUE

void ux_menulist_refresh(unsigned int stack_slot);

unsigned int ux_menulist_button(unsigned int button_mask, unsigned int button_mask_counter) {
c0d0474c:	b5b0      	push	{r4, r5, r7, lr}
c0d0474e:	4917      	ldr	r1, [pc, #92]	; (c0d047ac <ux_menulist_button+0x60>)
  UNUSED(button_mask_counter);

  switch(button_mask) {
c0d04750:	4288      	cmp	r0, r1
c0d04752:	d011      	beq.n	c0d04778 <ux_menulist_button+0x2c>
c0d04754:	4916      	ldr	r1, [pc, #88]	; (c0d047b0 <ux_menulist_button+0x64>)
c0d04756:	4288      	cmp	r0, r1
c0d04758:	d016      	beq.n	c0d04788 <ux_menulist_button+0x3c>
c0d0475a:	4916      	ldr	r1, [pc, #88]	; (c0d047b4 <ux_menulist_button+0x68>)
c0d0475c:	4288      	cmp	r0, r1
c0d0475e:	d123      	bne.n	c0d047a8 <ux_menulist_button+0x5c>
c0d04760:	20fc      	movs	r0, #252	; 0xfc
    case BUTTON_EVT_RELEASED|BUTTON_LEFT:
      if (G_ux.menulist_getter(G_ux.menulist_current-1UL)) {
c0d04762:	4c15      	ldr	r4, [pc, #84]	; (c0d047b8 <ux_menulist_button+0x6c>)
c0d04764:	5821      	ldr	r1, [r4, r0]
c0d04766:	25e4      	movs	r5, #228	; 0xe4
c0d04768:	5960      	ldr	r0, [r4, r5]
c0d0476a:	1e40      	subs	r0, r0, #1
c0d0476c:	4788      	blx	r1
c0d0476e:	2800      	cmp	r0, #0
c0d04770:	d01a      	beq.n	c0d047a8 <ux_menulist_button+0x5c>
      	G_ux.menulist_current--;
c0d04772:	5960      	ldr	r0, [r4, r5]
c0d04774:	1e40      	subs	r0, r0, #1
c0d04776:	e012      	b.n	c0d0479e <ux_menulist_button+0x52>
c0d04778:	20e4      	movs	r0, #228	; 0xe4
      	G_ux.menulist_current++;
      	ux_menulist_refresh(G_ux.stack_count-1);
      }
      break;
    case BUTTON_EVT_RELEASED|BUTTON_LEFT|BUTTON_RIGHT:
      G_ux.menulist_selector(G_ux.menulist_current);
c0d0477a:	490f      	ldr	r1, [pc, #60]	; (c0d047b8 <ux_menulist_button+0x6c>)
c0d0477c:	5808      	ldr	r0, [r1, r0]
c0d0477e:	2201      	movs	r2, #1
c0d04780:	0212      	lsls	r2, r2, #8
c0d04782:	5889      	ldr	r1, [r1, r2]
c0d04784:	4788      	blx	r1
c0d04786:	e00f      	b.n	c0d047a8 <ux_menulist_button+0x5c>
c0d04788:	20fc      	movs	r0, #252	; 0xfc
      if (G_ux.menulist_getter(G_ux.menulist_current+1UL)) {
c0d0478a:	4c0b      	ldr	r4, [pc, #44]	; (c0d047b8 <ux_menulist_button+0x6c>)
c0d0478c:	5821      	ldr	r1, [r4, r0]
c0d0478e:	25e4      	movs	r5, #228	; 0xe4
c0d04790:	5960      	ldr	r0, [r4, r5]
c0d04792:	1c40      	adds	r0, r0, #1
c0d04794:	4788      	blx	r1
c0d04796:	2800      	cmp	r0, #0
c0d04798:	d006      	beq.n	c0d047a8 <ux_menulist_button+0x5c>
      	G_ux.menulist_current++;
c0d0479a:	5960      	ldr	r0, [r4, r5]
c0d0479c:	1c40      	adds	r0, r0, #1
c0d0479e:	5160      	str	r0, [r4, r5]
c0d047a0:	7820      	ldrb	r0, [r4, #0]
c0d047a2:	1e40      	subs	r0, r0, #1
c0d047a4:	f000 f80a 	bl	c0d047bc <ux_menulist_refresh>
c0d047a8:	2000      	movs	r0, #0
      break;
  }
  return 0;
c0d047aa:	bdb0      	pop	{r4, r5, r7, pc}
c0d047ac:	80000003 	.word	0x80000003
c0d047b0:	80000002 	.word	0x80000002
c0d047b4:	80000001 	.word	0x80000001
c0d047b8:	20000250 	.word	0x20000250

c0d047bc <ux_menulist_refresh>:
}

void ux_menulist_refresh(unsigned int stack_slot) {
c0d047bc:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d047be:	b081      	sub	sp, #4
c0d047c0:	4604      	mov	r4, r0
c0d047c2:	2001      	movs	r0, #1
c0d047c4:	43c6      	mvns	r6, r0
c0d047c6:	4d0c      	ldr	r5, [pc, #48]	; (c0d047f8 <ux_menulist_refresh+0x3c>)
c0d047c8:	462f      	mov	r7, r5
c0d047ca:	37e8      	adds	r7, #232	; 0xe8
c0d047cc:	20fc      	movs	r0, #252	; 0xfc
  // set values
  int i;
  for (i = 0; i < 5; i++) {
    G_ux.menulist_params.lines[i] = G_ux.menulist_getter(G_ux.menulist_current+i-2);
c0d047ce:	5829      	ldr	r1, [r5, r0]
c0d047d0:	20e4      	movs	r0, #228	; 0xe4
c0d047d2:	5828      	ldr	r0, [r5, r0]
c0d047d4:	1830      	adds	r0, r6, r0
c0d047d6:	4788      	blx	r1
c0d047d8:	c701      	stmia	r7!, {r0}
  for (i = 0; i < 5; i++) {
c0d047da:	1c76      	adds	r6, r6, #1
c0d047dc:	2e03      	cmp	r6, #3
c0d047de:	d1f5      	bne.n	c0d047cc <ux_menulist_refresh+0x10>
  }
  // display
  ux_layout_nnbnn_init(stack_slot);
c0d047e0:	4620      	mov	r0, r4
c0d047e2:	f7ff fc73 	bl	c0d040cc <ux_layout_nnbnn_init>
c0d047e6:	2024      	movs	r0, #36	; 0x24
  // change callback to the menulist one
  G_ux.stack[stack_slot].button_push_callback = ux_menulist_button;
c0d047e8:	4360      	muls	r0, r4
c0d047ea:	1828      	adds	r0, r5, r0
c0d047ec:	21d4      	movs	r1, #212	; 0xd4
c0d047ee:	4a03      	ldr	r2, [pc, #12]	; (c0d047fc <ux_menulist_refresh+0x40>)
c0d047f0:	447a      	add	r2, pc
c0d047f2:	5042      	str	r2, [r0, r1]
}
c0d047f4:	b001      	add	sp, #4
c0d047f6:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d047f8:	20000250 	.word	0x20000250
c0d047fc:	ffffff59 	.word	0xffffff59

c0d04800 <ux_menulist_init_select>:
  );

void ux_menulist_init_select(unsigned int stack_slot, 
                      list_item_value_t getter, 
                      list_item_select_t selector, 
                      unsigned int selected_item_idx) {
c0d04800:	b5b0      	push	{r4, r5, r7, lr}
c0d04802:	4604      	mov	r4, r0
c0d04804:	20fc      	movs	r0, #252	; 0xfc
  G_ux.menulist_current  = selected_item_idx;
c0d04806:	4d0c      	ldr	r5, [pc, #48]	; (c0d04838 <ux_menulist_init_select+0x38>)
  G_ux.menulist_getter = getter;
c0d04808:	5029      	str	r1, [r5, r0]
c0d0480a:	20e4      	movs	r0, #228	; 0xe4
  G_ux.menulist_current  = selected_item_idx;
c0d0480c:	502b      	str	r3, [r5, r0]
c0d0480e:	2001      	movs	r0, #1
c0d04810:	0200      	lsls	r0, r0, #8
  G_ux.menulist_selector = selector;
c0d04812:	502a      	str	r2, [r5, r0]

  // ensure the current flow step reference the G_ux.menulist_params to ensure strings displayed correctly.
  // if not, then use the forged step (and display it if top of ux stack)
  if (ux_stack_get_step_params(stack_slot) != (void*)&G_ux.menulist_params) {
c0d04814:	4620      	mov	r0, r4
c0d04816:	f7ff fbc9 	bl	c0d03fac <ux_stack_get_step_params>
c0d0481a:	35e8      	adds	r5, #232	; 0xe8
c0d0481c:	42a8      	cmp	r0, r5
c0d0481e:	d006      	beq.n	c0d0482e <ux_menulist_init_select+0x2e>
    ux_flow_init(stack_slot, ux_menulist_constflow, NULL);
c0d04820:	4906      	ldr	r1, [pc, #24]	; (c0d0483c <ux_menulist_init_select+0x3c>)
c0d04822:	4479      	add	r1, pc
c0d04824:	2200      	movs	r2, #0
c0d04826:	4620      	mov	r0, r4
c0d04828:	f7ff fb68 	bl	c0d03efc <ux_flow_init>
  }
  else {
    ux_menulist_refresh(stack_slot);
  }
}
c0d0482c:	bdb0      	pop	{r4, r5, r7, pc}
    ux_menulist_refresh(stack_slot);
c0d0482e:	4620      	mov	r0, r4
c0d04830:	f7ff ffc4 	bl	c0d047bc <ux_menulist_refresh>
}
c0d04834:	bdb0      	pop	{r4, r5, r7, pc}
c0d04836:	46c0      	nop			; (mov r8, r8)
c0d04838:	20000250 	.word	0x20000250
c0d0483c:	00001272 	.word	0x00001272

c0d04840 <ux_menulist_init>:

// based on a nnbnn layout
void ux_menulist_init(unsigned int stack_slot, 
                             list_item_value_t getter, 
                             list_item_select_t selector) {
c0d04840:	b580      	push	{r7, lr}
c0d04842:	2300      	movs	r3, #0
	ux_menulist_init_select(stack_slot, getter, selector, 0);
c0d04844:	f7ff ffdc 	bl	c0d04800 <ux_menulist_init_select>
}
c0d04848:	bd80      	pop	{r7, pc}
	...

c0d0484c <ux_stack_push>:
  }

  return 0;
}

unsigned int ux_stack_push(void) {
c0d0484c:	b510      	push	{r4, lr}
  // only push if an available slot exists
  if (G_ux.stack_count < ARRAYLEN(G_ux.stack)) {
c0d0484e:	4c08      	ldr	r4, [pc, #32]	; (c0d04870 <ux_stack_push+0x24>)
c0d04850:	7820      	ldrb	r0, [r4, #0]
c0d04852:	2800      	cmp	r0, #0
c0d04854:	d10a      	bne.n	c0d0486c <ux_stack_push+0x20>
    memset(&G_ux.stack[G_ux.stack_count], 0, sizeof(G_ux.stack[0]));
c0d04856:	4620      	mov	r0, r4
c0d04858:	30c0      	adds	r0, #192	; 0xc0
c0d0485a:	2124      	movs	r1, #36	; 0x24
c0d0485c:	f000 f9c4 	bl	c0d04be8 <__aeabi_memclr>
c0d04860:	2000      	movs	r0, #0
#ifdef HAVE_UX_FLOW
    memset(&G_ux.flow_stack[G_ux.stack_count], 0, sizeof(G_ux.flow_stack[0]));
c0d04862:	6160      	str	r0, [r4, #20]
c0d04864:	61a0      	str	r0, [r4, #24]
c0d04866:	61e0      	str	r0, [r4, #28]
c0d04868:	2001      	movs	r0, #1
#endif // HAVE_UX_FLOW
    G_ux.stack_count++;
c0d0486a:	7020      	strb	r0, [r4, #0]
  }
  // return the stack top index
  return G_ux.stack_count - 1;
c0d0486c:	1e40      	subs	r0, r0, #1
c0d0486e:	bd10      	pop	{r4, pc}
c0d04870:	20000250 	.word	0x20000250

c0d04874 <ux_stack_display>:
}
#endif // UX_STACK_SLOT_ARRAY_COUNT == 1
#endif // HAVE_SE_SCREEN

// common code for all screens
void ux_stack_display(unsigned int stack_slot) {
c0d04874:	b5b0      	push	{r4, r5, r7, lr}
c0d04876:	4604      	mov	r4, r0
  // don't display any elements of a previous screen replacement
  if (G_ux.stack_count > 0 && stack_slot + 1 == G_ux.stack_count) {
c0d04878:	4810      	ldr	r0, [pc, #64]	; (c0d048bc <ux_stack_display+0x48>)
c0d0487a:	7801      	ldrb	r1, [r0, #0]
c0d0487c:	2900      	cmp	r1, #0
c0d0487e:	d00e      	beq.n	c0d0489e <ux_stack_display+0x2a>
c0d04880:	1c62      	adds	r2, r4, #1
c0d04882:	428a      	cmp	r2, r1
c0d04884:	d10b      	bne.n	c0d0489e <ux_stack_display+0x2a>
c0d04886:	2124      	movs	r1, #36	; 0x24
    io_seproxyhal_init_ux();
    // at worse a redisplay of the current screen has been requested, ensure to redraw it correctly
    G_ux.stack[stack_slot].element_index = 0;
c0d04888:	4361      	muls	r1, r4
c0d0488a:	1845      	adds	r5, r0, r1
    io_seproxyhal_init_ux();
c0d0488c:	f7fc fc18 	bl	c0d010c0 <io_seproxyhal_init_ux>
c0d04890:	20c2      	movs	r0, #194	; 0xc2
c0d04892:	2100      	movs	r1, #0
    G_ux.stack[stack_slot].element_index = 0;
c0d04894:	5229      	strh	r1, [r5, r0]
#ifdef HAVE_SE_SCREEN
    ux_stack_display_elements(&G_ux.stack[stack_slot]); // on balenos, no need to wait for the display processed event
#else // HAVE_SE_SCREEN
    ux_stack_al_display_next_element(stack_slot);
c0d04896:	4620      	mov	r0, r4
c0d04898:	f000 f822 	bl	c0d048e0 <ux_stack_al_display_next_element>
    if (G_ux.exit_code == BOLOS_UX_OK) {
      G_ux.exit_code = BOLOS_UX_REDRAW;
    }
  }
  // else don't draw (in stack insertion)
}
c0d0489c:	bdb0      	pop	{r4, r5, r7, pc}
c0d0489e:	2200      	movs	r2, #0
c0d048a0:	43d2      	mvns	r2, r2
  else if (stack_slot == -1UL || G_ux.stack_count == 0) {
c0d048a2:	1aa2      	subs	r2, r4, r2
c0d048a4:	1e53      	subs	r3, r2, #1
c0d048a6:	419a      	sbcs	r2, r3
  if (G_ux.stack_count > 0 && stack_slot + 1 == G_ux.stack_count) {
c0d048a8:	1e4b      	subs	r3, r1, #1
c0d048aa:	4199      	sbcs	r1, r3
  else if (stack_slot == -1UL || G_ux.stack_count == 0) {
c0d048ac:	420a      	tst	r2, r1
c0d048ae:	d104      	bne.n	c0d048ba <ux_stack_display+0x46>
c0d048b0:	7841      	ldrb	r1, [r0, #1]
c0d048b2:	29aa      	cmp	r1, #170	; 0xaa
c0d048b4:	d101      	bne.n	c0d048ba <ux_stack_display+0x46>
c0d048b6:	2169      	movs	r1, #105	; 0x69
      G_ux.exit_code = BOLOS_UX_REDRAW;
c0d048b8:	7041      	strb	r1, [r0, #1]
}
c0d048ba:	bdb0      	pop	{r4, r5, r7, pc}
c0d048bc:	20000250 	.word	0x20000250

c0d048c0 <ux_stack_init>:
void ux_stack_init(unsigned int stack_slot) {
c0d048c0:	b510      	push	{r4, lr}
c0d048c2:	4604      	mov	r4, r0
  io_seproxyhal_init_ux(); // glitch upon ux_stack_display for a button being pressed in a previous screen
c0d048c4:	f7fc fbfc 	bl	c0d010c0 <io_seproxyhal_init_ux>
  if (stack_slot < UX_STACK_SLOT_COUNT) {
c0d048c8:	2c00      	cmp	r4, #0
c0d048ca:	d000      	beq.n	c0d048ce <ux_stack_init+0xe>
}
c0d048cc:	bd10      	pop	{r4, pc}
    G_ux.stack[stack_slot].exit_code_after_elements_displayed = BOLOS_UX_CONTINUE;
c0d048ce:	4803      	ldr	r0, [pc, #12]	; (c0d048dc <ux_stack_init+0x1c>)
c0d048d0:	30c0      	adds	r0, #192	; 0xc0
c0d048d2:	2124      	movs	r1, #36	; 0x24
c0d048d4:	f000 f988 	bl	c0d04be8 <__aeabi_memclr>
}
c0d048d8:	bd10      	pop	{r4, pc}
c0d048da:	46c0      	nop			; (mov r8, r8)
c0d048dc:	20000250 	.word	0x20000250

c0d048e0 <ux_stack_al_display_next_element>:
void ux_stack_al_display_next_element(unsigned int stack_slot) {
c0d048e0:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d048e2:	b081      	sub	sp, #4
c0d048e4:	4604      	mov	r4, r0
c0d048e6:	2004      	movs	r0, #4
  unsigned int status = os_sched_last_status(TASK_BOLOS_UX);
c0d048e8:	f7fe f82c 	bl	c0d02944 <os_sched_last_status>
  if (status != BOLOS_UX_IGNORE && status != BOLOS_UX_CONTINUE) {
c0d048ec:	2800      	cmp	r0, #0
c0d048ee:	d039      	beq.n	c0d04964 <ux_stack_al_display_next_element+0x84>
c0d048f0:	2897      	cmp	r0, #151	; 0x97
c0d048f2:	d037      	beq.n	c0d04964 <ux_stack_al_display_next_element+0x84>
c0d048f4:	2024      	movs	r0, #36	; 0x24
           G_ux.stack[stack_slot].element_index < G_ux.stack[stack_slot].element_arrays[0].element_array_count &&
c0d048f6:	4360      	muls	r0, r4
c0d048f8:	491b      	ldr	r1, [pc, #108]	; (c0d04968 <ux_stack_al_display_next_element+0x88>)
c0d048fa:	180c      	adds	r4, r1, r0
c0d048fc:	20c4      	movs	r0, #196	; 0xc4
    while (G_ux.stack[stack_slot].element_arrays[0].element_array &&
c0d048fe:	5820      	ldr	r0, [r4, r0]
c0d04900:	2800      	cmp	r0, #0
c0d04902:	d02f      	beq.n	c0d04964 <ux_stack_al_display_next_element+0x84>
c0d04904:	4625      	mov	r5, r4
c0d04906:	35c4      	adds	r5, #196	; 0xc4
c0d04908:	4626      	mov	r6, r4
c0d0490a:	36c2      	adds	r6, #194	; 0xc2
c0d0490c:	4627      	mov	r7, r4
c0d0490e:	37d0      	adds	r7, #208	; 0xd0
c0d04910:	34c8      	adds	r4, #200	; 0xc8
           G_ux.stack[stack_slot].element_index < G_ux.stack[stack_slot].element_arrays[0].element_array_count &&
c0d04912:	8830      	ldrh	r0, [r6, #0]
c0d04914:	7821      	ldrb	r1, [r4, #0]
c0d04916:	b280      	uxth	r0, r0
c0d04918:	4288      	cmp	r0, r1
c0d0491a:	d223      	bcs.n	c0d04964 <ux_stack_al_display_next_element+0x84>
           !io_seproxyhal_spi_is_status_sent() &&
c0d0491c:	f7fd ffde 	bl	c0d028dc <io_seph_is_status_sent>
c0d04920:	2800      	cmp	r0, #0
c0d04922:	d11f      	bne.n	c0d04964 <ux_stack_al_display_next_element+0x84>
           (os_perso_isonboarded() != BOLOS_UX_OK || os_global_pin_is_validated() == BOLOS_UX_OK)) {
c0d04924:	f7fd ff5e 	bl	c0d027e4 <os_perso_isonboarded>
c0d04928:	28aa      	cmp	r0, #170	; 0xaa
c0d0492a:	d103      	bne.n	c0d04934 <ux_stack_al_display_next_element+0x54>
c0d0492c:	f7fd ff8a 	bl	c0d02844 <os_global_pin_is_validated>
    while (G_ux.stack[stack_slot].element_arrays[0].element_array &&
c0d04930:	28aa      	cmp	r0, #170	; 0xaa
c0d04932:	d117      	bne.n	c0d04964 <ux_stack_al_display_next_element+0x84>
          &G_ux.stack[stack_slot].element_arrays[0].element_array[G_ux.stack[stack_slot].element_index];
c0d04934:	6828      	ldr	r0, [r5, #0]
c0d04936:	8831      	ldrh	r1, [r6, #0]
c0d04938:	0149      	lsls	r1, r1, #5
c0d0493a:	1840      	adds	r0, r0, r1
      if (!G_ux.stack[stack_slot].screen_before_element_display_callback ||
c0d0493c:	6839      	ldr	r1, [r7, #0]
c0d0493e:	2900      	cmp	r1, #0
c0d04940:	d002      	beq.n	c0d04948 <ux_stack_al_display_next_element+0x68>
          (element = G_ux.stack[stack_slot].screen_before_element_display_callback(element))) {
c0d04942:	4788      	blx	r1
      if (!G_ux.stack[stack_slot].screen_before_element_display_callback ||
c0d04944:	2800      	cmp	r0, #0
c0d04946:	d007      	beq.n	c0d04958 <ux_stack_al_display_next_element+0x78>
        if ((unsigned int)element == 1) { /*backward compat with coding to avoid smashing everything*/
c0d04948:	2801      	cmp	r0, #1
c0d0494a:	d103      	bne.n	c0d04954 <ux_stack_al_display_next_element+0x74>
          element = &G_ux.stack[stack_slot].element_arrays[0].element_array[G_ux.stack[stack_slot].element_index];
c0d0494c:	6828      	ldr	r0, [r5, #0]
c0d0494e:	8831      	ldrh	r1, [r6, #0]
c0d04950:	0149      	lsls	r1, r1, #5
c0d04952:	1840      	adds	r0, r0, r1
        io_seproxyhal_display(element);
c0d04954:	f7fb fdfa 	bl	c0d0054c <io_seproxyhal_display>
      G_ux.stack[stack_slot].element_index++;
c0d04958:	8830      	ldrh	r0, [r6, #0]
c0d0495a:	1c40      	adds	r0, r0, #1
c0d0495c:	8030      	strh	r0, [r6, #0]
    while (G_ux.stack[stack_slot].element_arrays[0].element_array &&
c0d0495e:	6829      	ldr	r1, [r5, #0]
c0d04960:	2900      	cmp	r1, #0
c0d04962:	d1d7      	bne.n	c0d04914 <ux_stack_al_display_next_element+0x34>
}
c0d04964:	b001      	add	sp, #4
c0d04966:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d04968:	20000250 	.word	0x20000250

c0d0496c <__udivsi3>:
c0d0496c:	2900      	cmp	r1, #0
c0d0496e:	d034      	beq.n	c0d049da <.udivsi3_skip_div0_test+0x6a>

c0d04970 <.udivsi3_skip_div0_test>:
c0d04970:	2301      	movs	r3, #1
c0d04972:	2200      	movs	r2, #0
c0d04974:	b410      	push	{r4}
c0d04976:	4288      	cmp	r0, r1
c0d04978:	d32c      	bcc.n	c0d049d4 <.udivsi3_skip_div0_test+0x64>
c0d0497a:	2401      	movs	r4, #1
c0d0497c:	0724      	lsls	r4, r4, #28
c0d0497e:	42a1      	cmp	r1, r4
c0d04980:	d204      	bcs.n	c0d0498c <.udivsi3_skip_div0_test+0x1c>
c0d04982:	4281      	cmp	r1, r0
c0d04984:	d202      	bcs.n	c0d0498c <.udivsi3_skip_div0_test+0x1c>
c0d04986:	0109      	lsls	r1, r1, #4
c0d04988:	011b      	lsls	r3, r3, #4
c0d0498a:	e7f8      	b.n	c0d0497e <.udivsi3_skip_div0_test+0xe>
c0d0498c:	00e4      	lsls	r4, r4, #3
c0d0498e:	42a1      	cmp	r1, r4
c0d04990:	d204      	bcs.n	c0d0499c <.udivsi3_skip_div0_test+0x2c>
c0d04992:	4281      	cmp	r1, r0
c0d04994:	d202      	bcs.n	c0d0499c <.udivsi3_skip_div0_test+0x2c>
c0d04996:	0049      	lsls	r1, r1, #1
c0d04998:	005b      	lsls	r3, r3, #1
c0d0499a:	e7f8      	b.n	c0d0498e <.udivsi3_skip_div0_test+0x1e>
c0d0499c:	4288      	cmp	r0, r1
c0d0499e:	d301      	bcc.n	c0d049a4 <.udivsi3_skip_div0_test+0x34>
c0d049a0:	1a40      	subs	r0, r0, r1
c0d049a2:	431a      	orrs	r2, r3
c0d049a4:	084c      	lsrs	r4, r1, #1
c0d049a6:	42a0      	cmp	r0, r4
c0d049a8:	d302      	bcc.n	c0d049b0 <.udivsi3_skip_div0_test+0x40>
c0d049aa:	1b00      	subs	r0, r0, r4
c0d049ac:	085c      	lsrs	r4, r3, #1
c0d049ae:	4322      	orrs	r2, r4
c0d049b0:	088c      	lsrs	r4, r1, #2
c0d049b2:	42a0      	cmp	r0, r4
c0d049b4:	d302      	bcc.n	c0d049bc <.udivsi3_skip_div0_test+0x4c>
c0d049b6:	1b00      	subs	r0, r0, r4
c0d049b8:	089c      	lsrs	r4, r3, #2
c0d049ba:	4322      	orrs	r2, r4
c0d049bc:	08cc      	lsrs	r4, r1, #3
c0d049be:	42a0      	cmp	r0, r4
c0d049c0:	d302      	bcc.n	c0d049c8 <.udivsi3_skip_div0_test+0x58>
c0d049c2:	1b00      	subs	r0, r0, r4
c0d049c4:	08dc      	lsrs	r4, r3, #3
c0d049c6:	4322      	orrs	r2, r4
c0d049c8:	2800      	cmp	r0, #0
c0d049ca:	d003      	beq.n	c0d049d4 <.udivsi3_skip_div0_test+0x64>
c0d049cc:	091b      	lsrs	r3, r3, #4
c0d049ce:	d001      	beq.n	c0d049d4 <.udivsi3_skip_div0_test+0x64>
c0d049d0:	0909      	lsrs	r1, r1, #4
c0d049d2:	e7e3      	b.n	c0d0499c <.udivsi3_skip_div0_test+0x2c>
c0d049d4:	0010      	movs	r0, r2
c0d049d6:	bc10      	pop	{r4}
c0d049d8:	4770      	bx	lr
c0d049da:	b501      	push	{r0, lr}
c0d049dc:	2000      	movs	r0, #0
c0d049de:	f000 f80b 	bl	c0d049f8 <__aeabi_idiv0>
c0d049e2:	bd02      	pop	{r1, pc}

c0d049e4 <__aeabi_uidivmod>:
c0d049e4:	2900      	cmp	r1, #0
c0d049e6:	d0f8      	beq.n	c0d049da <.udivsi3_skip_div0_test+0x6a>
c0d049e8:	b503      	push	{r0, r1, lr}
c0d049ea:	f7ff ffc1 	bl	c0d04970 <.udivsi3_skip_div0_test>
c0d049ee:	bc0e      	pop	{r1, r2, r3}
c0d049f0:	4342      	muls	r2, r0
c0d049f2:	1a89      	subs	r1, r1, r2
c0d049f4:	4718      	bx	r3
c0d049f6:	46c0      	nop			; (mov r8, r8)

c0d049f8 <__aeabi_idiv0>:
c0d049f8:	4770      	bx	lr
c0d049fa:	46c0      	nop			; (mov r8, r8)

c0d049fc <__aeabi_llsl>:
c0d049fc:	4091      	lsls	r1, r2
c0d049fe:	0003      	movs	r3, r0
c0d04a00:	4090      	lsls	r0, r2
c0d04a02:	469c      	mov	ip, r3
c0d04a04:	3a20      	subs	r2, #32
c0d04a06:	4093      	lsls	r3, r2
c0d04a08:	4319      	orrs	r1, r3
c0d04a0a:	4252      	negs	r2, r2
c0d04a0c:	4663      	mov	r3, ip
c0d04a0e:	40d3      	lsrs	r3, r2
c0d04a10:	4319      	orrs	r1, r3
c0d04a12:	4770      	bx	lr

c0d04a14 <__aeabi_uldivmod>:
c0d04a14:	2b00      	cmp	r3, #0
c0d04a16:	d111      	bne.n	c0d04a3c <__aeabi_uldivmod+0x28>
c0d04a18:	2a00      	cmp	r2, #0
c0d04a1a:	d10f      	bne.n	c0d04a3c <__aeabi_uldivmod+0x28>
c0d04a1c:	2900      	cmp	r1, #0
c0d04a1e:	d100      	bne.n	c0d04a22 <__aeabi_uldivmod+0xe>
c0d04a20:	2800      	cmp	r0, #0
c0d04a22:	d002      	beq.n	c0d04a2a <__aeabi_uldivmod+0x16>
c0d04a24:	2100      	movs	r1, #0
c0d04a26:	43c9      	mvns	r1, r1
c0d04a28:	0008      	movs	r0, r1
c0d04a2a:	b407      	push	{r0, r1, r2}
c0d04a2c:	4802      	ldr	r0, [pc, #8]	; (c0d04a38 <__aeabi_uldivmod+0x24>)
c0d04a2e:	a102      	add	r1, pc, #8	; (adr r1, c0d04a38 <__aeabi_uldivmod+0x24>)
c0d04a30:	1840      	adds	r0, r0, r1
c0d04a32:	9002      	str	r0, [sp, #8]
c0d04a34:	bd03      	pop	{r0, r1, pc}
c0d04a36:	46c0      	nop			; (mov r8, r8)
c0d04a38:	ffffffc1 	.word	0xffffffc1
c0d04a3c:	b403      	push	{r0, r1}
c0d04a3e:	4668      	mov	r0, sp
c0d04a40:	b501      	push	{r0, lr}
c0d04a42:	9802      	ldr	r0, [sp, #8]
c0d04a44:	f000 f82a 	bl	c0d04a9c <__udivmoddi4>
c0d04a48:	9b01      	ldr	r3, [sp, #4]
c0d04a4a:	469e      	mov	lr, r3
c0d04a4c:	b002      	add	sp, #8
c0d04a4e:	bc0c      	pop	{r2, r3}
c0d04a50:	4770      	bx	lr
c0d04a52:	46c0      	nop			; (mov r8, r8)

c0d04a54 <__aeabi_lmul>:
c0d04a54:	b5f7      	push	{r0, r1, r2, r4, r5, r6, r7, lr}
c0d04a56:	9301      	str	r3, [sp, #4]
c0d04a58:	b283      	uxth	r3, r0
c0d04a5a:	469c      	mov	ip, r3
c0d04a5c:	0006      	movs	r6, r0
c0d04a5e:	0c03      	lsrs	r3, r0, #16
c0d04a60:	4660      	mov	r0, ip
c0d04a62:	000d      	movs	r5, r1
c0d04a64:	4661      	mov	r1, ip
c0d04a66:	b297      	uxth	r7, r2
c0d04a68:	4378      	muls	r0, r7
c0d04a6a:	0c14      	lsrs	r4, r2, #16
c0d04a6c:	435f      	muls	r7, r3
c0d04a6e:	4363      	muls	r3, r4
c0d04a70:	434c      	muls	r4, r1
c0d04a72:	0c01      	lsrs	r1, r0, #16
c0d04a74:	468c      	mov	ip, r1
c0d04a76:	19e4      	adds	r4, r4, r7
c0d04a78:	4464      	add	r4, ip
c0d04a7a:	42a7      	cmp	r7, r4
c0d04a7c:	d902      	bls.n	c0d04a84 <__aeabi_lmul+0x30>
c0d04a7e:	2180      	movs	r1, #128	; 0x80
c0d04a80:	0249      	lsls	r1, r1, #9
c0d04a82:	185b      	adds	r3, r3, r1
c0d04a84:	9901      	ldr	r1, [sp, #4]
c0d04a86:	436a      	muls	r2, r5
c0d04a88:	4371      	muls	r1, r6
c0d04a8a:	0c27      	lsrs	r7, r4, #16
c0d04a8c:	18fb      	adds	r3, r7, r3
c0d04a8e:	0424      	lsls	r4, r4, #16
c0d04a90:	18c9      	adds	r1, r1, r3
c0d04a92:	b280      	uxth	r0, r0
c0d04a94:	1820      	adds	r0, r4, r0
c0d04a96:	1889      	adds	r1, r1, r2
c0d04a98:	b003      	add	sp, #12
c0d04a9a:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d04a9c <__udivmoddi4>:
c0d04a9c:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d04a9e:	0006      	movs	r6, r0
c0d04aa0:	000f      	movs	r7, r1
c0d04aa2:	0015      	movs	r5, r2
c0d04aa4:	001c      	movs	r4, r3
c0d04aa6:	b085      	sub	sp, #20
c0d04aa8:	428b      	cmp	r3, r1
c0d04aaa:	d863      	bhi.n	c0d04b74 <__udivmoddi4+0xd8>
c0d04aac:	d101      	bne.n	c0d04ab2 <__udivmoddi4+0x16>
c0d04aae:	4282      	cmp	r2, r0
c0d04ab0:	d860      	bhi.n	c0d04b74 <__udivmoddi4+0xd8>
c0d04ab2:	0021      	movs	r1, r4
c0d04ab4:	0028      	movs	r0, r5
c0d04ab6:	f000 f86d 	bl	c0d04b94 <__clzdi2>
c0d04aba:	0039      	movs	r1, r7
c0d04abc:	9000      	str	r0, [sp, #0]
c0d04abe:	0030      	movs	r0, r6
c0d04ac0:	f000 f868 	bl	c0d04b94 <__clzdi2>
c0d04ac4:	9b00      	ldr	r3, [sp, #0]
c0d04ac6:	0021      	movs	r1, r4
c0d04ac8:	1a1b      	subs	r3, r3, r0
c0d04aca:	001a      	movs	r2, r3
c0d04acc:	0028      	movs	r0, r5
c0d04ace:	9303      	str	r3, [sp, #12]
c0d04ad0:	f7ff ff94 	bl	c0d049fc <__aeabi_llsl>
c0d04ad4:	9000      	str	r0, [sp, #0]
c0d04ad6:	9101      	str	r1, [sp, #4]
c0d04ad8:	42b9      	cmp	r1, r7
c0d04ada:	d845      	bhi.n	c0d04b68 <__udivmoddi4+0xcc>
c0d04adc:	d101      	bne.n	c0d04ae2 <__udivmoddi4+0x46>
c0d04ade:	42b0      	cmp	r0, r6
c0d04ae0:	d842      	bhi.n	c0d04b68 <__udivmoddi4+0xcc>
c0d04ae2:	9b00      	ldr	r3, [sp, #0]
c0d04ae4:	9c01      	ldr	r4, [sp, #4]
c0d04ae6:	2001      	movs	r0, #1
c0d04ae8:	2100      	movs	r1, #0
c0d04aea:	9a03      	ldr	r2, [sp, #12]
c0d04aec:	1af6      	subs	r6, r6, r3
c0d04aee:	41a7      	sbcs	r7, r4
c0d04af0:	f7ff ff84 	bl	c0d049fc <__aeabi_llsl>
c0d04af4:	0004      	movs	r4, r0
c0d04af6:	000d      	movs	r5, r1
c0d04af8:	9b03      	ldr	r3, [sp, #12]
c0d04afa:	2b00      	cmp	r3, #0
c0d04afc:	d02b      	beq.n	c0d04b56 <__udivmoddi4+0xba>
c0d04afe:	9b01      	ldr	r3, [sp, #4]
c0d04b00:	9a00      	ldr	r2, [sp, #0]
c0d04b02:	07db      	lsls	r3, r3, #31
c0d04b04:	0850      	lsrs	r0, r2, #1
c0d04b06:	4318      	orrs	r0, r3
c0d04b08:	9b01      	ldr	r3, [sp, #4]
c0d04b0a:	0859      	lsrs	r1, r3, #1
c0d04b0c:	9b03      	ldr	r3, [sp, #12]
c0d04b0e:	469c      	mov	ip, r3
c0d04b10:	42b9      	cmp	r1, r7
c0d04b12:	d82c      	bhi.n	c0d04b6e <__udivmoddi4+0xd2>
c0d04b14:	d101      	bne.n	c0d04b1a <__udivmoddi4+0x7e>
c0d04b16:	42b0      	cmp	r0, r6
c0d04b18:	d829      	bhi.n	c0d04b6e <__udivmoddi4+0xd2>
c0d04b1a:	0032      	movs	r2, r6
c0d04b1c:	003b      	movs	r3, r7
c0d04b1e:	1a12      	subs	r2, r2, r0
c0d04b20:	418b      	sbcs	r3, r1
c0d04b22:	2601      	movs	r6, #1
c0d04b24:	1892      	adds	r2, r2, r2
c0d04b26:	415b      	adcs	r3, r3
c0d04b28:	2700      	movs	r7, #0
c0d04b2a:	18b6      	adds	r6, r6, r2
c0d04b2c:	415f      	adcs	r7, r3
c0d04b2e:	2301      	movs	r3, #1
c0d04b30:	425b      	negs	r3, r3
c0d04b32:	449c      	add	ip, r3
c0d04b34:	4663      	mov	r3, ip
c0d04b36:	2b00      	cmp	r3, #0
c0d04b38:	d1ea      	bne.n	c0d04b10 <__udivmoddi4+0x74>
c0d04b3a:	0030      	movs	r0, r6
c0d04b3c:	0039      	movs	r1, r7
c0d04b3e:	9a03      	ldr	r2, [sp, #12]
c0d04b40:	f000 f81c 	bl	c0d04b7c <__aeabi_llsr>
c0d04b44:	9a03      	ldr	r2, [sp, #12]
c0d04b46:	19a4      	adds	r4, r4, r6
c0d04b48:	417d      	adcs	r5, r7
c0d04b4a:	0006      	movs	r6, r0
c0d04b4c:	000f      	movs	r7, r1
c0d04b4e:	f7ff ff55 	bl	c0d049fc <__aeabi_llsl>
c0d04b52:	1a24      	subs	r4, r4, r0
c0d04b54:	418d      	sbcs	r5, r1
c0d04b56:	9b0a      	ldr	r3, [sp, #40]	; 0x28
c0d04b58:	2b00      	cmp	r3, #0
c0d04b5a:	d001      	beq.n	c0d04b60 <__udivmoddi4+0xc4>
c0d04b5c:	601e      	str	r6, [r3, #0]
c0d04b5e:	605f      	str	r7, [r3, #4]
c0d04b60:	0020      	movs	r0, r4
c0d04b62:	0029      	movs	r1, r5
c0d04b64:	b005      	add	sp, #20
c0d04b66:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d04b68:	2400      	movs	r4, #0
c0d04b6a:	2500      	movs	r5, #0
c0d04b6c:	e7c4      	b.n	c0d04af8 <__udivmoddi4+0x5c>
c0d04b6e:	19b6      	adds	r6, r6, r6
c0d04b70:	417f      	adcs	r7, r7
c0d04b72:	e7dc      	b.n	c0d04b2e <__udivmoddi4+0x92>
c0d04b74:	2400      	movs	r4, #0
c0d04b76:	2500      	movs	r5, #0
c0d04b78:	e7ed      	b.n	c0d04b56 <__udivmoddi4+0xba>
	...

c0d04b7c <__aeabi_llsr>:
c0d04b7c:	40d0      	lsrs	r0, r2
c0d04b7e:	000b      	movs	r3, r1
c0d04b80:	40d1      	lsrs	r1, r2
c0d04b82:	469c      	mov	ip, r3
c0d04b84:	3a20      	subs	r2, #32
c0d04b86:	40d3      	lsrs	r3, r2
c0d04b88:	4318      	orrs	r0, r3
c0d04b8a:	4252      	negs	r2, r2
c0d04b8c:	4663      	mov	r3, ip
c0d04b8e:	4093      	lsls	r3, r2
c0d04b90:	4318      	orrs	r0, r3
c0d04b92:	4770      	bx	lr

c0d04b94 <__clzdi2>:
c0d04b94:	b510      	push	{r4, lr}
c0d04b96:	2900      	cmp	r1, #0
c0d04b98:	d103      	bne.n	c0d04ba2 <__clzdi2+0xe>
c0d04b9a:	f000 f807 	bl	c0d04bac <__clzsi2>
c0d04b9e:	3020      	adds	r0, #32
c0d04ba0:	e002      	b.n	c0d04ba8 <__clzdi2+0x14>
c0d04ba2:	0008      	movs	r0, r1
c0d04ba4:	f000 f802 	bl	c0d04bac <__clzsi2>
c0d04ba8:	bd10      	pop	{r4, pc}
c0d04baa:	46c0      	nop			; (mov r8, r8)

c0d04bac <__clzsi2>:
c0d04bac:	211c      	movs	r1, #28
c0d04bae:	2301      	movs	r3, #1
c0d04bb0:	041b      	lsls	r3, r3, #16
c0d04bb2:	4298      	cmp	r0, r3
c0d04bb4:	d301      	bcc.n	c0d04bba <__clzsi2+0xe>
c0d04bb6:	0c00      	lsrs	r0, r0, #16
c0d04bb8:	3910      	subs	r1, #16
c0d04bba:	0a1b      	lsrs	r3, r3, #8
c0d04bbc:	4298      	cmp	r0, r3
c0d04bbe:	d301      	bcc.n	c0d04bc4 <__clzsi2+0x18>
c0d04bc0:	0a00      	lsrs	r0, r0, #8
c0d04bc2:	3908      	subs	r1, #8
c0d04bc4:	091b      	lsrs	r3, r3, #4
c0d04bc6:	4298      	cmp	r0, r3
c0d04bc8:	d301      	bcc.n	c0d04bce <__clzsi2+0x22>
c0d04bca:	0900      	lsrs	r0, r0, #4
c0d04bcc:	3904      	subs	r1, #4
c0d04bce:	a202      	add	r2, pc, #8	; (adr r2, c0d04bd8 <__clzsi2+0x2c>)
c0d04bd0:	5c10      	ldrb	r0, [r2, r0]
c0d04bd2:	1840      	adds	r0, r0, r1
c0d04bd4:	4770      	bx	lr
c0d04bd6:	46c0      	nop			; (mov r8, r8)
c0d04bd8:	02020304 	.word	0x02020304
c0d04bdc:	01010101 	.word	0x01010101
	...

c0d04be8 <__aeabi_memclr>:
c0d04be8:	b510      	push	{r4, lr}
c0d04bea:	2200      	movs	r2, #0
c0d04bec:	f000 f80a 	bl	c0d04c04 <__aeabi_memset>
c0d04bf0:	bd10      	pop	{r4, pc}
c0d04bf2:	46c0      	nop			; (mov r8, r8)

c0d04bf4 <__aeabi_memcpy>:
c0d04bf4:	b510      	push	{r4, lr}
c0d04bf6:	f000 f811 	bl	c0d04c1c <memcpy>
c0d04bfa:	bd10      	pop	{r4, pc}

c0d04bfc <__aeabi_memmove>:
c0d04bfc:	b510      	push	{r4, lr}
c0d04bfe:	f000 f85f 	bl	c0d04cc0 <memmove>
c0d04c02:	bd10      	pop	{r4, pc}

c0d04c04 <__aeabi_memset>:
c0d04c04:	000b      	movs	r3, r1
c0d04c06:	b510      	push	{r4, lr}
c0d04c08:	0011      	movs	r1, r2
c0d04c0a:	001a      	movs	r2, r3
c0d04c0c:	f000 f8ae 	bl	c0d04d6c <memset>
c0d04c10:	bd10      	pop	{r4, pc}
c0d04c12:	46c0      	nop			; (mov r8, r8)

c0d04c14 <explicit_bzero>:
c0d04c14:	b510      	push	{r4, lr}
c0d04c16:	f000 f97b 	bl	c0d04f10 <bzero>
c0d04c1a:	bd10      	pop	{r4, pc}

c0d04c1c <memcpy>:
c0d04c1c:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d04c1e:	46c6      	mov	lr, r8
c0d04c20:	b500      	push	{lr}
c0d04c22:	2a0f      	cmp	r2, #15
c0d04c24:	d941      	bls.n	c0d04caa <memcpy+0x8e>
c0d04c26:	2703      	movs	r7, #3
c0d04c28:	000d      	movs	r5, r1
c0d04c2a:	003e      	movs	r6, r7
c0d04c2c:	4305      	orrs	r5, r0
c0d04c2e:	000c      	movs	r4, r1
c0d04c30:	0003      	movs	r3, r0
c0d04c32:	402e      	ands	r6, r5
c0d04c34:	422f      	tst	r7, r5
c0d04c36:	d13d      	bne.n	c0d04cb4 <memcpy+0x98>
c0d04c38:	0015      	movs	r5, r2
c0d04c3a:	3d10      	subs	r5, #16
c0d04c3c:	092d      	lsrs	r5, r5, #4
c0d04c3e:	46a8      	mov	r8, r5
c0d04c40:	012d      	lsls	r5, r5, #4
c0d04c42:	46ac      	mov	ip, r5
c0d04c44:	4484      	add	ip, r0
c0d04c46:	6827      	ldr	r7, [r4, #0]
c0d04c48:	001d      	movs	r5, r3
c0d04c4a:	601f      	str	r7, [r3, #0]
c0d04c4c:	6867      	ldr	r7, [r4, #4]
c0d04c4e:	605f      	str	r7, [r3, #4]
c0d04c50:	68a7      	ldr	r7, [r4, #8]
c0d04c52:	609f      	str	r7, [r3, #8]
c0d04c54:	68e7      	ldr	r7, [r4, #12]
c0d04c56:	3410      	adds	r4, #16
c0d04c58:	60df      	str	r7, [r3, #12]
c0d04c5a:	3310      	adds	r3, #16
c0d04c5c:	4565      	cmp	r5, ip
c0d04c5e:	d1f2      	bne.n	c0d04c46 <memcpy+0x2a>
c0d04c60:	4645      	mov	r5, r8
c0d04c62:	230f      	movs	r3, #15
c0d04c64:	240c      	movs	r4, #12
c0d04c66:	3501      	adds	r5, #1
c0d04c68:	012d      	lsls	r5, r5, #4
c0d04c6a:	1949      	adds	r1, r1, r5
c0d04c6c:	4013      	ands	r3, r2
c0d04c6e:	1945      	adds	r5, r0, r5
c0d04c70:	4214      	tst	r4, r2
c0d04c72:	d022      	beq.n	c0d04cba <memcpy+0x9e>
c0d04c74:	598c      	ldr	r4, [r1, r6]
c0d04c76:	51ac      	str	r4, [r5, r6]
c0d04c78:	3604      	adds	r6, #4
c0d04c7a:	1b9c      	subs	r4, r3, r6
c0d04c7c:	2c03      	cmp	r4, #3
c0d04c7e:	d8f9      	bhi.n	c0d04c74 <memcpy+0x58>
c0d04c80:	3b04      	subs	r3, #4
c0d04c82:	089b      	lsrs	r3, r3, #2
c0d04c84:	3301      	adds	r3, #1
c0d04c86:	009b      	lsls	r3, r3, #2
c0d04c88:	18ed      	adds	r5, r5, r3
c0d04c8a:	18c9      	adds	r1, r1, r3
c0d04c8c:	2303      	movs	r3, #3
c0d04c8e:	401a      	ands	r2, r3
c0d04c90:	1e56      	subs	r6, r2, #1
c0d04c92:	2a00      	cmp	r2, #0
c0d04c94:	d006      	beq.n	c0d04ca4 <memcpy+0x88>
c0d04c96:	2300      	movs	r3, #0
c0d04c98:	5ccc      	ldrb	r4, [r1, r3]
c0d04c9a:	001a      	movs	r2, r3
c0d04c9c:	54ec      	strb	r4, [r5, r3]
c0d04c9e:	3301      	adds	r3, #1
c0d04ca0:	4296      	cmp	r6, r2
c0d04ca2:	d1f9      	bne.n	c0d04c98 <memcpy+0x7c>
c0d04ca4:	bc80      	pop	{r7}
c0d04ca6:	46b8      	mov	r8, r7
c0d04ca8:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d04caa:	0005      	movs	r5, r0
c0d04cac:	1e56      	subs	r6, r2, #1
c0d04cae:	2a00      	cmp	r2, #0
c0d04cb0:	d1f1      	bne.n	c0d04c96 <memcpy+0x7a>
c0d04cb2:	e7f7      	b.n	c0d04ca4 <memcpy+0x88>
c0d04cb4:	0005      	movs	r5, r0
c0d04cb6:	1e56      	subs	r6, r2, #1
c0d04cb8:	e7ed      	b.n	c0d04c96 <memcpy+0x7a>
c0d04cba:	001a      	movs	r2, r3
c0d04cbc:	e7f6      	b.n	c0d04cac <memcpy+0x90>
c0d04cbe:	46c0      	nop			; (mov r8, r8)

c0d04cc0 <memmove>:
c0d04cc0:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d04cc2:	4288      	cmp	r0, r1
c0d04cc4:	d90a      	bls.n	c0d04cdc <memmove+0x1c>
c0d04cc6:	188b      	adds	r3, r1, r2
c0d04cc8:	4298      	cmp	r0, r3
c0d04cca:	d207      	bcs.n	c0d04cdc <memmove+0x1c>
c0d04ccc:	1e53      	subs	r3, r2, #1
c0d04cce:	2a00      	cmp	r2, #0
c0d04cd0:	d003      	beq.n	c0d04cda <memmove+0x1a>
c0d04cd2:	5cca      	ldrb	r2, [r1, r3]
c0d04cd4:	54c2      	strb	r2, [r0, r3]
c0d04cd6:	3b01      	subs	r3, #1
c0d04cd8:	d2fb      	bcs.n	c0d04cd2 <memmove+0x12>
c0d04cda:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d04cdc:	2a0f      	cmp	r2, #15
c0d04cde:	d80b      	bhi.n	c0d04cf8 <memmove+0x38>
c0d04ce0:	0005      	movs	r5, r0
c0d04ce2:	1e56      	subs	r6, r2, #1
c0d04ce4:	2a00      	cmp	r2, #0
c0d04ce6:	d0f8      	beq.n	c0d04cda <memmove+0x1a>
c0d04ce8:	2300      	movs	r3, #0
c0d04cea:	5ccc      	ldrb	r4, [r1, r3]
c0d04cec:	001a      	movs	r2, r3
c0d04cee:	54ec      	strb	r4, [r5, r3]
c0d04cf0:	3301      	adds	r3, #1
c0d04cf2:	4296      	cmp	r6, r2
c0d04cf4:	d1f9      	bne.n	c0d04cea <memmove+0x2a>
c0d04cf6:	e7f0      	b.n	c0d04cda <memmove+0x1a>
c0d04cf8:	2703      	movs	r7, #3
c0d04cfa:	000d      	movs	r5, r1
c0d04cfc:	003e      	movs	r6, r7
c0d04cfe:	4305      	orrs	r5, r0
c0d04d00:	000c      	movs	r4, r1
c0d04d02:	0003      	movs	r3, r0
c0d04d04:	402e      	ands	r6, r5
c0d04d06:	422f      	tst	r7, r5
c0d04d08:	d12b      	bne.n	c0d04d62 <memmove+0xa2>
c0d04d0a:	0015      	movs	r5, r2
c0d04d0c:	3d10      	subs	r5, #16
c0d04d0e:	092d      	lsrs	r5, r5, #4
c0d04d10:	46ac      	mov	ip, r5
c0d04d12:	012f      	lsls	r7, r5, #4
c0d04d14:	183f      	adds	r7, r7, r0
c0d04d16:	6825      	ldr	r5, [r4, #0]
c0d04d18:	601d      	str	r5, [r3, #0]
c0d04d1a:	6865      	ldr	r5, [r4, #4]
c0d04d1c:	605d      	str	r5, [r3, #4]
c0d04d1e:	68a5      	ldr	r5, [r4, #8]
c0d04d20:	609d      	str	r5, [r3, #8]
c0d04d22:	68e5      	ldr	r5, [r4, #12]
c0d04d24:	3410      	adds	r4, #16
c0d04d26:	60dd      	str	r5, [r3, #12]
c0d04d28:	001d      	movs	r5, r3
c0d04d2a:	3310      	adds	r3, #16
c0d04d2c:	42bd      	cmp	r5, r7
c0d04d2e:	d1f2      	bne.n	c0d04d16 <memmove+0x56>
c0d04d30:	4665      	mov	r5, ip
c0d04d32:	230f      	movs	r3, #15
c0d04d34:	240c      	movs	r4, #12
c0d04d36:	3501      	adds	r5, #1
c0d04d38:	012d      	lsls	r5, r5, #4
c0d04d3a:	1949      	adds	r1, r1, r5
c0d04d3c:	4013      	ands	r3, r2
c0d04d3e:	1945      	adds	r5, r0, r5
c0d04d40:	4214      	tst	r4, r2
c0d04d42:	d011      	beq.n	c0d04d68 <memmove+0xa8>
c0d04d44:	598c      	ldr	r4, [r1, r6]
c0d04d46:	51ac      	str	r4, [r5, r6]
c0d04d48:	3604      	adds	r6, #4
c0d04d4a:	1b9c      	subs	r4, r3, r6
c0d04d4c:	2c03      	cmp	r4, #3
c0d04d4e:	d8f9      	bhi.n	c0d04d44 <memmove+0x84>
c0d04d50:	3b04      	subs	r3, #4
c0d04d52:	089b      	lsrs	r3, r3, #2
c0d04d54:	3301      	adds	r3, #1
c0d04d56:	009b      	lsls	r3, r3, #2
c0d04d58:	18ed      	adds	r5, r5, r3
c0d04d5a:	18c9      	adds	r1, r1, r3
c0d04d5c:	2303      	movs	r3, #3
c0d04d5e:	401a      	ands	r2, r3
c0d04d60:	e7bf      	b.n	c0d04ce2 <memmove+0x22>
c0d04d62:	0005      	movs	r5, r0
c0d04d64:	1e56      	subs	r6, r2, #1
c0d04d66:	e7bf      	b.n	c0d04ce8 <memmove+0x28>
c0d04d68:	001a      	movs	r2, r3
c0d04d6a:	e7ba      	b.n	c0d04ce2 <memmove+0x22>

c0d04d6c <memset>:
c0d04d6c:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d04d6e:	0005      	movs	r5, r0
c0d04d70:	0783      	lsls	r3, r0, #30
c0d04d72:	d049      	beq.n	c0d04e08 <memset+0x9c>
c0d04d74:	1e54      	subs	r4, r2, #1
c0d04d76:	2a00      	cmp	r2, #0
c0d04d78:	d045      	beq.n	c0d04e06 <memset+0x9a>
c0d04d7a:	0003      	movs	r3, r0
c0d04d7c:	2603      	movs	r6, #3
c0d04d7e:	b2ca      	uxtb	r2, r1
c0d04d80:	e002      	b.n	c0d04d88 <memset+0x1c>
c0d04d82:	3501      	adds	r5, #1
c0d04d84:	3c01      	subs	r4, #1
c0d04d86:	d33e      	bcc.n	c0d04e06 <memset+0x9a>
c0d04d88:	3301      	adds	r3, #1
c0d04d8a:	702a      	strb	r2, [r5, #0]
c0d04d8c:	4233      	tst	r3, r6
c0d04d8e:	d1f8      	bne.n	c0d04d82 <memset+0x16>
c0d04d90:	2c03      	cmp	r4, #3
c0d04d92:	d930      	bls.n	c0d04df6 <memset+0x8a>
c0d04d94:	22ff      	movs	r2, #255	; 0xff
c0d04d96:	400a      	ands	r2, r1
c0d04d98:	0215      	lsls	r5, r2, #8
c0d04d9a:	4315      	orrs	r5, r2
c0d04d9c:	042a      	lsls	r2, r5, #16
c0d04d9e:	4315      	orrs	r5, r2
c0d04da0:	2c0f      	cmp	r4, #15
c0d04da2:	d934      	bls.n	c0d04e0e <memset+0xa2>
c0d04da4:	0027      	movs	r7, r4
c0d04da6:	3f10      	subs	r7, #16
c0d04da8:	093f      	lsrs	r7, r7, #4
c0d04daa:	013e      	lsls	r6, r7, #4
c0d04dac:	46b4      	mov	ip, r6
c0d04dae:	001e      	movs	r6, r3
c0d04db0:	001a      	movs	r2, r3
c0d04db2:	3610      	adds	r6, #16
c0d04db4:	4466      	add	r6, ip
c0d04db6:	6015      	str	r5, [r2, #0]
c0d04db8:	6055      	str	r5, [r2, #4]
c0d04dba:	6095      	str	r5, [r2, #8]
c0d04dbc:	60d5      	str	r5, [r2, #12]
c0d04dbe:	3210      	adds	r2, #16
c0d04dc0:	42b2      	cmp	r2, r6
c0d04dc2:	d1f8      	bne.n	c0d04db6 <memset+0x4a>
c0d04dc4:	3701      	adds	r7, #1
c0d04dc6:	013f      	lsls	r7, r7, #4
c0d04dc8:	19db      	adds	r3, r3, r7
c0d04dca:	270f      	movs	r7, #15
c0d04dcc:	220c      	movs	r2, #12
c0d04dce:	4027      	ands	r7, r4
c0d04dd0:	4022      	ands	r2, r4
c0d04dd2:	003c      	movs	r4, r7
c0d04dd4:	2a00      	cmp	r2, #0
c0d04dd6:	d00e      	beq.n	c0d04df6 <memset+0x8a>
c0d04dd8:	1f3e      	subs	r6, r7, #4
c0d04dda:	08b6      	lsrs	r6, r6, #2
c0d04ddc:	00b4      	lsls	r4, r6, #2
c0d04dde:	46a4      	mov	ip, r4
c0d04de0:	001a      	movs	r2, r3
c0d04de2:	1d1c      	adds	r4, r3, #4
c0d04de4:	4464      	add	r4, ip
c0d04de6:	c220      	stmia	r2!, {r5}
c0d04de8:	42a2      	cmp	r2, r4
c0d04dea:	d1fc      	bne.n	c0d04de6 <memset+0x7a>
c0d04dec:	2403      	movs	r4, #3
c0d04dee:	3601      	adds	r6, #1
c0d04df0:	00b6      	lsls	r6, r6, #2
c0d04df2:	199b      	adds	r3, r3, r6
c0d04df4:	403c      	ands	r4, r7
c0d04df6:	2c00      	cmp	r4, #0
c0d04df8:	d005      	beq.n	c0d04e06 <memset+0x9a>
c0d04dfa:	b2c9      	uxtb	r1, r1
c0d04dfc:	191c      	adds	r4, r3, r4
c0d04dfe:	7019      	strb	r1, [r3, #0]
c0d04e00:	3301      	adds	r3, #1
c0d04e02:	429c      	cmp	r4, r3
c0d04e04:	d1fb      	bne.n	c0d04dfe <memset+0x92>
c0d04e06:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d04e08:	0003      	movs	r3, r0
c0d04e0a:	0014      	movs	r4, r2
c0d04e0c:	e7c0      	b.n	c0d04d90 <memset+0x24>
c0d04e0e:	0027      	movs	r7, r4
c0d04e10:	e7e2      	b.n	c0d04dd8 <memset+0x6c>
c0d04e12:	46c0      	nop			; (mov r8, r8)

c0d04e14 <setjmp>:
c0d04e14:	c0f0      	stmia	r0!, {r4, r5, r6, r7}
c0d04e16:	4641      	mov	r1, r8
c0d04e18:	464a      	mov	r2, r9
c0d04e1a:	4653      	mov	r3, sl
c0d04e1c:	465c      	mov	r4, fp
c0d04e1e:	466d      	mov	r5, sp
c0d04e20:	4676      	mov	r6, lr
c0d04e22:	c07e      	stmia	r0!, {r1, r2, r3, r4, r5, r6}
c0d04e24:	3828      	subs	r0, #40	; 0x28
c0d04e26:	c8f0      	ldmia	r0!, {r4, r5, r6, r7}
c0d04e28:	2000      	movs	r0, #0
c0d04e2a:	4770      	bx	lr

c0d04e2c <longjmp>:
c0d04e2c:	3010      	adds	r0, #16
c0d04e2e:	c87c      	ldmia	r0!, {r2, r3, r4, r5, r6}
c0d04e30:	4690      	mov	r8, r2
c0d04e32:	4699      	mov	r9, r3
c0d04e34:	46a2      	mov	sl, r4
c0d04e36:	46ab      	mov	fp, r5
c0d04e38:	46b5      	mov	sp, r6
c0d04e3a:	c808      	ldmia	r0!, {r3}
c0d04e3c:	3828      	subs	r0, #40	; 0x28
c0d04e3e:	c8f0      	ldmia	r0!, {r4, r5, r6, r7}
c0d04e40:	0008      	movs	r0, r1
c0d04e42:	d100      	bne.n	c0d04e46 <longjmp+0x1a>
c0d04e44:	2001      	movs	r0, #1
c0d04e46:	4718      	bx	r3

c0d04e48 <strlen>:
c0d04e48:	b510      	push	{r4, lr}
c0d04e4a:	0783      	lsls	r3, r0, #30
c0d04e4c:	d00a      	beq.n	c0d04e64 <strlen+0x1c>
c0d04e4e:	0003      	movs	r3, r0
c0d04e50:	2103      	movs	r1, #3
c0d04e52:	e002      	b.n	c0d04e5a <strlen+0x12>
c0d04e54:	3301      	adds	r3, #1
c0d04e56:	420b      	tst	r3, r1
c0d04e58:	d005      	beq.n	c0d04e66 <strlen+0x1e>
c0d04e5a:	781a      	ldrb	r2, [r3, #0]
c0d04e5c:	2a00      	cmp	r2, #0
c0d04e5e:	d1f9      	bne.n	c0d04e54 <strlen+0xc>
c0d04e60:	1a18      	subs	r0, r3, r0
c0d04e62:	bd10      	pop	{r4, pc}
c0d04e64:	0003      	movs	r3, r0
c0d04e66:	6819      	ldr	r1, [r3, #0]
c0d04e68:	4a0c      	ldr	r2, [pc, #48]	; (c0d04e9c <strlen+0x54>)
c0d04e6a:	4c0d      	ldr	r4, [pc, #52]	; (c0d04ea0 <strlen+0x58>)
c0d04e6c:	188a      	adds	r2, r1, r2
c0d04e6e:	438a      	bics	r2, r1
c0d04e70:	4222      	tst	r2, r4
c0d04e72:	d10f      	bne.n	c0d04e94 <strlen+0x4c>
c0d04e74:	6859      	ldr	r1, [r3, #4]
c0d04e76:	4a09      	ldr	r2, [pc, #36]	; (c0d04e9c <strlen+0x54>)
c0d04e78:	3304      	adds	r3, #4
c0d04e7a:	188a      	adds	r2, r1, r2
c0d04e7c:	438a      	bics	r2, r1
c0d04e7e:	4222      	tst	r2, r4
c0d04e80:	d108      	bne.n	c0d04e94 <strlen+0x4c>
c0d04e82:	6859      	ldr	r1, [r3, #4]
c0d04e84:	4a05      	ldr	r2, [pc, #20]	; (c0d04e9c <strlen+0x54>)
c0d04e86:	3304      	adds	r3, #4
c0d04e88:	188a      	adds	r2, r1, r2
c0d04e8a:	438a      	bics	r2, r1
c0d04e8c:	4222      	tst	r2, r4
c0d04e8e:	d0f1      	beq.n	c0d04e74 <strlen+0x2c>
c0d04e90:	e000      	b.n	c0d04e94 <strlen+0x4c>
c0d04e92:	3301      	adds	r3, #1
c0d04e94:	781a      	ldrb	r2, [r3, #0]
c0d04e96:	2a00      	cmp	r2, #0
c0d04e98:	d1fb      	bne.n	c0d04e92 <strlen+0x4a>
c0d04e9a:	e7e1      	b.n	c0d04e60 <strlen+0x18>
c0d04e9c:	fefefeff 	.word	0xfefefeff
c0d04ea0:	80808080 	.word	0x80808080

c0d04ea4 <strncpy>:
c0d04ea4:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d04ea6:	000c      	movs	r4, r1
c0d04ea8:	4304      	orrs	r4, r0
c0d04eaa:	0003      	movs	r3, r0
c0d04eac:	0007      	movs	r7, r0
c0d04eae:	07a4      	lsls	r4, r4, #30
c0d04eb0:	d112      	bne.n	c0d04ed8 <strncpy+0x34>
c0d04eb2:	2a03      	cmp	r2, #3
c0d04eb4:	d910      	bls.n	c0d04ed8 <strncpy+0x34>
c0d04eb6:	4c14      	ldr	r4, [pc, #80]	; (c0d04f08 <strncpy+0x64>)
c0d04eb8:	46a4      	mov	ip, r4
c0d04eba:	4667      	mov	r7, ip
c0d04ebc:	680d      	ldr	r5, [r1, #0]
c0d04ebe:	4c13      	ldr	r4, [pc, #76]	; (c0d04f0c <strncpy+0x68>)
c0d04ec0:	001e      	movs	r6, r3
c0d04ec2:	192c      	adds	r4, r5, r4
c0d04ec4:	43ac      	bics	r4, r5
c0d04ec6:	423c      	tst	r4, r7
c0d04ec8:	d11b      	bne.n	c0d04f02 <strncpy+0x5e>
c0d04eca:	3304      	adds	r3, #4
c0d04ecc:	3a04      	subs	r2, #4
c0d04ece:	001f      	movs	r7, r3
c0d04ed0:	3104      	adds	r1, #4
c0d04ed2:	6035      	str	r5, [r6, #0]
c0d04ed4:	2a03      	cmp	r2, #3
c0d04ed6:	d8f0      	bhi.n	c0d04eba <strncpy+0x16>
c0d04ed8:	2400      	movs	r4, #0
c0d04eda:	18be      	adds	r6, r7, r2
c0d04edc:	e006      	b.n	c0d04eec <strncpy+0x48>
c0d04ede:	5d0d      	ldrb	r5, [r1, r4]
c0d04ee0:	3a01      	subs	r2, #1
c0d04ee2:	553d      	strb	r5, [r7, r4]
c0d04ee4:	1ab3      	subs	r3, r6, r2
c0d04ee6:	3401      	adds	r4, #1
c0d04ee8:	2d00      	cmp	r5, #0
c0d04eea:	d002      	beq.n	c0d04ef2 <strncpy+0x4e>
c0d04eec:	2a00      	cmp	r2, #0
c0d04eee:	d1f6      	bne.n	c0d04ede <strncpy+0x3a>
c0d04ef0:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d04ef2:	2100      	movs	r1, #0
c0d04ef4:	2a00      	cmp	r2, #0
c0d04ef6:	d0fb      	beq.n	c0d04ef0 <strncpy+0x4c>
c0d04ef8:	7019      	strb	r1, [r3, #0]
c0d04efa:	3301      	adds	r3, #1
c0d04efc:	429e      	cmp	r6, r3
c0d04efe:	d1fb      	bne.n	c0d04ef8 <strncpy+0x54>
c0d04f00:	e7f6      	b.n	c0d04ef0 <strncpy+0x4c>
c0d04f02:	001f      	movs	r7, r3
c0d04f04:	e7e8      	b.n	c0d04ed8 <strncpy+0x34>
c0d04f06:	46c0      	nop			; (mov r8, r8)
c0d04f08:	80808080 	.word	0x80808080
c0d04f0c:	fefefeff 	.word	0xfefefeff

c0d04f10 <bzero>:
c0d04f10:	b510      	push	{r4, lr}
c0d04f12:	000a      	movs	r2, r1
c0d04f14:	2100      	movs	r1, #0
c0d04f16:	f7ff ff29 	bl	c0d04d6c <memset>
c0d04f1a:	bd10      	pop	{r4, pc}
c0d04f1c:	6b627550 	.word	0x6b627550
c0d04f20:	41007965 	.word	0x41007965
c0d04f24:	6f727070 	.word	0x6f727070
c0d04f28:	52006576 	.word	0x52006576
c0d04f2c:	63656a65 	.word	0x63656a65
c0d04f30:	00000074 	.word	0x00000074

c0d04f34 <ux_display_public_flow_5_step_val>:
c0d04f34:	c0d04f1c 20000220                       .O.. .. 

c0d04f3c <ux_display_public_flow_5_step>:
c0d04f3c:	c0d0421d c0d04f34 00000000 00000000     .B..4O..........

c0d04f4c <ux_display_public_flow_6_step_validate_step>:
c0d04f4c:	c0d00271 00000000 00000000 00000000     q...............

c0d04f5c <ux_display_public_flow_6_step_validate>:
c0d04f5c:	c0d04f4c ffffffff                       LO......

c0d04f64 <ux_display_public_flow_6_step_val>:
c0d04f64:	c0d05144 c0d04f23                       DQ..#O..

c0d04f6c <ux_display_public_flow_6_step>:
c0d04f6c:	c0d045c1 c0d04f64 c0d04f5c 00000000     .E..dO..\O......

c0d04f7c <ux_display_public_flow_7_step_validate_step>:
c0d04f7c:	c0d00291 00000000 00000000 00000000     ................

c0d04f8c <ux_display_public_flow_7_step_validate>:
c0d04f8c:	c0d04f7c ffffffff                       |O......

c0d04f94 <ux_display_public_flow_7_step_val>:
c0d04f94:	c0d05054 c0d04f2b                       TP..+O..

c0d04f9c <ux_display_public_flow_7_step>:
c0d04f9c:	c0d045c1 c0d04f94 c0d04f8c 00000000     .E...O...O......

c0d04fac <ux_display_public_flow>:
c0d04fac:	c0d04f3c c0d04f6c c0d04f9c ffffffff     <O..lO...O......

c0d04fbc <C_aelf_logo_colors>:
c0d04fbc:	00000000 00ffffff                       ........

c0d04fc4 <C_aelf_logo_bitmap>:
c0d04fc4:	ffffffff fe63fe7f f3c3ffe3 c0ffe19f     ......c.........
c0d04fd4:	e19fc0ff ffe3f3c3 fe7ffe63 ffffffff     ........c.......

c0d04fe4 <C_aelf_logo>:
c0d04fe4:	00000010 00000010 00000001 c0d04fbc     .............O..
c0d04ff4:	c0d04fc4                                .O..

c0d04ff8 <C_icon_coggle_colors>:
c0d04ff8:	00000000 00ffffff                       ........

c0d05000 <C_icon_coggle_bitmap>:
c0d05000:	00000000 f80b400c f3c0fc07 03f03cf0     .....@.......<..
c0d05010:	002d01fe 00000003 00000000              ..-.........

c0d0501c <C_icon_coggle>:
c0d0501c:	0000000e 0000000e 00000001 c0d04ff8     .............O..
c0d0502c:	c0d05000                                .P..

c0d05030 <C_icon_crossmark_colors>:
c0d05030:	00000000 00ffffff                       ........

c0d05038 <C_icon_crossmark_bitmap>:
c0d05038:	e6018000 383871c0 1e00fc07 03f00780     .....q88........
c0d05048:	38e1c1ce 00180670 00000000              ...8p.......

c0d05054 <C_icon_crossmark>:
c0d05054:	0000000e 0000000e 00000001 c0d05030     ............0P..
c0d05064:	c0d05038                                8P..

c0d05068 <C_icon_dashboard_x_colors>:
c0d05068:	00000000 00ffffff                       ........

c0d05070 <C_icon_dashboard_x_bitmap>:
c0d05070:	00000000 f007800c ffc1fe03 03f03ff0     .............?..
c0d05080:	c03300cc 0000000c 00000000              ..3.........

c0d0508c <C_icon_dashboard_x>:
c0d0508c:	0000000e 0000000e 00000001 c0d05068     ............hP..
c0d0509c:	c0d05070                                pP..

c0d050a0 <C_icon_down_colors>:
c0d050a0:	00000000 00ffffff                       ........

c0d050a8 <C_icon_down_bitmap>:
c0d050a8:	01051141                                A...

c0d050ac <C_icon_down>:
c0d050ac:	00000007 00000004 00000001 c0d050a0     .............P..
c0d050bc:	c0d050a8                                .P..

c0d050c0 <C_icon_left_colors>:
c0d050c0:	00000000 00ffffff                       ........

c0d050c8 <C_icon_left_bitmap>:
c0d050c8:	08421248                                H.B.

c0d050cc <C_icon_left>:
c0d050cc:	00000004 00000007 00000001 c0d050c0     .............P..
c0d050dc:	c0d050c8                                .P..

c0d050e0 <C_icon_right_colors>:
c0d050e0:	00000000 00ffffff                       ........

c0d050e8 <C_icon_right_bitmap>:
c0d050e8:	01248421                                !.$.

c0d050ec <C_icon_right>:
c0d050ec:	00000004 00000007 00000001 c0d050e0     .............P..
c0d050fc:	c0d050e8                                .P..

c0d05100 <C_icon_up_colors>:
c0d05100:	00000000 00ffffff                       ........

c0d05108 <C_icon_up_bitmap>:
c0d05108:	08288a08                                ..(.

c0d0510c <C_icon_up>:
c0d0510c:	00000007 00000004 00000001 c0d05100     .............Q..
c0d0511c:	c0d05108                                .Q..

c0d05120 <C_icon_validate_14_colors>:
c0d05120:	00000000 00ffffff                       ........

c0d05128 <C_icon_validate_14_bitmap>:
c0d05128:	00000000 00c00000 e0670038 039c1c38     ........8.g.8...
c0d05138:	800f007e 00000001 00000000              ~...........

c0d05144 <C_icon_validate_14>:
c0d05144:	0000000e 0000000e 00000001 c0d05120     ............ Q..
c0d05154:	c0d05128 6e6b6e55 206e776f 6c656966     (Q..Unknown fiel
c0d05164:	756e2064 7265626d 0a642520 61725400     d number %d..Tra
c0d05174:	6566736e 65520072 69706963 00746e65     nsfer.Recipient.
c0d05184:	2077654e 55445041 63657220 65766965     New APDU receive
c0d05194:	250a3a64 0a482a2e 6c6c4100 6220776f     d:.%.*H..Allow b
c0d051a4:	646e696c 67697320 7550006e 79656b62     lind sign.Pubkey
c0d051b4:	6e656c20 00687467 70736944 2079616c      length.Display 
c0d051c4:	65646f6d 63614200 6f4e006b 73655900     mode.Back.No.Yes
c0d051d4:	6e6f4c00 68530067 0074726f 72657355     .Long.Short.User
c0d051e4:	70784500 00747265 6c707041 74616369     .Expert.Applicat
c0d051f4:	006e6f69 72207369 79646165 74655300     ion.is ready.Set
c0d05204:	676e6974 65560073 6f697372 2e31006e     tings.Version.1.
c0d05214:	00302e30 74697551 00000000              0.0.Quit....

c0d05220 <settings_submenu_getter_values>:
c0d05220:	c0d0519d c0d051ae c0d051bc c0d051c9     .Q...Q...Q...Q..

c0d05230 <no_yes_data_getter_values>:
c0d05230:	c0d051ce c0d051d1 c0d051c9              .Q...Q...Q..

c0d0523c <pubkey_display_data_getter_values>:
c0d0523c:	c0d051d5 c0d051da c0d051c9              .Q...Q...Q..

c0d05248 <display_mode_data_getter_values>:
c0d05248:	c0d051e0 c0d051e5 c0d051c9              .Q...Q...Q..

c0d05254 <ux_idle_flow_1_step_val>:
c0d05254:	c0d04fe4 c0d051ec c0d051f8              .O...Q...Q..

c0d05260 <ux_idle_flow_1_step>:
c0d05260:	c0d046cd c0d05254 00000000 00000000     .F..TR..........

c0d05270 <ux_idle_flow_2_step_validate_step>:
c0d05270:	c0d00dfd 00000000 00000000 00000000     ................

c0d05280 <ux_idle_flow_2_step_validate>:
c0d05280:	c0d05270 ffffffff                       pR......

c0d05288 <ux_idle_flow_2_step_val>:
c0d05288:	c0d0501c c0d05201                       .P...R..

c0d05290 <ux_idle_flow_2_step>:
c0d05290:	c0d045c1 c0d05288 c0d05280 00000000     .E...R...R......

c0d052a0 <ux_idle_flow_3_step_val>:
c0d052a0:	c0d0520a c0d05212                       .R...R..

c0d052a8 <ux_idle_flow_3_step>:
c0d052a8:	c0d04051 c0d052a0 00000000 00000000     Q@...R..........

c0d052b8 <ux_idle_flow_4_step_validate_step>:
c0d052b8:	c0d00e19 00000000 00000000 00000000     ................

c0d052c8 <ux_idle_flow_4_step_validate>:
c0d052c8:	c0d052b8 ffffffff                       .R......

c0d052d0 <ux_idle_flow_4_step_val>:
c0d052d0:	c0d0508c c0d05218                       .P...R..

c0d052d8 <ux_idle_flow_4_step>:
c0d052d8:	c0d045c1 c0d052d0 c0d052c8 00000000     .E...R...R......

c0d052e8 <ux_idle_flow>:
c0d052e8:	c0d05260 c0d05290 c0d052a8 c0d052d8     `R...R...R...R..
c0d052f8:	fffffffd ffffffff 65637865 6f697470     ........exceptio
c0d05308:	64255b6e 4c203a5d 78303d52 58383025     n[%d]: LR=0x%08X
c0d05318:	                                         ..

c0d0531a <seph_io_general_status>:
c0d0531a:	00020060 45002000 524f5252               `.... .ERROR.

c0d05327 <g_pcHex>:
c0d05327:	33323130 37363534 62613938 66656463     0123456789abcdef

c0d05337 <g_pcHex_cap>:
c0d05337:	33323130 37363534 42413938 46454443     0123456789ABCDEF
c0d05347:	00464c45                                ELF.

c0d0534b <BASE58_ALPHABET>:
c0d0534b:	34333231 38373635 43424139 47464544     123456789ABCDEFG
c0d0535b:	4c4b4a48 51504e4d 55545352 59585756     HJKLMNPQRSTUVWXY
c0d0536b:	6362615a 67666564 6b6a6968 706f6e6d     Zabcdefghijkmnop
c0d0537b:	74737271 78777675                        qrstuvwxyz.

c0d05386 <DayOffset>:
c0d05386:	01320000 00000151 003d001f 007a005c     ..2.Q.....=.\.z.
c0d05396:	00b80099 00f500d6                        ..........

c0d053a0 <ux_approve_step_validate_step>:
c0d053a0:	c0d0253d 00000000 00000000 00000000     =%..............

c0d053b0 <ux_approve_step_validate>:
c0d053b0:	c0d053a0 ffffffff 3a495547 2a2e250a     .S......GUI:.%.*
c0d053c0:	55000a48 6365726e 696e676f 0064657a     H..Unrecognized.
c0d053d0:	6d726f66 4d007461 61737365 48206567     format.Message H
c0d053e0:	00687361                                ash.

c0d053e4 <ux_approve_step_val>:
c0d053e4:	c0d05144 c0d04f23                       DQ..#O..

c0d053ec <ux_approve_step>:
c0d053ec:	c0d045c1 c0d053e4 c0d053b0 00000000     .E...S...S......

c0d053fc <ux_reject_step_validate_step>:
c0d053fc:	c0d0254d 00000000 00000000 00000000     M%..............

c0d0540c <ux_reject_step_validate>:
c0d0540c:	c0d053fc ffffffff                       .S......

c0d05414 <ux_reject_step_val>:
c0d05414:	c0d05054 c0d04f2b                       TP..+O..

c0d0541c <ux_reject_step>:
c0d0541c:	c0d045c1 c0d05414 c0d0540c 00000000     .E...T...T......

c0d0542c <ux_summary_step_val>:
c0d0542c:	20000c60 20000c80                       `.. ... 

c0d05434 <ux_summary_step>:
c0d05434:	c0d02559 c0d0542c 00000000 00000000     Y%..,T..........

c0d05444 <USBD_HID_Desc>:
c0d05444:	01112109 22220100                        .!...."".

c0d0544d <HID_ReportDesc>:
c0d0544d:	09ffa006 0901a101 26001503 087500ff     ...........&..u.
c0d0545d:	08814095 00150409 7500ff26 91409508     .@......&..u..@.
c0d0546d:	                                         ..

c0d0546f <C_usb_bos>:
c0d0546f:	00390f05 05101802 08b63800 a009a934     ..9......8..4...
c0d0547f:	a0fd8b47 b6158876 1e010065 05101c00     G...v...e.......
c0d0548f:	dd60df00 c74589d8 65d29c4c 8a649e9d     ..`...E.L..e..d.
c0d0549f:	0300009f 7700b206                        .......w.

c0d054a8 <HID_Desc>:
c0d054a8:	c0d037dd c0d037ed c0d037fd c0d0380d     .7...7...7...8..
c0d054b8:	c0d0381d c0d0382d c0d0383d c0d0384d     .8..-8..=8..M8..

c0d054c8 <C_winusb_string_descriptor>:
c0d054c8:	004d0312 00460053 00310054 00300030     ..M.S.F.T.1.0.0.
c0d054d8:	                                         w.

c0d054da <C_winusb_guid>:
c0d054da:	00000092 00050100 00880001 00070000     ................
c0d054ea:	002a0000 00650044 00690076 00650063     ..*.D.e.v.i.c.e.
c0d054fa:	006e0049 00650074 00660072 00630061     I.n.t.e.r.f.a.c.
c0d0550a:	00470065 00490055 00730044 00500000     e.G.U.I.D.s...P.
c0d0551a:	007b0000 00330031 00360064 00340033     ..{.1.3.d.6.3.4.
c0d0552a:	00300030 0032002d 00390043 002d0037     0.0.-.2.C.9.7.-.
c0d0553a:	00300030 00340030 0030002d 00300030     0.0.0.4.-.0.0.0.
c0d0554a:	002d0030 00630034 00350036 00340036     0.-.4.c.6.5.6.4.
c0d0555a:	00370036 00350036 00320037 0000007d     6.7.6.5.7.2.}...
	...

c0d0556c <C_winusb_request_descriptor>:
c0d0556c:	0000000a 06030000 000800b2 00000001     ................
c0d0557c:	000800a8 00010002 001400a0 49570003     ..............WI
c0d0558c:	4253554e 00000000 00000000 00840000     NUSB............
c0d0559c:	00070004 0044002a 00760065 00630069     ....*.D.e.v.i.c.
c0d055ac:	00490065 0074006e 00720065 00610066     e.I.n.t.e.r.f.a.
c0d055bc:	00650063 00550047 00440049 00000073     c.e.G.U.I.D.s...
c0d055cc:	007b0050 00450043 00300038 00320039     P.{.C.E.8.0.9.2.
c0d055dc:	00340036 0034002d 00320042 002d0034     6.4.-.4.B.2.4.-.
c0d055ec:	00450034 00310038 0041002d 00420038     4.E.8.1.-.A.8.B.
c0d055fc:	002d0032 00370035 00440045 00310030     2.-.5.7.E.D.0.1.
c0d0560c:	00350044 00300038 00310045 0000007d     D.5.8.0.E.1.}...
c0d0561c:	00000000                                ....

c0d05620 <USBD_HID>:
c0d05620:	c0d03659 c0d0368b c0d035c5 00000000     Y6...6...5......
c0d05630:	00000000 c0d036e1 c0d036f9 00000000     .....6...6......
	...
c0d05648:	c0d03955 c0d03955 c0d03955 c0d03965     U9..U9..U9..e9..

c0d05658 <USBD_WEBUSB>:
c0d05658:	c0d03745 c0d03771 c0d03775 00000000     E7..q7..u7......
c0d05668:	00000000 c0d03779 c0d03791 00000000     ....y7...7......
	...
c0d05680:	c0d03955 c0d03955 c0d03955 c0d03965     U9..U9..U9..e9..

c0d05690 <USBD_DeviceDesc>:
c0d05690:	02100112 40000000 10112c97 02010201     .......@.,......
c0d056a0:	                                         ..

c0d056a2 <USBD_LangIDDesc>:
c0d056a2:	04090304                                ....

c0d056a6 <USBD_MANUFACTURER_STRING>:
c0d056a6:	004c030e 00640065 00650067               ..L.e.d.g.e.r.

c0d056b4 <USBD_PRODUCT_FS_STRING>:
c0d056b4:	004e030e 006e0061 0020006f               ..N.a.n.o. .S.

c0d056c2 <USB_SERIAL_STRING>:
c0d056c2:	0030030a 00300030                        ..0.0.0.1.

c0d056cc <C_winusb_wcid>:
c0d056cc:	00000028 00040100 00000001 00000000     (...............
c0d056dc:	49570101 4253554e 00000000 00000000     ..WINUSB........
	...

c0d056f4 <USBD_CfgDesc>:
c0d056f4:	00400209 c0020102 00040932 00030200     ..@.....2.......
c0d05704:	21090200 01000111 07002222 40038205     ...!...."".....@
c0d05714:	05070100 00400302 01040901 ffff0200     ......@.........
c0d05724:	050702ff 00400383 03050701 01004003     ......@......@..

c0d05734 <USBD_DeviceQualifierDesc>:
c0d05734:	0200060a 40000000 64650001 31353532     .......@..ed2551
c0d05744:	65732039 00006465                       9 seed..

c0d0574c <ux_layout_bb_elements>:
c0d0574c:	00000003 00800000 00000020 00000001     ........ .......
c0d0575c:	00000000 00ffffff 00000000 00000000     ................
c0d0576c:	00020105 0004000c 00000007 00000000     ................
c0d0577c:	00ffffff 00000000 00000000 c0d050cc     .............P..
c0d0578c:	007a0205 0004000c 00000007 00000000     ..z.............
c0d0579c:	00ffffff 00000000 00000000 c0d050ec     .............P..
c0d057ac:	00061007 0074000c 00000020 00000000     ......t. .......
c0d057bc:	00ffffff 00000000 00008008 00000000     ................
c0d057cc:	00061107 0074001a 00000020 00000000     ......t. .......
c0d057dc:	00ffffff 00000000 00008008 00000000     ................

c0d057ec <ux_layout_nnbnn_elements>:
c0d057ec:	00000003 00800000 00000020 00000001     ........ .......
c0d057fc:	00000000 00ffffff 00000000 00000000     ................
c0d0580c:	00000105 0007000e 00000004 00000000     ................
c0d0581c:	00ffffff 00000000 00000000 c0d0510c     .............Q..
c0d0582c:	00780205 0007000e 00000004 00000000     ..x.............
c0d0583c:	00ffffff 00000000 00000000 c0d050ac     .............P..
c0d0584c:	00081107 00700003 00000020 00000000     ......p. .......
c0d0585c:	00ffffff 00000000 0000800a 00000000     ................
c0d0586c:	00081207 00700013 00000020 00000000     ......p. .......
c0d0587c:	00ffffff 00000000 00008008 00000000     ................
c0d0588c:	00081307 00700023 00000020 00000000     ....#.p. .......
c0d0589c:	00ffffff 00000000 0000800a 00000000     ................
c0d058ac:	28207325 252f6425 25002964 64250073     %s (%d/%d).%s.%d
c0d058bc:	0064252f 732a2e25                        /%d.%.*s.

c0d058c5 <nanos_characters_width>:
c0d058c5:	77463333 23899a66 66663434 45334433     33Fwf..#44ff3D3E
c0d058d5:	67676668 67686688 33336868 56656665     hfgg.fhghh33efeV
c0d058e5:	777778aa 88666688 78453488 9989ab66     .xww.ff..4Exf...
c0d058f5:	66789977 ab768876 45676768 56674545     w.xfv.v.hggEEEgV
c0d05905:	56776767 67566777 67453477 7777aa34     ggwVwgVgw4Eg4.ww
c0d05915:	56457777 9a677745 45566767 76664566     wwEVEwg.ggVEfEfv
c0d05925:	                                         ...

c0d05928 <ux_layout_pb_elements>:
c0d05928:	00000003 00800000 00000020 00000001     ........ .......
c0d05938:	00000000 00ffffff 00000000 00000000     ................
c0d05948:	00020105 0004000c 00000007 00000000     ................
c0d05958:	00ffffff 00000000 00000000 c0d050cc     .............P..
c0d05968:	007a0205 0004000c 00000007 00000000     ..z.............
c0d05978:	00ffffff 00000000 00000000 c0d050ec     .............P..
c0d05988:	00381005 00100002 00000010 00000000     ..8.............
c0d05998:	00ffffff 00000000 0000800a 00000000     ................
c0d059a8:	00001107 0080001c 00000020 00000000     ........ .......
c0d059b8:	00ffffff 00000000 00008008 00000000     ................

c0d059c8 <ux_layout_pbb_elements>:
c0d059c8:	00000003 00800000 00000020 00000001     ........ .......
c0d059d8:	00000000 00ffffff 00000000 00000000     ................
c0d059e8:	00020105 0004000c 00000007 00000000     ................
c0d059f8:	00ffffff 00000000 00000000 c0d050cc     .............P..
c0d05a08:	007a0205 0004000c 00000007 00000000     ..z.............
c0d05a18:	00ffffff 00000000 00000000 c0d050ec     .............P..
c0d05a28:	00100f05 00100008 00000010 00000000     ................
c0d05a38:	00ffffff 00000000 00000000 00000000     ................
c0d05a48:	00291007 0080000c 00000020 00000000     ..)..... .......
c0d05a58:	00ffffff 00000000 00000008 00000000     ................
c0d05a68:	00291107 0080001a 00000020 00000000     ..)..... .......
c0d05a78:	00ffffff 00000000 00000008 00000000     ................

c0d05a88 <ux_menulist_conststep>:
c0d05a88:	c0d047bd 20000338 00000000 00000000     .G..8.. ........

c0d05a98 <ux_menulist_constflow>:
c0d05a98:	c0d05a88 ffffffff                       .Z......

c0d05aa0 <_etext>:
	...

c0d05ac0 <N_storage_real>:
	...
