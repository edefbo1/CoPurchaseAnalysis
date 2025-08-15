#!/bin/bash
# Crea un cluster DataProc per test di co-acquisto
# Utilizzo: ./create_cluster.sh <cluster-name> <region> <num-workers>

CLUSTER_NAME=$1
REGION=$2
NUM_WORKERS=$3

gcloud dataproc clusters create $CLUSTER_NAME \
  --region=$REGION \
  --num-workers=$NUM_WORKERS \
  --master-boot-disk-size=240 \
  --worker-boot-disk-size=240 \
  --image-version=2.1-debian11
