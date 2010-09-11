# Alex Clemmer u0458675

        .data
Prompt:
        .asciiz "Enter an integer N: "
SuccessOutput:
	.asciiz "\nResult: "
ErrorOutput:
	.asciiz "That's a negative number. Try again."
ErrorOverflow:
	.asciiz "Overflow! Waa! "
ErrorOverflow2:
	.asciiz " iteration(s)!"
Space:
	.asciiz " "

	.text

# Get N from user
        la $a0, Prompt  # Put the address of the string in $a0
        li $v0, 4  # Syscall print Prompt
        syscall  # Print prompt

# Wait for and store N
	li $v0, 5  # syscall wait for N
	syscall
	blt $v0, 1, PrintErrorOutput # goto PrintError if < 1
	li $s0, 0

# Compute Hailstone
Loop:
	beq $v0, 1, PrintSuccessMessage
	addi $s0, $s0, 1
	andi $t1, $v0, 1  # 1 if N even, 0 else
	move $a0, $v0  # put in params
	bne $t1, 1, Even  # goto Even if even
	bgt $v0, 1431655764, PrintErrorOverflow
	jal IfOdd  # N is odd, so goto odd
	j Loop
Even:
	sra $v0, $v0, 1

	### PRINT CURR DIGIT ###
	move, $a0, $v0
	li $v0, 1
	syscall
	move, $v1, $a0
	la $a0, Space
	li $v0, 4
	syscall
	move $v0, $v1
	### END PRINT CURR DIGIT ###

	j Loop

IfOdd:
	add $v0, $a0, $a0  # times 2
	add $v0, $v0, $a0  # times 3
	add $v0, $v0, 1  # add 1

	### PRINT CURR DIGIT ###
	move $a0, $v0
	li $v0, 1
	syscall
	move $v1, $a0
	la $a0, Space
	li $v0, 4
	syscall
	move $v0, $v1
	### END PRINT CURR DIGIT ###

	jr $ra



# SUCCESS message
PrintSuccessMessage:
	la $a0, SuccessOutput  # load SuccessOutput
	li $v0, 4  # print success output
	syscall
	move $a0, $s0
	li $v0, 1
	syscall
	li $v0, 10
	syscall

# ERROR - Negative integer
PrintErrorOutput:
	la $a0, ErrorOutput # load ErrorOutput
	li $v0, 4  # print error output
	syscall
	li $v0, 10
	syscall

# ERROR - Overflow
PrintErrorOverflow:
	la $a0, ErrorOverflow # load ErrorOutput
	li $v0, 4  # print error output
	syscall
	move $a0, $s0
	li $v0, 1
	syscall
	la $a0, ErrorOverflow2 # load ErrorOutput
	li $v0, 4  # print error output
	syscall
	li $v0, 10
	syscall