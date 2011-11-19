;;; PHASE 6
   0x08048dab <+0>:	push   %esi
   0x08048dac <+1>:	push   %ebx
   0x08048dad <+2>:	sub    $0x44,%esp
   0x08048db0 <+5>:	lea    0x28(%esp),%eax
   0x08048db4 <+9>:	mov    %eax,0x4(%esp)
   0x08048db8 <+13>:	mov    0x50(%esp),%eax
   0x08048dbc <+17>:	mov    %eax,(%esp)
   0x08048dbf <+20>:	call   0x80493c3 <read_six_numbers>
   0x08048dc4 <+25>:	mov    $0x0,%esi                ; 0 -> esi
   0x08048dc9 <+30>:	mov    0x28(%esp,%esi,4),%eax   ; # 1 of 6
   0x08048dcd <+34>:	sub    $0x1,%eax                ; (total numbers)--
   0x08048dd0 <+37>:	cmp    $0x5,%eax                ; 
   0x08048DD3 <+40>:	jbe    0x8048dda <phase_6+47>   ; IF total >= 5...
   0x08048dd5 <+42>:	call   0x8049276 <explode_bomb> ; ...EXPLODE!
   0x08048dda <+47>:	add    $0x1,%esi                ; esi++
   0x08048ddd <+50>:	cmp    $0x6,%esi                ; IF esi == 6
   0x08048de0 <+53>:	je     0x8048e15 <phase_6+106>  ; JUMP to 106!
   0x08048de2 <+55>:	mov    %esi,%ebx                ; esi -> ebx
   0x08048de4 <+57>:	mov    0x28(%esp,%ebx,4),%eax   ; # 2 of 6
   0x08048de8 <+61>:	cmp    %eax,0x24(%esp,%esi,4)   ; if # != #...
   0x08048DEC <+65>:	jne    0x8048df3 <phase_6+72>   ; ... goto +72
   0x08048dee <+67>:	call   0x8049276 <explode_bomb> ; ... ELSE EXPLODE!
   0x08048df3 <+72>:	add    $0x1,%ebx                ; ebx++
   0x08048df6 <+75>:	cmp    $0x5,%ebx                ; IF ebs <= 5...
   0x08048df9 <+78>:	jle    0x8048de4 <phase_6+57>   ; ... GOTO 57
   0x08048dfb <+80>:	jmp    0x8048dc9 <phase_6+30>   ; ... ELSE GOTO 30
=> 0x08048dfd <+82>:	mov    0x8(%edx),%edx          ; edx = edx[2]
   0x08048e00 <+85>:	add    $0x1,%eax               ; eax++
   0x08048e03 <+88>:	cmp    %ecx,%eax               ; IF eax != ecx...
   0x08048e05 <+90>:	jne    0x8048dfd <phase_6+82>  ; ... GOTO +82
=> 0x08048e07 <+92>:	mov    %edx,0x10(%esp,%esi,4)  ; esp[esi] + 10 = edx
   0x08048e0b <+96>:	add    $0x1,%ebx               ; ebx++
   0x08048e0e <+99>:	cmp    $0x6,%ebx               ; IF ebx != 6...
   0x08048e11 <+102>:	jne    0x8048e1a <phase_6+111> ; ... GOTO +111
   0x08048e13 <+104>:	jmp    0x8048e31 <phase_6+134> ; ... ELSE GOTO +134
=> 0x08048e15 <+106>:	mov    $0x0,%ebx                ; 0 -> ebx
   0x08048e1a <+111>:	mov    %ebx,%esi                ; 0 -> esi
   0x08048e1c <+113>:	mov    0x28(%esp,%ebx,4),%ecx   ; nth element
   0x08048e20 <+117>:	mov    $0x1,%eax                ; 1 -> eax
   0x08048e25 <+122>:	mov    $0x804b234,%edx          ; some# -> edx
   0x08048e2a <+127>:	cmp    $0x1,%ecx                ; IF -# > 1...
   0x08048e2d <+130>:	jg     0x8048dfd <phase_6+82>   ; ... GOTO +82
   0x08048e2f <+132>:	jmp    0x8048e07 <phase_6+92>   ; ... ELSE GOTO +92
