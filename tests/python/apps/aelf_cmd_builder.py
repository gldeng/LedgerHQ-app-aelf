from typing import List
from enum import IntEnum
import base58
from nacl.signing import VerifyKey
from aelf import AElf

def verify_signature(from_public_key: bytes, message: bytes, signature: bytes):
    assert len(signature) == 65, "signature doesn't have the correct size"
    import eth_keys
    from hashlib import sha256
    api = eth_keys.KeyAPI()
    sig = api.Signature(signature)
    msg_hash = sha256(message).digest()
    recovered = sig.recover_public_key_from_msg_hash(msg_hash)
    assert recovered[:32] == from_public_key[1:33], "recovered public key doesn't match the given public key"

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
