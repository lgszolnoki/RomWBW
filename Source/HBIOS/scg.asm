;======================================================================
;	N8 VDU DRIVER FOR SBC PROJECT
;
;	WRITTEN BY: DOUGLAS GOODALL
;	UPDATED BY: WAYNE WARTHEN -- 4/7/2013
;======================================================================
;
; TODO:
;   - IMPLEMENT SET CURSOR STYLE (VDASCS) FUNCTION?
;   - IMPLEMENT ALTERNATE DISPLAY MODES?
;   - IMPLEMENT DYNAMIC READ/WRITE OF CHARACTER BITMAP DATA?
;
;======================================================================
; SCG DRIVER - CONSTANTS
;======================================================================
;
SCG_CMDREG	.EQU	N8_BASE + $19	; READ STATUS / WRITE REG SEL
SCG_DATREG	.EQU	N8_BASE + $18	; READ/WRITE DATA
;
SCG_ROWS	.EQU	24
SCG_COLS	.EQU	40
;
; BELOW WAS TUNED FOR N8 AT 18MHZ WITH 3 IO WAIT STATES
; WILL NEED TO BE MODIFIED FOR DIFFERENT ACCESS SPEEDS
; IF YOU SEE SCREEN CORRUPTION, ADJUST THIS!!!
;
#DEFINE		SCG_IODELAY	NOP \ NOP \ NOP \ NOP \ NOP \ NOP
;
;======================================================================
; SCG DRIVER - INITIALIZATION
;======================================================================
;
SCG_INIT:
	PRTS("SCG: IO=0x$")
	LD	A,SCG_DATREG
	CALL	PRTHEXBYTE
;
	CALL 	SCG_CRTINIT		; SETUP THE SCG CHIP REGISTERS
	CALL	SCG_LOADFONT		; LOAD FONT DATA FROM ROM TO SCG STRORAGE
;
	; ADD OURSELVES TO CIO DISPATCH TABLE
	LD	B,0			; PHYSICAL UNIT IS ZERO
	LD	C,CIODEV_SCG		; DEVICE TYPE
	LD	DE,0			; UNIT DATA BLOB ADDRESS
	CALL	CIO_ADDENT		; ADD ENTRY, A := UNIT ASSIGNED
	;LD	(SCG_CIOUNIT),A	; SAVE IT LOCALLY
	LD	(HCB + HCB_CRTDEV),A	; SET OURSELVES AS THE CRT DEVICE
	
	LD	D,VDAEMU		; DEFAULT EMULATION
	LD	E,0			; VIDEO MODE = 0
	JP	SCG_VDAINI
;	
;======================================================================
; SCG DRIVER - CHARACTER I/O (CIO) DISPATCHER AND FUNCTIONS
;======================================================================
;
SCG_DISPCIO:
	JP	PANIC
SCG_CIODISPADR	.EQU	$ - 2
;	
;======================================================================
; SCG DRIVER - VIDEO DISPLAY ADAPTER (VDA) DISPATCHER AND FUNCTIONS
;======================================================================
;
SCG_DISPATCH:
	LD	A,B		; GET REQUESTED FUNCTION
	AND	$0F		; ISOLATE SUB-FUNCTION

	JP	Z,SCG_VDAINI	; $40
	DEC	A
	JP	Z,SCG_VDAQRY	; $41
	DEC	A
	JP	Z,SCG_VDARES	; $42
	DEC	A
	JP	Z,SCG_VDASCS	; $43
	DEC	A
	JP	Z,SCG_VDASCP	; $44
	DEC	A
	JP	Z,SCG_VDASAT	; $45
	DEC	A
	JP	Z,SCG_VDASCO	; $46
	DEC	A
	JP	Z,SCG_VDAWRC	; $47
	DEC	A
	JP	Z,SCG_VDAFIL	; $48
	DEC	A
	JP	Z,SCG_VDACPY	; $49
	DEC	A
	JP	Z,SCG_VDASCR	; $4A
	DEC	A
	JP	Z,PPK_STAT	; $4B
	DEC	A
	JP	Z,PPK_FLUSH	; $4C
	DEC	A
	JP	Z,PPK_READ	; $4D
	CALL	PANIC

