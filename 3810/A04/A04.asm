.data
	StartMessage: .asciiz "Please input a number > 0 and < 10: "
	ErrorMsgLessThanZero: .asciiz "That number is less than 0! Oh noes! Try it again!\n"
	ErrorMsgGreaterThanTen: .asciiz "That number is greater than 10! The inhumanity! *cringes* *breaks*\n"
	ReachedEndMessage: .asciiz "Reached end\n"
	ProcessMessage1: .asciiz "In recursion depth "
	ProcessMessage2: .asciiz ":"
	PrintNewline: .asciiz "\n"
	PrintColon: .asciiz ": "
	PrintX: .asciiz "x"

.text

Main:
# Print start message
	la $a0, StartMessage  # load start message into $a0
	li $v0, 4  # supply syscall code for print string
	syscall  # print the start message
# Read the integer from user
	li $v0, 5  # supply syscall code for read int
	syscall  # read int
# Check to see that int iS > 0 and < 10
	blt $v0, 0, PrintErrorLessThanZero  # check to see that int is > 0
	bgt $v0, 10, PrintErrorGreaterThanTen  # check to see that int is < 10
# If 0 < int < 10, then continue; start by saving the value in $a0
	move $a0, $v0  # move int we read to saved register
# Then call Recursion function
	jal Recursion  # go to recursion
	j ExitGracefully

Recursion:
# Set up function call
	addi $sp, $sp, -12
	sw $ra, 8($sp)  # save RA on stack
	sw $fp, 4($sp)  # save previous fame pointer on stacks
# Allocate local variables, add params to stack
	sw $a0, ($sp)  # add parameter (int N) to stack
	addi $sp, $sp, -12
	sw $t0, ($sp)  # add k to stack

# Base case
	bne $a0, 10, SkipBaseCase  # skip base case if N != 10
	la $a0, ReachedEndMessage  # prepare reached end message
	li $v0, 4  # load proper syscall code
	syscall  # make syscall
	li $v0, 0  # return 0
	addi $sp, $sp, 24  # pop stack 
	jr $ra  # jump back

SkipBaseCase:
# Assemble the basic message
	la $a0, ProcessMessage1  # load PM1
	li $v0, 4  # set up syscall with appropriate code
	syscall  # print out PM1
	lw $a0, 12($sp)  # load param int N to print
	li $v0, 1  # load syscall code that prints an integer
	syscall  # print int N
	la $a0, PrintColon  # load colon to print
	li $v0, 4  # load code to print string
	syscall  # print the colon
# Print x's for histogram (uses first for loop)
	sw $s0, 4($sp)  # store $s0 so they can be accessed later
	la $a0, PrintX
	li $s0, 0  # set i to be 0
	lw $t1, 12($sp)  # get parameter (int N)
BeginLoop:
	beq $s0, $t1, SkipFirstLoop  # test for FirstLoop condition
	li $v0, 4  # Load 'x' character
	syscall  # call to call that in dea.
	addi $s0, $s0, 1 
	j BeginLoop
SkipFirstLoop:
	lw $s0, 4($sp)
	la $a0, PrintNewline  # load newline
	li $v0, 4
	syscall  # print newline

	lw $t1, 12($sp)  # $t1 = param int N
	addi $s0, $t1, 5  # i =  N + 5
	addi $t0, $t1, -6   # k = N-6
	addi $s1, $t1, 1  # j = N + 1
	
	move $a0, $s1  # put j in params
	jal Recursion  # recursion(j)
	add $s1, $v0, $v0  # j = j + j
	add $s1, $s1, $s0  # j = j + i
	add $s1, $s1, $t0  # j = j + k
	
	la $a0,  ProcessMessage1  # prepare to print message1
	li $v0, 4
	syscall  # print message 1
	lw $a0, ($sp)  # prepare param int N to be printed
	li $v0, 1
	syscall  # print param int nN
	la $a0, PrintColon  # prepare to print colon
	li $v0, 4
	syscall  # print colon



	move $v0, $s1  # return j
	lw $ra, 20($sp)  # replace return address
	addi $sp, $sp, 24  # pop stack
	jr $ra

ExitGracefully:
	li $v0, 10
	syscall

PrintErrorLessThanZero:
	la $a0, ErrorMsgLessThanZero  # load message for int < 0 error
	li $v0, 4  # load syscall to print message for int < 0 error
	syscall  # print message for int < 0 error

PrintErrorGreaterThanTen:
	la $a0, ErrorMsgGreaterThanTen  # load message for int > 10 error
	li $v0, 4  # load syscall to print message for int > 0 error
	syscall  # print message for int > 10 error
