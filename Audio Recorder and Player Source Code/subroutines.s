;---------------------------------------------------
;I2C Registers
RCGCI2C					EQU		0x400FE620	
I2C1_MCR				EQU		0x40021020
I2C1_MTPR				EQU		0x4002100C
I2C1_MSA				EQU		0x40021000
I2C1_MDR				EQU		0x40021008
I2C1_MCS				EQU		0x40021004
I2C1_SOAR				EQU		0x40021800
I2C1_SCSR				EQU		0x40021804

;TIMER Registers
SYSCTL_RCGCTIMER 		EQU 	0x400FE604
TIMER2_CFG				EQU		0x40032000
TIMER2_TAMR				EQU		0x40032004
TIMER2_CTL				EQU		0x4003200C
TIMER2_IMR				EQU		0x40032018
TIMER2_RIS				EQU		0x4003201C
TIMER2_ICR				EQU		0x40032024
TIMER2_TAILR			EQU		0x40032028
TIMER2_TAPR				EQU		0x40032038
TIMER2_TAR				EQU		0x40032048

;GPIO Registers
SYSCTL_RCGCGPIO			EQU		0x400FE608
RCGCGPIO				EQU		0x400FE608
PORTA_DEN				EQU		0x4000451C
PORTA_PUR				EQU		0x40004510
PORTA_AFSEL				EQU		0x40004420	
PORTA_PCTL				EQU		0x4000452C
PORTA_ODR				EQU		0x4000450C
GPIO_PORTE_AFSEL		EQU		0x40024420
GPIO_PORTE_DIR			EQU		0x40024400
GPIO_PORTE_AMSEL		EQU		0x40024528
	
;ADC1 Registers	
ADC1_ACTSS				EQU		0x40039000
ADC1_EMUX				EQU		0x40039014
ADC1_SSCTL3				EQU		0x400390A4
ADC1_PC					EQU		0x40039FC4
ADC1_IM					EQU		0x40039008
ADC1_SSMUX3				EQU		0x400390A0
SYSCTL_RCGCADC			EQU		0x400FE638	
ADC1_PSSI				EQU		0x40039028
ADC1_RIS				EQU		0x40039004
ADC1_SSFIFO3			EQU		0x400390A8
ADC1_ISC				EQU		0x4003900C

;NVIC Registers
NVIC_EN0				EQU 	0xE000E100 ; IRQ 0 to 31 Set Enable Register
NVIC_PRI5				EQU 	0xE000E414 ; IRQ 20 to 23 Priority Register
NVIC_EN1				EQU 	0xE000E104 ; IRQ 32 to 63 Set Enable Register
NVIC_PRI12				EQU 	0xE000E430 ; IRQ 48 to 51 Priority Register

;SRAM
SRAM_ADDR				EQU		0x20000402 ;
SRAM_LIM				EQU		0x20007FFE ;
;---------------------------------------------------
;LABEL		DIRECTIVE	VALUE		COMMENT
;---------------------------------------------------
			AREA    	subroutines, READONLY, CODE
			THUMB
			EXPORT  	initI2C	; Make available
			EXPORT		initTimer
			EXPORT		initADC_F
			EXPORT		Timer2A_H

initI2C 	PROC			
			LDR R0,=RCGCI2C
			LDR R1,[R0]
			ORR R1,#0x2
			STR R1,[R0]; Module 1 will be used- Pins SCL: PA6, SDA:PA7
			NOP
			NOP
			NOP
			NOP			
			
			LDR R0,=RCGCGPIO
			LDR R1,[R0]
			ORR R1,#0x1
			STR R1,[R0]; PORT A is powered
			NOP
			NOP
			NOP
			NOP
			
			LDR R0,=PORTA_DEN
			LDR R1,[R0]
			ORR R1,#0xC0
			STR R1,[R0]; PA6-PA7 are digital
			
			LDR R0,=PORTA_PUR
			LDR R1,[R0]
			ORR R1,#0xC0
			STR R1,[R0]; PA6-PA7 is pulled up
			
			; NOTE: Internal Pull up might be insufficient. If such case noticed
			; go to I2C manuals and use appropriate pull-ups externally
			; Note2: I have also noticed that DAC module has pull-up resistors on the board
			; they might be enough since they will pull-up the whole busses.			
			
			LDR R0,=PORTA_AFSEL
			LDR R1,[R0]
			ORR R1,#0xC0
			STR R1,[R0]; Alternate function for PA6-7
			
			LDR R0,=PORTA_PCTL
			LDR R1,[R0]
			LDR R2,=0x33000000
			ORR R1,R2
			STR R1,[R0]; Configured as SDA and SCL
			
			LDR R0,=PORTA_ODR
			LDR R1,[R0]
			ORR R1,#0x80
			STR R1,[R0]; SDA (PA7) is selected as open drain pin
			
			
			LDR R0,=I2C1_MCR
			LDR R1,=0x10; 0x31 -> Master and Slave enabled, loopback enabled -> debug purposes
			STR R1,[R0];  0x10 -> Master mode enabled, Loopback is disabled
			
			LDR R0,=I2C1_MTPR
			LDR R1,=0x02
			STR R1,[R0]; Fast Mode, Frequency will be 333kbps
			
			LDR R0,=I2C1_MSA
			LDR R1,=0xC4; Address is 0x62 and R/S is low (send)
			STR R1,[R0]
			
			;LDR R0,=I2C1_SOAR ; Uncomment when using loopback
			;LDR R1,=0x63
			;STR R1,[R0]
			
			;LDR R0,=I2C1_SCSR
			;MOV R1,#0x1
			;STR R1,[R0]
			
			BX LR
			ENDP