SCG_VDAINI:
	; RESET VDA
	PUSH	DE			; SAVE EMULATION TYPE (IN D)
	CALL	SCG_VDARES		; RESET VDA
	POP	DE			; RECOVER EMULATION TYPE

	; INITIALIZE EMULATION
	LD	B,D			; EMULATION TYPE TO B
	;LD	A,(SCG_CIOUNIT)		; CIO UNIT NUMBER
	;LD	C,A			; ... IS PASSED IN C
	LD	C,CIODEV_SCG		; PASS OUR DEVICE TYPE IN C
	LD	DE,SCG_DISPATCH		; DISPATCH ADDRESS TO DE
	CALL	EMU_INIT		; INITIALIZE EMULATION, DE := CIO DISPATCHER
	LD	(SCG_CIODISPADR),DE	; SAVE EMULATORS CIO DISPATCH INTERFACE ADDRESS

	XOR	A			; SIGNAL SUCCESS
	RET


SCG_VDAQRY:
	LD	C,$00		; MODE ZERO IS ALL WE KNOW
	LD	D,SCG_ROWS	; ROWS
	LD	E,SCG_COLS	; COLS
	LD	HL,0		; EXTRACTION OF CURRENT BITMAP DATA NOT SUPPORTED YET
	XOR	A		; SIGNAL SUCCESS
	RET
	
SCG_VDARES:
	LD	DE,0			; ROW = 0, COL = 0
	CALL	SCG_XY			; SEND CURSOR TO TOP LEFT
	LD	A,' '			; BLANK THE SCREEN
	LD	DE,SCG_ROWS * SCG_COLS	; FILL ENTIRE BUFFER
	CALL	SCG_FILL		; DO IT
	LD	DE,0			; ROW = 0, COL = 0
	CALL	SCG_XY			; SEND CURSOR TO TOP LEFT
	XOR	A
	DEC	A
	LD	(SCG_CURSAV),A
	CALL	SCG_SETCUR		; SET CURSOR
	
	XOR	A			; SIGNAL SUCCESS
	RET
	
SCG_VDASCS:
	CALL	PANIC		; NOT IMPLEMENTED (YET)
	
SCG_VDASCP:
	CALL	SCG_CLRCUR
	CALL	SCG_XY		; SET CURSOR POSITION
	CALL	SCG_SETCUR
	XOR	A		; SIGNAL SUCCESS
	RET
	
SCG_VDASAT:
	XOR	A		; NOT POSSIBLE, JUST SIGNAL SUCCESS
	RET
	
SCG_VDASCO:
	XOR	A		; NOT POSSIBLE, JUST SIGNAL SUCCESS
	RET
	
SCG_VDAWRC:
	CALL	SCG_CLRCUR	; CURSOR OFF
	LD	A,E		; CHARACTER TO WRITE GOES IN A
	CALL	SCG_PUTCHAR	; PUT IT ON THE SCREEN
	CALL	SCG_SETCUR
	XOR	A		; SIGNAL SUCCESS
	RET
	
SCG_VDAFIL:
	CALL	SCG_CLRCUR
	LD	A,E		; FILL CHARACTER GOES IN A
	EX	DE,HL		; FILL LENGTH GOES IN DE
	CALL	SCG_FILL	; DO THE FILL
	CALL	SCG_SETCUR
	XOR	A		; SIGNAL SUCCESS
	RET

SCG_VDACPY:
	CALL	SCG_CLRCUR
	; LENGTH IN HL, SOURCE ROW/COL IN DE, DEST IS SCG_POS
	; BLKCPY USES: HL=SOURCE, DE=DEST, BC=COUNT
	PUSH	HL		; SAVE LENGTH
	CALL	SCG_XY2IDX	; ROW/COL IN DE -> SOURCE ADR IN HL
	POP	BC		; RECOVER LENGTH IN BC
	LD	DE,(SCG_POS)	; PUT DEST IN DE
	CALL	SCG_BLKCPY	; DO A BLOCK COPY
	CALL	SCG_SETCUR
	XOR	A
	RET
	
SCG_VDASCR:
	CALL	SCG_CLRCUR
SCG_VDASCR0:
	LD	A,E		; LOAD E INTO A
	OR	A		; SET FLAGS
	JR	Z,SCG_VDASCR2	; IF ZERO, WE ARE DONE
	PUSH	DE		; SAVE E
	JP	M,SCG_VDASCR1	; E IS NEGATIVE, REVERSE SCROLL
	CALL	SCG_SCROLL	; SCROLL FORWARD ONE LINE
	POP	DE		; RECOVER E
	DEC	E		; DECREMENT IT
	JR	SCG_VDASCR0	; LOOP
