TITLE CAPSTONE (EXE)
;////////////////////////////////////////////////////////////////////////;
STACKSEG SEGMENT PARA 'Stack'
STACKSEG ENDS
;////////////////////////////////////////////////////////////////////////;
DATASEG SEGMENT PARA 'Data'
		HNTMSG1	DB	'Tip: $'          
		HNTMSG2	DB	'Use W,A,S,&D to$'
		HNTMSG3	DB	'to move around!$'
		HUDLBLS	DB	'Score: $'
		HUDLBLH	DB	'HP: $'
		DIRECTN	DB	0
		HEROUP	DB	30, '$'
		HERODN	DB	31, '$'
		HEROLF	DB	17, '$'
		HERORT	DB	16, '$'
		HEROX	DB	3
		HEROY	DB	3
		HEROSCORE DB 0
		COINSY	DB	2, '$'
		x db 9
		y db 5
		UP_ARROW DB 48H
		DOWN_ARROW DB 50H
		LEFT_ARROW DB 4Bh
		RIGHT_ARROW DB 4DH
		ESC_KEY DB 1BH
		INPUT_DATA DW ?
DATASEG ENDS
;///////////////////////////////////////////////////////////////////////;
CODESEG SEGMENT PARA 'Code'
ASSUME SS:STACKSEG, DS:DATASEG, CS:CODESEG
;=======================================================================;
;=====================MAIN PROCEDURE====================================;
MAIN PROC FAR
START:
		MOV 	AX, DATASEG
		MOV 	DS, AX
	
		;CALL TITLE PAGE
		
		CALL GAME ;temporary. for testing purposes only

	
TERMINATE:
		MOV 	AH, 4CH
		INT 	21H
MAIN 	ENDP
;=======================================================================;
;====================GAME SCREEN========================================;
GAME 	PROC NEAR
		CALL	DRAW_FIELD	;draw the playing field and the hud on the right
		
		MOV 	AH, 02H   ;function code to request for set cursor
		MOV 	BH, 00    ;page number 0, i.e. current screen
		MOV 	DH, 3H    ;set row
		MOV 	DL, 3H    ;set column
		INT 	10H
		
ANIMATION:	
		
		CALL	CLEAN_BOARD
		
		CALL	_GET_KEY
		
		CALL	MOV_POS
		
		CALL 	PRINTHERO
		
		CALL 	CHECKCOIN
		
		CALL    PRINTCOIN
		
		CALL 	_DELAY

		JMP 	ANIMATION
		
		RET
GAME	ENDP
;=======================================================================;
;====================MOVES CURSOR TO MOVE CHAR==========================;
;--------------------prints whatever is in DX---------------------------;
MOV_POS PROC NEAR
		MOV 	AX, INPUT_DATA

		; is up?
		CMP 	AH, UP_ARROW
		JE MOV_UP
		; is right?
		CMP 	AH, RIGHT_ARROW
		JE 		MOV_RIGHT
		; is down?
		CMP 	AH, DOWN_ARROW
		JE 		MOV_DOWN
		; is left?
		CMP 	AH, LEFT_ARROW
		JE 		MOV_LEFT
		; is esc?
		CMP 	AL, ESC_KEY
		JE 		TERMINATE
		; is not those?
		JMP 	SET_PRINT_COOR

		MOV_UP:
		MOV 	[DIRECTN], 1
		CMP 	heroy, 3
		JG 		PROCESS_UP
		MOV 	heroy, 21
		PROCESS_UP:
		DEC 	heroy
		JMP 	SET_PRINT_COOR

		MOV_DOWN:
		MOV 	[DIRECTN], 2
		CMP 	heroy, 21
		JL 		PROCESS_DOWN
		MOV 	heroy, 3
		PROCESS_DOWN:
		INC 	heroy
		JMP 	SET_PRINT_COOR

		MOV_LEFT:
		MOV 	[DIRECTN], 3
		CMP 	herox, 3
		JG 		PROCESS_LEFT
		MOV 	herox, 58
		PROCESS_LEFT:
		DEC 	herox
		JMP 	SET_PRINT_COOR

		MOV_RIGHT:
		MOV 	[DIRECTN], 4
		CMP 	herox, 58
		Jl 		PROCESS_RIGHT
		MOV 	herox, 3
		PROCESS_RIGHT:
		INC 	herox
		JMP 	SET_PRINT_COOR


		SET_PRINT_COOR:
		MOV 	AH, 02H   ;function code to request for set cursor
		MOV 	BH, 00    ;page number 0, i.e. current screen
		MOV 	DH, heroy    ;set row
		MOV 	DL, herox    ;set column
		INT 	10H

		RET
