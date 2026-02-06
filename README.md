# RISC-V Audiomark - Coding Challenge
## Problem Statement:
To compute:
Q15 y = a + alpha * b using vector intrinsics of riscv where <br>
• a[i], b[i], alpha are signed Q15 (int16_t) <br>
•	Final result must saturate to [-32768, 32767]
## Design Choice:
1.	Load 16-bit
2.	Widen to 32-bit
3.	Multiply (vector-scalar widen)
4.	Accumulate in 32-bit
5.	Saturating narrow back to 16-bit
6.	Store
## Implementation:
    int i = 0;
    while (i < n) {
        size_t vl = __riscv_vsetvl_e16m1(n - i);
        // Load a[i] and b[i]
        vint16m1_t va16 = __riscv_vle16_v_i16m1(&a[i], vl);
        vint16m1_t vb16 = __riscv_vle16_v_i16m1(&b[i], vl);

        // Widen b to 32-bit and multiply with scalar alpha
        vint32m2_t vb32 = __riscv_vwmul_vx_i32m2(vb16, alpha, vl);

        // Widen a to 32-bit
        vint32m2_t va32 = __riscv_vwcvt_x_x_v_i32m2(va16, vl);

        // Accumulate in 32-bit
        vint32m2_t vacc = __riscv_vadd_vv_i32m2(va32, vb32, vl);

        // Saturate to Q15
        vint16m1_t vy16 = __riscv_vnclip_wx_i16m1(vacc, 0, vl);

        // Store result
        __riscv_vse16_v_i16m1(&y[i], vy16, vl);

        i += vl;
	cycles++;
    }

  ## File Structure and Usage
  **Source Files** : q15_axpy_challenge.c (boilerplate used) and q15_axpy_challenge_modified.c (modified q15_challenge.c to print no of iterations for each scalar and vector implmentation) <br><br>
  **Object Files** : q15_axpy and q15_axpy_modified Obtained after building the .c files using
  
    riscv64-linux-gnu-gcc   -O2   -march=rv64gcv   -static   q15_axpy_challenge.c   -o q15_axpy

**Log files** : q15_axpy.log and q15_axpy_modified.log Contain the asm of the object files, genrated by using 

    qemu-riscv64 -d in_asm -D q15_axpy.log ./q15_axpy

**Script file** : run_benchmark.sh to test the speedup obatined while emulating riscv64 on qemu 

    ./run_benchmark.sh

## Results Obtained:
The theorteical speedup was around 6.2x. The vlen for the system tested on was 8 and the no of instructions per iteration were 14 and 18 for scalar and vector implemanetions respectively.
Since the system was veified using qemu the results devieated from ideality, but showed vector to be bit‑for‑bit identical to the scalar reference for all tested inputs (the harness will check).
