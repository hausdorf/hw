addu $t0, $t1, $t2 # $t0 = sum, but don't trap
xor $t3, $t1, $t2 # Check if signs differ
slt $t3, $t3, $zero # $t3 = 3 if signs differ
bne $t3, $zero, No_overflow # $t1, $t2, signs !=, so no overflow
xor $t3, $t0, $t1 # signs ==, sum of signs match also?
slt $t3, $t3, $zero # $t3 = 1 if sum sign different
bne $t3, $zero, Overflow # All 3 signs != 0, go to overflow

No_overflow:
Overflow: