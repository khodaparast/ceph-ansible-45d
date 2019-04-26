#!/bin/bash
for i in {1..3};do
	for j in {b..p};do
		ssh vosd$i wipefs -a /dev/sd$j
	done
done
