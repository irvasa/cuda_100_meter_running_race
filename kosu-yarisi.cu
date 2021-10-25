

#include <stdio.h>
#include "device_launch_parameters.h"
#include <curand.h>
#include <curand_kernel.h>
#include "cuda_runtime.h"

#define N 100 /* runners*/
#define MAX 6 /* runners max speed 5 */

/* this GPU kernel function is used to initialize the random states */
__global__ void init(unsigned int seed, curandState_t* states) {

    /* we have to initialize the state */
    curand_init(seed, blockIdx.x, 0, &states[blockIdx.x]);
}

/* this GPU kernel takes an array of states, and an array of ints, and puts a random int into each */
__global__ void randoms(curandState_t* states, unsigned int* speeds) {


    speeds[blockIdx.x] = curand(&states[blockIdx.x]) % 6;
    if (speeds[blockIdx.x] == 0)
        speeds[blockIdx.x] += 1;

}
void Delay(undigned int time) {
    for(int j=0; j<time;j++){}
}



int main() {

   
  //vaariables
    curandState_t* states;
    unsigned int cpu_nums[N];
    unsigned int* gpu_nums;
    unsigned int location[N];
    unsigned int i;
    
    while (1) {
        unsigned int wait = 100000;

        /* allocate space on the GPU for the random states */
        cudaMalloc((void**)&states, N * sizeof(curandState_t));

        /* invoke the GPU to initialize all of the random states */
        init << < N, 1 >> > (time(0), states);
        cudaDeviceSynchronize();
        /* allocate an array of unsigned ints on the CPU and GPU */

        cudaMalloc((void**)&gpu_nums, N * sizeof(unsigned int));

        /*  kernel to get some random numbers */
        randoms << < N, 1 >> > (states, gpu_nums);
        cudaDeviceSynchronize();

        /* copy the random numbers back */
        cudaMemcpy(cpu_nums, gpu_nums, N * sizeof(unsigned int), cudaMemcpyDeviceToHost);


        /* print them out */
        for (i = 0; i < N; i++) {
            location[i] = cpu_nums[i] + location[i];
            printf("%d  nolu yarismaci \t %u anlik hizi \t %u yarismaci konumu \n", i, cpu_nums[i], location[i]);
        }

        Delay(wait);

        /* free the memory we allocated for the states and numbers */
        cudaFree(states);
        cudaFree(gpu_nums);


    }
    
    
   return 0;
}