/*

to compile this code 
  >> nvcc simple_cuda_test.cu -o cuda_test
to profile execution speed
  >> nvprof cuda_test.exe
  
  runs in 456.87 us on my laptop with GeForce GT 745M

*/


#include <iostream>
#include <math.h>

// this function implements grid-sride loop
__global__
void add(int n, float *x, float *y)
{
  int index = blockIdx.x * blockDim.x + threadIdx.x;
	
	int stride = blockDim.x * gridDim.x;

  for (int i = index; i < n; i += stride) 
  {
		y[i] = x[i] + y[i];
	}
}

int main(void)
{
  int N = 1<<20; 
  float *x, *y;

  cudaMallocManaged(&x, N*sizeof(float));
  cudaMallocManaged(&y, N*sizeof(float));

  for (int i = 0; i < N; i++) {
    x[i] = 1.0f;
    y[i] = 2.0f;
  }

  int blockSize = 256;
  int numBlocks = (N + blockSize - 1) / blockSize;

  // 4069x256 
  add<<<numBlocks, blockSize>>>(N, x, y);

  cudaDeviceSynchronize();

  // Check for errors (all values should be 3.0f)
  float maxError = 0.0f;
  for (int i = 0; i < N; i++)
  {
    maxError = fmax(maxError, fabs(y[i]-3.0f));
  }
  std::cout << "Max error: " << maxError << std::endl;

  cudaFree(x);
  cudaFree(y);
  
  return 0;
}
