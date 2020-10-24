;EXERCICE 3
;----------------------------------------
;Program  : Decimal -> binaire
;FileName : convertir_decimal_en_binaire.asm
;I/P 	  : 8
;O/P 	  : 1000 
;By       : Kevin DUBUCHE 
;---------------------------------------- 

;Ecrire un programme assembleur en 8086 qui convertit
;un nombre decimal de 16 bit en nombre binaire        

;__________________________________________________________

;;;;;;8086 programme pour convertir un decimal de 16 bit en binaire
.MODEL SMALL 
.STACK 100H 
.DATA 
MSG8	DB	' -- Bonjour. Entrer un nombre decimal --', '$'  
MSG9	DB	' -- Merci d avoir utiliser notre programme! --', '$'
;;;;;;;;;;;; on stock la valeur a convertir dans d1
d1 dw 8    
; this macro prints a char in AL and advances
; the current cursor position:
putc    macro   char
        push    ax
        mov     al, char
        mov     ah, 0eh
        int     10h     
        pop     ax
endm

.CODE 

MAIN PROC FAR               
 
    ;;;;;;chargement du segment de code
	MOV AX, @DATA 
	MOV DS, AX 
	;;;;;; fin chargement du segment de code 
	   LEA DX,MSG8 
		MOV AH,9
		INT 21H
        call new_line 
                                     
             xor ax, ax
	    call  SCAN_NUM 
           
           mov al, 0ah
           mov ah, 0eh
           int 10h
           
           mov al, 0dh
           mov ah, 0eh
           int 10h
                
           mov ax, cx
           xor cx, cx
	   call print
	;;;;;;appel de la procedure qui fait la converion
	
	;;;;;;;;;;;;;fin du programme 
	call new_line 
	 LEA DX,MSG9
		MOV AH,9
		INT 21H
	MOV AH, 4CH 
	INT 21H 
MAIN ENDP


;;;;;;;;definition de ma procedure
PRINT PROC  
  ;;;;;;;;;CX taille de la pile qui va recevoir les nombres
  mov cx, 0 
  ;;;;;;;;dx recoit le reste le la division
  mov dx, 0 
  
  ;;;;;;;;on compare AX a 0
  label1:  
	cmp ax, 0 
	je print1 

  ;;;;;on met 2  dans bs, car on fera des divisions successives par 2
  mov bx, 2 
  ;;;;;;;;;;;on divise par 16 pour la conversion en hexadecimal
  ;;;;;;;;;;;AX est divise par BX, le quotient est dans ax (plus precisement AL) et le reste dans dx
	
  div bx 
  push dx 
  ;;;;;;;;on incremente cx car pour chaque division on push le quotient dans la pile
  inc cx 
  ;;;;;;;;;;on met dx, qui recoit le reste de la division a 0 (xor est plus efficace que mov dx,0)
  xor dx,dx 
  jmp label1 
			
  print1: 
    ;;;;;;;;verifier si CX est > 0 por savoir s'il reste un element a convertir (en lettre) dans la pile
  	cmp cx, 0 
	je exit
 
	pop dx 
	;;;;;;;on ajoute 48 pour avooir l'equivalent des digit en  ASCII
	add dx, 48 
	;;;;;on affiche le caractere grace a l'interruption suivante
	mov ah, 02h 
	int 21h 

	;;;;on decremente le compteur
	dec cx 
	jmp print1 

  exit: ret 

PRINT ENDP 


; gets the multi-digit SIGNED number from the keyboard,
; and stores the result in CX register:
  SCAN_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI
        
        MOV     CX, 0

        ; reset flag:
        MOV     CS:make_minus, 0

next_digit:

        ; get char from keyboard
        ; into AL:
        MOV     AH, 00h
        INT     16h
        ; and print it:
        MOV     AH, 0Eh
        INT     10h

        ; check for MINUS:
        CMP     AL, '-'
        JE      set_minus

        ; check for ENTER key:
        CMP     AL, 0Dh  ; carriage return?
        JNE     not_cr
        JMP     stop_input
not_cr:


        CMP     AL, 8                   ; 'BACKSPACE' pressed?
        JNE     backspace_checked
        MOV     DX, 0                   ; remove last digit by
        MOV     AX, CX                  ; division:
        DIV     CS:ten                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX
        PUTC    ' '                     ; clear position.
        PUTC    8                       ; backspace again.
        JMP     next_digit
backspace_checked:


        ; allow only digits:
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:       
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered not digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for next input.       
ok_digit:


        ; multiply CX by 10 (first time the result is zero)
        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten                  ; DX:AX = AX*10
        MOV     CX, AX
        POP     AX

        ; check if the number is too big
        ; (result should be 16 bits)
        CMP     DX, 0
        JNE     too_big

        ; convert from ASCII code:
        SUB     AL, 30h

        ; add AL to CX:
        MOV     AH, 0
        MOV     DX, CX      ; backup, in case the result will be too big.
        ADD     CX, AX
        JC      too_big2    ; jump if the number is too big.

        JMP     next_digit

set_minus:
        MOV     CS:make_minus, 1
        JMP     next_digit

too_big2:
        MOV     CX, DX      ; restore the backuped value before add.
        MOV     DX, 0       ; DX was zero before backup!
too_big:
        MOV     AX, CX
        DIV     CS:ten  ; reverse last DX:AX = AX*10, make AX = DX:AX / 10
        MOV     CX, AX
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for Enter/Backspace.
        
        
stop_input:
        ; check flag:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:

        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?       ; used as a flag.
SCAN_NUM        ENDP

ten             DW      10      ; used as multiplier/divider by SCAN_NUM & PRINT_NUM_UNS.
         
         
                                             ;Procedure pour faire un saut de ligne
new_line	PROC
		PUSH DX
		PUSH AX
		
		MOV dl, 10	;  \n
		MOV ah, 02h
		INT 21h
		MOV dl, 13
		MOV ah, 02h
		INT 21h
		
		POP AX
		POP DX
		RET
new_line ENDP


END MAIN 
