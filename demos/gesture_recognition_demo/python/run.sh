#!/bin/bash
source /opt/intel/openvino_2021/bin/setupvars.sh &&\
python3 gesture_recognition_demo.py  -m_a asl-recognition-0004.xml -m_d person-detection-asl-0001.xml  -i gesture.jpg  -c msasl100.json -d CPU
