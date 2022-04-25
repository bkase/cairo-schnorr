%builtins pedersen range_check

from bigint import BASE, BigInt3, UnreducedBigInt5, UnreducedBigInt3, bigint_div_mod, bigint_mul_mod, bigint_sub_mod, bigint_mul_u
from param_def import  N0, N1, N2, GX0, GX1, GX2, GY0, GY1, GY2
from ec import EcPoint, ec_add, ec_mul, verify_point
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.cairo_builtins import HashBuiltin

from starkware.cairo.common.math import assert_nn_le, assert_not_zero

struct Signature:
    member e : BigInt3
    member s : BigInt3
end

func hash4{hash_ptr: HashBuiltin*}(a, b, c, d) -> (digest:felt) :
    let (e) = hash2(a, b)
    let (e) = hash2(e, c)
    let (e) = hash2(e, d)

    return (digest=e)
end

func reduce{
    range_check_ptr
    }    (unreduced3: UnreducedBigInt3, mod: BigInt3) -> (res: BigInt3):
    alloc_locals
    let (local unreduced5) = bigint_mul_u(unreduced3, BigInt3(1,0,0))
    let (local reduced) = bigint_div_mod(unreduced5, UnreducedBigInt3(1,0,0), mod)

    return (res=reduced)
end


func sign{
    hash_ptr : HashBuiltin*,
    range_check_ptr
    }(private_key : BigInt3, msg_hash: felt) -> (signature: Signature) :
    alloc_locals

    # generator
    let gen_pt = EcPoint(
        BigInt3(GX0, GX1, GX2),
        BigInt3(GY0, GY1, GY2))

    # the modulus q for the Z_q
    let q = BigInt3(N0, N1, N2)

    # WARNING: this is not something you should do
    let k = private_key

    # r
    let (local r) = ec_mul(gen_pt, k)

    # e = H(r, M)
    let (local e) = hash4(r.x.d0, r.x.d1, r.x.d2, msg_hash)
    local unreduced3_e: UnreducedBigInt3 = UnreducedBigInt3(
        d0 = e,
        d1 = 0,
        d2 = 0
    )
    let (local reduced_e) = reduce(unreduced3_e, q)

    # s = k - xe
    let (s_1: BigInt3) = bigint_mul_mod(private_key, reduced_e, q)
    let (s: BigInt3) = bigint_sub_mod(k, s_1, q)

    # sig
    let signature = Signature(reduced_e, s)
    return (signature)
end


# Verifies that val is in the range [1, N).
func validate_signature_entry{range_check_ptr}(val : BigInt3):
    assert_nn_le(val.d2, N2)
    assert_nn_le(val.d1, BASE - 1)
    assert_nn_le(val.d0, BASE - 1)

    if val.d2 == N2:
        if val.d1 == N1:
            assert_nn_le(val.d0, N0 - 1)
            return ()
        end
        assert_nn_le(val.d1, N1 - 1)
        return ()
    end

    if val.d2 == 0:
        if val.d1 == 0:
            # Make sure val > 0.
            assert_not_zero(val.d0)
            return ()
        end
    end
    return ()
end

# Verifies a schnorr signature.
# Soundness assumptions:
# * All the limbs of public_key_pt.x, public_key_pt.y, msg_hash are in the range [0, 3 * BASE).

func verify{      
    hash_ptr : HashBuiltin*,
    range_check_ptr}(
        public_key_pt : EcPoint, msg_hash : felt, signature: Signature):
    alloc_locals

    # verify public key
    verify_point(public_key_pt)

    # verify range of signature e,s (must be scalars)
    validate_signature_entry(signature.e)
    validate_signature_entry(signature.s)

    # generator point
    let gen_pt = EcPoint(
        BigInt3(GX0, GX1, GX2),
        BigInt3(GY0, GY1, GY2))
    
    # TODO: what is N? scalar field no?
    let N = BigInt3(N0, N1, N2)

    # [s]G 
    let (local sg) = ec_mul(gen_pt, signature.s)

    # [e]pub
    let (local ep) = ec_mul(public_key_pt, signature.e)

    # r = [s]G + [e]pub
    let (local r) = ec_add(sg, ep)

    # compute e = H(r, M)
    let (local e) = hash4(r.x.d0, r.x.d1, r.x.d2, msg_hash)
    local unreduced3_e: UnreducedBigInt3 = UnreducedBigInt3(
        d0 = e,
        d1 = 0,
        d2 = 0
    )
    let (local reduced_e) = reduce(unreduced3_e, N)

    # equality check
    assert signature.e = reduced_e

    return ()
end

# main
func main{pedersen_ptr: HashBuiltin*, range_check_ptr}():
    alloc_locals

    # keygen
    let private_key = BigInt3(5, 5, 5)

    let gen_pt = EcPoint(
        BigInt3(GX0, GX1, GX2),
        BigInt3(GY0, GY1, GY2))
    let (local public_key) = ec_mul(gen_pt, private_key)

    # sign
    let msg_hash = 'some_msg'
    let (signature) = sign{hash_ptr = pedersen_ptr}(private_key, msg_hash)

    # verify
    verify{hash_ptr = pedersen_ptr}(public_key, msg_hash, signature)

    return ()
end
