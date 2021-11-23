#!/bin/bash
source /opt/intel/openvino_2021/bin/setupvars.sh 
crossroad_camera_demo \
    -i ./people-detection.mp4 \
    -m ./intel/person-vehicle-bike-detection-crossroad-0078/FP16-INT8/person-vehicle-bike-detection-crossroad-0078.xml \
    -m_pa ./intel/person-attributes-recognition-crossroad-0230/FP16-INT8/person-attributes-recognition-crossroad-0230.xml \
    -m_reid ./intel/person-reidentification-retail-0287/FP16-INT8/person-reidentification-retail-0287.xml \
    -d CPU \
    -no_show \
    -o ./cpp-test-result-210813.mp4
