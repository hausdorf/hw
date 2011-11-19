   0x08048a04 <+0>:	push   ebp
   0x08048a05 <+1>:	mov    ebp,esp
   0x08048a07 <+3>:	push   ebx
   0x08048a08 <+4>:	and    esp,0xfffffff0
   0x08048a0b <+7>:	sub    esp,0x10
   0x08048a0e <+10>:	mov    eax,DWORD PTR [ebp+0x8]
   0x08048a11 <+13>:	mov    ebx,DWORD PTR [ebp+0xc]
   0x08048a14 <+16>:	cmp    eax,0x1
   0x08048a17 <+19>:	jne    0x8048a25 <main+33>
   0x08048a19 <+21>:	mov    eax,ds:0x804b8a4
   0x08048a1e <+26>:	mov    ds:0x804b8d0,eax
   0x08048a23 <+31>:	jmp    0x8048a89 <main+133>
   0x08048a25 <+33>:	cmp    eax,0x2
   0x08048a28 <+36>:	jne    0x8048a6b <main+103>
   0x08048a2a <+38>:	mov    DWORD PTR [esp+0x4],0x804a188
   0x08048a32 <+46>:	mov    eax,DWORD PTR [ebx+0x4]
   0x08048a35 <+49>:	mov    DWORD PTR [esp],eax
   0x08048a38 <+52>:	call   0x8048858 <fopen@plt>       ;;; OPEN FILE IF PROVIDED
   0x08048a3d <+57>:	mov    ds:0x804b8d0,eax
   0x08048a42 <+62>:	test   eax,eax
   0x08048a44 <+64>:	jne    0x8048a89 <main+133>
   0x08048a46 <+66>:	mov    eax,DWORD PTR [ebx+0x4]
   0x08048a49 <+69>:	mov    DWORD PTR [esp+0x8],eax
   0x08048a4d <+73>:	mov    eax,DWORD PTR [ebx]
   0x08048a4f <+75>:	mov    DWORD PTR [esp+0x4],eax
   0x08048a53 <+79>:	mov    DWORD PTR [esp],0x804a18a
   0x08048a5a <+86>:	call   0x8048888 <printf@plt>     ;;; PRINT ERROR IF OPEN FILE FAILS
   0x08048a5f <+91>:	mov    DWORD PTR [esp],0x8
   0x08048a66 <+98>:	call   0x8048918 <exit@plt>       ;;; EXIT IF OPEN FILE FAILS
   0x08048a6b <+103>:	mov    eax,DWORD PTR [ebx]
   0x08048a6d <+105>:	mov    DWORD PTR [esp+0x4],eax
   0x08048a71 <+109>:	mov    DWORD PTR [esp],0x804a1a7
   0x08048a78 <+116>:	call   0x8048888 <printf@plt>     ;;; PRINT USAGE IF BAD
   0x08048a7d <+121>:	mov    DWORD PTR [esp],0x8
   0x08048a84 <+128>:	call   0x8048918 <exit@plt>       ;;; EXIT IF USAGE BAD
   0x08048a89 <+133>:	call   0x804904b <initialize_bomb>   ;;; INITIALIZE THE BOMB
   0x08048a8e <+138>:	mov    DWORD PTR [esp],0x804a20c
   0x08048a95 <+145>:	call   0x80488e8 <puts@plt>          ;;;  PRINT GREETING
   0x08048a9a <+150>:	mov    DWORD PTR [esp],0x804a248
   0x08048aa1 <+157>:	call   0x80488e8 <puts@plt>         ;;; GREETING 2
   0x08048aa6 <+162>:	call   0x80492b5 <read_line>        ;;; GET INPUT
   0x08048aab <+167>:	mov    DWORD PTR [esp],eax
   0x08048aae <+170>:	call   0x8048b60 <phase_1>          ;;; CALL PHASE 1
   0x08048ab3 <+175>:	call   0x8049413 <phase_defused>    ;;; SEE IF PROPERLY DEFUSED
   0x08048ab8 <+180>:	mov    DWORD PTR [esp],0x804a274
   0x08048abf <+187>:	call   0x80488e8 <puts@plt>         ;;; GREETING 3
   0x08048ac4 <+192>:	call   0x80492b5 <read_line>        ;;; GET INPUT
   0x08048ac9 <+197>:	mov    DWORD PTR [esp],eax
   0x08048acc <+200>:	call   0x8048b84 <phase_2>          ;;; CALL PHASE 2
   0x08048ad1 <+205>:	call   0x8049413 <phase_defused>    ;;; SEE IF PROPERLY DEFUSED
   0x08048ad6 <+210>:	mov    DWORD PTR [esp],0x804a1c1
   0x08048add <+217>:	call   0x80488e8 <puts@plt>         ;;; GREETING 3
   0x08048ae2 <+222>:	call   0x80492b5 <read_line>        ;;; GET INPUT
   0x08048ae7 <+227>:	mov    %eax,(%esp)
   0x08048aea <+230>:	call   0x8048bcb <phase_3>          ;;; CALL PHASE 3
   0x08048aef <+235>:	call   0x8049413 <phase_defused>    ;;; SEE IF PROPERLY DEFUSED
   0x08048af4 <+240>:	movl   $0x804a1df,(%esp)
   0x08048afb <+247>:	call   0x80488e8 <puts@plt>         ;;; GREETING 4
   0x08048b00 <+252>:	call   0x80492b5 <read_line>        ;;; GET INPUT
   0x08048b05 <+257>:	mov    %eax,(%esp)
   0x08048b08 <+260>:	call   0x8048cc8 <phase_4>          ;;; CALL PHASE 4
   0x08048b0d <+265>:	call   0x8049413 <phase_defused>    ;;; SEE IF PROPERLY DEFUSED
   0x08048b12 <+270>:	movl   $0x804a2a0,(%esp)
   0x08048b19 <+277>:	call   0x80488e8 <puts@plt>         ;;; GREETING 4
   0x08048b1e <+282>:	call   0x80492b5 <read_line>        ;;; GET INPUT
   0x08048b23 <+287>:	mov    %eax,(%esp)
   0x08048b26 <+290>:	call   0x8048d37 <phase_5>          ;;; CALL PHASE 5
   0x08048b2b <+295>:	call   0x8049413 <phase_defused>    ;;; SEE IF PROPERLY DEFUSED
   0x08048b30 <+300>:	movl   $0x804a1ee,(%esp)
   0x08048b37 <+307>:	call   0x80488e8 <puts@plt>         ;;; GREETING 5
   0x08048b3c <+312>:	call   0x80492b5 <read_line>        ;;; GET INPUT
   0x08048b41 <+317>:	mov    %eax,(%esp)
   0x08048b44 <+320>:	call   0x8048dab <phase_6>          ;;; CALL PHASE 6
   0x08048b49 <+325>:	call   0x8049413 <phase_defused>    ;;; SEE IF PROPERLY DEFUSED
   0x08048b4e <+330>:	mov    $0x0,%eax
   0x08048b53 <+335>:	mov    -0x4(%ebp),%ebx
   0x08048b56 <+338>:	leave  
   0x08048b57 <+339>:	ret