;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Programme : Trie d'une liste saisie par l'utilisateur ;;
;;Exercice  :20                                         ;;
;;Membres   :Jean-Bernard ALTIDOR                       ;;
;;                  Assembleur 8086 (Octobre 2020)      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
STACKSG SEGMENT PARA STACK 'STACK'
        DW 64 DUP(?)
STACKSG ENDS

DATASG  SEGMENT PARA 'DATA'
DIZI    DB 100 dup(0)
ELEMAN  DB 100
MSG2	DB	'Entrez la dimension de la liste: ','$'
MSG_neg	DB	'-','$'
MSG_val	DB	'. Element: ','$'
MSG_err DB	' -Erreur! Veuillez entrer un nombre entre 1 et 255', '$'
MSG_err1 DB	' -Erreur! Veuillez entrer un nombre entre 1 et 100', '$'
MSG4 	DB	'-- Liste originale: --', '$'
MSG5 	DB	'-- Liste trie: --', '$'
MSG9	DB	'           -- Trie d une liste saisie par l utilisateur. --', '$'
MSG10	DB	'           -- Merci d avoir utiliser notre programme! --', '$'


MSG_voi	DB	'  ','$'
the_string db 26         
           db ?          
           db 26 dup (?) 
size DW 0;      Dimension du tableau
DATASG ENDS

CODESG  SEGMENT PARA 'CODE'
        ASSUME CS:CODESG, DS:DATASG, SS:STACKSG

BASLA   PROC FAR
        PUSH DS
        XOR AX,AX
        PUSH AX
        MOV AX, DATASG
        MOV DS, AX
		;----------;

		LEA DX,MSG9 
		MOV AH,9
		INT 21H
        CALL new_line

        ;Demande de la dimension du tableau
		ask_again:
        LEA DX,MSG2	 
		MOV AH,9
		INT 21H
		
		CALL read_number ; Recoit la dimension de la liste  
		CMP BX,101
		JGE	hata0    ;  Borne superieur 100
		CMP BX,1
		JL hata0	; Borne inferieur 1 
		
		
        JMP ok:

		hata0:
        LEA DX,MSG_err1 ;Message d'erreur
		MOV AH,9
		INT 21H		
		CALL new_line
		JMP ask_again

        ok:
		CALL new_line ;saut de ligne
        PUSH BX 
		
		XOR CX,CX
		MOV CL,BL 
		
		XOR SI,SI 

        ;Reception et analyse de des entrees de l'utilisateur
getElement:
		MOV BX,SI
		INC BL
		CALL print	;

		LEA DX,MSG_val	
		MOV AH,9
		
		INT 21H

		CALL read_number ; recoit l'input
		
		CMP BX,256
		JGE	hata1    ; Borne superieur 255
		CMP BX,1
		JL hata1	; Borne inferieur 1
        
		JMP hatayok
		hata1:
			LEA DX,MSG_err 
			MOV AH,9
			INT 21H
			DEC SI 
			INC CX 
			JMP hataDevam
		hatayok:
		
		MOV dizi[SI],BL 
		hataDevam:
		CALL new_line
		INC SI
		LOOP getElement
		
		CALL new_line	
		LEA DX,MSG4	
		MOV AH,9
		INT 21H
		CALL new_line	
		
		POP CX
		PUSH CX ;
		XOR SI,SI

                        ;Affichage de la liste initiale
showArray:
		XOR BH,BH
		MOV BL, dizi[SI]
		CALL print	
		
		LEA DX,MSG_voi	
		MOV AH,9
		INT 21H
		
		INC SI
		LOOP showArray
		
		CALL new_line
		CALL new_line
		LEA DX,MSG5	; 
		MOV AH,9
		INT 21H
		
		
        
		XOR AX,AX ; left = 0
		POP BX ; right = BX = n
		PUSH BX 
		DEC BX ; right = n-1
		CALL  quicksort
		
		CALL new_line
		
		
		POP CX  ; cx = n
        MOV size,cx
		XOR SI, SI
        
                            ;Affichage des Nombres pairs
