#!/usr/bin/env bash

# critical VMs, when these are not running the others may not boot or build correctly
microvm -Ru svc-fpx01
# fpx may need some time to finish building
sleep 5000

microvm -Ru svc-pg01
microvm -Ru svc-mari01

for vm in /var/lib/microvms/*; do
  microvm -Ru "$(basename "$vm")"
done
