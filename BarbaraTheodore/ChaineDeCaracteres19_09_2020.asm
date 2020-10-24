
;Exo 23: Ce programme permet
;d'afficher une chaine de
;caracteres donnees

DATA SEGMENT
    chaine db 100 DUP ('$')
    message1 dw 10,13,'Entrez une chaine de caracteres: $'
    message2 dw 10,13,'Vous aviez rentre: $'
    retour dw 10,13,'Appuyez sur une touche pour sortir $'
DATA ENDS 

STACK SEGMENT
    DW 300H
STACK ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    mov ax,data ; ces deux instructions servent à
    mov ds,ax ; initialiser l'adresse du segment de code.
    call affichage_message1
    call saisieCh
    call affichage_message2
    call affichageCh
    call fin

    saisieCh:
        mov dx, offset chaine
        MOV AH,0Ah
        INT 21h ; lit une chaine de caracteres pointée par dx
        ret

    Affichage_message1:
        MOV DX, offset message1
        MOV AH,09h
        INT 21h ; affiche une chaine de caracteres pointé par DX
        ret 

    Affichage_message2:
        MOV DX, offset message2
        MOV AH,09h
        INT 21h ; affiche une chaine de caracteres pointé par DX
        ret

    AffichageCh:
        MOV DX, offset chaine
        inc dx
        inc dx
        MOV AH,09h
        INT 21h ; affiche une chaine de caractères pointé par DX
        ret

    fin:
        MOV DX, offset retour
        MOV AH,09h
        int 21h
        mov ah,7; attends une interruption avant de sortir
        INT 21h ; retour au DOS

CODE ENDS 