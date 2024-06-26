;===============================================================================
;HTALK - BARE MINIMUM TERMINAL INTERFACE
;
; CONSOLE TALKS TO ARBITRARY CHARACTER DEVICE.
;===============================================================================
;
; AUTHOR: TOM PLANO (TOMPLANO@PROTON.ME)
;
; USAGE:
;	HTALK $<CHAR_DEVICE_NUM>
;
;_______________________________________________________________________________
;
; CHANGE LOG:
;			I'VE NOTATED SECTIONS OF CODE THAT ARNT REQUIRED IF THIS APP IS
;			INCORPORATED INTO DBGMOD WITH A <OPT> TAG
;
;_______________________________________________________________________________
;
; TODO:
; 	SEE ENUM_DEV1 TODO
;				
;
;_______________________________________________________________________________
;
;===============================================================================
; DEFINITIONS
;===============================================================================
;
STKSIZ	.EQU	$FF
;
; HBIOS SYSTEM CALLS AND ID STRING ADDRESS
; 
ROMWBW_ID	.EQU		$FFFE	; ROMWBW ID STRING ADDRESS
HBIOS_SYS	.EQU		$FFF0 	; HBIOS SYSCALL ADDRESS

H_SYSGET	.EQU		$F8		;	GET SYSTEM INFO
H_CIOCNT	.EQU		$00		; GET CHAR DEV COUNT SUBFUNCTION

BF_CIOIN			.EQU		$00	; HBIOS CHAR INPUT 
BF_CIOOUT			.EQU		$01	; HBIOS CHAR OUTPUT 
BF_CIOIST			.EQU		$02	; HBIOS CHAR INPUT STATUS 
BF_CIOOST			.EQU		$03	; HBIOS CHAR OUTPUT STATUS 
BF_CIOINIT		.EQU		$04	; HBIOS CHAR I/O INIT 
BF_CIOQUERY		.EQU		$05	; HBIOS CHAR I/O QUERY 
BF_CIODEVICE	.EQU		$06	; HBIOS CHAR I/O DEVICE
;
; SUPPORTED HBIOS CIO DEVICE TYPES
; 
CIODEV_UART		.EQU		$00 ; 16C550 FAMILY SERIAL INTERFACE UART.ASM
CIODEV_ASCI		.EQU		$10 ; Z180 BUILT-IN SERIAL PORTS ASCI.ASM
CIODEV_TERM		.EQU		$20 ; TERMINAL ANSI.ASM
CIODEV_PRPCON	.EQU		$30 ; PROPIO SERIAL CONSOLE INTERFACE PRP.ASM
CIODEV_PPPCON	.EQU 		$40 ; PARPORTPROP SERIAL CONSOLE INTERFACE PPP.ASM
CIODEV_SIO		.EQU		$50 ; ZILOG SERIAL PORT INTERFACE SIO.ASM
CIODEV_ACIA		.EQU		$60 ; MC68B50 ASYNCHRONOUS INTERFACE ACIA.ASM
CIODEV_PIO		.EQU		$70 ; ZILOG PARALLEL INTERFACE CONTROLLER PIO.ASM
CIODEV_UF			.EQU		$80 ; FT232H-BASED ECB USB FIFO UF.ASM
CIODEV_DUART	.EQU		$90 ; SCC2681 FAMILY DUAL UART DUART.ASM
CIODEV_Z2U		.EQU		$A0 ; ZILOG Z280 BUILT-IN SERIAL PORTS Z2U.ASM
CIODEV_LPT		.EQU		$B0 ; PARALLEL I/O CONTROLLER LPT.ASM

; HBIOS CURRENT CONSOLE NUMBER
CIO_CONSOLE	.EQU	$80

; SPECIAL CHARS
CTRLC			.EQU	$03
CHR_BEL		.EQU	$07
CHR_CR		.EQU	$0D
CHR_LF		.EQU	$0A
CHR_BS		.EQU	$08
CHR_ESC		.EQU	$1B
CHR_DEL		.EQU	$7F

;
;===============================================================================
; BEGIN MAIN PROGRAM 
;===============================================================================
;
	.ORG	$0100
;	
; SETUP STACK (SAVE OLD VALUE)
;	<OPT> HANDLED BY DBGMON	
	LD		(STKSAV),SP
	LD		SP,STACK
	

;
; INITIALIZATION + STARTUP MESSAGE + HBIOS DETECT
;	<OPT> HANDLED BY DBGMON	
	CALL INIT_PROG
	JP NZ,EXIT
;
; LIST HBIOS DEV OPTIONS FOR REFERENCE
; ALSO GETS MAX CONN
;	
;	<OPT> THIS IS OPTIONAL BECAUSE IF A CHAR DEVICE DOESNT EXIST, WE NEVER READ OR
; WRITE TO IT, WE SIMPLY CALL CIOIST AND CIOOST OVER AND OVER ON IT, WITHOUT
;	EVER PUSHING DATA TO IT
	CALL	ENUM_DEV
	JP NZ,EXIT
;
; PARSE COMMAND LINE 
;
 	CALL	PARSE		
	JP NZ,EXIT
;
; RUN CONVERSTION WITH CHAR DEVICE
;
	CALL 	TALK
;
;  DONE
	JP		EXIT


;
; CLEAN UP AND RETURN TO CALLING PROCESS
;
EXIT:	
	CALL 	NEWLINE						; ...
	LD		HL,STR_EXITMSG	; LOAD EXIT STRING
	CALL	PRTSTR					;	PRINT IT
	CALL 	NEWLINE						; ...
	LD		SP,(STKSAV)			; RESET STACK
	RET										; RETURN TO CALLER
	

;
;===============================================================================
; END MAIN PROGRAM 
;===============================================================================
;

;
;===============================================================================
; BEGIN MAIN PROGRAM SUBROUTINES
;===============================================================================
;
	
INIT_PROG:
	LD		HL, STR_BANNER 	; LOAD WELCOME BANNER
	CALL	PRTSTR					;	PRINT IT
	CALL 	NEWLINE					;	...
	LD		HL,(ROMWBW_ID) 	; GET FIRST BYTE OF ROMWBW MARKER
	LD		A,(HL)					;	... THROUGH HL 
	CP		'W'							; MATCH?
	JP		NZ,NOTHBIOS			; ABORT WITH INVALID CONFIG BLOCK
	INC		HL							; NEXT BYTE (MARKER BYTE 2)
	LD		A,(HL)					; LOAD IT
	CP		~'W'						; MATCH?
	JP		NZ,NOTHBIOS			; ABORT WITH INVALID CONFIG BLOCK
	LD		HL,STR_HBIOS		; POINT TO HBIOS STR
	CALL	PRTSTR					; PRINT IT
	CALL 	NEWLINE					; ...
	RET
;
;	HBOIS NOT DETECTED, BAIL OUT W/ ERROR
;
NOTHBIOS:
	LD		HL,STR_BIOERR		; LOAD HBIOS NOT FOUND STR
	CALL	PRTSTR					; PRINT IT
	CALL 	NEWLINE					; ...
	AND 	$FF							; SET FLAGS
	RET

ENUM_DEV:
;
; CHAR COUNT HEADER
;
	LD 		HL,STR_DEVS_FOUND
	CALL 	PRTSTR
;
;GET COUNT OF CHAR UNITS
;
	LD 		B,H_SYSGET			; LOAD SYSGET HBIOS FUNCTION
	LD		C,H_CIOCNT			; LOAD SYSGET CHAR DEV COUNT SUBFUNCTION
	CALL 	HBIOS_SYS				; JUMP TO HBIOS
	OR		A								; SET FLAGS
	JP 		NZ, EXIT				; JUMP TO EXIT ON FAILED
	LD 		A,E							;	NUM CHAR DEVICES NOW IN A

	DEC 	A								; DEC NUM DEVICES TO BE	0 INDEXED
	LD		(CIODEV_CNT), A	; STORE BEFORE PRINT 
	LD		(CIODEV_MAX), A	; STORE BEFORE PRINT 
	INC A									; RESTORE NUM DEVICES VALUE

	CALL 	PRTHEX 					; PRINT NUMBER OF UNITS FOUND
	CALL 	NEWLINE						; ...

ENUM_DEV1:

	LD 		IX, TGT_DEV				
; TODO: H AND L DONT ALWAYS GET SET BY THE DRIVERS. FIND SOME WAY TO MASK
; THEM OUT IF THEY ARE THE SAME BEFORE AND AFTER THE CALL?
	LD 		B, BF_CIODEVICE		; LOAD HBIOS FUNCTION TO QUERRY DEVICE INFO
	LD		HL, CIODEV_CNT		; REQUEST A CHAR DEVICE
	LD		C, (HL)						; ...
	LD		(IX), C						; REMEMBER WHAT DEVICE WE ASKED FOR BEFORE BE
	CALL	HBIOS_SYS					; EXECUTE HBIOS SUBROUTINE
	OR		A									; SET FLAGS
	RET NZ									; RETURN FAILED
;
;	STORE RESULTS OF HBOIS DEVICE QUERRY
;
  LD 		A,C								; MOVE C TO A
	LD		(IX+1),	A					; STORE A DEVICE ATTRIBUTES, SKIP FIRST ENTRY
	LD		A,D
	LD		(IX+2),	A
	LD		A,E
	LD		(IX+3),	A
	LD		A,H
	LD		(IX+4),	A
	LD		A,L
	LD		(IX+5),	A
;
;	PRINT FORMATED DATA LOOP 
;
	LD 		B, $06 					;	PRINT THE 5 ELEMENTS OF DEV_STR_TBL
	LD		HL,DEV_STR_TBL	; TABLE BASE PTR

PLOOP_BASE:
	CALL 	PRTSTR					; PTRSTR INCREMENTS HL FOR US
	LD		A, (IX)
	CALL 	PRTHEX
	LD		A, '|'
	CALL 	COUT
	INC 	IX
	DJNZ	PLOOP_BASE

	CALL NEWLINE

	LD A, (CIODEV_CNT) 
	DEC A
	LD		(CIODEV_CNT), A
	JP P,	ENUM_DEV1 ; JUMP WHILE CIODEV_CNT >=0
	AND $00
	RET


;
; RUN CONVERSTION WITH CHAR DEVICE
;
TALK:	
;
; INIT PING PONG DEVICE POINTERS 
;
	LD 		IX,	USER_CON 	; LOAD VALUE AT ADDR USER_CON
	LD 		A, (IX) 			; LOAD VALUE AT ADDR USER_CON
	LD		(RF_DEV), A		; STORE TO ADDR RF_DEV
	LD		A, (IX+1)			;	LOAD VALUE AT ADDR TARGET_CON
	LD		(WT_DEV), A		;	STORE TO ADDR WT_DEV
;
; READ FROM RF_DEV -> WRITE TO WT_DEV
;
TALK_LOOP:
;
; CHECK FOR DATA ON RF_DEV
;
	LD		B,BF_CIOIST		; SET HBIOS FUNCTION TO RUN
	LD		HL, RF_DEV
	LD		C,(HL)		
	CALL	HBIOS_SYS			; CHECK FOR CHAR PENDING ON INPUT BUFFER USING HBIOS
	OR		A							;	SET FLAGS	 
	JP		Z,TALK_NEXT		; JUMP NO CHARACTERS  READY 
	JP		M,TALK_NEXT		;	JUMP ERROR ON READ 	
;
; EXEC READ FROM RF_DEV 
;
	LD		B,BF_CIOIN			; SET FUNCTION TO RUN
	LD		HL, RF_DEV
	LD		C,(HL)				; RETRIEVE CON_DEV_NUM TO READ/WRITE FROM ACTIVE CONSOLE
	CALL	HBIOS_SYS			; CHECK FOR CHAR PENDING USING HBIOS
	LD 		A,E						; MOVE RESULT TO A
	CP		CTRLC					; CHECK FOR EXIT REQUEST (CTRL+C)
	RET		Z							; IF SO, BAIL OUT
	PUSH	AF						; SAVE THE CHAR WE READ
;
; CHECK FOR SPACE ON WT_DEV
;
	LD		B,BF_CIOOST		; SET HBIOS FUNCTION TO RUN
	LD		HL, WT_DEV
	LD		C,(HL)	
	CALL	HBIOS_SYS			; CHECK FOR SPACE IN OUTPUT BUFFER USING HBIOS
	
	OR		A							; 0 OR 1 IS A VALID RETURN 
	JP		Z,TALK_NEXT		;	JUMP  NO SPACE
	JP		M,TALK_NEXT		; JUMP 	ERROR ON WRITE 
;
; EXEC WRITE TO WT_DEV
;
	LD		B,BF_CIOOUT		; SET HBIOS FUNCTION TO RUN
	LD		HL, WT_DEV
	LD		C,(HL)				; RETRIEVE TGT_DEV_NUM TO READ/WRITE FROM TARGET CHAR DEVICE
	;
	POP		AF						; RECOVER THE CHARACTER
	LD		E,A						; MOVE CHARACTER TO E
	CALL	HBIOS_SYS			; WRITE CHAR USING HBIOS

TALK_NEXT:
;
; SWAP RF_DEV  AND WT_DEV
;
	LD 		IX,	RF_DEV	 	; LOAD VALUE AT ADDR USER_CON
	LD 		A, (IX)				; LOAD VALUE AT ADDR RF_DEV
	LD 		B, (IX+1) 		; LOAD VALUE AT ADDR WT_DEV
	LD		(IX+1), A			;	STORE TO OLD RF_DEV TO  ADDR WT_DEV
	LD		A, B					;	MOVE OLD WT_DEV TO A 
	LD		(IX), A				;	STORE TO OLD WT_DEF TO  ADDR RF_DEV
	JP		TALK_LOOP			; LOOP

;
;===============================================================================
; END MAIN PROGRAM SUBROUTINES
;===============================================================================
;

;
;===============================================================================
; BEGIN ROUTINES THAT ARE NOT COMPATIBLE WITH DBGMON
;===============================================================================
;


PARSE:
;
	LD		HL,$81					; POINT TO START OF COMMAND TAIL (AFTER LENGTH BYTE)
	CALL	NONBLANK				; SKIP LEADING BLANKS, 
	CALL	HEXBYTE 
	JP		C,ERRHEXRD			; IF NOT, ERR
  LD		(TARGET_CON),A	; REQUESTED TARGET CONN 
	
	LD		B,A	; MOVE  TO B							

	LD		HL,CIODEV_MAX		; GRAB MAX VALUE OF TARGETCON
	LD		A,(HL)

	CP		B								; CHECK IF B<=A
	JP		M, 	ERROOR				; IF B>A,  and both are less then 80 then S SET, ERR
	JP		C,	ERROOR        ; IF B> 80 carry set instead (signed numbers problem)
	; swap A and B

	JP		PE, ERROOR					; IF B>A, C SET, ERR

	LD	HL, MSGTALKING		; PRINT TARGET DEVICE
	CALL PRTSTR
	LD A, B								; RETRIEVE TARGET CON
	CALL PRTHEX
	CALL  NEWLINE
	
	AND $00
	RET



;
;NOT COMPATIBLE WITH THE DBGMON FUNCTION OF THE SAME NAME
;
NONBLANK:
	LD	A,(HL)				; LOAD NEXT CHARACTER
	OR	A							; STRING ENDS WITH A NULL
	RET	Z							; IF NULL, RETURN POINTING TO NULL
	CP	' '						; CHECK FOR BLANK
	RET	NZ						; RETURN IF NOT BLANK
	INC	HL						; IF BLANK, INCREMENT CHARACTER POINTER
	JR	NONBLANK			; AND LOOP

