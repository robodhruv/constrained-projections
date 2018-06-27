num_patches = 1e5; % Irrelevant in an exhaustive sampling case
patches = load_data('bsds500\minibatch\', num_patches, 16, 'exhaustive');

k = 50; % GMM mixture components
[labels, model_gmm, llh] = mixGaussEm(patches', k);
save(strcat('results/gmm-train_', num2str(num_patches), '_', num2str(k), '.mat'), 'model_gmm', 'llh');