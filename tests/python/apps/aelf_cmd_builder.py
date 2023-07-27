from typing import List
from enum import IntEnum
import base58
from nacl.signing import VerifyKey
from aelf import AElf
import logging
logger = logging.getLogger(__name__)


def verify_signature(from_public_key: bytes, message: bytes, signature: bytes):
    if len(signature) == 64:
        if verify_signature0(from_public_key, message, signature + b'\00'):
            return True
        return verify_signature0(from_public_key, message, signature + b'\01')
    return verify_signature0(from_public_key, message, signature)


def verify_signature0(from_public_key: bytes, message: bytes, signature: bytes):
    import eth_keys
    from hashlib import sha256
    api = eth_keys.KeyAPI()
    sig = api.Signature(signature)
    msg_hash = sha256(message).digest()
    recovered = sig.recover_public_key_from_msg_hash(msg_hash)
    matched = recovered[:32] == from_public_key[1:33]
    logger.info("Pubkeys%s match: recovered -> %s, and expected %s" % (not matched and " NOT" or "", recovered.encode('hex'), from_public_key.encode('hex')))
    return matched


class SystemInstruction(IntEnum):
    CreateAccount           = 0x00
    Assign                  = 0x01
    Transfer                = 0x02

# Only support Transfer instruction for now
# TODO add other instructions if the need arises
class Instruction:
    data: bytes
    to_pubkey: bytes
    ticker: bytes
    def serialize(self) -> bytes:
        serialized: bytes = self.to_pubkey
        serialized += len(self.ticker).to_bytes(1, byteorder='little')
        serialized += self.ticker
        serialized += self.data
        return serialized

class TxResultInstruction:
    from_pubkey: bytes
    chain_pubkey: bytes
    ref_block_number: bytes
    method_name: bytes
    to_pubkey: bytes
    ticker: bytes
    data: bytes
    def serialize(self) -> bytes:
        serialized: bytes = self.from_pubkey
        serialized += self.chain_pubkey
        serialized += self.ref_block_number
        serialized += len(self.method_name).to_bytes(8, byteorder='little')
        serialized += self.method_name
        serialized += self.to_pubkey
        serialized += len(self.ticker).to_bytes(1, byteorder='little')
        serialized += self.ticker
        serialized += self.data
        return serialized

class SystemInstructionTransfer(Instruction):
    def __init__(self, to_pubkey: bytes, ticker: bytes, amount: bytes):
        self.data =  (amount).to_bytes(8, byteorder='little')
        self.to_pubkey = to_pubkey
        self.ticker = ticker
class SystemInstructionGetTxResult(TxResultInstruction):
    def __init__(self, from_pubkey: bytes, chain_pubkey: bytes, ref_block_number: int, method_name: bytes, to_pubkey : bytes, ticker: bytes, amount: int):
        self.from_pubkey = from_pubkey
        self.chain_pubkey = chain_pubkey
        self.ref_block_number = (ref_block_number).to_bytes(8, byteorder='little')
        self.method_name = method_name
        self.to_pubkey = to_pubkey
        self.ticker = ticker
        self.data = (amount).to_bytes(8, byteorder='little')
class MessageTransfer:
    recent_blockhash: bytes
    instruction: Instruction

    def __init__(self, instruction: Instruction):
        self.recent_blockhash = base58.b58decode(FAKE_RECENT_BLOCKHASH)
        self.instruction = instruction

    def serialize(self) -> bytes:
        serialized: bytes = self.recent_blockhash
        serialized += self.instruction.serialize()
        return serialized

class MessageTxResult:
    recent_blockhash: bytes
    txResultInstruction: TxResultInstruction

    def __init__(self, txResultInstruction: TxResultInstruction):
        self.recent_blockhash = base58.b58decode(FAKE_RECENT_BLOCKHASH)
        self.txResultInstruction = txResultInstruction

    def serialize(self) -> bytes:
        serialized: bytes = self.recent_blockhash
        serialized += self.txResultInstruction.serialize()
        return serialized
