INCLUDE DOS.MAC
.MODEL	SMALL
.STACK	266
.DATA
	MESSAGE		DB	0AH,0DH,'Enter an algebraic command line: $'

    RESULT     	DB	0AH, 0DH,'Result: $'

	ERRORMSG	DB	0AH,0DH,'Error!!! '
				DB	0AH,0DH,'Input format: Operand1 Operator Operand2 '
				DB	0AH,0DH,'Operand: decimal numbers '
				DB	0AH,0DH,'Operator: + - * / $'

	AGAIN		DB	0AH,0DH,'Again? [Y/N] $'

    NEWLINE		DB   0AH,0DH,'$'		; new line

    STRINGIN	DB   100				; max number(100) of chars expected
	NUM			DB   ?					; returns the number of chars typed
	ACT_STRINGIN	DB   100 DUP (?)	; actual buffer w/ size=¡°max number¡±

	INCHAR		DB	?
	
	Operand1	DB	5 DUP (?)
	Operand2	DB	5 DUP (?)
	Operator	DB	?
	
	Op1sign		DB	1 DUP (?)
	Op2sign		DB	1 DUP (?)
	
	Temp1		DB	5 DUP (?)
	Temp2		DB	5 DUP (?)
	
	MULT1		DW	0000H         ; Initial result= 0
	MULT2		DW	0000H         ; Initial result= 0
	
	resultt 	DW   0
	resascii   	DB   10 dup (?)
	
.CODE
	.STARTUP
MAIN PROC FAR

		MOV  AX,@data
		MOV  DS,AX
		MOV  ES,AX
		
			CALL CLEAR_ALL

			
Inputsmtg:	OUTPUT MESSAGE

			;get string
			MOV  AH, 0AH
			MOV  DX, OFFSET STRINGIN
			INT 21H
			
				CALL CHECKOP1
				CALL CHECKOPE
				CALL CHECKOP2
				
				CALL GETSIGN_
				
				CALL H2A
				
				OUTPUT NEWLINE
				OUTPUT RESULT
				
				CALL OPERATION_
	.Exit
MAIN 	ENDP

;AGAIN_ is here

AGAIN_ PROC NEAR
			OUTPUT AGAIN
			
			;read a character from keyboard
			MOV AH,01H
			INT 21H
			MOV INCHAR,AL
			
			OUTPUT NEWLINE
			
			CMP INCHAR,59H
			JE Inputsmtg
			CMP INCHAR,79H
			JE Inputsmtg
			MOV AH,4CH
			INT 21H
	RET
AGAIN_ ENDP



;ERROR_ is here

ERROR_ PROC NEAR
			OUTPUT NEWLINE
			OUTPUT NEWLINE
			OUTPUT ERRORMSG
			CALL AGAIN_

	RET
ERROR_ ENDP



;CLEAR_ALL is here

CLEAR_ALL PROC NEAR
		MOV  AX,0000H
		MOV  BX,0000H
		MOV  CX,0000H
		MOV  DX,0000H
		MOV  SI,0000H
		MOV  DI,0000H
	RET
CLEAR_ALL ENDP




;CHECKOP1 is here

CHECKOP1 PROC NEAR
			
			;let SI holds actual string offset and AL holds the content in SI 
			MOV SI,OFFSET ACT_STRINGIN
			MOV AL,[SI]
			
			;let BX holds the offset of operand1
			MOV BX,0000H
			MOV BX,OFFSET Operand1
			
			CMP AL,2DH
			JE storeit1
			CMP AL,2BH
			JE storeit1
			CMP AL,2DH
			JNE dostoring1
			CMP AL,2BH
			JNE dostoring1
			
storeit1:			MOV [BX],AL
					INC SI
					MOV AL,[SI]
					INC BX

					
dostoring1:			
					CMP AL,39H
					JA Label1
					CMP AL,30H
					JB Label1
					
					MOV [BX],AL
					INC SI
					MOV AL,[SI]
					INC BX
					CMP AL,20H
					JNE	dostoring1
					MOV DL,24H
					MOV [BX],DL
					INC SI
					RET
					
Label1:				CALL ERROR_


CHECKOP1 ENDP




;CHECKOPE is here

CHECKOPE PROC NEAR

			;let BX holds the offset of operator
			MOV BX,0000H
			MOV BX,OFFSET Operator

			MOV AL,[SI]
			
			CMP AL,2AH
			JE dostoring
			CMP AL,2BH
			JE dostoring
			CMP AL,2DH
			JE dostoring
			CMP AL,2FH
			JE dostoring
			
			CALL ERROR_

dostoring:	MOV [BX],AL

			INC SI
			MOV AL,[SI]
			CMP AL,20H
			JE siplusone
			
			CALL ERROR_
			
siplusone:	INC SI
			MOV AL,[SI]

	RET
