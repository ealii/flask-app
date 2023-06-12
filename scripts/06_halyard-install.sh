#!/bin/bash

# https://spinnaker.io/docs/setup/install/halyard/#install-halyard-on-docker

HALYARD_DATA=`realpath ../.hal`

mkdir -p $HALYARD_DATA
chmod -R 777 $HALYARD_DATA

docker run -it \
    --name halyard \
    --network host \
    --volume $HALYARD_DATA:/home/spinnaker/.hal \
    --volume ~/.kube:/home/spinnaker/.kube:ro \
    --volume $PWD:/home/spinnaker/scripts:ro \
    --workdir /home/spinnaker/scripts \
    --rm \
    --detach \
    us-docker.pkg.dev/spinnaker-community/docker/halyard:1.55.0

docker exec -it halyard bash