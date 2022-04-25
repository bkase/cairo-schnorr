# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from ec import EcPoint
from bigint import BigInt3
from ecdsa import verify_ecdsa


# Define a storage variable.
@storage_var
func balance() -> (res : felt):
end

# Increases the balance by the given amount.
@external
func increase_balance{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(amount : felt):
    let public_key_pt = EcPoint(
        BigInt3(0x35dec240d9f76e20b48b41, 0x27fcb378b533f57a6b585, 0xbff381888b165f92dd33d),
        BigInt3(0x1711d8fb6fbbf53986b57f, 0x2e56f964d38cb8dbdeb30b, 0xe4be2a8547d802dc42041))
    let r = BigInt3(0x2e6c77fee73f3ac9be1217, 0x3f0c0b121ac1dc3e5c03c6, 0xeee3e6f50c576c07d7e4a)
    let s = BigInt3(0x20a4b46d3c5e24cda81f22, 0x967bf895824330d4273d0, 0x541e10c21560da25ada4c)
    let msg_hash = BigInt3(
        0x38a23ca66202c8c2a72277, 0x6730e765376ff17ea8385, 0xca1ad489ab60ea581e6c1)
    verify_ecdsa(public_key_pt=public_key_pt, msg_hash=msg_hash, r=r, s=s)

    let (res) = balance.read()
    balance.write(res + amount)
    return ()
end

# Returns the current balance.
@view
func get_balance{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}() -> (res : felt):
    let (res) = balance.read()
    return (res)
end