CHECKOPE ENDP



;CHECKOP2 is here

CHECKOP2 PROC NEAR
			
			;let BX holds the offset of operator
			MOV BX,0000H
			MOV BX,OFFSET Operand2
			
			
			CMP AL,2DH
			JE storeit2
			CMP AL,2BH
			JE storeit2
			CMP AL,2DH
			JNE dostoring2
			CMP AL,2BH
			JNE dostoring2
			
storeit2:			MOV [BX],AL
					INC SI
					MOV AL,[SI]
					INC BX
					
dostoring2:			
					CMP AL,39H
					JA Label2
					CMP AL,30H
					JB Label2
					
					MOV [BX],AL
					INC SI
					MOV AL,[SI]
					INC BX
					CMP AL,0DH
					JNE	dostoring2
					MOV DL,24H
					MOV [BX],DL
					INC SI
					RET
					
Label2:				CALL ERROR_	

CHECKOP2 ENDP




;Convert Hex to ASCII [H2A] is here

H2A PROC NEAR
	CALL CLEAR_ALL
	
			MOV SI,OFFSET Operand1
			MOV AL,[SI]			
seenext1:		CMP AL,30H
				JB isasign1

					SUB AL,30H
					MOV [SI],AL
					
isasign1:	INC SI
			MOV AL,[SI]
			CMP AL,24H
			JNE seenext1
		
			
	CALL CLEAR_ALL
	
			MOV SI,OFFSET Operand2
			MOV AL,[SI]			
seenext2:		CMP AL,30H
				JB isasign2
				
					SUB AL,30H
					MOV [SI],AL
					
isasign2:	INC SI
			MOV AL,[SI]
			CMP AL,24H
			JNE seenext2

	RET
H2A ENDP




;Convert Answer from ASCII to Hex [A2H1] is here

A2H1 PROC NEAR
	CALL CLEAR_ALL
	
		MOV SI,OFFSET Operand1
seenext3:		MOV AL,[SI]			
				CMP AL,09H
				JA isasign3
					
					ADD AL,30H
					MOV [SI],AL
					
isasign3:	INC SI
			MOV AL,[SI]
			CMP AL,24H
			JNE seenext3

	RET
A2H1 ENDP





;Convert Answer from ASCII to Hex [A2H2] is here

A2H2 PROC NEAR
	CALL CLEAR_ALL
	
			MOV SI,OFFSET Operand2
seenext4:		MOV AL,[SI]			
				CMP AL,09H
				JA isasign4
				
					ADD AL,30H
					MOV [SI],AL
					
isasign4:	INC SI
			MOV AL,[SI]
			CMP AL,24H
			JNE seenext4

	RET
A2H2 ENDP






;GETSIGN is here

GETSIGN_ PROC NEAR
	CALL CLEAR_ALL
		
		MOV SI,OFFSET Operand1
		MOV AL,[SI]
		
		MOV DI,OFFSET Operand2
		MOV BL,[DI]
		

		
					CMP AL,30H
					JB op11issign1
					CMP BL,30H
					JB op21issign2
					
						MOV SI,0000H
						MOV DI,0000H
						
						MOV SI,OFFSET Op1sign
						MOV DI,OFFSET Op2sign
						
						MOV CL,2BH
						MOV [SI],CL
						MOV DL,2BH
						MOV [DI],DL


							RET
		op11issign1:
					CMP BL,30H
					JB op21issign1
					
						MOV CL,30H
						MOV [SI],CL
						
						MOV SI,0000H
						MOV DI,0000H
						
						MOV SI,OFFSET Op1sign
						MOV DI,OFFSET Op2sign
							
						MOV [SI],AL
						MOV DL,2BH
						MOV [DI],DL

					
						RET
					
		op21issign1:
						MOV CL,30H
						MOV [SI],DL
						MOV DL,30H
						MOV [DI],CL
					
						MOV CX,0000H
						MOV DX,0000H
						MOV SI,0000H
						MOV DI,0000H
						
						MOV SI,OFFSET Op1sign
						MOV DI,OFFSET Op2sign
						
						MOV [SI],AL
						MOV [DI],BL
					
							RET
					

					
		op21issign2:
						MOV DL,30H
						MOV [DI],DL

						MOV SI,0000H
						MOV DI,0000H
						
						MOV SI,OFFSET Op1sign
						MOV DI,OFFSET Op2sign

						MOV CL,2BH
						MOV [SI],CL
						MOV [DI],BL
						
						RET
GETSIGN_ ENDP



