source /opt/intel/openvino_2021/bin/setupvars.sh && \
   python3 instance_segmentation_demo.py \
      -m /opt/app-root/intel/instance-segmentation-security-0228/FP32/instance-segmentation-security-0228.xml \
     --label coco_80cl.txt \
     --no_keep_aspect_ratio \
     -i classroom.mp4 \
     --delay 1
     -o /data/outpit_instance_segmentation.mp4
