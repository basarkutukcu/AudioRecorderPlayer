;---------------------------------------------------
;SysTick registers
ST_CTRL				EQU	0xE000E010
ST_RELOAD			EQU	0xE000E014
ST_CURRENT			EQU	0xE000E018
SYSPRI3				EQU	0xE000ED20

;GPIO Registers
GPIO_PORTE_DATA		EQU 0x40024010 ; Access BIT2
GPIO_PORTE_DIR 		EQU 0x40024400 ; Port Direction
GPIO_PORTE_AFSEL	EQU 0x40024420 ; Alt Function enable
GPIO_PORTE_DEN 		EQU 0x4002451C ; Digital Enable
GPIO_PORTE_AMSEL 	EQU 0x40024528 ; Analog enable
GPIO_PORTE_PCTL 	EQU 0x4002452C ; Alternate Functions
GPIO_PORTF_DATA_L	EQU 0x40025038 ; Access leds
GPIO_PORTF_DATA_S	EQU	0x40025044 ; Access Sws
GPIO_PORTF_DIR 		EQU 0x40025400 ; Port Direction
GPIO_PORTF_AFSEL	EQU 0x40025420 ; Alt Function enable
GPIO_PORTF_DEN 		EQU 0x4002551C ; Digital Enable
GPIO_PORTF_AMSEL 	EQU 0x40025528 ; Analog enable
GPIO_PORTF_PCTL 	EQU 0x4002552C ; Alternate Functions
GPIO_PORTF_PUR		EQU	0x40025510 ; Pull up
GPIO_PORTF_LOCK		EQU	0x40025520
GPIO_PORTF_CR		EQU	0x40025524
;System Registers
SYSCTL_RCGCGPIO 	EQU 0x400FE608 ; GPIO Gate Control
SYSCTL_RCGCADC		EQU	0x400FE638 ; ADC Gate Control
SYSCTL_RCGCTIMER 	EQU 0x400FE604 ; GPTM Gate Control

;ADC0 Registers
ADC0_ACTSS			EQU	0x40038000 ; 
ADC0_EMUX			EQU	0x40038014 ;
ADC0_SSMUX3			EQU 0x400380A0 ; 
ADC0_SSCTL3			EQU 0x400380A4 ;
ADC0_PC				EQU	0x40038FC4 ;
ADC0_PSSI			EQU 0x40038028 ;
ADC0_ISC			EQU 0x4003800C ;
ADC0_RIS			EQU	0x40038004 ;
ADC0_SSFIFO3		EQU 0x400380A8 ;
;---------------------------------------------------
			AREA 	routines, CODE, READONLY
			THUMB
			EXPORT	ATD_INIT
			EXPORT	ST_INIT
			EXPORT	ST_ISR