OPERATION_ PROC NEAR
		CALL CLEAR_ALL

				MOV SI,OFFSET Operator
				MOV AL,[SI]
				
				CMP AL,2BH
				JE doaddition
				CMP AL,2DH
				JE dosubtraction
				CMP AL,2AH
				JE domultiplication
				CMP AL,2FH
				JE dodivision
				
				RET
				
				
	doaddition:
				CALL DO_ADDITION_
				CALL A2H1
				CALL OP1OPEOP2_
				CALL CLEAR_ALL
				RET
	dosubtraction:
				CALL DO_SUBTRACTION_
				CALL A2H1
				CALL OP1OPEOP2_
				CALL CLEAR_ALL
				RET
	domultiplication:
				CALL DO_MULTIPLICATION_
				CALL CLEAR_ALL
				RET
	dodivision:
				CALL DO_DIVISION_
				CALL CLEAR_ALL
				RET
OPERATION_ ENDP



DO_ADDITION_ PROC NEAR 
	; Operation for addition starts here
	
				CALL CLEAR_ALL
				
				MOV DI,OFFSET Op1sign
				MOV AL,[DI]
				
				MOV DI,0000H
				
				MOV DI,OFFSET Op2sign
				MOV BL,[DI]
				
				CMP AL,BL
				JNE LL2
				
				CMP AL,2BH
				JNE LL3
				
				CALL ADDITION_
				RET
				
	LL3:		
				CALL ADDITION_
				
				MOV DL,2DH
				MOV AH,02H
				INT 21H
				RET
				
	LL2:
				CALL REMOVEZEROOP1_
				CALL REMOVEZEROOP2_
				
				CALL CLEAR_ALL
				
				MOV SI,OFFSET Operand1
				MOV AL,[SI]
				
				MOV DI,OFFSET Operand2
				MOV BL,[DI]
				
	op1gotobackope:	INC SI
					MOV AL,[SI]
					INC CL
					CMP AL,24H
					JNE op1gotobackope
					
					
	op2gotobackope:	INC DI
					MOV BL,[DI]
					INC DL
					CMP BL,24H
					JNE op2gotobackope
					
					MOV SI,0000H
					MOV DI,0000H
					MOV AX,0000H
					MOV BX,0000H
					
					MOV SI,OFFSET Op1sign
					MOV AL,[SI]
					
					MOV DI,OFFSET Op2sign
					MOV BL,[DI]
					
					CMP CL,DL
					JE LL7
					CMP CL,DL
					JA LL4
					
					CMP BL,2DH
					JE LL6
					
					CALL SUBTRACTION_
					RET

	LL6:
					CALL SUBTRACTION_
					MOV DL,2DH
					MOV AH,02H
					INT 21H
					RET
					
	LL4:			
					CMP AL,2BH
					JE LL5
					
					CALL SUBTRACTION_
					MOV DL,2DH
					MOV AH,02H
					INT 21H
					RET
	LL5:
					CALL SUBTRACTION_
					RET
					
	LL7:			
					CALL CLEAR_ALL
					
					MOV SI,OFFSET Op1sign
					MOV AL,[SI]
					
					MOV DI,OFFSET Op2sign
					MOV BL,[DI]
					
					MOV SI,0000H
					MOV DI,0000H
					
					MOV SI,OFFSET Operand1
					MOV CL,[SI]
					
					MOV DI,OFFSET Operand2
					MOV DL,[DI]
					
					CMP CL,DL;
					JNE LL9
					
	cmpmoretimes1:
						INC SI
						MOV CL,[SI]
						INC DI
						MOV DL,[DI]
						CMP CL,24H
						JE ansiszero1
						CMP CL,DL
						JE cmpmoretimes1
					
					
					
	LL9:			CMP CL,DL
					JA LL8
					
					CMP BL,2DH
					JNE LL009
					
					MOV DL,BL
					MOV AH,02H
					INT 21H
					CALL SUBTRACTION_
					RET
					
	LL009:
					CALL SUBTRACTION_
					RET
					
	LL8:
					CMP AL,2BH
					JNE LL008
					
					CALL SUBTRACTION_
					RET
					
	LL008:			MOV DL,AL
					MOV AH,02H
					INT 21H
					CALL SUBTRACTION_
					RET
					
	ansiszero1:			
					CALL CLEAR_ALL
					
					MOV SI,OFFSET Operand1
					
					MOV AL,00H
					MOV [SI],AL
					
					INC SI
					
					MOV AL,24H
					MOV [SI],AL
					
					RET
					
	; Operation for addition ends here
DO_ADDITION_ ENDP