;
;
;===============================================================================
; END ROUTINES THAT ARE NOT COMPATIBLE WITH DBGMON
;===============================================================================
;




;
;===============================================================================
; BEGIN ROUTINES THAT ARE LIFTED FROM  DBGMON
;===============================================================================
;


;
;	PRINT THE VALUE IN A IN HEX WITHOUT DESTROYING ANY REGISTERS
;
PRTHEX:
	PUSH	DE				; SAVE DE
	CALL	HEXASCII	; CONVERT VALUE IN A TO HEX CHARS IN DE
	LD	A,D					; GET THE HIGH ORDER HEX CHAR
	CALL	COUT			; PRINT IT
	LD	A,E					; GET THE LOW ORDER HEX CHAR
	CALL	COUT			; PRINT IT
	POP	DE					; RESTORE DE
	RET							; DONE

;
; CONVERT BINARY VALUE IN A TO ASCII HEX CHARACTERS IN DE
;

HEXASCII:
	LD	D,A				; SAVE A IN D
	CALL	HEXCONV	; CONVERT LOW NIBBLE OF A TO HEX
	LD	E,A				; SAVE IT IN E
	LD	A,D				; GET ORIGINAL VALUE BACK
	RLCA					; ROTATE HIGH ORDER NIBBLE TO LOW BITS
	RLCA
	RLCA
	RLCA
	CALL	HEXCONV	; CONVERT NIBBLE
	LD	D,A				; SAVE IT IN D
	RET						; DONE

;
; CONVERT LOW NIBBLE OF A TO ASCII HEX
;
HEXCONV:
	AND	$0F	     	; LOW NIBBLE ONLY
	ADD	A,$90
	DAA	
	ADC	A,$40
	DAA	
	RET
;


;
; ADD THE VALUE IN A TO HL (HL := HL + A)
;
ADDHL:
	ADD	A,L				; A := A + L
	LD	L,A				; PUT RESULT BACK IN L
	RET	NC				; IF NO CARRY, WE ARE DONE
	INC	H					; IF CARRY, INCREMENT H
	RET						; AND RETURN


;
;__________________________________________________________________________________________________
;
; UTILITY PROCS TO PRINT SINGLE CHARACTERS WITHOUT TRASHING ANY REGISTERS
;
;__________________________________________________________________________________________________
;
PC_SPACE:
	PUSH	AF
	LD	A,' '
	JR	PC_PRTCHR
PC_COLON:
	PUSH	AF
	LD	A,':'
	JR	PC_PRTCHR
PC_CR:
	PUSH	AF
	LD	A,CHR_CR
	JR	PC_PRTCHR

PC_LF:
	PUSH	AF
	LD	A,CHR_LF
	JR	PC_PRTCHR

PC_PRTCHR:
	CALL	COUT
	POP	AF
	RET

NEWLINE2:
	CALL	NEWLINE
NEWLINE:
	CALL	PC_CR
	CALL	PC_LF
	RET

PRTSTR:
	LD	A,(HL)
	INC	HL
	CP	'$'
	RET	Z
	CALL	COUT
	JR	PRTSTR

;
;__COUT_______________________________________________________________________
;
;	OUTPUT CHARACTER FROM A
;_____________________________________________________________________________
;
COUT:
	; SAVE ALL INCOMING REGISTERS
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
;
	; OUTPUT CHARACTER TO CONSOLE VIA HBIOS
	LD	E,A							; OUTPUT CHAR TO E
	LD	C,CIO_CONSOLE		; CONSOLE UNIT TO C
	LD	B,BF_CIOOUT			; HBIOS FUNC: OUTPUT CHAR
	CALL	HBIOS_SYS			; HBIOS OUTPUTS CHARACTER