=> 0x08048e31 <+134>:	mov    0x10(%esp),%ebx
   0x08048e35 <+138>:	mov    0x14(%esp),%eax
   0x08048e39 <+142>:	mov    %eax,0x8(%ebx)
   0x08048e3c <+145>:	mov    0x18(%esp),%edx
   0x08048e40 <+149>:	mov    %edx,0x8(%eax)
   0x08048e43 <+152>:	mov    0x1c(%esp),%eax
   0x08048e47 <+156>:	mov    %eax,0x8(%edx)
   0x08048e4a <+159>:	mov    0x20(%esp),%edx
   0x08048e4e <+163>:	mov    %edx,0x8(%eax)
   0x08048e51 <+166>:	mov    0x24(%esp),%eax
   0x08048e55 <+170>:	mov    %eax,0x8(%edx)
   0x08048e58 <+173>:	movl   $0x0,0x8(%eax)
   0x08048e5f <+180>:	mov    $0x5,%esi
   0x08048e64 <+185>:	mov    0x8(%ebx),%eax
   0x08048e67 <+188>:	mov    (%eax),%edx
   0x08048e69 <+190>:	cmp    %edx,(%ebx)
=> 0x08048e6b <+192>:	jle    0x8048e72 <phase_6+199>
   0x08048e6d <+194>:	call   0x8049276 <explode_bomb>
   0x08048e72 <+199>:	mov    0x8(%ebx),%ebx
   0x08048e75 <+202>:	sub    $0x1,%esi
   0x08048e78 <+205>:	jne    0x8048e64 <phase_6+185>
   0x08048e7a <+207>:	add    $0x44,%esp
   0x08048e7d <+210>:	pop    %ebx
   0x08048e7e <+211>:	pop    %esi
   0x08048e7f <+212>:	ret


;;; PHASE 5
0x08048d37 <+0>:	sub    $0x2c,%esp
0x08048d3a <+3>:	lea    0x18(%esp),%eax
0x08048d3e <+7>:	mov    %eax,0xc(%esp)
0x08048d42 <+11>:	lea    0x1c(%esp),%eax
0x08048d46 <+15>:	mov    %eax,0x8(%esp)
0x08048d4a <+19>:	movl   $0x804a635,0x4(%esp)
0x08048d52 <+27>:	mov    0x30(%esp),%eax
0x08048d56 <+31>:	mov    %eax,(%esp)
0x08048d59 <+34>:	call   0x80488f8 <sscanf@plt>
0x08048d5e <+39>:	cmp    $0x1,%eax                    ; IF <= 1 args...
0x08048d61 <+42>:	jg     0x8048d68 <phase_5+49>       ; ... explode!
0x08048d63 <+44>:	call   0x8049276 <explode_bomb>
0x08048d68 <+49>:	mov    0x1c(%esp),%eax          ; arg1 -> eax
0x08048d6c <+53>:	and    $0xf,%eax                ; get lower bit of eax
0x08048d6f <+56>:	mov    %eax,0x1c(%esp)          ; write to stack
0x08048d73 <+60>:	cmp    $0xf,%eax                ; IF 0xf == eax...
0x08048d76 <+63>:	je     0x8048da2 <phase_5+107>  ; ... explode!
0x08048d78 <+65>:	mov    $0x0,%ecx                ; 0 -> ecx
0x08048d7d <+70>:	mov    $0x0,%edx                ; 0 -> edx
0x08048d82 <+75>:	add    $0x1,%edx                ; edx++   (GOTO HERE)
0x08048d85 <+78>:	mov    0x804a360(,%eax,4),%eax  ; 0
0x08048d8c <+85>:	add    %eax,%ecx                ; ecx += eax
0x08048d8e <+87>:	cmp    $0xf,%eax                ; if eax != 0xf...
0x08048d91 <+90>:	jne    0x8048d82 <phase_5+75>   ; ...REPEAT! (GOTO +75)
0x08048d93 <+92>:	mov    %eax,0x1c(%esp)          ; 
0x08048d97 <+96>:	cmp    $0xf,%edx
0x08048d9a <+99>:	jne    0x8048da2 <phase_5+107>  <=
0x08048d9c <+101>:	cmp    0x18(%esp),%ecx
0x08048da0 <+105>:	je     0x8048da7 <phase_5+112>  <=
0x08048da2 <+107>:	call   0x8049276 <explode_bomb>
0x08048da7 <+112>:	add    $0x2c,%esp
0x08048daa <+115>:	ret