DO_SUBTRACTION_ PROC NEAR
	; Operation for subtraction starts here
	
					CALL CLEAR_ALL
					
					MOV SI,OFFSET Op1sign
					MOV AL,[SI]
					
					MOV SI,0000H
					
					MOV SI,OFFSET Op2sign
					MOV BL,[SI]
					
					MOV SI,0000H
					
					CMP AL,BL
					JE LL12
					
						CMP AL,2BH
						JE LL13
						
							MOV DL,2DH
							MOV AH,02H
							INT 21H
							
							CALL ADDITION_
							RET
					
	LL13:					CALL ADDITION_
							RET
							
	LL12:
					CALL REMOVEZEROOP1_
					CALL REMOVEZEROOP2_
					
					CALL CLEAR_ALL
					
					MOV SI,OFFSET Operand1
					MOV AL,[SI]
					
					MOV DI,OFFSET Operand2
					MOV BL,[DI]
					
	op1gotobackope1:	
					INC SI
					MOV AL,[SI]
					INC CL
					CMP AL,24H
					JNE op1gotobackope1
					
					
	op2gotobackope2:	
					INC DI
					MOV BL,[DI]
					INC DL
					CMP BL,24H
					JNE op2gotobackope2
	
					CMP CL,DL
					JE LL17
					CMP CL,DL
					JA LL14
					
					MOV SI,0000H
					MOV DI,0000H
					MOV AX,0000H
					MOV BX,0000H
					
					MOV DI,OFFSET Op2sign
					MOV BL,[DI]
					
					CMP BL,2DH
					JE LL15
					
						MOV DL,2DH
						MOV AH,02H
						INT 21H
						
						CALL SUBTRACTION_
						RET
						
	LL15:
						CALL SUBTRACTION_
						RET
						
	LL14:
						
					MOV SI,0000H
					MOV DI,0000H
					MOV AX,0000H
					MOV BX,0000H
					
					MOV SI,OFFSET Op1sign
					MOV AL,[SI]
					
					CMP AL,2DH
					JE LL16
					

						CALL SUBTRACTION_
						RET
						
	LL16:
						MOV DL,2DH
						MOV AH,02H
						INT 21H
						
						CALL SUBTRACTION_
						RET
						
	LL17:
						CALL CLEAR_ALL
						
						MOV SI,OFFSET Operand1
						MOV CL,[SI]
						
						MOV DI,OFFSET Operand2
						MOV DL,[DI]
						
						CMP CL,DL
						JNE LL19
						
	cmpmoretimes11:
						INC SI
						MOV CL,[SI]
						INC DI
						MOV DL,[DI]
						CMP CL,24H
						JE ansiszero11
						CMP CL,DL
						JE cmpmoretimes11
						
	LL19:
						CMP CL,DL
						JA LL18
						
						MOV SI,0000H
						MOV DI,0000H
						MOV AX,0000H
						MOV BX,0000H
	
						MOV DI,OFFSET Op2sign
						MOV BL,[DI]
						
							CMP BL,2DH
							JE LL110
							
							MOV DL,2DH
							MOV AH,02H
							INT 21H
							
							CALL SUBTRACTION_
							RET
							
	LL110:
							CALL SUBTRACTION_
							RET
							
	LL18:
						MOV SI,0000H
						MOV DI,0000H
						MOV AX,0000H
						MOV BX,0000H
	
						MOV SI,OFFSET Op1sign
						MOV AL,[SI]
						
						CMP AL,2DH
						JE LL111
						
							CALL SUBTRACTION_
							RET
							
	LL111:
						MOV DL,2DH
						MOV AH,02H
						INT 21H
						
						CALL SUBTRACTION_
						RET
	
	ansiszero11:
						
					CALL CLEAR_ALL
					
					MOV SI,OFFSET Operand1
					
					MOV AL,00H
					MOV [SI],AL
					
					INC SI
					
					MOV AL,24H
					MOV [SI],AL
					
					RET
	
	; Operation for subtraction ends here
				
DO_SUBTRACTION_ ENDP



DO_MULTIPLICATION_ PROC NEAR
	CALL CLEAR_ALL
	
	MOV SI,OFFSET Op1sign
	MOV AL,[SI]
	
	MOV DI,OFFSET Op2sign
	MOV BL,[DI]
	
		CMP AL,BL
		JE LL21
		
		MOV DL,2DH
		MOV AH,02H
		INT 21H
		CALL MULTIPLICATION_
		RET
		
	LL21:
		CALL MULTIPLICATION_
		RET
		
DO_MULTIPLICATION_ ENDP



DO_DIVISION_ PROC NEAR
	CALL CLEAR_ALL

	MOV SI,OFFSET Op1sign
	MOV AL,[SI]
	
	MOV DI,OFFSET Op2sign
	MOV BL,[DI]
	
		CMP AL,BL
		JE LL331
		
		MOV DL,2DH
		MOV AH,02H
		INT 21H
		CALL DIVISION_
		RET
		
	LL331:
		CALL DIVISION_
		RET
		
DO_DIVISION_ ENDP