;---------------------------------------------------
initTimer	PROC			
			LDR R0,=SYSCTL_RCGCTIMER
			LDR R1,[R0]
			ORR R1,#0x04; Enable module 2
			STR R1,[R0]
			NOP
			NOP
			NOP
			
			LDR R0,=TIMER2_CTL
			LDR R1,[R0]
			BIC R1,#0x01; Disable during setup
			STR R1,[R0]
			
			LDR R0,=TIMER2_CFG
			MOV R1,#0x04; 16 bit mode
			STR R1,[R0]
			
			LDR R0,=TIMER2_IMR
			LDR R1,[R0]
			ORR R1,#0x1; Enable Time-out Interrupt
			STR R1,[R0]
			
			LDR R0,=TIMER2_TAPR
			MOV R1,#15; Assuming we got 20Mhz clock from RCC
			STR R1,[R0]; Timer period will be 1us
			
			LDR R0,=TIMER2_TAILR
			MOV R1,#40
			STR R1,[R0]; Start with 8kHz
																	
			LDR R0,=TIMER2_TAMR
			MOV R1,#0x2; Periodic - Down
			STR R1,[R0]
			
			; Timer2A EN # 23
			
			LDR R0,=NVIC_EN0
			LDR R1,[R0]
			LDR R2,=0x00800000
			ORR R1,R2
			STR R1,[R0]; Enable interrupt for Timer2A
			
			;For Pri, #23 is controlled by 31:29 of PRI5
			
			LDR R0,=NVIC_PRI5
			LDR R1,[R0]
			LDR R2,=0x40000000
			ORR R1,R2
			STR R1,[R0]
			
			LDR R0,=TIMER2_CTL
			LDR R1,[R0]
			ORR R1,#0x03; Enable, Halt in debug
			STR R1,[R0]
			
			BX LR
			ENDP			
;---------------------------------------------------
initADC_F	PROC
			
;***************GPIO INIT*************************

			LDR R0,=SYSCTL_RCGCGPIO
			LDR R1,[R0]
			ORR R1,#0x10; Enable PortE
			STR R1,[R0]
			NOP
			NOP
			NOP
			
			LDR R0,=GPIO_PORTE_AFSEL
			LDR R1,=0x04; Enable AF for bit2
			STR R1,[R0]
			
			LDR R0,=GPIO_PORTE_DIR
			LDR R1,[R0]
			BIC R1,#0x04; Clear to make it input
			STR R1,[R0]
			
			LDR R0,=GPIO_PORTE_AMSEL
			LDR R1,[R0]
			ORR R1,#0x04
			STR R1,[R0]
			
;*******************ADC INIT*********************

			LDR R0,=SYSCTL_RCGCADC
			LDR R1,[R0]
			ORR R1,#0x02; Enable ADC1
			STR R1,[R0]
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			
			LDR R0,=ADC1_ACTSS
			LDR R1,[R0]
			BIC R1,#0x08; Clear bit3
			STR R1,[R0]
			
			LDR R0,=ADC1_EMUX
			LDR R1,[R0]
			BFC R1,#12,#4; Clear bits 15:12 to trigger by software
			STR R1,[R0]
			
			LDR R0,=ADC1_SSMUX3
			LDR R1,[R0]
			ORR R1,#0x1
			STR R1,[R0]
			
			LDR R0,=ADC1_SSCTL3
			LDR R1,[R0]
			ORR R1,#0x06; Set IE0 & END0
			STR R1,[R0]
			
			LDR R0,=ADC1_PC
			LDR R1,[R0]
			ORR R1,#0x01; Choose 125 ksps
			STR R1,[R0]
			
			; If ADC interrupts are to be used, uncomment the following piece of code 
			;LDR R0,=ADC1_IM
			;LDR R1,[R0]
			;ORR R1,#0x8
			;STR R1,[R0]
			
			;LDR R0,=NVIC_EN1
			;LDR R1,[R0]
			;LDR R2,=0x00080000
			;ORR R1,R2
			;STR R1,[R0]; Enable bit 51
			
			;LDR R0,=NVIC_PRI12
			;LDR R1,[R0]
			;LDR R2,=0x80000000
			;ORR R1,R2
			;STR R1,[R0]; Pri is 3
			
			LDR R0,=ADC1_ACTSS
			LDR R1,[R0]
			ORR R1,#0x08; Set bit3
			STR R1,[R0]		
			
			BX LR
			ENDP
