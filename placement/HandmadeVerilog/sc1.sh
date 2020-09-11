#!/bin/bash

for counter in $(seq 0 100); do
    cp listas/qspline/qspline_$counter.* qspline.in
    python script_exec.py qspline
    mv result_qspline.txt res_qspline$counter.txt
    #done

done