ADDITION_ PROC NEAR
				CALL CLEAR_ALL
				
				MOV SI,OFFSET Operand1
				MOV AL,[SI]
				
				MOV DI, OFFSET Operand2
				MOV BL,[DI]
					
					
	op1gotoback:	INC SI
					MOV AL,[SI]
					INC CL
					CMP AL,24H
					JNE op1gotoback
					DEC SI
					MOV AL,[SI]
					
					
	op2gotoback:	INC DI
					MOV BL,[DI]
					INC DL
					CMP BL,24H
					JNE op2gotoback
					DEC DI
					MOV BL,[DI]
					
	addagain:		ADD AL,BL
					MOV [SI],AL
					MOV [DI],AL
					DEC SI
					DEC DI
					MOV AL,[SI]
					MOV BL,[DI]
					DEC DL
					JZ  adjustans1
					DEC CL
					JNZ addagain
					
						
						CALL OP2TOOP1_
						CALL REMOVEZEROOP1_
						CALL ADJUSTNUMOP11_
						RET
						
					
	adjustans1:		
						CALL REMOVEZEROOP1_
						CALL ADJUSTNUMOP11_
						RET
	
					

ADDITION_ ENDP






SUBTRACTION_ PROC NEAR
	CALL CLEAR_ALL
		
		CALL REMOVEZEROOP1_
		CALL REMOVEZEROOP2_
		
				MOV SI,OFFSET Operand1
				MOV AL,[SI]
				
				MOV DI, OFFSET Operand2
				MOV BL,[DI]
					
					
	op1gotobacksub:	INC SI
					MOV AL,[SI]
					INC CL
					CMP AL,24H
					JNE op1gotobacksub
					DEC SI
					MOV AL,[SI]
					
					
	op2gotobacksub:	INC DI
					MOV BL,[DI]
					INC DL
					CMP BL,24H
					JNE op2gotobacksub
					DEC DI
					MOV BL,[DI]

					CMP CL,DL
					JE equalsub
					CMP CL,DL
					JA  directsub1
					
					
	sbbagain2:
					CMP BL,AL
					JB borrowsub2
					SUB BL,AL
					MOV [DI],BL
					DEC DI
					MOV BL,[DI]
					DEC SI
					MOV AL,[SI]
					DEC CL
					JNZ sbbagain2
					JZ retprocess2
					
	borrowsub2:		
					ADD BL,0AH
					SUB BL,AL
					MOV [DI],BL
					DEC DI
					MOV BL,[DI]
					SUB BL,01H
					MOV [DI],BL
					DEC SI
					MOV AL,[SI]
					DEC CL
					JNZ sbbagain2
					JZ retprocess2


	retprocess2:	
					CALL OP2TOOP1_
					CALL REMOVEZEROOP1_
					RET
					
					
					
					
	directsub1:
	sbbagain1:
					CMP AL,BL
					JB borrowsub1
					SUB AL,BL
					MOV [SI],AL
					DEC SI
					MOV AL,[SI]
					DEC DI
					MOV BL,[DI]
					DEC DL
					JNZ sbbagain1
					JZ retprocess1

	borrowsub1:		
					ADD AL,0AH
					SUB AL,BL
					MOV [SI],AL
					DEC SI
					MOV AL,[SI]
					SUB AL,01H
					MOV [SI],AL
					DEC DI
					MOV BL,[DI]
					DEC DL
					JNZ sbbagain1
					JZ retprocess1


	retprocess1:		
					CALL REMOVEZEROOP1_
					RET
	
	
	
	equalsub:		
					CALL CLEAR_ALL
									
						MOV SI,OFFSET Operand1
						MOV AL,[SI]
						
						MOV DI, OFFSET Operand2
						MOV BL,[DI]
						
						CMP AL,BL
						JNE firstnotsame1
						
	cmpmoretimes:
						INC SI
						MOV AL,[SI]
						INC CL
						INC DI
						MOV BL,[DI]
						INC DL
						CMP AL,24H
						JE ansiszero
						CMP AL,BL
						JE cmpmoretimes
						
						CMP AL,BL
						JA op1gotobacksub2
						JB op1gotobacksub3
						
	ansiszero:
						CALL CLEAR_ALL
						
						MOV SI,OFFSET Operand1
						MOV AL,[SI]
						
						MOV AL,00H
						MOV [SI],AL
						
						INC SI
						MOV AL,24H
						MOV [SI],AL
						
						RET
						
						
	firstnotsame1:
						CMP AL,BL
						JA op1firstbig1
						
		op1gotobacksub3:
						INC SI
						MOV AL,[SI]
						INC CL
						CMP AL,24H
						JNE op1gotobacksub3
						DEC SI
						MOV AL,[SI]
						
						
		op2gotobacksub3:	
						INC DI
						MOV BL,[DI]
						INC DL
						CMP BL,24H
						JNE op2gotobacksub3
						DEC DI
						MOV BL,[DI]
						
						
						
					
	sbbagain25:
					CMP BL,AL
					JB borrowsub25
					SUB BL,AL
					MOV [DI],BL
					DEC DI
					MOV BL,[DI]
					DEC SI
					MOV AL,[SI]
					DEC CL
					JNZ sbbagain25
					JZ retprocess25
					
	borrowsub25:		
					ADD BL,0AH
					SUB BL,AL
					MOV [DI],BL
					DEC DI
					MOV BL,[DI]
					SUB BL,01H
					MOV [DI],BL
					DEC SI
					MOV AL,[SI]
					DEC CL
					JNZ sbbagain25
					JZ retprocess25


	retprocess25:	
					CALL OP2TOOP1_
					CALL REMOVEZEROOP1_
					RET
						
						
						
						
	op1firstbig1:
						
					
		op1gotobacksub2:
						INC SI
						MOV AL,[SI]
						INC CL
						CMP AL,24H
						JNE op1gotobacksub2
						DEC SI
						MOV AL,[SI]
						
						
		op2gotobacksub2:	
						INC DI
						MOV BL,[DI]
						INC DL
						CMP BL,24H
						JNE op2gotobacksub2
						DEC DI
						MOV BL,[DI]
						
						
	sbbagain14:
					CMP AL,BL
					JB borrowsub14
					SUB AL,BL
					MOV [SI],AL
					DEC SI
					MOV AL,[SI]
					DEC DI
					MOV BL,[DI]
					DEC DL
					JNZ sbbagain14
					JZ retprocess14

	borrowsub14:		
					ADD AL,0AH
					SUB AL,BL
					MOV [SI],AL
					DEC SI
					MOV AL,[SI]
					SUB AL,01H
					MOV [SI],AL
					DEC DI
					MOV BL,[DI]
					DEC DL
					JNZ sbbagain14
					JZ retprocess14


	retprocess14:		
					CALL REMOVEZEROOP1_
					RET
						
						
					
	
	
