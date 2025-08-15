#!/bin/bash
# Sottomette un job Spark al cluster DataProc
# Utilizzo: ./submit_job.sh <cluster-name> <region> <jar-gcs-path> <input-file-gcs> <output-file-gcs> [extra-args]

CLUSTER_NAME=$1
REGION=$2
JAR_PATH=$3
INPUT_PATH=$4
OUTPUT_PATH=$5
EXTRA_ARGS=${@:6}

gcloud dataproc jobs submit spark \
  --cluster=$CLUSTER_NAME \
  --region=$REGION \
  --jar=$JAR_PATH \
  -- $INPUT_PATH $OUTPUT_PATH $EXTRA_ARGS
