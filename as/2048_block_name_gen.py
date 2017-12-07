blocks = ['Colin','bill125','lazycal','twd2','fsygd','wuhz','YYF','128','256','512','1024','lss']
notice = 'Welcome to 2048 game!'
help = '[N]: new game, [Q]: store and quit, [W]\\[S]\\[A]\\[D]: up\\down\\left\\right'
for block in blocks:
    l = len(block)
    ll = (12 - l) / 2
    for i in range(ll):
        print '.word 32'
    for char in block:
        print '.word \'' + char + '\''
    for i in range(12 - l -ll):
        print '.word 32'
for char in notice:
	print '.word \'' + char + '\''
for char in help:
	print '.word \'' + char + '\''
