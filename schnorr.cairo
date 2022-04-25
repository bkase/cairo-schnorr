from bigint import BASE, BigInt3, UnreducedBigInt5, UnreducedBigInt3, bigint_div_mod
from param_def import  N0, N1, N2, GX0, GX1, GX2, GY0, GY1, GY2
from ec import EcPoint, ec_add, ec_mul, verify_point

func validate_signature_entry{range_check_ptr}(val : BigInt3):
    return ()
end