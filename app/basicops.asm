            .cdecls C,LIST,"msp430.h"  ; Include device header file
            .include "delay.asm"
            
            
            .text                           ; Assemble to Flash memory
            .retain                         ; Ensure current section gets linked
            .retainrefs

data_low    .macro 
            bic.b   #BIT4,&P2OUT            ; Bring data line low
            bis.b   #BIT4,&P2DIR            ; Set data to output
            .endm

data_high   .macro 
            bic.b   #BIT4,&P2DIR            ; Set data to input
            ;bis.b   #BIT4,&P2REN
            ;bis.b   #BIT4,&P2OUT            ; Make sure resistor is pullup
            .endm

;------------------------------------i2c_start--------------------------------------------
; Tx an i2c start condition
i2c_start:
            data_low                        ; Bring data line low
            call    #i2c_delay
            ret


;------------------------------------i2c_stop--------------------------------------------
; Tx an i2c stop conditions
i2c_stop:   
            bic.b   #BIT5,&P2OUT            ; Bring clock low
            call    #i2c_delay
            data_low                        ; Bring data line low if not already
            call    #i2c_delay
            bis.b   #BIT5,&P2OUT            ; Bring clock back high
            call    #i2c_delay
            data_high                       ; Bring data high to signify stop
            call    #i2c_delay
            ret


;------------------------------------i2c_tx_bit--------------------------------------------
; Take bit to send on R15
i2c_tx_bit:
            bic.b   #BIT5,&P2OUT            ; Bring clock low
            call    #i2c_delay

            cmp     #0,R15                  ; Check data passed
            jz      data_zero
            data_high                       ; Bring data high if passed 1
            jmp     data_one
data_zero   data_low                        ; Bring data line low if passed 0
data_one    call    #i2c_delay
            
            bis.b   #BIT5,&P2OUT            ; Bring clock back high
            call    #i2c_delay
            call    #i2c_delay
            ret

;------------------------------------i2c_tx_byte--------------------------------------------
; Take byte to send on R15
i2c_tx_byte:
            push    R14                     ; Store used registers on stack
            push    R13

            mov     R15, R14                ; Move byte to send to R14
            mov     #7, R13                 ; Setup bit counter

next_bit    rlc.b   R14                     ; Grab MSB of R15 (now in R14)
            jc      bit_one                 ; Load a value depending on what carry bit from R14
            mov.b   #0, R15
            jmp     bit_zero
bit_one     mov.b   #1, R15
bit_zero    
            push    R14
            push    R13
            call    #i2c_tx_bit             ; Call subroutine to write bit
            pop     R13
            pop     R14

            cmp     #0, R13                 ; Check bit counter, loop if not done
            jz      end_byte
            dec     R13
            jmp     next_bit

end_byte    pop     R13
            pop     R14                     ; Grab original R14 off stack
            ret


;------------------------------------i2c_rx_byte--------------------------------------------
; Rx a byte over i2c result in R15
i2c_rx_byte:

            push    R14
            push    R13

            mov.b   #8, R13                 ; Bit Counter
            mov.w   #0,R14                  ; Store bute

next_bit_rx
            push R14                        ; Save our important registers
            push R13                        ; They will otherwise be rewritten

            bic.b   #BIT5, &P2OUT           ; SCL low
            call    #i2c_delay
            data_high                       ; Data high also sets line to receive
            call    #i2c_delay
            bis.b   #BIT5, &P2OUT           ; SCL high for read
            call    #i2c_delay
            cmp     #BIT4, &P2IN            ; Check SDA for 1 or 0
            jnz     bit_one_rx              ; Load rx bit into R15 
            mov.b   #0, R15
            jmp     store_bit
bit_one_rx
            mov.b   #1, R15


store_bit
            call #i2c_delay                 ; Finish high clock cycle
            pop R13                         ; Get back important registers
            pop R14


            rlc.b   R14                     ; Set received bit in lowest position of R14
            bis.b   R15, R14

            dec     R13                     ; Loop if not done based on bit counter in R13
            jnz     next_bit_rx

            mov.b   R14,R15                 ; Move output to R15

            pop     R13
            pop     R14
            ret



;------------------------------------i2c_rx_ack--------------------------------------------
; Result of ack read in R15
; R15==0 ack received
; R15==1 nack received
i2c_rx_ack:  

            bic.b   #BIT5, &P2OUT           ; SCL low
            call    #i2c_delay      
            data_high                       ; Bring data high, sets line as input

            call    #i2c_delay
            bis.b   #BIT5, &P2OUT           ; Clock high            
            call    #i2c_delay

            cmp     #BIT4, &P2IN            ; Check if SDA is low
            jz      ack_received            ; If low, ack received
            jnz     nack_received           ; If high, nack received

            

ack_received
            mov.b   #0, R15                 ; Store ack/nack result in R15
            jmp     ack_end
nack_received
            mov.b   #1, R15
            ;jmp     i2c_stop               ; Bring back maybe?

ack_end     
            call    #i2c_delay
            ret


;------------------------------------i2c_tx_ack--------------------------------------------
; Tx an ack/nack (selectable via R15)
; R15==0 send ack
; R15==1 send nack
i2c_tx_ack:
            bic.b   #BIT5, &P2OUT       ; Clock low
            call    #i2c_delay

            cmp     #0, R15             ; Check R15 for ack/nack selection
            jz      send_ack
            
            jmp     send_nack

send_ack    
            data_low                        ; Bring data line low if R14 low
            jmp     send_end

send_nack
            data_high                       ; Bring data high if R14 high
            
send_end    
            call    #i2c_delay
            bis.b   #BIT5, &P2OUT       ; Clock high
            call    #i2c_delay
            call    #i2c_delay          ; Finish out clock pulse
            ret




            