;
	; RESTORE ALL REGISTERS
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
;__CIN________________________________________________________________________
;
;	INPUT CHARACTER TO A
;_____________________________________________________________________________
;
CIN:
	; SAVE INCOMING REGISTERS (AF IS OUTPUT)
	PUSH	BC
	PUSH	DE
	PUSH	HL
;
	; INPUT CHARACTER FROM CONSOLE VIA HBIOS
	LD	C,CIO_CONSOLE	; CONSOLE UNIT TO C
	LD	B,BF_CIOIN		; HBIOS FUNC: INPUT CHAR
	CALL	HBIOS_SYS		; HBIOS READS CHARACTER
	LD	A,E						; MOVE CHARACTER TO A FOR RETURN
;
	; RESTORE REGISTERS (AF IS OUTPUT)
	POP	HL
	POP	DE
	POP	BC
	RET
;
;__CST________________________________________________________________________
;
;	RETURN INPUT STATUS IN A (0 = NO CHAR, !=0 CHAR WAITING)
;_____________________________________________________________________________
;
CST:
	; SAVE INCOMING REGISTERS (AF IS OUTPUT)
	PUSH	BC
	PUSH	DE
	PUSH	HL
;
	; GET CONSOLE INPUT STATUS VIA HBIOS
	LD	C,CIO_CONSOLE		; CONSOLE UNIT TO C
	LD	B,BF_CIOIST			; HBIOS FUNC: INPUT STATUS
	CALL	HBIOS_SYS			; HBIOS RETURNS STATUS IN A
;
	; RESTORE REGISTERS (AF IS OUTPUT)
	POP	HL
	POP	DE
	POP	BC
	RET
;


;
;__ISHEX______________________________________________________________________
;
;	CHECK BYTE AT (HL) FOR HEX CHAR, RET Z IF SO, ELSE NZ
;_____________________________________________________________________________
;
ISHEX:
	LD	A,(HL)			; CHAR TO AS
	CP	'0'					; < '0'?
	JR	C,ISHEX1		; YES, NOT 0-9, CHECK A-F
	CP	'9' + 1			; > '9'
	JR	NC,ISHEX1		; YES, NOT 0-9, CHECK A-F
	XOR	A						; MUST BE 0-9, SET ZF
	RET							; AND DONE
ISHEX1:
	CP	'A'					; < 'A'?
	JR	C,ISHEX2		; YES, NOT A-F, FAIL
	CP	'F' + 1			; > 'F'
	JR	NC,ISHEX2		; YES, NOT A-F, FAIL
	XOR	A						; MUST BE A-F, SET ZF
	RET							; AND DONE
ISHEX2:
	OR	$FF					; CLEAR ZF
	RET							; AND DONE
;
;__HEXBYTE____________________________________________________________________
;
;	GET ONE BYTE OF HEX DATA FROM BUFFER IN HL, RETURN IN A
;_____________________________________________________________________________
;
HEXBYTE:
	LD	C,0					; INIT WORKING VALUE
HEXBYTE1:
	CALL	ISHEX			; DO WE HAVE A HEX CHAR?
	JR	NZ,HEXBYTE3	; IF NOT, WE ARE DONE
	LD	B,4					; SHIFT WORKING VALUE (C := C * 16)
HEXBYTE2:
	SLA	C						; SHIFT ONE BIT
	RET	C						; RETURN W/ CF SET INDICATING OVERFLOW ERROR
	DJNZ	HEXBYTE2	; LOOP FOR 4 BITS
	CALL	NIBL			; CONVERT HEX CHAR TO BINARY VALUE IN A & INC HL
	OR	C						; COMBINE WITH WORKING VALUE
	LD	C,A					; AND PUT BACK IN WORKING VALUE
	JR	HEXBYTE1		; DO ANOTHER CHARACTER
HEXBYTE3:
	LD	A,C					; WORKING VALUE TO A
	OR	A						; CLEAR CARRY
	RET		

