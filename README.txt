项目报告：report/report.pdf
硬件源代码工程文件：sopc/sopc.xise
软件源代码：as/*

软件构建方法：
1. 进入as目录，执行make.sh，得到a.out
2. 进入badapple目录，用Python 3执行make_img.py，得到sd.img
3. 将刚才得到的sd.img写入SD卡