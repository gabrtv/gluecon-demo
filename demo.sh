#!/bin/bash

. ./util.sh

run "cat broker.yaml"

run "kubectl --context service-catalog get broker -o yaml"

run "kubectl --context service-catalog get serviceclass"

run "cat demo/instance.yaml"

run "kubectl --context service-catalog create -f demo/instance.yaml"

run "kubectl --context service-catalog get instance demo-redis -o yaml"

run "kubectl --context service-catalog get instance"

run "kubectl --context service-catalog get instance redis -o yaml"

run "cat binding.yaml"

run "kubectl --context service-catalog create -f binding.yaml"

run "kubectl --context service-catalog get binding redis -o yaml"

run "kubectl get secret redis-creds -o yaml"

run "cat deployment.yaml"

run "kubectl create -f deployment.yaml"