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

    ; command == "help"?
    la r1, help
    call strcmp
    nop
    beqz r4, show_help
    nop

    ; command == "gpio on"?
    la r1, gpio_on
    call strcmp
    nop
    beqz r4, do_gpio_on
    nop

    ; command == "gpio off"?
    la r1, gpio_off
    call strcmp
    nop
    beqz r4, do_gpio_off
    nop

    ; command == "2048"?
    la r1, _2048
    call strcmp
    nop
    beqz r4, call_2048
    nop

    ; command == "reboot"?
    la r1, reboot
    call strcmp
    nop
    beqz r4, do_reboot
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
    la r0, running_server
    call puts
    nop
    ; goto 0x0003
    li r0, 0x0003
    jr r0
    nop

show_help:
    la r0, usage
    call puts
    nop
    b shell_loop
    nop

do_gpio_on:
    la r0, gpio_base
    li r1, 0x0000 ; out
    sw r0, r1, 1 ; gpio control
    li r1, 0xffff ; on
    sw r0, r1, 0 ; gpio data
    b shell_loop
    nop
do_gpio_off:
    la r0, gpio_base
    li r1, 0x0000 ; out
    sw r0, r1, 1 ; gpio control
    li r1, 0x0000 ; off
    sw r0, r1, 0 ; gpio data
    b shell_loop
    nop

do_reboot:
    ; goto 0x0000
    li r0, 0
    jr r0
    nop

call_2048:
    call game_2048
    nop
    call clear_screen
    nop
    b shell_loop
    nop