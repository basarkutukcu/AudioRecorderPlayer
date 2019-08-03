;---------------------------------------------------
; EE447 Introduction to Microprocessors
; Laboratory Project Source Code Submission
; Group ID: 8
; Basar Kütükcü - 2031110
; Faruk Volkan Mutlu - 2031136
;---------------------------------------------------
RCC			EQU			0x400FE060
RCC_RIS		EQU			0x400FE050

SRAM_ADDR			EQU	0x20000402 ;
SRAM_LIM			EQU	0x20007FFE ;
	
ADC0_PSSI			EQU 0x40038028 ;
ADC0_ISC			EQU 0x4003800C ;
ADC0_RIS			EQU	0x40038004 ;
ADC0_SSFIFO3		EQU 0x400380A8 ;
	
TIMER0_RIS			EQU 0x4003001C ; Timer Interrupt Status
TIMER0_ICR			EQU 0x40030024 ; Timer Interrupt Clear
TIMER0_CTL			EQU 0x4003000C ;

GPIO_PORTF_DATA_L	EQU 0x40025038 ; Access leds
GPIO_PORTF_DATA_S	EQU	0x40025044 ; Access Sws	
;---------------------------------------------------
;LABEL		DIRECTIVE	VALUE		COMMENT
;---------------------------------------------------
			AREA    	main, READONLY, CODE
			THUMB
			EXPORT  	__main	; Make available
			EXTERN  	initI2C	; Make available
			EXTERN		initTimer
			EXTERN		initADC_F
			EXTERN		Timer2A_H
			EXTERN		ATD_INIT
			EXTERN		ST_INIT
				
__main

			LDR R0,=RCC
			LDR R1,[R0]
			ORR R1,#0x00000800
			BIC R1,#0x00400000
			STR R1,[R0]; set Bypass and clear UseSysDiv
			
			LDR R0,=RCC
			LDR R1,[R0]
			ORR R1,#0x10; Choose PIOSC
			BIC R1,#0x2000; Clear PWRDN
			STR R1,[R0]
			
			LDR R0,=RCC
			LDR R1,[R0]
			ORR R1,#0x04C00000
			STR R1,[R0]; 20Mhz
			
wait_rcc	LDR R0,=RCC_RIS
			LDR R1,[R0]
			AND R1,#0x40
			CMP R1,#0x40
			BNE wait_rcc
			
			LDR R0,=RCC
			LDR R1,[R0]
			BIC R1,#0x00000800
			STR R1,[R0]; Clear ByPass
			
			LDR	R3, =ADC0_SSFIFO3
			LDR	R6, =0x04
			LDR	R7,	=GPIO_PORTF_DATA_L
			LDR R12,=GPIO_PORTF_DATA_S
			LDR	R8,	=SRAM_ADDR			
			LDR	R9,	=SRAM_LIM
			LDR R10,=0			

			BL ATD_INIT

sw1			LDR R0,[R12]
			ANDS R0,#0x10
			BNE sw1
			
			MOV R0,#0x02; Turn on LED RED
			STR R0,[R7]			
			
			BL ST_INIT			
			
sw2			LDR R0,[R12]
			ANDS R0,#0x01
			BNE sw2			
			
			LDR	R8,=SRAM_ADDR			
			LDR	R9,=SRAM_LIM

			MOV R0,#0x8; Turn on LED GREEN
			STR R0,[R7]
			
			BL initI2C
			BL initTimer
			BL initADC_F
frv			B frv
;---------------------------------------------------
			ALIGN
			END