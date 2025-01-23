            .cdecls C,LIST,"msp430.h"  ; Include device header file
            .include "delay.asm"
            
            
            .text                           ; Assemble to Flash memory
            .retain                         ; Ensure current section gets linked
            .retainrefs


i2c_start:
            bic.b   #BIT4,&P2OUT            ; Bring data line low
            call    #i2c_delay
            ret

i2c_stop:   
            bic.b   #BIT5,&P2OUT            ; Bring clock low
            call    #i2c_delay
            bic.b   #BIT4,&P2OUT            ; Bring data low if not already
            call    #i2c_delay
            bis.b   #BIT5,&P2OUT            ; Bring clock back high
            call    #i2c_delay
            bis.b   #BIT4,&P2OUT            ; Bring data high to signify stop
            call    #i2c_delay
            ret


; Take bit to send on R15
i2c_tx_bit:
            bic.b   #BIT5,&P2OUT            ; Bring clock low
            call    #i2c_delay

            cmp     #0,R15                  ; Check data passed
            jz      data_zero
            bis.b   #BIT4,&P2OUT            ; Set data high if passed 1
            jmp     data_one
data_zero   bic.b   #BIT4,&P2OUT            ; Set data low if passed 0
data_one    call    #i2c_delay
            
            bis.b   #BIT5,&P2OUT            ; Bring clock back high
            call    #i2c_delay
            call    #i2c_delay
            ret

; Take byte to send on R15
i2c_tx_byte:
            push    R14                     ; Store used registers on stack
            push    R13

            mov     R15, R14
            mov     #7, R13

next_bit    rlc.b   R14                     ; Grab MSB of R15
            jc      bit_one
            mov.b   #0, R15
            jmp     bit_zero
bit_one     mov.b   #1, R15
bit_zero    
            push    R14
            push    R13
            call    #i2c_tx_bit             ; Call subroutine to write bit
            pop     R13
            pop     R14

            cmp     #0, R13
            jz      end_byte
            dec     R13
            jmp     next_bit

end_byte    pop     R13
            pop     R14                     ; Grab original R14 off stack
            ret

i2c_ack_poll

            bic.b   #BIT5, &P2OUT           ; SCL low
            call    #i2c_delay      
            bis.b   #BIT4, &P2OUT           ; SDA high

            bis.b   #BIT4, &P2DIR           ; SDA to input

            call    #i2c_delay
            bis.b   #BIT5, &P2OUT           ; Clock high            
            call    #i2c_delay

            ;cmp     #1, &P2OUT
            call    #i2c_delay

            jmp      ack_received

ack_received
            ret


            