showArray2:
		XOR BH,BH
		MOV BL, dizi[SI]
		CALL print	
		
		LEA DX,MSG_voi	
		MOV AH,9
		INT 21H
		
		INC SI
		LOOP showArray2   
		
                                     
        

        CALL new_line
        LEA DX,MSG10 
		MOV AH,9
		INT 21H
        

        HLT

BASLA   ENDP

                                        ;Procedure de QuickSort
quicksort	PROC

	; LEFT:AX, RIGHT:BX
PUSH BX
PUSH AX
	CMP AX,BX
	JGE bitti
	CALL arrange_pivot 
	
POP AX
	MOV BX,DX 
	DEC BX ; right = pivot - 1
	CALL quicksort ; (left:left, right:pivot-1)
POP BX
	MOV AX,DX 
	INC AX ; left = pivot + 1
	CALL quicksort ; (left:pivot+1, right:right)
	JMP devamEdiyor
	bitti:
	POP AX
	POP BX
	devamEdiyor:
	RET
quicksort	ENDP

arrange_pivot PROC
	XOR DH,DH
	; DX: pivot, AX: left, BX: right
	MOV DL, dizi[BX] ; DX = dizi[right]
	MOV SI,AX
	DEC SI ; ind = SI = left - 1
	
	MOV CX,BX
	SUB CX,AX ;  right-left
	
	MOV DI,AX ; j = left
dongu1:
	PUSH BX
	XOR BH,BH
	MOV BL, dizi[DI]
	CMP BL,DL
	JG devam2
	INC SI
	
	
	PUSH DX
	XOR DH,DH
	MOV DL,dizi[SI]
	XCHG DL,dizi[DI]
	MOV dizi[SI],DL
	POP DX
	
	devam2:
	POP BX
	INC DI
	LOOP dongu1

	
	PUSH DX
	XOR DH,DH
	INC SI ; SI+1
	MOV DL,dizi[SI]
	XCHG DL,dizi[BX]
	MOV dizi[SI],DL
	POP DX
	
	MOV DX,SI ;; DX = SI+1 

	RET
arrange_pivot ENDP

                                    ;Procedure pour recevoir les entrees de l'uitilisateur
read_number	PROC
PUSH SI
	
	MOV AH, 0ah  
	mov dx,offset the_string  
	INT 21H
	
	MOV SI, offset the_string 
	CALL string2num	
POP SI
	RET
read_number ENDP

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
                                ;Procedure d'affichage
print		PROC
push ax
push dx
push cx
push bx
	mov  ax, bx 
	CMP bl,0
	JGE devam ; 
		LEA DX,MSG_neg ;
		MOV AH,9
		INT 21H
		MOV AX,BX 
		NEG Al 
	devam:
	
   MOV BX, 10     
   XOR DX,DX
   XOR CX,CX
    
          
bol1:  
	XOR DX,DX
    DIV BX      ;AX/BX
    PUSH DX     
    INC CX      
    CMP AX, 0     
    JNE bol1     
    
bol2:  POP DX      
   ADD DX, 30H     
   MOV AH, 02H     
   INT 21H      
   LOOP bol2    

pop bx
pop cx
pop dx
pop ax
  RET
print ENDP

string2num	PROC
push cx 
push si

  inc  si 
  mov  cl, [ si ]                                         
  xor ch,ch 
  add  si, cx 

  xor bx,bx
  mov  bp, 1 ;MULTIPLE OF 10 TO MULTIPLY EVERY DIGIT.

  xor ax,ax
repeat:
                   
  mov  al, [ si ] 
  CMP AL,'-'
  JNE positive
		
		NEG BX
		JMP negative  
  positive:
  sub  al, 48 

  xor ah,ah
  mul  bp ;AX*BP = DX:AX
  add  bx,ax 

  mov  ax, bp
  mov  bp, 10
  mul  bp 
  mov  bp, ax 

  dec  si 
  loop repeat
negative:

pop si
pop cx
  RET
string2num ENDP

CODESG  ENDS
        END BASLA