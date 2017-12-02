blocks = ['Colin','bill125','lazycal','twd2','fsygd','wuhz','YYF','128','256','512','1024','lss']
for block in blocks:
    l = len(block)
    ll = (12 - l) / 2
    for i in range(ll):
        print '.word 32'
    for char in block:
        print '.word \'' + char + '\''
    for i in range(12 - l -ll):
        print '.word 32'