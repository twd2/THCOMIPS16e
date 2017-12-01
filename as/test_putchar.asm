la r0, boot_message
call puts
nop

shell_loop:
    la r0, prompt
    call puts
    nop
    li r0, 0xb000 ; temp buffer
    call gets
    nop
    call puts
    nop
    li r0, 10
    call putchar
    nop
    b shell_loop
    nop