;---------------------------------------------------
Timer2A_H	PROC			
			LDR R0,=TIMER2_CTL
			LDR R1,[R0]
			BIC R1,#0x01; Disable during interrupt
			STR R1,[R0]
			
			CMP R11,#0
			BNE clr
			;sft, R11 = 0
			LDRH R3,[R8],#1
			BFC R3,#12,#4; Clear prev part
			MOV R11,#1
			B jmpclr
			
			;clr, R11 = 1
clr			LDRH R3,[R8],#2
			LSR R3,#4
			MOV R11,#0
			
jmpclr		MOV R4,R3; R3 & R4 Contains the data that will be transmitted			
			
			;LDR R0,=I2C1_MDR ; This byte is removed from transmission while code is commented
			;MOV R1,#0xC0; = 1100.0000 (Device Addressing byte)
			;STR R1,[R0]
			
			;; Note: A2,A1 are taken 00. They are 00 as default according to datasheet however they may be different
			;; as I've read from internet. A0 is also taken 0, there should be an A0 bit on the board. However there is not.
			;; So if does not work try A0 = 1 as well.
			;; --> Total Chaos
			
			;LDR R0,=I2C1_MCS
			;MOV R1,#0x3
			;STR R1,[R0]; Start,Run
			
;busy		LDR R1,[R0]; Read back the status bits
			;BIC R1,#0xFE; Clear all bits except Busy bit
			;CMP R1,#0x1
			;BEQ busy
			
			;LDR R1,[R0]; Read back the status bits
			;BIC R1,#0xFD; Clear all bits except error bit
			;CMP R1,#0x02
			;BNE jump
;err_loop	B err_loop;B error_subroutine

			;2nd Byte

jump		LSR R3,#8; keep MSB 4 bits
			MOV R1,R3
			LDR R0,=I2C1_MDR
			;LDR R1,=0; Trial
			STR R1,[R0]		

			LDR R0,=I2C1_MCS
			MOV R1,#0x3;#0x1
			STR R1,[R0]; Start&Run
			
busy2		LDR R1,[R0]; Read back the status bits
			BIC R1,#0xFE; Clear all bits except Busy bit
			CMP R1,#0x1
			BEQ busy2
			
			LDR R1,[R0]; Read back the status bits
			BIC R1,#0xFD; Clear all bits except error bit
			CMP R1,#0x02
			BNE jump2
;err_loop2	B err_loop2;B error_subroutine

			;3rd Byte
			
jump2		BFC R4,#8,#4; Keep LSB 8 bits
			MOV R1,R4
			LDR R0,=I2C1_MDR
			;LDR R1,=0x12; Trial
			STR R1,[R0]		

			LDR R0,=I2C1_MCS
			MOV R1,#0x1
			STR R1,[R0]; Run
			
busy3		LDR R1,[R0]; Read back the status bits
			BIC R1,#0xFE; Clear all bits except Busy bit
			CMP R1,#0x1
			BEQ busy3
			
			LDR R1,[R0]; Read back the status bits
			BIC R1,#0xFD; Clear all bits except error bit
			CMP R1,#0x02
			BNE jump3
;err_loop3	B err_loop3;B error_subroutine

			; EOT Byte
			
jump3		LDR R0,=I2C1_MCS
			MOV R1,#0x4
			STR R1,[R0]; EOT
			
busy4		LDR R1,[R0]; Read back the status bits
			BIC R1,#0xFE; Clear all bits except Busy bit
			CMP R1,#0x1
			BEQ busy4
			
			LDR R1,[R0]; Read back the status bits
			BIC R1,#0xFD; Clear all bits except error bit
			CMP R1,#0x02
;err_loop4	B err_loop4
			
			; ADC to decide next timer period (Sound of frequency)
			
smpl		LDR R0,=ADC1_PSSI
			MOV R1,#0x08; bit 3 is set
			STR R1,[R0]
			
			LDR R0,=ADC1_RIS
			LDR R1,[R0]
			CMP R1,#0x08; Is sampling done?
			BNE smpl
			
			LDR R0,=ADC1_SSFIFO3
			LDR R2,[R0]; R2 contains the sampled value
			
			LDR R0,=ADC1_ISC
			MOV R1,#0x08; Clear the flag to continue with sampling
			STR R1,[R0]
			
			; Adjust frequency with sample result
			
			LDR R0,=TIMER2_TAILR
			MOV R1,#40
			UDIV R2,R1
			CMP R2,#5
			MOVLO R2,#5
			STR R2,[R0]
			
			CMP R8,R9
			BNE cont
			LDR R8,=SRAM_ADDR			
			
cont		LDR R0,=TIMER2_ICR
			LDR R1,[R0]
			ORR R1,#0x1
			STR R1,[R0]; Clear the flag of Timer
			
			LDR R0,=TIMER2_CTL
			LDR R1,[R0]
			ORR R1,#0x01; Enable again
			STR R1,[R0]
			
			BX LR
			ALIGN
			ENDP
;---------------------------------------------------
			END