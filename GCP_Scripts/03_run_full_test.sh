#!/bin/bash

PROJECT_ID="inserisci-il-tuo-project-id"
REGION="europe-west1"

echo "Eliminazione cluster DataProc..."
for cluster in $(gcloud dataproc clusters list --region=${REGION} --project=${PROJECT_ID} --format="value(name)"); do
    gcloud dataproc clusters delete $cluster --region=${REGION} --project=${PROJECT_ID} --quiet
done

echo "Eliminazione VM Compute Engine..."
for zone in $(gcloud compute zones list --project=${PROJECT_ID} --format="value(name)"); do
  for inst in $(gcloud compute instances list --project=${PROJECT_ID} --zones=$zone --format="value(name)"); do
    gcloud compute instances delete $inst --zone=$zone --project=${PROJECT_ID} --quiet
  done
done

echo "Eliminazione dischi persistenti orfani..."
for zone in $(gcloud compute zones list --project=${PROJECT_ID} --format="value(name)"); do
  for disk in $(gcloud compute disks list --project=${PROJECT_ID} --zones=$zone --filter="-users:*" --format="value(name)"); do
    gcloud compute disks delete $disk --zone=$zone --project=${PROJECT_ID} --quiet
  done
done

echo "Eliminazione bucket Cloud Storage..."
for bucket in $(gsutil ls -p $PROJECT_ID); do
  gsutil -m rm -r $bucket
done

echo "Eliminazione Cloud SQL instances..."
for sql in $(gcloud sql instances list --project=${PROJECT_ID} --format="value(name)"); do
    gcloud sql instances delete $sql --project=${PROJECT_ID} --quiet
done

echo "Pulizia completata!"
