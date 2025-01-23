

            .text                           ; Assemble to Flash memory
            .retain                         ; Ensure current section gets linked
            .retainrefs


            


i2c_delay:

            mov.w   #3, R14                 ; 25 us delay (actual 24.8 us)

delay:
            dec     R14
            jnz     delay

            ret
