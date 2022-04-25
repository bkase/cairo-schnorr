from bigint import BASE, BigInt3, UnreducedBigInt5, UnreducedBigInt3, bigint_div_mod, bigint_mul_mod, bigint_sub_mod
from param_def import  N0, N1, N2, GX0, GX1, GX2, GY0, GY1, GY2
from ec import EcPoint, ec_add, ec_mul, ec_neg, verify_point
from starkware.cairo.common.alloc import alloc


# The signature for signing a message (M: felt)
struct Signature:
    member s : BigInt3
    member e : BigInt3
end

# TODO: Figure out how to hash (hashing needs to be hash BigInt3||felt)
# TODO: Figure out how to pick a random number

func keygen{range_check_ptr}(private_key: BigInt3) -> (public_key: EcPoint):
    # TODO: Assert that the scalar is the right range
    let gen_pt = EcPoint(
        BigInt3(GX0, GX1, GX2),
        BigInt3(GY0, GY1, GY2))

    let (public_key: EcPoint) = ec_mul(gen_pt, private_key)
    return (public_key) 
end

# returns 0 for verified, 1 for error
func verify{range_check_ptr}(public_key: EcPoint, signature : Signature, message: felt) -> (verified: felt):
    let gen_pt = EcPoint(
        BigInt3(GX0, GX1, GX2),
        BigInt3(GY0, GY1, GY2))
    # the modulus q for the Z_q
    let q = BigInt3(N0, N1, N2)

    let (g_to_the_s: EcPoint) = ec_mul(gen_pt, signature.s)
    let (y_to_the_e: EcPoint) = ec_mul(public_key, signature.e)
    let (r_v: EcPoint) = ec_add(g_to_the_s, y_to_the_e)

    #----
    # Make an array
    #----
    const ARRAY_SIZE = 7
    # Allocate an array.
    let (hashdata) = alloc()
    # Populate some values in the array.
    #rv1x
    assert [hashdata] = r_v.x.d0
    #rv1y
    assert [hashdata + 1] = r_v.y.d0
    #rv2x
    assert [hashdata + 2] = r_v.x.d1
    #rv2y
    assert [hashdata + 3] = r_v.y.d1
    #rv3x
    assert [hashdata + 4] = r_v.x.d2
    #rv3y
    assert [hashdata + 5] = r_v.y.d2
    #message
    assert [hashdata + 6] = message

    let e_v = 0 # TODO: Replace with: hash(hashdata, size=ARRAY_SIZE)

    # TODO: Figure out how to say "if signature.e == e_v then RETURN VALID else RETURN INVALID"

    return ()
end

func sign{range_check_ptr}(private_key : BigInt3, message: felt) -> (signature: Signature) :
    # TODO(bkase)
    let gen_pt = EcPoint(
        BigInt3(GX0, GX1, GX2),
        BigInt3(GY0, GY1, GY2))
    # the modulus q for the Z_q
    let q = BigInt3(N0, N1, N2)

    #TODO replace with a real random number
    let k = private_key
    let (r: EcPoint) = ec_mul(gen_pt, k)

    #----
    # Make an array
    #----
    const ARRAY_SIZE = 7
    # Allocate an array.
    let (hashdata) = alloc()
    # Populate some values in the array.
    #r1x
    assert [hashdata] = r.x.d0
    #r1y
    assert [hashdata + 1] = r.y.d0
    #r2x
    assert [hashdata + 2] = r.x.d1
    #r2y
    assert [hashdata + 3] = r.y.d1
    #r3x
    assert [hashdata + 4] = r.x.d2
    #r3y
    assert [hashdata + 5] = r.y.d2
    #message
    assert [hashdata + 6] = message

    let e_0 = 0 # TODO: Replace with: hash(hashdata, size=ARRAY_SIZE)
    let e = BigInt3(e_0, 0, 0)

    let (s_1: BigInt3) = bigint_mul_mod(private_key, e, q)
    let (s: BigInt3) = bigint_sub_mod(k, s_1, q)
    let signature = Signature(s, e)

    return (signature)
end