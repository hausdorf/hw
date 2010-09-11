# Mystery Code.asm
#
# This assembly code accepts an integer as input, computes a result, and
# outputs an integer as output.  Report your input and output as answers
# on your first homework assignment.
#
# To use:
#    Run "MARS" MIPS simulator
#        In CADE lab:     Use Mars menu item or type mars.
#        At home:         Download and double-click it in Windows.
#    Select File->new
#    Cut-and-paste this code into the editor window
#    Select File->save and save the program
#    Press f3 to assemble  (You can also use the toolbar button)
#    Press f5 to run       (You can also use the toolbar button)
#    Enter input
#    Examine output (in Run I/O tabbed window)
#    Return to editor view (click Edit tabbed window)

            .data

prompt1:
            .asciiz "Enter your student ID number as an integer: "

prompt2:
            .asciiz "Thank you.\n"

prompt3:
            .asciiz "Your answer is: "

prompt4:
            .asciiz "\n"

            .text
main:
            li    $v0, 4
            la    $a0, prompt1
            syscall               # Print input prompt

            li    $v0, 5
            syscall               # Input the integer

            move  $s0, $v0        # Save the result

            li    $v0, 4
            la    $a0, prompt2
            syscall               # Say thank you. ; )

                                  # Start of unspecified computation

            li    $t1, 7
            li    $t2, 1
            li    $t3, -1
	    sub   $t1, $t1, $t2
	    add   $t1, $t3, $t1

loop:
            add   $t3, $t3, $t2
            sub   $s0, $s0, $t1
            slt   $t0, $s0, $zero
            beq   $t0, $zero, loop

                                  # Done with unspecified computation

            move  $s1, $t3        # Save the result

            li    $v0, 4
            la    $a0, prompt3
            syscall               # Print output prompt

            li    $v0, 1
            move  $a0, $s1
            syscall               # Print the result

            li    $v0, 4
            la    $a0, prompt4
            syscall               # Print extra newline

            li    $v0, 10
            syscall               # Done, return to callervs