SCG_VDASCR1:
	CALL	SCG_RSCROLL	; SCROLL REVERSE ONE LINE
	POP	DE		; RECOVER E
	INC	E		; INCREMENT IT
	JR	SCG_VDASCR0	; LOOP
SCG_VDASCR2:
	CALL	SCG_SETCUR
	XOR	A
	RET
;
;======================================================================
; SCG DRIVER - PRIVATE DRIVER FUNCTIONS
;======================================================================
;
;----------------------------------------------------------------------
; SET TMS9918 REGISTER VALUE
;   SCG_SET WRITES VALUE IN A TO VDU REGISTER SPECIFIED IN C
;----------------------------------------------------------------------
;
SCG_SET:
	OUT	(SCG_CMDREG),A		; WRITE IT
	SCG_IODELAY
	LD	A,C			; GET THE DESIRED REGISTER
	OR	$80			; SET BIT 7 
	OUT	(SCG_CMDREG),A		; SELECT THE DESIRED REGISTER
	SCG_IODELAY
	RET
;
;----------------------------------------------------------------------
; SET TMS9918 READ/WRITE ADDRESS
;   SCG_WR SETS TMS9918 TO BEGIN WRITING TO ADDRESS SPECIFIED IN HL
;   SCG_RD SETS TMS9918 TO BEGIN READING TO ADDRESS SPECIFIED IN HL
;----------------------------------------------------------------------
;
SCG_WR:
	PUSH	HL
	SET	6,H			; SET WRITE BIT
	CALL	SCG_RD
	POP	HL
	RET
;
SCG_RD:
	LD	A,L
	OUT	(SCG_CMDREG),A
	SCG_IODELAY
	LD	A,H
	OUT	(SCG_CMDREG),A
	SCG_IODELAY
	RET
;
;----------------------------------------------------------------------
; MOS 8563 DISPLAY CONTROLLER CHIP INITIALIZATION
;----------------------------------------------------------------------
;
SCG_CRTINIT:
	; SET WRITE ADDRESS TO $0
	LD	HL,0
	CALL	SCG_WR
;
	; FILL ENTIRE RAM CONTENTS
	LD	DE,$4000
SCG_CRTINIT1:
	XOR	A
	OUT	(SCG_DATREG),A
	DEC	DE
	LD	A,D
	OR	E
	JR	NZ,SCG_CRTINIT1
;
	; INITIALIZE VDU REGISTERS
    	LD 	C,0			; START WITH REGISTER 0
	LD	B,SCG_INIT9918LEN	; NUMBER OF REGISTERS TO INIT
    	LD 	HL,SCG_INIT9918		; HL = POINTER TO THE DEFAULT VALUES
SCG_CRTINIT2:
	LD	A,(HL)			; GET VALUE
	CALL	SCG_SET			; WRITE IT
	INC	HL			; POINT TO NEXT VALUE
	INC	C			; POINT TO NEXT REGISTER
	DJNZ	SCG_CRTINIT2		; LOOP
    	RET
;
;----------------------------------------------------------------------
; LOAD FONT DATA
;----------------------------------------------------------------------
;
SCG_LOADFONT:
	; SET WRITE ADDRESS TO $800
	LD	HL,$800
	CALL	SCG_WR
;
	; FILL $800 BYTES FROM FONTDATA
	LD	HL,SCG_FONTDATA
	LD	DE,$100 * 8
SCG_LOADFONT1:
	LD	B,8
SCG_LOADFONT2:
	LD	A,(HL)
	PUSH	AF
	INC	HL
	DJNZ	SCG_LOADFONT2
;
	LD	B,8
SCG_LOADFONT3:
	POP	AF
	OUT	(SCG_DATREG),A
	DEC	DE
	DJNZ	SCG_LOADFONT3
;
	LD	A,D
	OR	E
	JR	NZ,SCG_LOADFONT1
;
	RET
;
;----------------------------------------------------------------------
; VIRTUAL CURSOR MANAGEMENT
;   SCG_SETCUR CONFIGURES AND DISPLAYS CURSOR AT CURRENT CURSOR LOCATION
;   SCG_CLRCUR REMOVES THE CURSOR
;
; VIRTUAL CURSOR IS GENERATED BY DYNAMICALLY CHANGING FONT GLYPH
; FOR CHAR 255 TO BE THE INVERSE OF THE GLYPH OF THE CHARACTER UNDER
; THE CURRENT CURSOR POSITION.  THE CHARACTER CODE IS THEN SWITCH TO
; THE VALUE 255 AND THE ORIGINAL VALUE IS SAVED.  WHEN THE DISPLAY
; NEEDS TO BE CHANGED THE PROCESS IS UNDONE.  IT IS ESSENTIAL THAT
; ALL DISPLAY CHANGES BE BRACKETED WITH CALLS TO SCG_CLRCUR PRIOR TO
; CHANGES AND SCG_SETCUR AFTER CHANGES.
;----------------------------------------------------------------------
;
SCG_SETCUR:
	PUSH	HL			; PRESERVE HL
	PUSH	DE			; PRESERVE DE
	LD	HL,(SCG_POS)		; GET CURSOR POSITION
	CALL	SCG_RD			; SETUP TO READ VDU BUF
	IN	A,(SCG_DATREG)		; GET REAL CHAR UNDER CURSOR
	SCG_IODELAY			; DELAY
	PUSH	AF			; SAVE THE CHARACTER
	CALL	SCG_WR			; SETUP TO WRITE TO THE SAME PLACE
	LD	A,$FF			; REPLACE REAL CHAR WITH 255
	OUT	(SCG_DATREG),A		; DO IT
	SCG_IODELAY			; DELAY
	POP	AF			; RECOVER THE REAL CHARACTER
	LD	B,A			; PUT IT IN B
	LD	A,(SCG_CURSAV)		; GET THE CURRENTLY SAVED CHAR
	CP	B			; COMPARE TO CURRENT
	JR	Z,SCG_SETCUR3		; IF EQUAL, BYPASS EXTRA WORK
	LD	A,B			; GET REAL CHAR BACK TO A
	LD	(SCG_CURSAV),A		; SAVE IT
	; GET THE GLYPH DATA FOR REAL CHARACTER
	LD	HL,0			; ZERO HL
	LD	L,A			; HL IS NOW RAW CHAR INDEX
	LD	B,3			; LEFT SHIFT BY 3 BITS
SCG_SETCUR0:	; MULT BY 8 FOR FONT INDEX
	SLA	L			; SHIFT LSB INTO CARRY
	RL	H			; SHFT MSB FROM CARRY
	DJNZ	SCG_SETCUR0		; LOOP 3 TIMES
	LD	DE,$800			; OFFSET TO START OF FONT TABLE
	ADD	HL,DE			; ADD TO FONT INDEX
	CALL	SCG_RD			; SETUP TO READ GLYPH
	LD	B,8			; 8 BYTES
	LD	HL,SCG_BUF		; INTO BUFFER
SCG_SETCUR1:	; READ GLYPH LOOP
	IN	A,(SCG_DATREG)		; GET NEXT BYTE
	SCG_IODELAY			; IO DELAY
	LD	(HL),A			; SAVE VALUE IN BUF
	INC	HL			; BUMP BUF POINTER
	DJNZ	SCG_SETCUR1		; LOOP FOR 8 BYTES
;
	; NOW WRITE INVERTED GLYPH INTO FONT INDEX 255
	LD	HL,$800 + (255 * 8)	; LOC OF GLPYPH DATA FOR CHAR 255
	CALL	SCG_WR			; SETUP TO WRITE THE INVERTED GLYPH
	LD	B,8			; 8 BYTES PER GLYPH
	LD	HL,SCG_BUF		; POINT TO BUFFER
SCG_SETCUR2:	; WRITE INVERTED GLYPH LOOP
	LD	A,(HL)			; GET THE BYTE
	INC	HL			; BUMP THE BUF POINTER
	XOR	$FF			; INVERT THE VALUE
	OUT	(SCG_DATREG),A		; WRITE IT TO VDU
	SCG_IODELAY			; IO DELAY
	DJNZ	SCG_SETCUR2		; LOOP FOR ALL 8 BYTES OF GLYPH
;
SCG_SETCUR3:	; RESTORE REGISTERS AND RETURN
	POP	DE			; RECOVER DE
	POP	HL			; RECOVER HL
	RET				; RETURN
;
;
;
SCG_CLRCUR:	; REMOVE VIRTUAL CURSOR FROM SCREEN
	PUSH	HL			; SAVE HL
	LD	HL,(SCG_POS)		; POINT TO CURRENT CURSOR POS
	CALL	SCG_WR			; SET UP TO WRITE TO VDU
	LD	A,(SCG_CURSAV)		; GET THE REAL CHARACTER
	OUT	(SCG_DATREG),A		; WRITE IT
	SCG_IODELAY			; IO DELAY
	POP	HL			; RECOVER HL
	RET				; RETURN
;
;----------------------------------------------------------------------
; SET CURSOR POSITION TO ROW IN D AND COLUMN IN E
;----------------------------------------------------------------------
;
SCG_XY:
	CALL	SCG_XY2IDX		; CONVERT ROW/COL TO BUF IDX
	LD	(SCG_POS),HL		; SAVE THE RESULT (DISPLAY POSITION)
	RET
;
;----------------------------------------------------------------------
; CONVERT XY COORDINATES IN DE INTO LINEAR INDEX IN HL
; D=ROW, E=COL
;----------------------------------------------------------------------
;
SCG_XY2IDX:
	LD	A,E			; SAVE COLUMN NUMBER IN A
	LD	H,D			; SET H TO ROW NUMBER
	LD	E,SCG_COLS		; SET E TO ROW LENGTH
	CALL	MULT8			; MULTIPLY TO GET ROW OFFSET
	LD	E,A			; GET COLUMN BACK
	ADD	HL,DE			; ADD IT IN
	RET				; RETURN
;
;----------------------------------------------------------------------
; WRITE VALUE IN A TO CURRENT VDU BUFFER POSTION, ADVANCE CURSOR
;----------------------------------------------------------------------
;
SCG_PUTCHAR:
	PUSH	AF			; SAVE CHARACTER
	LD	HL,(SCG_POS)		; LOAD CURRENT POSITION INTO HL
	CALL	SCG_WR			; SET THE WRITE ADDRESS
	POP	AF			; RECOVER CHARACTER TO WRITE
	OUT	(SCG_DATREG),A		; WRITE THE CHARACTER
	LD	HL,(SCG_POS)		; LOAD CURRENT POSITION INTO HL
	INC	HL
	LD	(SCG_POS),HL
	RET
;
;----------------------------------------------------------------------
; FILL AREA IN BUFFER WITH SPECIFIED CHARACTER AND CURRENT COLOR/ATTRIBUTE
; STARTING AT THE CURRENT FRAME BUFFER POSITION
;   A: FILL CHARACTER
;   DE: NUMBER OF CHARACTERS TO FILL
;----------------------------------------------------------------------
;
SCG_FILL:
	LD	C,A			; SAVE THE CHARACTER TO WRITE
	LD	HL,(SCG_POS)		; SET STARTING POSITION
	CALL	SCG_WR			; SET UP FOR WRITE
;
SCG_FILL1:
	LD	A,C			; RECOVER CHARACTER TO WRITE
	OUT	(SCG_DATREG),A
	SCG_IODELAY
	DEC	DE
	LD	A,D
	OR	E
	JR	NZ,SCG_FILL1
;
	RET
;
;----------------------------------------------------------------------
; SCROLL ENTIRE SCREEN FORWARD BY ONE LINE (CURSOR POSITION UNCHANGED)
;----------------------------------------------------------------------
;
SCG_SCROLL:
	LD	HL,0			; SOURCE ADDRESS OF CHARACER BUFFER
	LD	C,SCG_ROWS - 1		; SET UP LOOP COUNTER FOR ROWS - 1
;
SCG_SCROLL0:	; READ LINE THAT IS ONE PAST CURRENT DESTINATION
	PUSH	HL			; SAVE CURRENT DESTINATION
	LD	DE,SCG_COLS
	ADD	HL,DE			; POINT TO NEXT ROW SOURCE
	CALL	SCG_RD			; SET UP TO READ
	LD	DE,SCG_BUF
	LD	B,SCG_COLS
SCG_SCROLL1:
	IN	A,(SCG_DATREG)
	SCG_IODELAY
	LD	(DE),A
	INC	DE
	DJNZ	SCG_SCROLL1
	POP	HL			; RECOVER THE DESTINATION
;	
	; WRITE THE BUFFERED LINE TO CURRENT DESTINATION
	CALL	SCG_WR			; SET UP TO WRITE
	LD	DE,SCG_BUF
	LD	B,SCG_COLS
SCG_SCROLL2:
	LD	A,(DE)
	OUT	(SCG_DATREG),A
	SCG_IODELAY
	INC	DE
	DJNZ	SCG_SCROLL2
;
	; BUMP TO NEXT LINE
	LD	DE,SCG_COLS
	ADD	HL,DE
	DEC	C			; DECREMENT ROW COUNTER
	JR	NZ,SCG_SCROLL0		; LOOP THRU ALL ROWS
;
	; FILL THE NEWLY EXPOSED BOTTOM LINE
	CALL	SCG_WR
	LD	A,' '
	LD	B,SCG_COLS
SCG_SCROLL3:
	OUT	(SCG_DATREG),A
	SCG_IODELAY
	DJNZ	SCG_SCROLL3
;
	RET
;
;----------------------------------------------------------------------
; REVERSE SCROLL ENTIRE SCREEN BY ONE LINE (CURSOR POSITION UNCHANGED)
;----------------------------------------------------------------------
;
SCG_RSCROLL:
	LD	HL,SCG_COLS * (SCG_ROWS - 1)
	LD	C,SCG_ROWS - 1
;
SCG_RSCROLL0:	; READ THE LINE THAT IS ONE PRIOR TO CURRENT DESTINATION
	PUSH	HL			; SAVE THE DESTINATION ADDRESS
	LD	DE,-SCG_COLS
	ADD	HL,DE			; SET SOURCE ADDRESS
	CALL	SCG_RD			; SET UP TO READ
	LD	DE,SCG_BUF		; POINT TO BUFFER
	LD	B,SCG_COLS		; LOOP FOR EACH COLUMN
SCG_RSCROLL1:
	IN	A,(SCG_DATREG)		; GET THE CHAR
	SCG_IODELAY			; RECOVER
	LD	(DE),A			; SAVE IN BUFFER
	INC	DE			; BUMP BUFFER POINTER
	DJNZ	SCG_RSCROLL1		; LOOP THRU ALL COLS
	POP	HL			; RECOVER THE DESTINATION ADDRESS
;
	; WRITE THE BUFFERED LINE TO CURRENT DESTINATION
	CALL	SCG_WR			; SET THE WRITE ADDRESS
	LD	DE,SCG_BUF		; POINT TO BUFFER
	LD	B,SCG_COLS		; INIT LOOP COUNTER
SCG_RSCROLL2:
	LD	A,(DE)			; LOAD THE CHAR
	OUT	(SCG_DATREG),A		; WRITE TO SCREEN
	SCG_IODELAY			; DELAY
	INC	DE			; BUMP BUF POINTER
	DJNZ	SCG_RSCROLL2		; LOOP THRU ALL COLS
;
	; BUMP TO THE PRIOR LINE
	LD	DE,-SCG_COLS		; LOAD COLS (NEGATIVE)
	ADD	HL,DE			; BACK UP THE ADDRESS
	DEC	C			; DECREMENT ROW COUNTER
	JR	NZ,SCG_RSCROLL0		; LOOP THRU ALL ROWS
;
	; FILL THE NEWLY EXPOSED BOTTOM LINE
	CALL	SCG_WR
	LD	A,' '
	LD	B,SCG_COLS
SCG_RSCROLL3:
	OUT	(SCG_DATREG),A
	SCG_IODELAY
	DJNZ	SCG_RSCROLL3
;
	RET
;
;----------------------------------------------------------------------
; BLOCK COPY BC BYTES FROM HL TO DE
;----------------------------------------------------------------------
;
SCG_BLKCPY:
	; SAVE DESTINATION AND LENGTH
	PUSH	BC		; LENGTH
	PUSH	DE		; DEST
;
	; READ FROM THE SOURCE LOCATION
SCG_BLKCPY1:
	CALL	SCG_RD		; SET UP TO READ FROM ADDRESS IN HL
	LD	DE,SCG_BUF	; POINT TO BUFFER
	LD	B,C
SCG_BLKCPY2:
	IN	A,(SCG_DATREG)	; GET THE NEXT BYTE
	SCG_IODELAY		; DELAY
	LD	(DE),A		; SAVE IN BUFFER
	INC	DE		; BUMP BUF PTR
	DJNZ	SCG_BLKCPY2	; LOOP AS NEEDED
