;-------------------------------------------------------------------------------
; Include files
            .cdecls C,LIST,"msp430.h"  ; Include device header file

            .include "basicops.asm"
;-------------------------------------------------------------------------------

            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.

            .global __STACK_END
            .sect   .stack                  ; Make stack linker segment ?known?

            .text                           ; Assemble to Flash memory
            .retain                         ; Ensure current section gets linked
            .retainrefs

RESET       mov.w   #__STACK_END,SP         ; Initialize stack pointer

init:
            ; stop watchdog timer
            mov.w   #WDTPW+WDTHOLD,&WDTCTL

SetupP1     bic.b   #BIT0,&P1OUT            ; Clear P1.0 output
            bis.b   #BIT0,&P1DIR            ; P1.0 output
        
SetupP6     bic.b   #BIT6,&P6OUT
            bis.b   #BIT6,&P6DIR


TimerB0     bis.w	#TBCLR, &TB0CTL					;TB0
		    bis.w 	#TBSSEL__SMCLK, &TB0CTL			;Small Clock Counter
		    bis.w	#MC__UP, &TB0CTL				;Up Count
		    bis.w	#ID__4, &TB0CTL					; D1 = 4
            bis.w   #TBIDEX__8, &TB0EX0             ; D2 = 8
            mov.w   #32830, &TB0CCR0

Interrupts  bic.w	#CCIFG, &TB0CCTL0  					;Enable overflow interupt TB0
   		    bis.w	#CCIE, &TB0CCTL0					;Clear interupt flag TB0

            NOP
		    bis.w	#GIE, SR						;Enable Global Interrupts
            NOP

            ; Disable low-power mode
            bic.w   #LOCKLPM5,&PM5CTL0

main:

            xor.b   #BIT6, &P6OUT
            ;call    #i2c_delay
            
            
            
            jmp main
            nop
TimerB0_1s:

		xor.b		#BIT0, &P1OUT
		bic.w		#CCIFG, &TB0CCTL0
		reti

EndTimerB0_1s:


;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   RESET_VECTOR            ; MSP430 RESET Vector
            .short  RESET                   ;

;-------------- Timer B0 Interrupt --------------------------------------------

            .sect	".int43"				; Timer B0
            .short	TimerB0_1s

;-------------- END Timer B0 Interrupt ----------------------------------------