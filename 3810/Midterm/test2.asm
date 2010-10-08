li $a0, 3
jal Fact
j Exit

Fact:
addi $sp, $sp, -8
sw $ra, 0($sp)
sw $a0, 4($sp)

slti $t0, $a0, 1
beq $t0, $zero, False
li $v0, 1
addi $sp, $sp, 8
jr $ra

False:
addi $a0, $a0, -1
jal Fact
lw $ra, 0($sp)
lw $a0, 4($sp)
addi $sp, $sp, 8
mul $t0, $v0, $a0
move $v0, $t0
jr $ra


Exit: