from .protobuf.aelf_pb2 import TransferInput, Transaction
import base58
from struct import pack

packed_derivation_path = bytes.fromhex("01048000002c800006508000000080000000")


def get_default_transfer() -> TransferInput:
    transfer = TransferInput()
    transfer.to.value = base58.b58decode_check("cDPLA9axUVeujnTTk4Cyr3aqRby3cHHAB6Rh28o7BRTTxi8US")
    transfer.symbol = "ELF"
    transfer.amount = 42_00_000_000
    transfer.memo = "a test memo"
    return transfer


def get_default_transaction(transfer: TransferInput) -> Transaction:
    tx = Transaction()
    tx.__getattribute__("from").value = base58.b58decode_check("CRuQygxHeZLvfMFLbZQVvs6DMeWe3Jn9m3yDiCF5JgmdWAiLN")
    tx.to.value = base58.b58decode_check("JRmBduh4nXWi1aXgdUsj5gJrzeZb2LxmrAbf7W99faZSvoAaE")
    tx.method_name = "Transfer"
    tx.ref_block_number = 157853325
    tx.ref_block_prefix = bytes.fromhex('5a744738')
    tx.params = transfer.SerializeToString()
    return tx


def pack_transaction(tx: Transaction) -> str:
    def _pack_APDU(cla: int, ins: int, p1: int = 0, p2: int = 0, data: bytes = b"") -> bytes:
        return pack(">BBBBB", cla, ins, p1, p2, len(data)) + data
    data = packed_derivation_path + tx.SerializeToString()
    return _pack_APDU(0xe0, 0x03, 0x01, 0x00, data).hex()


def _default_tc():
    tfr = get_default_transfer()
    tx = get_default_transaction(tfr)
    return pack_transaction(tx)


def _invalid_symbol():
    tfr = get_default_transfer()
    tfr.symbol = "ABC"
    tx = get_default_transaction(tfr)
    return pack_transaction(tx)


def _invalid_method_name():
    tfr = get_default_transfer()
    tx = get_default_transaction(tfr)
    tx.method_name = "Approve" # Cheating user to approve an allowance
    return pack_transaction(tx)


def _non_token_contract():
    non_token_addr = base58.b58decode_check("2aoPatvMevjmhwsU1S9pkH2vnkNAuaiUaiU6JDroKNKe3fBQns")
    tfr = get_default_transfer()
    tx = get_default_transaction(tfr)
    tx.to.value = non_token_addr
    return pack_transaction(tx)


def generate_test_cases():
    return {
        "default": _default_tc(),
        "invalidSymbol": _invalid_symbol(),
        "invalidMethodName": _invalid_method_name(),
        "nonTokenContract": _non_token_contract(),
    }