;
;__NIBL_______________________________________________________________________
;
;	GET ONE BYTE OF HEX DATA FROM BUFFER IN HL, RETURN IN A
;_____________________________________________________________________________
;
NIBL:
	LD	A,(HL)		; GET K B. DATA
	INC	HL				; INC KB POINTER
	CP	40H				; TEST FOR ALPHA
	JR	NC,ALPH
	AND	0FH				; GET THE BITS
	RET
ALPH:
	AND	0FH				; GET THE BITS
	ADD	A,09H			; MAKE IT HEX A-F
	RET


;
;===============================================================================
; END ROUTINES THAT ARE LIFTED FROM  DBGMON
;===============================================================================
;




;
;===============================================================================
; ERROR RESPONCES
;===============================================================================
;

ERROOR:						; REQUESTED DEV OUT OF RANGE (SYNTAX)
	CALL	NEWLINE
	LD		A, 'R'
	CALL	COUT	
	LD 		HL,TARGET_CON
	LD    A,(HL)
	CALL	PRTHEX


	LD		A, ':'
	CALL	COUT
	LD		A, 'M'
	CALL	COUT
	LD 		HL,CIODEV_MAX
	LD    A,(HL)
	CALL	PRTHEX

	LD	HL,MSGOOR
	JR	ERROR
ERRHEXRD:					; COMMAND HEX READ ERROR (SYNTAX)
	LD	HL,MSGHEXRD
	JR	ERROR
ERRUSE:						; COMMAND USAGE ERROR (SYNTAX)
	LD	HL,MSGUSE
	JR	ERROR
ERRPRM:						; COMMAND PARAMETER ERROR (SYNTAX)
	LD	HL,MSGPRM
	JR	ERROR
ERROR:						; PRINT ERROR STRING AND RETURN ERROR SIGNAL
	CALL	NEWLINE		; PRINT NEWLINE
	CALL	PRTSTR		; PRINT ERROR STRING
	OR	$FF					; SIGNAL ERROR
	RET							; DONE

;===============================================================================
; STORAGE SECTION
;===============================================================================
;

; CHAR DEV COUNT 
CIODEV_CNT	.DB	$0
CIODEV_MAX	.DB	$0

;TALK LOOP DATA, DEFAULT TO LOOPBACK
USER_CON		.DB $80
TARGET_CON	.DB $80

; PING PONG POINTERS
RF_DEV			.DB 0
WT_DEV			.DB 0

; TARGET CHARACTER DEVICE DATA
TGT_DEV:
	.DB	0		; HBIOS CHAR NUM
	.DB	0		; C: DEVICE ATTRIBUTES
	.DB	0		; D: DEVICE TYPE
	.DB	0		; E: DEVICE NUMBER
	.DB	0		; H: DEVICE MODE
	.DB	0		; L: DEVICE I/O BASE ADDRESS

; STRING LITERALS 
MSGUSE			.TEXT	"USAGE: HTALK <CIO_DEV_ID>$"
MSGPRM			.TEXT	"PARAMETER ERROR$"
MSGOOR			.TEXT	"CIO VAL TOO LARGE$"
MSGHEXRD		.TEXT	"HEX READ ERR$"
MSGTALKING	.TEXT	"CONNECTING TO CHAR:$"


DEV_STR_TBL:
	.TEXT "CHAR:$"
	.TEXT "ATTR:$"
	.TEXT "TYPE:$"
	.TEXT "NUMB:$"
	.TEXT "MODE:$"
	.TEXT "ADDR:$"

STR_DEVS_FOUND	.TEXT "NUM CHAR DEVICES FOUND - $"
STR_EXITMSG	.TEXT "HTALK DONE$"
STR_BANNER	.TEXT	"HTALK V1.0 (CTRL-C TO EXIT)$"
STR_HBIOS	.TEXT "HBIOS DETECTED$"
STR_BIOERR	.TEXT	"*** UNKNOWN BIOS	-	BAILING OUT ***$"
	
STKSAV	.DW	0		; STACK POINTER SAVED AT START
	.FILL	STKSIZ,0	; STACK
STACK	.EQU	$		; STACK TOP
;
	.END
