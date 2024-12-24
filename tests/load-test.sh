#!/bin/bash

SERVICE_NAME="php-apache-service" 
NAMESPACE="services"              

# Create a load generator pod
kubectl run -i \
  --tty load-generator \
  --rm --image=busybox \
  --restart=Never \
  --namespace=${NAMESPACE} \
  -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://${SERVICE_NAME}:80; done"