SUBTRACTION_ ENDP



MULTIPLICATION_ PROC NEAR

	CALL REMOVEZEROOP1_
	CALL REMOVEZEROOP2_
	
	CALL CLEAR_ALL
	
	CALL ASC2HEX1_
	CALL ASC2HEX2_
	
	    MOV 	AX,MULT1
    	MUL 	MULT2
    	MOV 	resultt,AX
		
			PUSH BX
			PUSH DX
			MOV BX,0000H
			MOV DX,0000H
			MOV BX,OFFSET MULT1
			MOV [BX],DX
			MOV BX,0000H
			MOV DX,0000H
			MOV BX,OFFSET MULT2
			MOV [BX],DX
			POP DX
			POP BX
		
            	  CALL HEX2ASC_
            	
            	
		MOV DX,OFFSET resascii
		MOV AH,09H
		INT 21H
		
		CALL CLEAR_ALL
		OUTPUT NEWLINE
		CALL AGAIN_
	
	RET
MULTIPLICATION_ ENDP



DIVISION_ PROC NEAR

	CALL REMOVEZEROOP1_
	CALL REMOVEZEROOP2_

	CALL CLEAR_ALL
	
	CALL ASC2HEX1_
	CALL ASC2HEX2_
	
	    MOV 	AX,MULT1
    	DIV 	MULT2
    	MOV 	resultt,AX	
		
			PUSH BX
			PUSH DX
			MOV BX,0000H
			MOV DX,0000H
			MOV BX,OFFSET MULT1
			MOV [BX],DX
			MOV BX,0000H
			MOV DX,0000H
			MOV BX,OFFSET MULT2
			MOV [BX],DX
			POP DX
			POP BX
		
		
        CALL HEX2ASC_
            	
		MOV DX,OFFSET resascii
		MOV AH,09H
		INT 21H
		
		CALL CLEAR_ALL
		OUTPUT NEWLINE
		CALL AGAIN_
	
	RET
DIVISION_ ENDP







;Clear zero in front
REMOVEZEROOP1_ PROC NEAR
	CALL CLEAR_ALL
	
		MOV SI,OFFSET Operand1
		MOV AL,[SI]
		
				CMP AL,00H
				JNE Labeladj1
					
		Labeladj2:	
					INC SI
					MOV AL,[SI]
					
					CMP AL,00H
					JE Labeladj2
					
					MOV DI,OFFSET Temp1
					MOV BL,[DI]
					
		Labeladj3:	
					MOV [DI],AL
					INC SI
					MOV AL,[SI]
					INC DI
					CMP AL,24H
					JNE Labeladj3
					
					MOV BL,24H
					MOV [DI],BL
					
						CALL CLEAR_ALL
						
						MOV SI,OFFSET Temp1
						MOV AL,[SI]
						
						MOV DI,OFFSET Operand1
						MOV BL,[DI]
						
			Labeladj4:	
						MOV [DI],AL
						INC SI
						MOV Al,[SI]
						INC DI
						CMP AL,24H
						JNE Labeladj4
						
						MOV BL,24H
						MOV [DI],BL
						
						CALL CLEARTEMP1_
						RET
			
	Labeladj1:	
	
					RET
