# CATS: Cat Activity Tracking System
This project implements a visual tracking system for tracking cats in a video, 
although the algorithm does not reply on the prior that the target is a cat.
The system first detect the cat in the first frame, 
and then use a tracking algorithm to estimate the positio of the cat in subsequent frames.

[Faster R-CNN](https://github.com/ShaoqingRen/faster_rcnn) is used for the detection part,
and the tracking part is our own implementation of [RTCST](http://ieeexplore.ieee.org/xpl/login.jsp?tp=&arnumber=5995483&url=http%3A%2F%2Fieeexplore.ieee.org%2Fxpls%2Fabs_all.jsp%3Farnumber%3D5995483).

# Install
```
git clone https://github.com/sizhuom/CATS.git
```
This software depends on Faster R-CNN
```
cd CATS
git clone https://github.com/ShaoqingRen/faster_rcnn.git
```
Also notice that Faster R-CNN depends on Caffe. 
Please check the instructions of [Faster R-CNN](https://github.com/ShaoqingRen/faster_rcnn) for how to install Caffe.

# Usage
See video_test.m
