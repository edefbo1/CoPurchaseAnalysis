#!/bin/bash
# Cancella un cluster DataProc
# Utilizzo: ./delete_cluster.sh <cluster-name> <region>

CLUSTER_NAME=$1
REGION=$2

gcloud dataproc clusters delete $CLUSTER_NAME --region=$REGION --quiet
