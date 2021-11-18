#docker pull openvino/ubuntu18_data_dev
#docker run -it --device /dev/dri:/dev/dri --device-cgroup-rule='c 189:* rmw' -v /dev/bus/usb:/dev/bus/usb --rm openvino/ubuntu18_data_dev:latest
source /opt/intel/openvino_2021.4.752/bin/setupvars.sh
python3 gesture_recognition_demo.py \
    -m_a asl-recognition-0004.xml \
    -m_d person-detection-asl-0001.xml \
    -i 0 
    -c msasl100.json
