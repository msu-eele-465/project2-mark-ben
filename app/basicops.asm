            .text                           ; Assemble to Flash memory
            .retain                         ; Ensure current section gets linked
            .retainrefs


i2c_start:
            bis.b   #BIT4,&P2OUT            ; Bring data line low
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