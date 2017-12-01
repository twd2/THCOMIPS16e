s = input()
for ch in s:
    if ch not in ['\'', ' ', ',', ':']:
        print('.word \'{}\''.format(ch))
    else:
        print('.word {}'.format(ord(ch)))