#!/bin/bash


ZONE="us-central1-a"
MACHINE_TYPE="n1-standard-1"
INSTANCE_NAME="my-instance"
DISK_NAME="my-disk"
DATABASE_NAME="my-db"
TABLE_NAME="my-table"
PROJECT_ID="my-project"


gcloud compute instances create $INSTANCE_NAME \
  --machine-type $MACHINE_TYPE \
  --zone $ZONE \
  --image-project debian-cloud \
  --image-family debian-10 \
  --boot-disk-size 10GB \
  --boot-disk-type pd-standard \
  --tags http-server,https-server


gcloud compute ssh $INSTANCE_NAME --zone $ZONE --command "sudo apt-get update && sudo apt-get install -y apache2"


gcloud compute disks create $DISK_NAME \
  --size 100GB \
  --zone $ZONE

gcloud compute instances attach-disk $INSTANCE_NAME \
  --disk $DISK_NAME \
  --zone $ZONE


gcloud sql instances create $DATABASE_NAME \
  --tier=db-n1-standard-1 \
  --region=us-central1 \
  --database-version=MYSQL_5_7 \
  --storage-auto-increase \
  --project=$PROJECT_ID


gcloud sql databases create $DATABASE_NAME \
  --instance=$DATABASE_NAME \
  --project=$PROJECT_ID

gcloud sql connect $DATABASE_NAME --user=root --quiet --project=$PROJECT_ID << EOF
CREATE TABLE $TABLE_NAME (
  id INT NOT NULL AUTO_INCREMENT,
  temperature FLOAT NOT NULL,
  humidity FLOAT NOT NULL,
  timestamp TIMESTAMP NOT NULL,
  PRIMARY KEY (id)
);
EOF