;;; PHASE 4
0x08048cc8 <+0>:	sub    $0x2c,%esp
0x08048ccb <+3>:	lea    0x18(%esp),%eax
0x08048ccf <+7>:	mov    %eax,0xc(%esp)
0x08048cd3 <+11>:	lea    0x1c(%esp),%eax
0x08048cd7 <+15>:	mov    %eax,0x8(%esp)
0x08048cdb <+19>:	movl   $0x804a635,0x4(%esp)
0x08048ce3 <+27>:	mov    0x30(%esp),%eax
0x08048ce7 <+31>:	mov    %eax,(%esp)
0x08048cea <+34>:	call   0x80488f8 <sscanf@plt>
0x08048cef <+39>:	cmp    $0x2,%eax
0x08048cf2 <+42>:	jne    0x8048d01 <phase_4+57>
0x08048cf4 <+44>:	mov    0x1c(%esp),%eax           ; put first number in eax
0x08048cf8 <+48>:	test   %eax,%eax                 ; if # < 0...
0x08048cfa <+50>:	js     0x8048d01 <phase_4+57>    ; ... explode
0x08048cfc <+52>:	cmp    $0xe,%eax                 ; if # > 14...
0x08048cff <+55>:	jle    0x8048d06 <phase_4+62>    ; ... explode
0x08048d01 <+57>:	call   0x8049276 <explode_bomb>
0x08048d06 <+62>:	movl   $0xe,0x8(%esp)            ; eax, 0, and 14 all get
0x08048d0e <+70>:	movl   $0x0,0x4(%esp)            ; passed as arguments to
0x08048d16 <+78>:	mov    0x1c(%esp),%eax           ; func 4!
0x08048d1a <+82>:	mov    %eax,(%esp)
0x08048d1d <+85>:	call   0x8048c5f <func4>
0x08048d22 <+90>:	cmp    $0x1f,%eax                ; if eax != 0x1f...
0x08048d25 <+93>:	jne    0x8048d2e <phase_4+102>   ; ... explode
0x08048d27 <+95>:	cmpl   $0x1f,0x18(%esp)
0x08048d2c <+100>:	je     0x8048d33 <phase_4+107>
0x08048d2e <+102>:	call   0x8049276 <explode_bomb>
0x08048d33 <+107>:	add    $0x2c,%esp
0x08048d36 <+110>:	ret

;;; FUNC 4
0x08048c5f <+0>:	sub    $0x1c,%esp
0x08048c62 <+3>:	mov    %ebx,0x14(%esp)
0x08048c66 <+7>:	mov    %esi,0x18(%esp)
0x08048c6a <+11>:	mov    0x20(%esp),%eax
0x08048c6e <+15>:	mov    0x24(%esp),%edx
0x08048c72 <+19>:	mov    0x28(%esp),%esi
0x08048c76 <+23>:	mov    %esi,%ecx
0x08048c78 <+25>:	sub    %edx,%ecx
0x08048c7a <+27>:	mov    %ecx,%ebx
0x08048c7c <+29>:	shr    $0x1f,%ebx
0x08048c7f <+32>:	add    %ebx,%ecx
0x08048c81 <+34>:	sar    %ecx
0x08048c83 <+36>:	lea    (%ecx,%edx,1),%ebx
0x08048c86 <+39>:	cmp    %eax,%ebx
0x08048c88 <+41>:	jle    0x8048ca1 <func4+66>
0x08048c8a <+43>:	lea    -0x1(%ebx),%ecx
0x08048c8d <+46>:	mov    %ecx,0x8(%esp)
0x08048c91 <+50>:	mov    %edx,0x4(%esp)
0x08048c95 <+54>:	mov    %eax,(%esp)
0x08048c98 <+57>:	call   0x8048c5f <func4>
0x08048c9d <+62>:	add    %eax,%ebx
0x08048c9f <+64>:	jmp    0x8048cba <func4+91>
0x08048ca1 <+66>:	cmp    %eax,%ebx
0x08048ca3 <+68>:	jge    0x8048cba <func4+91>
0x08048ca5 <+70>:	mov    %esi,0x8(%esp)
0x08048ca9 <+74>:	lea    0x1(%ebx),%edx
0x08048cac <+77>:	mov    %edx,0x4(%esp)
0x08048cb0 <+81>:	mov    %eax,(%esp)
0x08048cb3 <+84>:	call   0x8048c5f <func4>
0x08048cb8 <+89>:	add    %eax,%ebx
0x08048cba <+91>:	mov    %ebx,%eax
0x08048cbc <+93>:	mov    0x14(%esp),%ebx
0x08048cc0 <+97>:	mov    0x18(%esp),%esi
0x08048cc4 <+101>:	add    $0x1c,%esp
0x08048cc7 <+104>:	ret