REMOVEZEROOP1_ ENDP



;clear temp
CLEARTEMP1_ PROC NEAR
	CALL CLEAR_ALL
	
				MOV SI,OFFSET Temp1
				MOV AL,[SI]
Labelct1:		MOV BL,00H
				MOV [SI],BL
				INC SI
				MOV AL,[SI]
				CMP AL,24H
				JNE Labelct1
				
				MOV BL,00H
				MOV [SI],BL
				
				CALL CLEAR_ALL
		

	RET
CLEARTEMP1_ ENDP


ADJUSTNUMOP11_ PROC NEAR
	CALL CLEAR_ALL
					
					MOV SI,OFFSET Operand1
					MOV AL,[SI]
					
	op1gotoback11:	INC SI
					MOV AL,[SI]
					INC CL
					CMP AL,24H
					JNE op1gotoback11
					DEC SI
					MOV AL,[SI]
					
		gotocmp1:
					CMP AL,09H
					JA mtenpone1
						DEC SI
						MOV AL,[SI]
						DEC CL
						JNZ gotocmp1
						JZ gotoreturn1
		mtenpone1:	
					SUB AL,0AH
					MOV [SI],AL
					DEC SI
					MOV AL,[SI]
					INC AL
					MOV [SI],AL
					DEC CL
					JNZ gotocmp1
					
					
					
					CALL CLEAR_ALL
					
					MOV DL,01H
					
					MOV SI,OFFSET Operand1
					MOV AL,[SI]
					MOV DI,OFFSET Temp1
					MOV BL,[DI]
					
					MOV [DI],DL
					INC DI
		movetotemp1:
					MOV [DI],AL
					INC SI
					MOV AL,[SI]
					INC DI
					CMP AL,24H
					JNE movetotemp1
					
					MOV BL,24H
					MOV [DI],BL
					
					CALL CLEAR_ALL
					
					MOV SI,OFFSET Temp1
					MOV AL,[SI]
					MOV DI,OFFSET Operand1
					MOV BL,[DI]
					
		temp1toop1:
					MOV [DI],AL
					INC SI
					MOV AL,[SI]
					INC DI
					CMP AL,24H
					JNE temp1toop1
					
					MOV BL,24H
					MOV [DI],BL
					
					CALL CLEARTEMP1_
					
					

		gotoreturn1: RET
ADJUSTNUMOP11_ ENDP






REMOVEZEROOP2_ PROC NEAR
	CALL CLEAR_ALL
	
		MOV SI,OFFSET Operand2
		MOV AL,[SI]
		
				CMP AL,00H
				JNE Labeladj12
					
		Labeladj22:	
					INC SI
					MOV AL,[SI]
					
					CMP AL,00H
					JE Labeladj22
					
					MOV DI,OFFSET Temp2
					MOV BL,[DI]
					
		Labeladj32:	
					MOV [DI],AL
					INC SI
					MOV AL,[SI]
					INC DI
					CMP AL,24H
					JNE Labeladj32
					
					MOV BL,24H
					MOV [DI],BL
					
						CALL CLEAR_ALL
						
						MOV SI,OFFSET Temp2
						MOV AL,[SI]
						
						MOV DI,OFFSET Operand2
						MOV BL,[DI]
						
			Labeladj42:	
						MOV [DI],AL
						INC SI
						MOV Al,[SI]
						INC DI
						CMP AL,24H
						JNE Labeladj42
						
						MOV BL,24H
						MOV [DI],BL
						
						CALL CLEARTEMP2_
						RET
			
	Labeladj12:	RET
REMOVEZEROOP2_ ENDP


CLEARTEMP2_ PROC NEAR
	CALL CLEAR_ALL
	
				MOV SI,OFFSET Temp2
				MOV AL,[SI]
Labelct2:		MOV BL,00H
				MOV [SI],BL
				INC SI
				MOV AL,[SI]
				CMP AL,24H
				JNE Labelct2
				
				MOV BL,00H
				MOV [SI],BL
				
				CALL CLEAR_ALL
		

	RET
CLEARTEMP2_ ENDP




