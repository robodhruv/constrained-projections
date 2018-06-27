%% Comparing reconstruction results using various methods
%  Written by Dhruv Ilesh Shah (dhruv.ilesh@gmail.com)

%% init
clear all; close all;
addpath('../misc/spgl1');
addpath('../misc');

rng(1);
patch_dim = 16;
load('../gmm-train/results/trained_model.mat');

% Choose image from `<base>/datasets/` or use your own
img_path = '../datasets/bsds_minib_test/201080.jpg'

I = imread(img_path);
I = im2double(rgb2gray(I));
img_dim = size(I);
I = I(1:uint16(img_dim(1)/16)*16, 1:uint16(img_dim(2)/16)*16);
patches = get_patches(I, 0, patch_dim, 'exhaustive')';
num_patches = size(patches, 2);
M = 32;
mu = model_gmm.mu;
sigma = model_gmm.Sigma;
comp = size(sigma, 3);

% Pre-allocating matrices
premult = zeros([patch_dim^2, M, comp]);
rmse = zeros([num_patches, 4]);
recon = zeros([patch_dim^2, num_patches, 4]);
sig_inv = zeros(size(sigma));
sig_det_log = zeros(size(sigma, 3));
noise_lev = 0.01; % Noise STD fraction


% Choose representation (sparsifying) basis
psi = kron(dctmtx(patch_dim)', dctmtx(patch_dim)');
% psi = kron(haarmtx(patch_dim)', haarmtx(patch_dim)');
load(strcat('../designed-matrices/coherence-opt/2ddct/projected/coherence-opt-16-M', num2str(M), '.mat'));
phi_sanei_org = phi_org; phi_sanei_con = phi_con;
load(strcat('../designed-matrices/mmse-opt/mmse-opt-M', num2str(M), '.mat'));
phi_mmse_org = phi_org; phi_mmse_con = phi_con;

tic;
for id = 1:4
    if (id==1 || id==3)
        phi_c = phi_org; % phi_mmse_org = phi_sanei_org;
    elseif (id==2)
        phi_c = phi_sanei_con;
    elseif (id==4)
        phi_c = phi_mmse_con;
    end
    if (id==1 || id==2)
        % L1 recovery
        disp(strcat('ID: ', num2str(id)))
        mean_y = mean2(abs(phi_c * patches));
        A = phi_c * psi;
        sigma_n = noise_lev * mean_y;
        epsilon = sigma_n * sqrt(M) * sqrt(1 + 2 * sqrt(2) / sqrt(M));
        
        for i = [1:size(patches, 2)]
            x = patches(:, i);
            y = phi_c * x + (randn(M, 1) * sigma_n);

        % Choose package for L1 recovery
            % CVX
        % 	cvx_begin quiet
        % 		variable dec_t(N, 1)
        % 		minimize(norm(dec_t, 1))
        % 		subject to
        % 			norm(y - A * dec_t) <= epsilon
        % 	cvx_end

            % l1-magic
        %     t0 = pinv(A) * y;
        %     dec_t = l1qc_logbarrier(t0, A, [], y, epsilon, 1e-3);

            % SPGL1
            opts = spgSetParms('verbosity',0);
            dec_t = spg_bpdn(A, y, epsilon, opts);

           
            recon(:, i, id) = psi * dec_t;
            rmse(i, id) = mean((x - (psi*dec_t)) .^ 2) / mean(x.^2);
        end
        
    end
    if (id==3 || id==4)
        % SCS recovery
        disp(strcat('ID: ', num2str(id)))
        mean_y = mean2(abs(phi_c * patches));
        sigma_n = noise_lev * mean_y;
        for i = 1:comp
            S = sigma(:, :, i);
            sig_inv(:, :, i) = inv(S);
            sig_det_log(i) = log(det(S));
            premult(:, :, i) = S * phi_c' / (((phi_c * S * phi_c')  + (eye(size(phi_c, 1)) * (sigma_n.^2))));
        end
        for i = 1:num_patches
%             disp(strcat('Patch:', num2str(i)))
            x = patches(:, i);
            y = phi_c * x + (randn(M, 1) * sigma_n);
            [dec_x, id_dec] = pwl_decoder(y, phi_c, sigma, mu, comp, sigma_n, sig_det_log, sig_inv, premult);
            recon(:, i, id) = dec_x;
            rmse(i, id) = min(mean((dec_x - x).^2) / mean(x.^2), 1.0);
        end
    end
end
toc

vis_results;