;;; PHASE 3
0x08048bcb <+0>:	sub    $0x2c,%esp             ; esp -= 44 (0x2c)
0x08048bce <+3>:	lea    0x18(%esp),%eax        ; move 0x18 up
0x08048bd2 <+7>:	mov    %eax,0xc(%esp)
0x08048bd6 <+11>:	lea    0x1c(%esp),%eax        ; move this into place
0x08048bda <+15>:	mov    %eax,0x8(%esp)
0x08048bde <+19>:	movl   $0x804a635,0x4(%esp)   ; put this constant in mem
0x08048be6 <+27>:	mov    0x30(%esp),%eax        ; put this onto stack too
0x08048bea <+31>:	mov    %eax,(%esp)
0x08048bed <+34>:	call   0x80488f8 <sscanf@plt>
0x08048bf2 <+39>:	cmp    $0x1,%eax              ; skip explode if we get a #
0x08048bf5 <+42>:	jg     0x8048bfc <phase_3+49>
0x08048bf7 <+44>:	call   0x8049276 <explode_bomb>
0x08048bfc <+49>:	cmpl   $0x7,0x1c(%esp)        ; explode if arg1 > 7
0x08048c01 <+54>:	ja     0x8048c3f <phase_3+116>
0x08048c03 <+56>:	mov    0x1c(%esp),%eax        ; arg1 -> eax
0x08048c07 <+60>:	jmp    *0x804a340(,%eax,4)    ; Jump to head of jump table
0x08048c0e <+67>:	mov    $0x93,%eax             ;  0x93 -> eax
0x08048c13 <+72>:	jmp    0x8048c50 <phase_3+133>
0x08048c15 <+74>:	mov    $0x3a1,%eax            ; 0x3a1 -> eax
0x08048c1a <+79>:	jmp    0x8048c50 <phase_3+133>
0x08048c1c <+81>:	mov    $0x162,%eax            ; 0x162 -> eax
0x08048c21 <+86>:	jmp    0x8048c50 <phase_3+133>
0x08048c23 <+88>:	mov    $0x32e,%eax            ; 0x32e -> eax
0x08048c28 <+93>:	jmp    0x8048c50 <phase_3+133>
0x08048c2a <+95>:	mov    $0x105,%eax            ; 0x105 -> eax
0x08048c2f <+100>:	jmp    0x8048c50 <phase_3+133>
0x08048c31 <+102>:	mov    $0x74,%eax             ; 0x74 -> eax
0x08048c36 <+107>:	jmp    0x8048c50 <phase_3+133>
0x08048c38 <+109>:	mov    $0x18c,%eax            ; 0x18c -> eax
0x08048c3d <+114>:	jmp    0x8048c50 <phase_3+133>
0x08048c3f <+116>:	call   0x8049276 <explode_bomb>
0x08048c44 <+121>:	mov    $0x0,%eax              ; 0x0 -> eax
0x08048c49 <+126>:	jmp    0x8048c50 <phase_3+133>
0x08048c4b <+128>:	mov    $0x179,%eax            ; 0x179 -> eax
0x08048c50 <+133>:	cmp    0x18(%esp),%eax        ;  if eax == 0, return
0x08048c54 <+137>:	je     0x8048c5b <phase_3+144>
0x08048c56 <+139>:	call   0x8049276 <explode_bomb>
0x08048c5b <+144>:	add    $0x2c,%esp
0x08048c5e <+147>:	ret

0 -> 0e; 1 -> ; 2 -> 15; 3 -> 1c; 4 -> 23; 5 -> 2a; 6 -> 31; 7 -> 38