ADJUSTNUMOP22_ PROC NEAR
	CALL CLEAR_ALL
					
					MOV SI,OFFSET Operand2
					MOV AL,[SI]
					
	op1gotoback22:	INC SI
					MOV AL,[SI]
					INC CL
					CMP AL,24H
					JNE op1gotoback22
					DEC SI
					MOV AL,[SI]
					
		gotocmp2:
					CMP AL,09H
					JA mtenpone2
						DEC SI
						MOV AL,[SI]
						DEC CL
						JNZ gotocmp2
						JZ gotoreturn2
		mtenpone2:	
					SUB AL,0AH
					MOV [SI],AL
					DEC SI
					MOV AL,[SI]
					INC AL
					MOV [SI],AL
					DEC CL
					JNZ gotocmp2
					
					
					
					CALL CLEAR_ALL
					
					MOV DL,01H
					
					MOV SI,OFFSET Operand2
					MOV AL,[SI]
					MOV DI,OFFSET Temp2
					MOV BL,[DI]
					
					MOV [DI],DL
					INC DI
		movetotemp2:
					MOV [DI],AL
					INC SI
					MOV AL,[SI]
					INC DI
					CMP AL,24H
					JNE movetotemp2
					
					MOV BL,24H
					MOV [DI],BL
					
					CALL CLEAR_ALL
					
					MOV SI,OFFSET Temp2
					MOV AL,[SI]
					MOV DI,OFFSET Operand2
					MOV BL,[DI]
					
		temp2toop2:
					MOV [DI],AL
					INC SI
					MOV AL,[SI]
					INC DI
					CMP AL,24H
					JNE temp2toop2
					
					MOV BL,24H
					MOV [DI],BL
					
					CALL CLEARTEMP2_
					
					
		gotoreturn2: RET
ADJUSTNUMOP22_ ENDP




OP1TOOP2_ PROC NEAR	
				CALL CLEAR_ALL

				
				MOV SI,OFFSET Operand2
				MOV AL,[SI]
				
				MOV DI, OFFSET Operand1
				MOV BL,[DI]
				
storebackans2:	MOV [SI],BL
				INC SI
				INC DI
				MOV BL,[DI]
				CMP BL,24H
				JNE storebackans2
				
				MOV AL,24H
				MOV [SI],AL
				
				RET
OP1TOOP2_ ENDP




OP2TOOP1_ PROC NEAR	
				CALL CLEAR_ALL

				
				MOV SI,OFFSET Operand1
				MOV AL,[SI]
				
				MOV DI, OFFSET Operand2
				MOV BL,[DI]
				
storebackans1:	MOV [SI],BL
				INC SI
				INC DI
				MOV BL,[DI]
				CMP BL,24H
				JNE storebackans1
				
				MOV AL,24H
				MOV [SI],AL
				
				RET
OP2TOOP1_ ENDP



ASC2HEX1_ PROC NEAR

			PUSH AX
			PUSH DX
			SUB 	DI,DI 		;CLEAR DI FOR THE BINARY(HEX) RESULT
			MOV 	SI,OFFSET Operand1   ; Number that  has the ASCII value
			SUB	CX,CX		;clear register CX
	DONECONL1:    
			MOV	CL,[SI]         ; move first ASCII vlaue
			INC	SI
			CMP	CL,24H          ; CHECK IF $
			JE	FINISH1
			MOV	AX,10           ;
			MUL	MULT1           ; Place holder FOR THE RESULT , initially =0
			ADD	AX,CX
			MOV	MULT1,AX
			JMP	DONECONL1

	FINISH1:
			POP DX
			POP AX
			
			RET
			
ASC2HEX1_ ENDP


ASC2HEX2_ PROC NEAR

			PUSH AX
			PUSH DX
			SUB DI,DI 		;CLEAR DI FOR THE BINARY(HEX) RESULT
			MOV SI,OFFSET Operand2   ; Number that  has the ASCII value
			SUB	CX,CX			;clear register CX
	DONECONL2:    
			MOV	CL,[SI]         ; move first ASCII vlaue
			INC	SI
			CMP	CL,24H          ; CHECK IF $
			JE	FINISH2
			MOV	AX,10D			
			MUL	MULT2			; Place holder FOR THE RESULT , initially =0
			ADD	AX,CX
			MOV	MULT2,AX
			JMP	DONECONL2

	FINISH2:			
			
			POP DX
			POP AX
			
			
			RET
			
ASC2HEX2_ ENDP



HEX2ASC_ PROC NEAR

	MOV AX, resultt
	MOV BX, offset resascii
	PUSH 10D
	MOV  CX, 10D
L1:
	MOV  DX, 0000H
	DIV  CX
	PUSH DX
	CMP  AX, 0000H
	JNZ  L1
	
L2:
 
	POP  DX
	CMP  DX, 10
	JE   L4
	ADD  DL, 30H
 
L3:
	MOV [BX], DL
	INC BX
	JMP L2
 
L4:
	MOV BYTE PTR[BX], '$'
	RET
			

HEX2ASC_ ENDP




OP1OPEOP2_ PROC NEAR
;Test the program
			CALL CLEAR_ALL

			MOV DX,OFFSET Operand1
				MOV AH,09H
				INT 21H
				
			OUTPUT NEWLINE
			CALL AGAIN_
				
	RET
OP1OPEOP2_ ENDP





END

