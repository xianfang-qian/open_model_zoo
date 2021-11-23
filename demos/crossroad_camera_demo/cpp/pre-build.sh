source /opt/intel/openvino_2021/bin/setupvars.sh
set INTEL_OPENVINO_DIR = /opt/intel/openvino_2021
python3 ${INTEL_OPENVINO_DIR}/deployment_tools/open_model_zoo/tools/downloader/downloader.py --list models.lst --precisions FP16-INT8 && \
python3 ${INTEL_OPENVINO_DIR}/deployment_tools/open_model_zoo/tools/downloader/converter.py --list models.lst
