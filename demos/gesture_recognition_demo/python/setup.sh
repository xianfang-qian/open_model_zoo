#source /opt/ov2021.4-venv/bin/activate
python3 gesture_recognition_demo.py \
    -m_a asl-recognition-0004.xml \
    -m_d person-detection-asl-0001.xml \
    -i 0 
    -c msasl100.json
