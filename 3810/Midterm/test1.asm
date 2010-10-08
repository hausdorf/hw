li $a0, 3   # G
li $a1, 5   # H
li $a2, 7   # I
li $a3, 13  # J

li $t0, 999
li $t1, 999

jal Leaf_Example
j Exit

Leaf_Example:
addi $sp, $sp, -12
sw $t0, 0($sp)
sw $t1, 4($sp)
sw $s0, 8($sp)

add $t0, $a0, $a1
add $t1, $a2, $a3
sub $s0, $t0, $t1

move $v0, $s0

lw $t0, 0($sp)
lw $t1, 4($sp)
lw $s0, 8($sp)

addi $sp, $sp, 12

jr $ra

Exit:
