;
;==================================================================================================
;   SC130 STANDARD CONFIGURATION
;==================================================================================================
;
; THE COMPLETE SET OF DEFAULT CONFIGURATION SETTINGS FOR THIS PLATFORM ARE FOUND IN THE
; CFG_<PLT>.ASM INCLUDED FILE WHICH IS FOUND IN THE PARENT DIRECTORY.  THIS FILE CONTAINS
; COMMON CONFIGURATION SETTINGS THAT OVERRIDE THE DEFAULTS.  IT IS INTENDED THAT YOU MAKE
; YOUR CUSTOMIZATIONS IN THIS FILE AND JUST INHERIT ALL OTHER SETTINGS FROM THE DEFAULTS.
; EVEN BETTER, YOU CAN MAKE A COPY OF THIS FILE WITH A NAME LIKE <PLT>_XXX.ASM AND SPECIFY
; YOUR FILE IN THE BUILD PROCESS.
;
; THE SETTINGS BELOW ARE THE SETTINGS THAT ARE MOST COMMONLY MODIFIED FOR THIS PLATFORM.
; MANY OF THEM ARE EQUAL TO THE SETTINGS IN THE INCLUDED FILE, SO THEY DON'T REALLY DO
; ANYTHING AS IS.  THEY ARE LISTED HERE TO MAKE IT EASY FOR YOU TO ADJUST THE MOST COMMON
; SETTINGS.
;
; N.B., SINCE THE SETTINGS BELOW ARE REDEFINING VALUES ALREADY SET IN THE INCLUDED FILE,
; TASM INSISTS THAT YOU USE THE .SET OPERATOR AND NOT THE .EQU OPERATOR BELOW. ATTEMPTING
; TO REDEFINE A VALUE WITH .EQU BELOW WILL CAUSE TASM ERRORS!
;
; PLEASE REFER TO THE CUSTOM BUILD INSTRUCTIONS (README.TXT) IN THE SOURCE DIRECTORY (TWO
; DIRECTORIES ABOVE THIS ONE).
;
#define	PLATFORM_NAME	"SC130"
;
#define	BOOT_DEFAULT	"H"		; DEFAULT BOOT LOADER CMD ON <CR> OR AUTO BOOT
;
#include "cfg_scz180.asm"
;
CRTACT		.SET	FALSE		; ACTIVATE CRT (VDU,CVDU,PROPIO,ETC) AT STARTUP
;
CPUOSC		.SET	18432000	; CPU OSC FREQ IN MHZ
;
Z180_CLKDIV	.SET	1		; Z180: CHK DIV: 0=OSC/2, 1=OSC, 2=OSC*2
Z180_MEMWAIT	.SET	0		; Z180: MEMORY WAIT STATES (0-3)
Z180_IOWAIT	.SET	1		; Z180: I/O WAIT STATES TO ADD ABOVE 1 W/S BUILT-IN (0-3)
;
HBIOS_MUTEX	.SET	FALSE		; ENABLE REENTRANT CALLS TO HBIOS (ADDS OVERHEAD)
;
LEDENABLE	.SET	TRUE		; ENABLE STATUS LED (SINGLE LED)
;
DIAGENABLE	.SET	FALSE		; ENABLES OUTPUT TO 8 BIT LED DIAGNOSTIC PORT
;
DSRTCENABLE	.SET	FALSE		; DSRTC: ENABLE DS-1302 CLOCK DRIVER (DSRTC.ASM)
INTRTCENABLE	.SET	TRUE		; ENABLE PERIODIC INTERRUPT CLOCK DRIVER (INTRTC.ASM)
;
UARTENABLE	.SET	TRUE		; UART: ENABLE 8250/16550-LIKE SERIAL DRIVER (UART.ASM)
ASCIENABLE	.SET	TRUE		; ASCI: ENABLE Z180 ASCI SERIAL DRIVER (ASCI.ASM)
ACIAENABLE	.SET	FALSE		; ACIA: ENABLE MOTOROLA 6850 ACIA DRIVER (ACIA.ASM)
SIOENABLE	.SET	FALSE		; SIO: ENABLE ZILOG SIO SERIAL DRIVER (SIO.ASM)
;
TMSENABLE	.SET	FALSE		; TMS: ENABLE TMS9918 VIDEO/KBD DRIVER (TMS.ASM)
;
FDENABLE	.SET	FALSE		; FD: DRIVER MODE: FDMODE_[DIO|ZETA|ZETA2|DIDE|N8|DIO3|RCSMC|RCWDC|DYNO|EPWDC]
FDMODE		.SET	FDMODE_RCWDC	; FD: DRIVER MODE: FDMODE_[DIO|ZETA|DIDE|N8|DIO3]
;
IDEENABLE	.SET	TRUE		; IDE: ENABLE IDE DISK DRIVER (IDE.ASM)
;
PPIDEENABLE	.SET	TRUE		; PPIDE: ENABLE PARALLEL PORT IDE DISK DRIVER (PPIDE.ASM)
;
SDENABLE	.SET	TRUE		; SD: ENABLE SD CARD DISK DRIVER (SD.ASM)
;
PRPENABLE	.SET	FALSE		; PRP: ENABLE ECB PROPELLER IO BOARD DRIVER (PRP.ASM)
