#!/bin/bash
# Carica dataset o jar su un bucket GCS
# Utilizzo: ./upload_to_gcs.sh <local-file-path> <gcs-bucket-path>

FILE_PATH=$1
GCS_PATH=$2

gsutil cp $FILE_PATH $GCS_PATH
