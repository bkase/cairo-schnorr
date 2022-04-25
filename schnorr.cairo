from bigint import BASE, BigInt3, UnreducedBigInt5, UnreducedBigInt3, bigint_div_mod
from param_def import  N0, N1, N2, GX0, GX1, GX2, GY0, GY1, GY2
from ec import EcPoint, ec_add, ec_mul, verify_point

func keygen{range_check_ptr}(private_key: BigInt3) -> (res: EcPoint):
    # TODO: Assert that the scalar is the right range
    let gen_pt = EcPoint(
        BigInt3(GX0, GX1, GX2),
        BigInt3(GY0, GY1, GY2))

    let (res: EcPoint) = ec_mul(gen_pt, private_key)
    return (res) 
end

func verify{range_check_ptr}(public_key: EcPoint, val : BigInt3):
    return ()
end

func sign{range_check_ptr}(val : BigInt3):
    return ()
end