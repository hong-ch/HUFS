DIS MACRO STR
MOV AH,09H
LEA DX,STR
INT 21H
ENDM

DATA SEGMENT
    MSG1 DB 0Dh, 0Ah, 'Enter a decimal number: $'
    MSG2 DB "BINARY NUMBER IS : $"
    STR1 DB 20 DUP('$')
    STR2 DB 20 DUP('$')
    NO   DW ?
    LINE DB 10,13,'$'
    INBUF DB 6 DUP(0)
DATA ENDS

CODE SEGMENT
          ASSUME DS:DATA,CS:CODE

; ------------------------
; 사용자 입력 → NO 저장
; ------------------------
INPUT:
          MOV AX, DATA
          MOV DS, AX

          DIS MSG1

          LEA SI, INBUF
          XOR CX, CX

READ_LOOP:
          MOV AH, 01H
          INT 21H
          CMP AL, 0Dh
          JE STR_TO_INT
          CMP AL, '0'
          JB READ_LOOP
          CMP AL, '9'
          JA READ_LOOP
          MOV [SI], AL
          INC SI
          INC CX
          CMP CX, 5
          JNE READ_LOOP
          JMP STR_TO_INT

STR_TO_INT:
          MOV BYTE PTR [SI], 0
          LEA SI, INBUF
          XOR AX, AX

NEXT_DIGIT:
          MOV BL, [SI]
          CMP BL, 0
          JE STORE_TO_NO
          SUB BL, '0'
          MOV BH, 0

          ; Calculate AX = AX * 10 + BX
          PUSH AX         ; Save AX
          MOV CL, 3       ; CL = 3 (for SHL AX, 3 -> AX * 8)
          SHL AX, CL      ; AX = AX * 8
          MOV DX, AX      ; Save AX * 8 in DX
          POP AX          ; Restore original AX
          SHL AX, 1       ; AX = AX * 2
          ADD AX, DX      ; AX = AX * 2 + AX * 8 = AX * 10
          ADD AX, BX      ; Add the current digit

          INC SI
          JMP NEXT_DIGIT

STORE_TO_NO:
          MOV NO, AX    ; 입력된 값을 NO에 저장
          JMP START     ; 기존 코드 시작으로 점프

; ------------------------
; 기존 코드 그대로 유지
; ------------------------

START:
          MOV AX,DATA
          MOV DS,AX
          LEA SI,STR1
          MOV AX,NO
          MOV BH,00
          MOV BL,2
     L1:DIV BL
          ADD AH,'0'
          MOV BYTE PTR[SI],AH
          MOV AH,00
          INC SI
          INC BH
          CMP AL,00
          JNE L1

          MOV CL,BH
          LEA SI,STR1
          LEA DI,STR2
          MOV CH,00
          ADD SI,CX
          DEC SI

     L2:MOV AH,BYTE PTR[SI]
          MOV BYTE PTR[DI],AH
          DEC SI
          INC DI
          LOOP L2

          DIS LINE
          DIS MSG2
          DIS STR2
          MOV AH,4CH
          INT 21H
CODE ENDS
END INPUT