MOV_POS ENDP
;=======================================================================;
;====================DRAW FIELD=========================================;
;--------------------clears screen, draws green field-------------------;
DRAW_FIELD PROC NEAR
		;CMP: Fill (0, 0) to (24, 79) wtih a black backgrond and black text
		;ENG: Cleans up any residual texts
		MOV 	AX, 0600H   ;full screen
		MOV 	BH, 020H     ;black bg (0), black fg (0)
		MOV 	CX, 0000H   ;upper left row:column (00, 00)
		MOV 	DX, 184FH   ;lower right row:column (24:79)
		INT 	10H

		CALL	CLEAN_BOARD
		
		;CMP: Fill (03, 61) to (08, 76) wtih a black backgrond and black text
		;ENG: Draws background for score
		MOV 	AX, 0600H   ;full screen
		MOV 	BH, 2FH     ;green backgrond, white foreground
		MOV 	CX, 033DH   ;upper left row:column (03, 61)
		MOV 	DX, 074CH   ;lower right row:column (08, 76)
		INT 	10H
		
		;ENG: print label for score
		MOV 	AH, 02H   ;function code to request for set cursor
		MOV 	BH, 00    ;page number 0, i.e. current screen
		MOV 	DH, 04H    ;set row
		MOV 	DL, 3EH    ;set column
		INT 	10H
		; printf(hintmsg);
		LEA 	DX, HUDLBLS
		CALL 	PRINTF
		
		;CMP: Fill (03, 61) to (08, 76) wtih a black backgrond and black text
		;ENG: Draws background for hp
		MOV 	AX, 0600H   ;full screen
		MOV 	BH, 3FH     ;light blue backgrond, white foreground
		MOV 	CX, 093DH   ;upper left row:column (03, 61)
		MOV 	DX, 0D4CH   ;lower right row:column (08, 76)
		INT 	10H
		
		; ENG: Print label for hp
		MOV 	AH, 02H   ;function code to request for set cursor
		MOV 	BH, 00    ;page number 0, i.e. current screen
		MOV 	DH, 0AH    ;set row
		MOV 	DL, 3EH    ;set column
		INT 	10H
		; printf(hintmsg);
		LEA 	DX, HUDLBLH
		CALL 	PRINTF
		
		;CMP: Fill somewhere idk hahah with blakc bg and white text
		;ENG: Make hint text visible
		MOV 	AX, 0600H   ;full screen
		MOV 	BH, 0FH     ;light blue backgrond, white foreground
		MOV 	CX, 0F3DH   ;upper left row:column (03, 61)
		MOV 	DX, 134CH   ;lower right row:column (08, 76)
		INT 	10H
		
		MOV 	AH, 02H   ;function code to request for set cursor
		MOV 	BH, 00    ;page number 0, i.e. current screen
		MOV 	DH, 0FH    ;set row
		MOV 	DL, 3DH    ;set column
		INT 	10H
		; printf(hintmsg);
		LEA 	DX, HNTMSG1
		CALL 	PRINTF
		
		MOV 	AH, 02H   ;function code to request for set cursor
		MOV 	BH, 00    ;page number 0, i.e. current screen
		MOV 	DH, 10H    ;set row
		MOV 	DL, 3DH    ;set column
		INT 	10H
		; printf(hintmsg);
		LEA 	DX, HNTMSG2
		CALL 	PRINTF
		; printf(hintmsg);
		MOV 	AH, 02H   ;function code to request for set cursor
		MOV 	BH, 00    ;page number 0, i.e. current screen
		MOV 	DH, 11H    ;set row
		MOV 	DL, 3DH    ;set column
		INT 	10H
		; printf(hintmsg);
		LEA 	DX, HNTMSG3
		CALL 	PRINTF
		
		RET
