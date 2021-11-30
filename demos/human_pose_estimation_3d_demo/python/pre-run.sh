source /opt/intel/openvino_2021/bin/setupvars.sh
pip install -r requirements.txt

set INTEL_OPENVINO_DIR = /opt/intel/openvino_2021
python3 ${INTEL_OPENVINO_DIR}/deployment_tools/open_model_zoo/tools/downloader/downloader.py --list models.lst && \
python3 ${INTEL_OPENVINO_DIR}/deployment_tools/open_model_zoo/tools/downloader/converter.py --list models.lst