;---------------------------------------------------
ATD_INIT	PROC
			LDR R1, =SYSCTL_RCGCGPIO ; start GPIO clock
			LDR	R0,	[R1]
			ORR	R0,	R0,	#0x30 ; set bits 4 and 5 for port E and F
			STR R0, [R1]
			NOP ; allow clock to settle
			NOP
			NOP
			NOP
			NOP
			NOP
			
			LDR R1, =GPIO_PORTE_AFSEL ; bit3 set to 1
			LDR R0, [R1]
			ORR	R0,	R0,	#0x08
			STR R0, [R1]		
			
			LDR R1, =GPIO_PORTE_AMSEL ; enable analog for bit3
			MOV R0, #0x08
			STR R0, [R1]
			
			LDR	R1, =GPIO_PORTE_DEN ; disable digital for bit3
			LDR	R0,	[R1]
			BIC	R0,	R0,	#0x08
			STR	R0,	[R1]
			
			LDR R1, =GPIO_PORTE_DIR ; set direction of PE3
			MOV R0, #0 ; set all bits to input
			STR R0, [R1]	

			LDR R0,=GPIO_PORTF_LOCK
			LDR R1,=0x4C4F434B
			STR R1,[R0]
			
			LDR R0,=GPIO_PORTF_CR
			MOV R1,#0x01
			STR R1,[R0]
			
			
			LDR R0,=GPIO_PORTF_PUR
			LDR R1,=0x11
			STR R1,[R0]
	
			LDR R1, =GPIO_PORTF_DIR ; 
			LDR R0, [R1]
			ORR R0, R0, #0xE ; 
			STR R0, [R1]
			LDR R1, =GPIO_PORTF_AFSEL ; regular port function
			LDR R0, [R1]
			BIC R0, R0, #0x04
			STR R0, [R1]
			LDR R1, =GPIO_PORTF_PCTL ; no alternate function
			LDR R0, [R1]
			BIC R0, R0, #0x00000F00
			STR R0, [R1]
			LDR R1, =GPIO_PORTF_AMSEL ; disable analog
			MOV R0, #0
			STR R0, [R1]
			LDR R1, =GPIO_PORTF_DEN ; enable port digital
			LDR R0, [R1]
			ORR R0, R0, #0x1F
			STR R0, [R1]
			
			LDR R1, =SYSCTL_RCGCADC ; power-up ADC
			LDR	R0,	[R1]
			ORR	R0,	R0,	#0x01 ; set bit 1 for port ADC0
			STR R0, [R1]
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			
			LDR	R1,	=ADC0_ACTSS ; Sequencer 3 disabled
			LDR	R0,	[R1]
			BIC	R0,	R0, #0x08
			;MOV	R0,	#0
			STR	R0,	[R1]
			
			LDR	R1,	=ADC0_EMUX ; software trigger
			LDR	R0,	[R1]
			BIC	R0,	R0,	#0xF000
			STR	R0,	[R1]
			
			LDR	R1, =ADC0_SSMUX3 ; AIN0
			MOV	R0,	#0
			STR	R0,	[R1]
			
			LDR	R1,	=ADC0_SSCTL3 ; end after 1 sample, generate interrupt
			MOV	R0,	#0x06
			STR	R0,	[R1]
			
			LDR	R1, =ADC0_PC ; 125 ksps
			MOV	R0,	#0x01
			STR	R0, [R1]
			
			LDR	R1,	=ADC0_ACTSS ; Sequencer 3 enabled
			LDR	R0, [R1]
			ORR	R0,	R0,	#0x08
			STR	R0,	[R1]
			BX LR
			ENDP
;---------------------------------------------------
ST_INIT		PROC
			
			LDR 		R1,=ST_CTRL
			MOV 		R0,#0
			STR 		R0,[R1]
			
			LDR 		R1,=ST_RELOAD
			LDR 		R0,=800
			STR 		R0,[R1]
			
			LDR 		R1,=ST_CURRENT
			STR 		R0,[R1]
			
			LDR 		R1,=SYSPRI3
			MOV 		R0,#0x40000000
			STR 		R0,[R1]
			
			LDR 		R1,=ST_CTRL
			MOV 		R0,#0x03
			STR 		R0,[R1]			 
			
			BX	LR
			ENDP
;---------------------------------------------------
ST_ISR		PROC
	
			LDR	R1,	=ADC0_PSSI ; start sampling for sequencer 3
			LDR	R0,	[R1]
			ORR	R0,	R0, #0x08
			STR	R0,	[R1]
			
poll		LDR	R1,	=ADC0_RIS
			LDR	R0,	[R1]
			CMP	R0,	#0x08
			BNE poll ; if flag is not set poll again
			
			CMP R10,#0
			BNE most
			LDR	R4,[R3]
			ADD	R10,#1
			B clr
			
most		CMP	R10,#1
			BNE clr
			LDR	R5,[R3]
			LSL R5,#12
			ADD	R4,R5
			STR	R4,[R8],#3
			MOV	R10,#0
			
			
clr			LDR	R1,	=ADC0_ISC
			LDR	R0,	[R1]
			ORR	R0,	R0,	#0x08 ; set bit3 in ADC0_ISC to clear interrupt
			STR	R0,	[R1]

			CMP	R8,R9
			BNE ret
			LDR R1,=ST_CTRL ; if R8=R9, stop SysTick
			MOV R0,#0
			STR R0,[R1]
			STR	R6,[R7] ; turn on LED
			
ret			BX LR
			ENDP
;---------------------------------------------------
;LABEL      DIRECTIVE       VALUE           COMMENT
			ALIGN
			END