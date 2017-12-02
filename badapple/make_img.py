
with open('sd.img', 'wb') as fout:
    with open('../as/a.out', 'rb') as f:
        code = f.read()
        fout.write(code)
    fout.seek(65536 * 512) # 1 * 64K + 0 sector
    with open('badapple.out', 'rb') as f:
        badapple = f.read()
        fout.write(badapple)
    # fout.seek(3 * 65536 * 512) # 3 * 64K + 0 sector
    # with open('badapple_ascii.out', 'rb') as f:
    #    badapple = f.read()
    #    fout.write(badapple)