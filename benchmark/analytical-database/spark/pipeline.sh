#!/bin/bash
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.05b."
./submit.sh  0.05b_coalesce_config.ini
sleep 60s
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.06b."
./submit.sh  0.06b_coalesce_config.ini
sleep 60s
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.07b."
./submit.sh 0.07b_coalesce_config.ini
sleep 90s
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.08b."
./submit.sh 0.08b_coalesce_config.ini
sleep 90s
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.09b."
./submit.sh 0.09b_coalesce_config.ini
sleep 120s
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.1b."
./submit.sh 0.1b_coalesce_config.ini
sleep 150s
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.2b."
./submit.sh 0.2b_coalesce_config.ini
sleep 300s
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.3b."
./submit.sh 0.3b_coalesce_config.ini
sleep 300s
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.4b."
./submit.sh 0.4b_coalesce_config.ini
sleep 300s
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Start to test 0.5b."
./submit.sh 0.5b_coalesce_config.ini
echo "[INFO | $(date +%Y%m%d-%H:%M:%S) ] Succeeded!"
