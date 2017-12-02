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

    ; command == "server"?
    la r1, server
    call strcmp
    nop
    beqz r4, goto_server
    nop

    la r1, empty_string
    call strcmp
    nop
    beqz r4, shell_loop
    nop

    ; print "Unknown command: xxx\n"
    move r1, r0
    la r0, unknown_command
    call puts
    nop
    move r0, r1
    call puts
    nop
    li r0, 10
    call putchar
    nop

    b shell_loop
    nop

goto_server:
    ; goto 0x0003
    li r0, 0x0003
    jr r0
    nop