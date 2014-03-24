#!/bin/bash
set -e

mkdir -p cgroup
mount -t cgroup cgroup cgroup || :


# this is what we need for the veth setup
brctl addbr br0
ifconfig br0 10.0.3.1/24
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -A POSTROUTING -s 10.0.3.0/24 -t nat -j MASQUERADE


# this is what we need for the macvlan setup
brctl addbr br1
ifconfig br1 up
