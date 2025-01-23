

            .text                           ; Assemble to Flash memory
            .retain                         ; Ensure current section gets linked
            .retainrefs


            


i2c_delay:

            mov.w   #3, R14

delay:
            dec     R14
            jnz     delay

            ret
