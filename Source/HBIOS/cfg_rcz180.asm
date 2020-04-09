;
;==================================================================================================
;   ROMWBW 2.X CONFIGURATION DEFAULTS FOR RC2014
;==================================================================================================
;
; THIS FILE CONTAINS THE FULL SET OF DEFAULT CONFIGURATION SETTINGS FOR THE PLATFORM
; INDICATED ABOVE. THIS FILE SHOULD *NOT* NORMALLY BE CHANGED.	INSTEAD, YOU SHOULD
; OVERRIDE ANY SETTINGS YOU WANT USING A CONFIGURATION FILE IN THE CONFIG DIRECTORY
; UNDER THIS DIRECTORY.
;
; THIS FILE CAN BE CONSIDERED A REFERENCE THAT LISTS ALL POSSIBLE CONFIGURATION SETTINGS
; FOR THE PLATFORM.
;
#DEFINE PLATFORM_NAME "RC2014"
;
PLATFORM	.EQU	PLT_RCZ180	; PLT_[SBC|ZETA|ZETA2|N8|MK4|UNA|RCZ80|RCZ180|EZZ80|SCZ180|DYNO]
CPUFAM		.EQU	CPU_Z180	; CPU FAMILY: CPU_[Z80|Z180]
BIOS		.EQU	BIOS_WBW	; HARDWARE BIOS: BIOS_[WBW|UNA]
BATCOND		.EQU	FALSE		; ENABLE LOW BATTERY WARNING MESSAGE
HBIOS_MUTEX	.EQU	FALSE		; ENABLE REENTRANT CALLS TO HBIOS (ADDS OVERHEAD)
USELZSA2	.EQU	TRUE		; ENABLE FONT COMPRESSION
;
BOOT_TIMEOUT	.EQU	0		; AUTO BOOT TIMEOUT IN SECONDS, 0 TO DISABLE
;
CPUOSC		.EQU	18432000	; CPU OSC FREQ IN MHZ
INTMODE		.EQU	2		; INTERRUPTS: 0=NONE, 1=MODE 1, 2=MODE 2
DEFSERCFG	.EQU	SER_115200_8N1	; DEFAULT SERIAL LINE CONFIG (SEE STD.ASM)
;
RAMSIZE		.EQU	512		; SIZE OF RAM IN KB (MUST MATCH YOUR HARDWARE!!!)
MEMMGR		.EQU	MM_Z180		; MEMORY MANAGER: MM_[SBC|Z2|N8|Z180]
RAMBIAS		.EQU	512		; OFFSET OF START OF RAM IN PHYSICAL ADDRESS SPACE
MPGSEL_0	.EQU	$78		; Z2 MEM MGR BANK 0 PAGE SELECT REG (WRITE ONLY)
MPGSEL_1	.EQU	$79		; Z2 MEM MGR BANK 1 PAGE SELECT REG (WRITE ONLY)
MPGSEL_2	.EQU	$7A		; Z2 MEM MGR BANK 2 PAGE SELECT REG (WRITE ONLY)
MPGSEL_3	.EQU	$7B		; Z2 MEM MGR BANK 3 PAGE SELECT REG (WRITE ONLY)
MPGENA		.EQU	$7C		; Z2 MEM MGR PAGING ENABLE REGISTER (BIT 0, WRITE ONLY)
;
Z180_BASE	.EQU	$C0		; Z180: I/O BASE ADDRESS FOR INTERNAL REGISTERS
Z180_CLKDIV	.EQU	1		; Z180: CHK DIV: 0=OSC/2, 1=OSC, 2=OSC*2
Z180_MEMWAIT	.EQU	0		; Z180: MEMORY WAIT STATES (0-3)
Z180_IOWAIT	.EQU	1		; Z180: I/O WAIT STATES TO ADD ABOVE 1 W/S BUILT-IN (0-3)
;
RTCIO		.EQU	$0C		; RTC LATCH REGISTER ADR
;
KIOENABLE	.EQU	FALSE		; ENABLE ZILOG KIO SUPPORT
KIOBASE		.EQU	$80		; KIO BASE I/O ADDRESS
;
CTCENABLE	.EQU	FALSE		; ENABLE ZILOG CTC SUPPORT
;
DIAGENABLE	.EQU	TRUE		; ENABLES OUTPUT TO 8 BIT LED DIAGNOSTIC PORT
DIAGPORT	.EQU	$00		; DIAGNOSTIC PORT ADDRESS
DIAGDISKIO	.EQU	TRUE		; ENABLES DISK I/O ACTIVITY ON DIAGNOSTIC LEDS
;
LEDENABLE	.EQU	FALSE		; ENABLES STATUS LED (SINGLE LED)
LEDPORT		.EQU	$0E		; STATUS LED PORT ADDRESS
LEDDISKIO	.EQU	TRUE		; ENABLES DISK I/O ACTIVITY ON STATUS LED
;
DSKYENABLE	.EQU	FALSE		; ENABLES DSKY (DO NOT COMBINE WITH PPIDE)
;
CRTACT		.EQU	FALSE		; ACTIVATE CRT (VDU,CVDU,PROPIO,ETC) AT STARTUP
VDAEMU		.EQU	EMUTYP_ANSI	; VDA EMULATION: EMUTYP_[TTY|ANSI]
ANSITRACE	.EQU	1		; ANSI DRIVER TRACE LEVEL (0=NO,1=ERRORS,2=ALL)
;
TIMRTCENABLE	.EQU	FALSE		; ENABLE PERIODIC TIMER CLOCK DRIVER (TIMRTC.ASM)
;
HTIMENABLE	.EQU	FALSE		; ENABLE SIMH TIMER SUPPORT
SIMRTCENABLE	.EQU	FALSE		; ENABLE SIMH CLOCK DRIVER (SIMRTC.ASM)
;
DSRTCENABLE	.EQU	TRUE		; DSRTC: ENABLE DS-1302 CLOCK DRIVER (DSRTC.ASM)
DSRTCMODE	.EQU	DSRTCMODE_STD	; DSRTC: OPERATING MODE: DSRTC_[STD|MFPIC]
DSRTCCHG	.EQU	FALSE		; DSRTC: FORCE BATTERY CHARGE ON (USE WITH CAUTION!!!)
;
BQRTCENABLE	.EQU	FALSE		; BQRTC: ENABLE BQ4845 CLOCK DRIVER (BQRTC.ASM)
BQRTC_BASE	.EQU	$50		; BQRTC: I/O BASE ADDRESS
;
UARTENABLE	.EQU	TRUE		; UART: ENABLE 8250/16550-LIKE SERIAL DRIVER (UART.ASM)
UARTOSC		.EQU	1843200		; UART: OSC FREQUENCY IN MHZ
UARTCFG		.EQU	DEFSERCFG	; UART: LINE CONFIG FOR UART PORTS
UARTSBC		.EQU	FALSE		; UART: AUTO-DETECT SBC/ZETA ONBOARD UART
UARTCAS		.EQU	FALSE		; UART: AUTO-DETECT ECB CASSETTE UART
UARTMFP		.EQU	FALSE		; UART: AUTO-DETECT MF/PIC UART
UART4		.EQU	FALSE		; UART: AUTO-DETECT 4UART UART
UARTRC		.EQU	TRUE		; UART: AUTO-DETECT RC UART
;
ASCIENABLE	.EQU	TRUE		; ASCI: ENABLE Z180 ASCI SERIAL DRIVER (ASCI.ASM)
ASCI0CFG	.EQU	DEFSERCFG	; ASCI 0: SERIAL LINE CONFIG
ASCI1CFG	.EQU	DEFSERCFG	; ASCI 1: SERIAL LINE CONFIG
;
ACIAENABLE	.EQU	FALSE		; ACIA: ENABLE MOTOROLA 6850 ACIA DRIVER (ACIA.ASM)
;
SIOENABLE	.EQU	TRUE		; SIO: ENABLE ZILOG SIO SERIAL DRIVER (SIO.ASM)
SIODEBUG	.EQU	FALSE		; SIO: ENABLE DEBUG OUTPUT
SIOCNT		.EQU	2		; SIO: NUMBER OF CHIPS TO DETECT (1-2), 2 CHANNELS PER CHIP
SIO0MODE	.EQU	SIOMODE_RC	; SIO 0: CHIP TYPE: SIOMODE_[RC|SMB|ZP|EZZ80]
SIO0CTCC	.EQU	-1		; SIO 0: CTC CHANNEL CLOCK SCALER, (0-3), -1 FOR NONE
SIO0BASE	.EQU	$80		; SIO 0: REGISTERS BASE ADR
SIO0ACLK	.EQU	7372800		; SIO 0A: OSC FREQ IN HZ, ZP=2457600/4915200, RC/SMB=7372800
SIO0ADIV	.EQU	1		; SIO 0A: SERIAL CLOCK DIVIDER, RC2014/SMB=1, ZP=2/4/8/16/32/64/128/256 (X5)
SIO0ACFG	.EQU	SER_115200_8N1	; SER_115200_8N1 0A: SERIAL LINE CONFIG
SIO0BCLK	.EQU	7372800		; SIO 0B: OSC FREQ IN HZ, ZP=2457600/4915200, RC/SMB=7372800
SIO0BDIV	.EQU	1		; SIO 0B: SERIAL CLOCK DIVIDER, RC2014/SMB=1, ZP=2/4/8/16/32/64/128/256 (X5)
SIO0BCFG	.EQU	SER_115200_8N1	; SIO 0B: SERIAL LINE CONFIG
SIO1MODE	.EQU	SIOMODE_RC	; SIO 1: CHIP TYPE: SIOMODE_[RC|SMB|ZP|EZZ80]
SIO1CTCC	.EQU	-1		; SIO 1: CTC CHANNEL CLOCK SCALER, (0-3), -1 FOR NONE
SIO1BASE	.EQU	$84		; SIO 1: REGISTERS BASE ADR
SIO1ACLK	.EQU	7372800		; SIO 1A: OSC FREQ IN HZ, ZP=2457600/4915200, RC/SMB=7372800
SIO1ADIV	.EQU	1		; SIO 1A: SERIAL CLOCK DIVIDER, RC2014/SMB=1, ZP=2/4/8/16/32/64/128/256 (X5)
SIO1ACFG	.EQU	SER_115200_8N1	; SER_115200_8N1 1A: SERIAL LINE CONFIG
SIO1BCLK	.EQU	7372800		; SIO 1B: OSC FREQ IN HZ, ZP=2457600/4915200, RC/SMB=7372800
SIO1BDIV	.EQU	1		; SIO 1B: SERIAL CLOCK DIVIDER, RC2014/SMB=1, ZP=2/4/8/16/32/64/128/256 (X5)
SIO1BCFG	.EQU	SER_115200_8N1	; SIO 1B: SERIAL LINE CONFIG
;
XIOCFG		.EQU	DEFSERCFG	; XIO: SERIAL LINE CONFIG
;
VDUENABLE	.EQU	FALSE		; VDU: ENABLE VDU VIDEO/KBD DRIVER (VDU.ASM)
CVDUENABLE	.EQU	FALSE		; CVDU: ENABLE CVDU VIDEO/KBD DRIVER (CVDU.ASM)
NECENABLE	.EQU	FALSE		; NEC: ENABLE NEC UPD7220 VIDEO/KBD DRIVER (NEC.ASM)
TMSENABLE	.EQU	FALSE		; TMS: ENABLE TMS9918 VIDEO/KBD DRIVER (TMS.ASM)
VGAENABLE	.EQU	FALSE		; VGA: ENABLE VGA VIDEO/KBD DRIVER (VGA.ASM)
;
SPKENABLE	.EQU	FALSE		; SPK: ENABLE RTC LATCH IOBIT SOUND DRIVER (SPK.ASM)
;
AYENABLE	.EQU	FALSE		; AY: ENABLE AY PSG SOUND DRIVER
AYMODE		.EQU	AYMODE_RCZ180	; AY: DRIVER MODE: AYMODE_[SCG/N8/RCZ80/RCZ180]
;
MDENABLE	.EQU	TRUE		; MD: ENABLE MEMORY (ROM/RAM) DISK DRIVER (MD.ASM)
MDTRACE		.EQU	1		; MD: TRACE LEVEL (0=NO,1=ERRORS,2=ALL)
;
FDENABLE	.EQU	FALSE		; FD: ENABLE FLOPPY DISK DRIVER (FD.ASM)
FDMODE		.EQU	FDMODE_RCWDC	; FD: DRIVER MODE: FDMODE_[DIO|ZETA|DIDE|N8|DIO3|DYNO]
FDTRACE		.EQU	1		; FD: TRACE LEVEL (0=NO,1=FATAL,2=ERRORS,3=ALL)
FDMEDIA		.EQU	FDM144		; FD: DEFAULT MEDIA FORMAT FDM[720|144|360|120|111]
FDMEDIAALT	.EQU	FDM720		; FD: ALTERNATE MEDIA FORMAT FDM[720|144|360|120|111]
FDMAUTO		.EQU	TRUE		; FD: AUTO SELECT DEFAULT/ALTERNATE MEDIA FORMATS
;
RFENABLE	.EQU	FALSE		; RF: ENABLE RAM FLOPPY DRIVER
;
IDEENABLE	.EQU	FALSE		; IDE: ENABLE IDE DISK DRIVER (IDE.ASM)
IDETRACE	.EQU	1		; IDE: TRACE LEVEL (0=NO,1=ERRORS,2=ALL)
IDECNT		.EQU	1		; IDE: NUMBER OF IDE INTERFACES TO DETECT (1-3), 2 DRIVES EACH
IDE0MODE	.EQU	IDEMODE_RC	; IDE 0: DRIVER MODE: IDEMODE_[DIO|DIDE|MK4|RC]
IDE0BASE	.EQU	$10		; IDE 0: IO BASE ADDRESS
IDE0DATLO	.EQU	$00		; IDE 0: DATA LO PORT FOR 16-BIT I/O
IDE0DATHI	.EQU	$00		; IDE 0: DATA HI PORT FOR 16-BIT I/O
IDE0A8BIT	.EQU	TRUE		; IDE 0A (MASTER): 8 BIT XFER
IDE0B8BIT	.EQU	TRUE		; IDE 0B (MASTER): 8 BIT XFER
IDE1MODE	.EQU	IDEMODE_NONE	; IDE 1: DRIVER MODE: IDEMODE_[DIO|DIDE|MK4|RC]
IDE1BASE	.EQU	$00		; IDE 1: IO BASE ADDRESS
IDE1DATLO	.EQU	$00		; IDE 1: DATA LO PORT FOR 16-BIT I/O
IDE1DATHI	.EQU	$00		; IDE 1: DATA HI PORT FOR 16-BIT I/O
IDE1A8BIT	.EQU	TRUE		; IDE 1A (MASTER): 8 BIT XFER
IDE1B8BIT	.EQU	TRUE		; IDE 1B (MASTER): 8 BIT XFER
IDE2MODE	.EQU	IDEMODE_NONE	; IDE 2: DRIVER MODE: IDEMODE_[DIO|DIDE|MK4|RC]
IDE2BASE	.EQU	$00		; IDE 2: IO BASE ADDRESS
IDE2DATLO	.EQU	$00		; IDE 2: DATA LO PORT FOR 16-BIT I/O
IDE2DATHI	.EQU	$00		; IDE 2: DATA HI PORT FOR 16-BIT I/O
IDE2A8BIT	.EQU	TRUE		; IDE 2A (MASTER): 8 BIT XFER
IDE2B8BIT	.EQU	TRUE		; IDE 2B (MASTER): 8 BIT XFER
;
PPIDEENABLE	.EQU	FALSE		; PPIDE: ENABLE PARALLEL PORT IDE DISK DRIVER (PPIDE.ASM)
PPIDETRACE	.EQU	1		; PPIDE: TRACE LEVEL (0=NO,1=ERRORS,2=ALL)
PPIDECNT	.EQU	1		; PPIDE: NUMBER OF PPI CHIPS TO DETECT (1-3), 2 DRIVES PER CHIP
PPIDE0BASE	.EQU	$20		; PPIDE 0: PPI REGISTERS BASE ADR
PPIDE0A8BIT	.EQU	FALSE		; PPIDE 0A (MASTER): 8 BIT XFER
PPIDE0B8BIT	.EQU	FALSE		; PPIDE 0B (SLAVE): 8 BIT XFER
PPIDE1BASE	.EQU	$00		; PPIDE 1: PPI REGISTERS BASE ADR
PPIDE1A8BIT	.EQU	FALSE		; PPIDE 1A (MASTER): 8 BIT XFER
PPIDE1B8BIT	.EQU	FALSE		; PPIDE 0B (SLAVE): 8 BIT XFER
PPIDE2BASE	.EQU	$00		; PPIDE 2: PPI REGISTERS BASE ADR
PPIDE2A8BIT	.EQU	FALSE		; PPIDE 2A (MASTER): 8 BIT XFER
PPIDE2B8BIT	.EQU	FALSE		; PPIDE 0B (SLAVE): 8 BIT XFER;
SDENABLE	.EQU	FALSE		; SD: ENABLE SD CARD DISK DRIVER (SD.ASM)
SDMODE		.EQU	SDMODE_PPI	; SD: DRIVER MODE: SDMODE_[JUHA|N8|CSIO|PPI|UART|DSD|MK4|SC|MT]
SDCNT		.EQU	1		; SD: NUMBER OF SD CARD DEVICES (1-2), FOR DSD & SC ONLY
SDTRACE		.EQU	1		; SD: TRACE LEVEL (0=NO,1=ERRORS,2=ALL)
SDCSIOFAST	.EQU	FALSE		; SD: ENABLE TABLE-DRIVEN BIT INVERTER IN CSIO MODE
;
PRPENABLE	.EQU	FALSE		; PRP: ENABLE ECB PROPELLER IO BOARD DRIVER (PRP.ASM)
;
PPPENABLE	.EQU	FALSE		; PPP: ENABLE ZETA PARALLEL PORT PROPELLER BOARD DRIVER (PPP.ASM)
;
HDSKENABLE	.EQU	FALSE		; HDSK: ENABLE SIMH HDSK DISK DRIVER (HDSK.ASM)
;
PIO_4P		.EQU	FALSE		; PIO: ENABLE PARALLEL PORT DRIVER FOR ECB 4P BOARD
PIO_ZP		.EQU	FALSE		; PIO: ENABLE PARALLEL PORT DRIVER FOR ECB ZILOG PERIPHERALS BOARD (PIO.ASM)
PPI_SBC		.EQU	FALSE		; PIO: ENABLE PARALLEL PORT DRIVER FOR 8255 CHIP
;
UFENABLE	.EQU	FALSE		; UF: ENABLE ECB USB FIFO DRIVER (UF.ASM)
