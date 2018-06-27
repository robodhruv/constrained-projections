%% Designing Constrained Projections for Compressed Sensing
% Constrained optimization using statistical priors. GMM prior
% on patches (known) is assumed.
% Written by Dhruv Ilesh Shah (dhruv.ilesh@gmail.com)

%% init
clear all; close all;
patch_dim = 16;
rng(40);
n = patch_dim^2;
ind = 1:patch_dim^2;
noise_level = 0.02; % 2% noise
mean_y = 60; % Empirically determined for some images in dataset -- 10081
noise_val = noise_level * mean_y;

addpath('../misc')
% load('../gmm-train/results/gmm-minib_exh_50'); % Loading synthetic GMM model & data
load('../gmm-train/results/trained-model.mat'); % Loading GMM model

means = model_gmm.mu;
sigma = model_gmm.Sigma;
comp = size(sigma, 3);
w = model_gmm.w;
max_iter = 1;
M = 32; % Number of measurements

% Choose seeding matrix
% phi_org = randn(M, patch_dim^2); mode = 'Random Gaussian';
% phi_org = double(randn(M, patch_dim^2) > 0); mode = 'Binary Mask';
% phi_org = phi_org / max(max(abs(phi_org))); mode = strcat('Constrained', mode);
% phi_org = (phi_org + 1) / 2;
phi_org = rand(M, patch_dim^2); mode = 'Uniform Random';
phi = phi_org;
phi_con = phi;
phi_con_prev = phi_con;
k_w = eye(M) * noise_val^2;
step_size = 25; % Fixed for now
mmse = zeros(max_iter, comp);
k_e = zeros([patch_dim^2, patch_dim^2, comp]);

for j = 1:max_iter
    disp(strcat('iter: ', num2str(j)))
    phi_con_prev = phi_con;
    % Taking projection on the set of interest
    phi_con = get_projection(phi);

    for c = 1:comp
        S = sigma(:, :, c);
        k_e(:, :, c) = inv(inv(S) + ((phi_con' * phi_con) ./ (noise_val^2))); % Error covariance matrix
        mmse(j, c) = trace(k_e(:, :, c));
    end

    if (j > 1)
        if (sum(mmse(j, :)) > sum(mmse(j-1, :)))
            step_size = step_size / 2; % Adaptive Step Size
            phi_con = phi_con_prev;
        end
    end

    if mod(j, 10)==0
        disp(mmse(j))
    end

    % Projected gradient descent
    for k = 1:size(phi, 1)
        disp(strcat('Row: ', num2str(k)))
        for l = 1:size(phi, 2)
            % Descending on mmse for \Phi_{ij} (Refer supplemental material for proof)
            % Let A = inv(k_e);
            grad_term = 0;
            del_A = ([zeros(n, l-1), phi_con(k, :)', zeros(n, n-l)] + [zeros(l-1, n); phi_con(k, :); zeros(n-l, n)]) / noise_val^2;
            for c = 1:comp
                del_mmse = -1 * trace(k_e(:, :, c) * k_e(:, :, c) * del_A);
                grad_term = grad_term + (del_mmse * w(c));
            end
            phi(k, l) = phi_con(k, l) -  step_size * grad_term;
        end
    end
end

% figure('Position', [100 100 1600 400]);
% subplot(1, 3, 1), imagesc(phi_org); colorbar;
% title('\Phi_o');
% subplot(1, 3, 2), imagesc(phi_con); colorbar;
% title('\Phi_c after Projected GD on MMSE');
% subplot(1, 3, 3), imagesc(abs(phi_con - phi_org)); colorbar;
% title('| \Phi_c - \Phi_o |');