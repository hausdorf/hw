.data
	StartMessage: .asciiz "Let's add a number 3 times!"

.text

StartProgram:
	la $a0, StartMessage
	li $v0, 4
	syscall

	li $s0, 3  # Put number in register
AddNumber:
	li $t1, 10  # compare-to address
	bgt $s0, $t1, FinishLoop  # Finish the loop if given number > $t1
	jal Multiply  # Multiply the number by 2
	j AddNumber  # Back to the beginning
FinishLoop:
	j ExitGracefully  # If done, send to exit
Multiply:
	add $s0, $s0, $s0  # Multiply by 2
	jr $ra  # Go back to caller

ExitGracefully:
	li $v0, 10
	syscall