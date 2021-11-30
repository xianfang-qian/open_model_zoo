source /opt/intel/openvino_2021/bin/setupvars.sh && \
   python3 human_pose_estimation_3d_demo.py \
    -i face-demographics-walking-and-pause.mp4 \
    -m human-pose-estimation-3d-0001.xml \    
    -d CPU \
    --no_show \
    -o /data/outpit_human_pose_estimation.mp4