DRAW_FIELD ENDP
;=======================================================================;
;====================PRINTHERO==========================================;
;--------------------prints hero icon matching movements----------------;
PRINTHERO PROC NEAR
		CMP 	DIRECTN, 1
		JE		DRAWUP
		CMP		DIRECTN, 2
		JE		DRAWDOWN
		CMP		DIRECTN, 3
		JE		DRAWLEFT
		CMP		DIRECTN, 4
		JE		DRAWRIGHT
DRAWUP:
		LEA		DX, HEROUP
		JMP 	RENDERHERO
DRAWDOWN:
		LEA		DX, HERODN
		JMP 	RENDERHERO
DRAWLEFT:
		LEA		DX, HEROLF
		JMP 	RENDERHERO
DRAWRIGHT:
		LEA		DX, HERORT
		JMP 	RENDERHERO		
RENDERHERO:
		CALL	PRINTF

		RET
PRINTHERO ENDP
;=======================================================================;
;====================PRINTCOIN==========================================;
;--------------------prints coin in given position----------------------;
PRINTCOIN PROC NEAR
		MOV 	AH, 02H   ;function code to request for set cursor
		MOV 	BH, 00    ;page number 0, i.e. current screen
		MOV 	DH, Y    ;set row
		MOV 	DL, X    ;set column
		INT 	10H
		; printf(hintmsg);
		LEA 	DX, COINSY
		CALL 	PRINTF
		RET
PRINTCOIN ENDP

;=======================================================================;
;====================CLEAN_BOARD========================================;
;--------------------prints whatever is in DX---------------------------;
CLEAN_BOARD PROC NEAR
		;CMP: Fill (3, 3) to (21, 58) wtih a black backgrond and black text
		;ENG: Draws the playing field
		MOV 	AX, 0600H   ;full screen
		MOV 	BH, 7FH     ;grey bg (7), white fg(1);
		MOV 	CX, 0303H   ;upper left row:column (03, 03)
		MOV 	DX, 153AH   ;lower right row:column (21, 58)
		INT 	10H
		RET
CLEAN_BOARD ENDP
;=======================================================================;
;====================SAVES KEY TO INPUT_DATA============================;
;--------------------prints whatever is in DX---------------------------;
_GET_KEY	PROC	NEAR
			MOV		AH, 01H		;check for input
			INT		16H

			JZ		__LEAVETHIS

			MOV		AH, 00H		;get input	MOV AH, 10H; INT 16H
			INT		16H

            MOV     INPUT_DATA, AX

	__LEAVETHIS:
			RET
_GET_KEY 	ENDP
;=======================================================================;
;====================PRINTF=============================================;
;--------------------prints whatever is in DX---------------------------;
PRINTF PROC NEAR
    MOV AH, 09
    INT 21H
    RET
PRINTF ENDP
;-----------------------------------------------------------------------
_DELAY PROC	NEAR
			mov bp, 2 ;lower value faster
			mov si, 2 ;lower value faster
		delay2:
			dec bp
			nop
			jnz delay2
			dec si
			cmp si,0
			jnz delay2
			RET
_DELAY ENDP
;----------------------------------
CHECKCOIN PROC NEAR
		MOV AL, HEROX
		MOV AH, HEROY
		MOV BL, X
		MOV BH, Y
		CMP AL, BL
		
		JNE __LEAVETHIS2
		CMP AH, BH
		JNE __LEAVETHIS2
		ADD X, 3
		MOV DX, 0
		MOV AH, 0
		MOV AL, X
		MOV BX, 55
		DIV BX
		MOV [X], DL
		ADD X, 3
		
		ADD Y, 4 
		MOV DX, 0
		MOV AH, 0
		MOV AL, Y
		MOV BX, 18
		DIV BX
		MOV [Y], DL
		ADD Y, 3
		
__LEAVETHIS2:
		RET
CHECKCOIN ENDP

	
CODESEG ENDS
END START
