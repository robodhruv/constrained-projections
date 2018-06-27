This folder contains results of average coherence based design of sensing matrices as discussed in section 3. The folder contains 3 subfolders, based on the choice of sparsifying dictionary:
 1. `2ddct` - for signals sparse in the 2D Discrete Cosine Transforma basis
 2. `2dhaar` - for signals sparse in the 2D Haar Wavelet basis
 3. `canonical` - for signals sparse in the canonical basis

For a custom dictionary, you can design matrices using the scripts provided in `<base>/design-coherence-opt`.


For each sparsifying basis, matrices are optimized with and without accounting for constraints:
 * `vanilla/` - results with no optical constraints, and starting point as the same uniform random matrix
 * `projected/` - results with optical constraints imposed by performing a projected gradient descent with adaptive step size, using the same cost function