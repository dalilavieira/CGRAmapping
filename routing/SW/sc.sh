#!/bin/bash

for i in `ls headers`
do
	#cat headers/$i
	cp headers/$i inputs.h
	gcc route36_1hop.c
	#g++ route36.cpp
	./a.out > $i
	python file2.py $i
done
