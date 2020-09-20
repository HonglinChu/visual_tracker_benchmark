# visual_tracker_benchmark
OTB 工具箱优化,代码同样适用 VisDrone,UAVDT,DTB70,UAV123等(只要是OTB评价标准的Success和Precision都可以适用)

## 原始工具箱功能 
- configSeqs.m 配置视频序列

- configTrackers.m 配置跟踪器

- main_running.m 在指定视频序列上运行跟踪器

- perfPlot.m 画出精度图和成功率图

- drawResultBB.m 画出指定跟踪器在指定序列指定序列上的跟踪框（bounding box）

## 我们的扩展

- hp_search.m 支持多线程调参

- main_parpool.m  支持多线跑数据集

- Curve_perfPlot.m 可视化每一个视频的位置误差和重叠率

![image](https://github.com/HonglinChu/visual_tracker_benchmark/blob/master/O-Bird1.png)

![image](https://github.com/HonglinChu/visual_tracker_benchmark/blob/master/E-Bird1.png)

## matlab画图指南
https://mp.weixin.qq.com/s/blSO9Ci15DMidrGudIGNkQ