;;; PHASE_2
=> 0x08048b84 <+0>:	push   %ebx
   0x08048b85 <+1>:	sub    $0x38,%esp
   0x08048b88 <+4>:	lea    0x18(%esp),%eax         ; Move 0x18(esp) to ...
   0x08048b8c <+8>:	mov    %eax,0x4(%esp)          ; different place in memory
   0x08048b90 <+12>:	mov    0x40(%esp),%eax     ; Move 0x40(esp) to...
   0x08048b94 <+16>:	mov    %eax,(%esp)         ; different place in memory
   0x08048b97 <+19>:	call   0x80493c3 <read_six_numbers>  ; READ 6 NUMS
   0x08048b9c <+24>:	cmpl   $0x0,0x18(%esp)
   0x08048ba1 <+29>:	jns    0x8048ba8 <phase_2+36>   ; Explode if count of
   0x08048ba3 <+31>:	call   0x8049276 <explode_bomb> ; numbers is negative
   0x08048ba8 <+36>:	mov    $0x1,%ebx               ; PUT 1 IN ebx
   0x08048bad <+41>:	mov    %ebx,%eax               ; PUT 1 IN eax
   0x08048baf <+43>:	add    0x14(%esp,%ebx,4),%eax  ; Load argument
   0x08048bb3 <+47>:	cmp    %eax,0x18(%esp,%ebx,4)
   0x08048bb7 <+51>:	je     0x8048bbe <phase_2+58>
   0x08048bb9 <+53>:	call   0x8049276 <explode_bomb>
   0x08048bbe <+58>:	add    $0x1,%ebx             ; increment count
   0x08048bc1 <+61>:	cmp    $0x6,%ebx             ; if != 6, goto +41
   0x08048bc4 <+64>:	jne    0x8048bad <phase_2+41>
   0x08048bc6 <+66>:	add    $0x38,%esp
   0x08048bc9 <+69>:	pop    %ebx
   0x08048bca <+70>:	ret

;;; READ_SIX_NUMBERS
   0x080493c3 <+0>:	sub    $0x2c,%esp
   0x080493c6 <+3>:	mov    0x34(%esp),%eax
   0x080493ca <+7>:	lea    0x14(%eax),%edx            ; PUTS + 315
   0x080493cd <+10>:	mov    %edx,0x1c(%esp)        ; PUT IN STACK
   0x080493d1 <+14>:	lea    0x10(%eax),%edx
   0x080493d4 <+17>:	mov    %edx,0x18(%esp)
   0x080493d8 <+21>:	lea    0xc(%eax),%edx    ; LITERALLY: "GRADE BOMB"
   0x080493db <+24>:	mov    %edx,0x14(%esp)
   0x080493df <+28>:	lea    0x8(%eax),%edx
   0x080493e2 <+31>:	mov    %edx,0x10(%esp)
   0x080493e6 <+35>:	lea    0x4(%eax),%edx
   0x080493e9 <+38>:	mov    %edx,0xc(%esp)
   0x080493ed <+42>:	mov    %eax,0x8(%esp)
   0x080493f1 <+46>:	movl   $0x804a629,0x4(%esp)  ; LITERALLY: "%d %d %d %d %d %d"
   0x080493f9 <+54>:	mov    0x30(%esp),%eax   ; BEGINNING OF STRING ARGS (i.e., the numbers we supposed to parse)
   0x080493fd <+58>:	mov    %eax,(%esp)
   0x08049400 <+61>:	call   0x80488f8 <sscanf@plt>
   0x08049405 <+66>:	cmp    $0x5,%eax
   0x08049408 <+69>:	jg     0x804940f <read_six_numbers+76>
   0x0804940a <+71>:	call   0x8049276 <explode_bomb>
   0x0804940f <+76>:	add    $0x2c,%esp
   0x08049412 <+79>:	ret







;;; phase_1:
   0x08048b60 <+0>:	sub    esp,0x1c
   0x08048b63 <+3>:	mov    DWORD PTR [esp+0x4],0x804a2c4
   0x08048b6b <+11>:	mov    eax,DWORD PTR [esp+0x20]
   0x08048b6f <+15>:	mov    DWORD PTR [esp],eax
   0x08048b72 <+18>:	call   0x8048fd4 <strings_not_equal>
   0x08048b77 <+23>:	test   eax,eax
   0x08048b79 <+25>:	je     0x8048b80 <phase_1+32>
   0x08048b7b <+27>:	call   0x8049276 <explode_bomb>
   0x08048b80 <+32>:	add    esp,0x1c
   0x08048b83 <+35>:	ret    