;
	; WRITE TO THE DESTINATION LOCATION
	POP	HL		; RECOVER DESTINATION INTO HL
	CALL	SCG_WR		; SET UP TO WRITE
	LD	DE,SCG_BUF	; POINT TO BUFFER
	POP	BC		; GET LOOP COUNTER BACK
	LD	B,C
SCG_BLKCPY3:
	LD	A,(DE)		; GET THE CHAR FROM BUFFER
	OUT	(SCG_DATREG),A	; WRITE TO VDU
	SCG_IODELAY		; DELAY
	INC	DE		; BUMP BUF PTR
	DJNZ	SCG_BLKCPY3	; LOOP AS NEEDED
;
	RET
;
;==================================================================================================
;   SCG DRIVER - DATA
;==================================================================================================
;
;SCG_CIOUNIT	.DB	$FF	; LOCAL COPY OF OUR CIO UNIT NUMBER
;
SCG_POS		.DW 	0	; CURRENT DISPLAY POSITION
SCG_CURSAV	.DB	0	; SAVES ORIGINAL CHARACTER UNDER CURSOR
SCG_BUF		.FILL	256,0	; COPY BUFFER
;
;==================================================================================================
;   SCG DRIVER - TMS9918 REGISTER INITIALIZATION
;==================================================================================================
;
; Control Registers (write CMDREG):
;
; Reg	Bit 7	Bit 6	Bit 5	Bit 4	Bit 3	Bit 2	Bit 1	Bit 0	Description
; 0	-	-	-	-	-	-	M2	EXTVID
; 1	4/16K	BL	GINT	M1	M3	-	SI	MAG
; 2	-	-	-	-	PN13	PN12	PN11	PN10
; 3	CT13	CT12	CT11	CT10	CT9	CT8	CT7	CT6
; 4	-	-	-	-	-	PG13	PG12	PG11
; 5	-	SA13	SA12	SA11	SA10	SA9	SA8	SA7
; 6	-	-	-	-	-	SG13	SG12	SG11
; 7	TC3	TC2	TC1	TC0	BD3	BD2	BD1	BD0
;
; Status (read CMDREG):
;
; 	Bit 7	Bit 6	Bit 5	Bit 4	Bit 3	Bit 2	Bit 1	Bit 0	Description
; 	INT	5S	C	FS4	FS3	FS2	FS1	FS0
;
; M1,M2,M3	Select screen mode
; EXTVID	Enables external video input.
; 4/16K		Selects 16kB RAM if set. No effect in MSX1 system.
; BL		Blank screen if reset; just backdrop. Sprite system inactive
; SI		16x16 sprites if set; 8x8 if reset
; MAG		Sprites enlarged if set (sprite pixels are 2x2)
; GINT		Generate interrupts if set
; PN*		Address for pattern name table
; CT*		Address for colour table (special meaning in M2)
; PG*		Address for pattern generator table (special meaning in M2)
; SA*		Address for sprite attribute table
; SG*		Address for sprite generator table
; TC*		Text colour (foreground)
; BD*		Back drop (background). Sets the colour of the border around
; 		the drawable area. If it is 0, it is black (like colour 1).
; FS*		Fifth sprite (first sprite that's not displayed). Only valid
; 		if 5S is set.
; C		Sprite collision detected
; 5S		Fifth sprite (not displayed) detected. Value in FS* is valid.
; INT		Set at each screen update, used for interrupts.
;
SCG_INIT9918:
	.DB	$00		; REG 0 - NO EXTERNAL VID
	.DB	$50		; REG 1 - ENABLE SCREEN, SET MODE 1
	.DB	$00		; REG 2 - PATTERN NAME TABLE := 0
	.DB	$00		; REG 3 - NO COLOR TABLE
	.DB	$01		; REG 4 - SET PATTERN GENERATOR TABLE TO $800
	.DB	$00		; REG 5 - SPRITE ATTRIBUTE IRRELEVANT
	.DB	$00		; REG 6 - NO SPRITE GENERATOR TABLE
	.DB	$F0		; REG 7 - WHITE ON BLACK
;
SCG_INIT9918LEN	.EQU	$ - SCG_INIT9918
;
;==================================================================================================
;   SCG DRIVER - FONT DATA
;==================================================================================================
;
SCG_FONTDATA:
#INCLUDE "scg_font.inc"