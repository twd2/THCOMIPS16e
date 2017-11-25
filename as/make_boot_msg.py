
message = b'System is booting...'
message += b' ' * (80 - len(message))
message += b'If you wait too long, please check SD card.'

with open('boot.bin', 'wb') as f:
    for b in message:
        f.write(bytes([b, 0x07]))