#!/bin/bash
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.05b."
./exec.py 0.05b_coalesce_config.ini
sleep 30s
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.06b."
./exec.py 0.06b_coalesce_config.ini
sleep 30s
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.07b."
./exec.py 0.07b_coalesce_config.ini
sleep 30s
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.08b."
./exec.py 0.08b_coalesce_config.ini
sleep 30s
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.09b."
./exec.py 0.09b_coalesce_config.ini
sleep 30s
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.1b."
./exec.py 0.1b_coalesce_config.ini
sleep 30s
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.2b."
./exec.py 0.2b_coalesce_config.ini
sleep 30s
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.3b."
./exec.py 0.3b_coalesce_config.ini
sleep 30s
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.4b."
./exec.py 0.4b_coalesce_config.ini
sleep 30s
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.5b."
./exec.py 0.5b_coalesce_config.ini
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Succeeded!"
