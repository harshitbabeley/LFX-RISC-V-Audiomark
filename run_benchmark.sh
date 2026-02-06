#!/bin/bash

runs=100
sum_ref=0
sum_rvv=0

for i in $(seq 1 $runs); do

    output=$(qemu-riscv64 -d in_asm -D q15_axpy_modified.log ./q15_axpy_modified)

    # Extract numbers
    ref=$(echo "$output" | grep "Cycles ref" | awk '{print $3}')
    rvv=$(echo "$output" | grep "Cycles RVV" | awk '{print $3}')

    sum_ref=$((sum_ref + ref))
    sum_rvv=$((sum_rvv + rvv))
done

mean_ref=$(echo "scale=2; $sum_ref / $runs" | bc)
mean_rvv=$(echo "scale=2; $sum_rvv / $runs" | bc)

echo "----------------------------------"
echo "Mean Cycles ref : $mean_ref"
echo "Mean Cycles RVV : $mean_rvv"
echo "----------------------------------"