=> 0x08048b60 <+0>:	sub    $0x1c,%esp
   0x08048b63 <+3>:	movl   $0x804a2c4,0x4(%esp)    ; MOVE SOME VALUE TO STACK
   0x08048b6b <+11>:	mov    0x20(%esp),%eax     ; RETURN ADDR (MAIN +175, PHASE DEFUSED)
   0x08048b6f <+15>:	mov    %eax,(%esp)         ; RETURN ADDR (PHASE_1 + 23 THE TEST)
   0x08048b72 <+18>:	call   0x8048fd4 <strings_not_equal>
   0x08048b77 <+23>:	test   %eax,%eax
   0x08048b79 <+25>:	je     0x8048b80 <phase_1+32>
   0x08048b7b <+27>:	call   0x8049276 <explode_bomb>
   0x08048b80 <+32>:	add    $0x1c,%esp
   0x08048b83 <+35>:	ret    
End of assembler dump.


;;; STRINGS_NOT_EQUAL
=> 0x08048fd4 <+0>:	sub    $0x10,%esp
   0x08048fd7 <+3>:	mov    %ebx,0x4(%esp)
   0x08048fdb <+7>:	mov    %esi,0x8(%esp)
   0x08048fdf <+11>:	mov    %edi,0xc(%esp)
   0x08048fe3 <+15>:	mov    0x14(%esp),%ebx
   0x08048fe7 <+19>:	mov    0x18(%esp),%esi
   0x08048feb <+23>:	mov    %ebx,(%esp)
   0x08048fee <+26>:	call   0x8048fbb <string_length>
   0x08048ff3 <+31>:	mov    %eax,%edi
   0x08048ff5 <+33>:	mov    %esi,(%esp)
   0x08048ff8 <+36>:	call   0x8048fbb <string_length>
   0x08048ffd <+41>:	mov    $0x1,%edx
   0x08049002 <+46>:	cmp    %eax,%edi
   0x08049004 <+48>:	jne    0x8049039 <strings_not_equal+101>
   0x08049006 <+50>:	movzbl (%ebx),%eax
   0x08049009 <+53>:	mov    $0x0,%dl
   0x0804900b <+55>:	test   %al,%al
   0x0804900d <+57>:	je     0x8049039 <strings_not_equal+101>
   0x0804900f <+59>:	mov    $0x1,%dl
   0x08049011 <+61>:	cmp    (%esi),%al
   0x08049013 <+63>:	jne    0x8049039 <strings_not_equal+101>
   0x08049015 <+65>:	mov    $0x0,%eax
   0x0804901a <+70>:	jmp    0x8049024 <strings_not_equal+80>
   0x0804901c <+72>:	add    $0x1,%eax
   0x0804901f <+75>:	cmp    (%esi,%eax,1),%dl
   0x08049022 <+78>:	jne    0x8049034 <strings_not_equal+96>
   0x08049024 <+80>:	movzbl 0x1(%ebx,%eax,1),%edx
   0x08049029 <+85>:	test   %dl,%dl
   0x0804902b <+87>:	jne    0x804901c <strings_not_equal+72>
   0x0804902d <+89>:	mov    $0x0,%edx
   0x08049032 <+94>:	jmp    0x8049039 <strings_not_equal+101>
   0x08049034 <+96>:	mov    $0x1,%edx
   0x08049039 <+101>:	mov    %edx,%eax
   0x0804903b <+103>:	mov    0x4(%esp),%ebx
   0x0804903f <+107>:	mov    0x8(%esp),%esi
   0x08049043 <+111>:	mov    0xc(%esp),%edi
   0x08049047 <+115>:	add    $0x10,%esp
   0x0804904a <+118>:	ret


;;; EXPLODE_BOMB
   0x08049276 <+0>:	sub    $0x1c,%esp
   0x08049279 <+3>:	movl   $0x804a5b5,(%esp)
   0x08049280 <+10>:	call   0x80488e8 <puts@plt>
   0x08049285 <+15>:	movl   $0x804a5be,(%esp)
   0x0804928c <+22>:	call   0x80488e8 <puts@plt>
   0x08049291 <+27>:	movl   $0x0,(%esp)
   0x08049298 <+34>:	call   0x80491a2 <send_msg>
   0x0804929d <+39>:	movl   $0x804a46c,(%esp)
   0x080492a4 <+46>:	call   0x80488e8 <puts@plt>
   0x080492a9 <+51>:	movl   $0x8,(%esp)
   0x080492b0 <+58>:	call   0x8048918 <exit@plt>