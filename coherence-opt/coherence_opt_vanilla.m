%% Designing Constrained Projections for Compressed Sensing
% Implementation of "Optimizing Measurement Matrix for Compressive Sensing" [Abolghasemi et al. 2010]
% Vanilla optimization of the sensing matrix be minimizing the
% coherence of D = \Phi\Psi. Optical constraints ignored.
% Written by Dhruv Ilesh Shah (dhruv.ilesh@gmail.com)

%% init
clear all; close all;
addpath('../misc');

patch_dim = 16;
measurements = [32, 48, 64, 96, 128];
N = patch_dim ^ 2;
max_iter = 2000;
step_size = 1e-3;
rng(40);
mu_av = zeros(max_iter, size(measurements, 2));
mu_mx = zeros(max_iter, size(measurements, 2));
gd_err = zeros(max_iter, size(measurements, 2));

% set desired representation matrix
psi = kron(dctmtx(patch_dim)', dctmtx(patch_dim )');

for m = 1 : size(measurements, 2)
    M = measurements(m)
    phi_org = rand(M, N); % Uniform(0, 1) init
    D_org = phi_org * psi; % Overall sensing matrix
    D = D_org;
    phi = phi_org;
    step_size = 0.00001;
    
    for i = 1:max_iter
        [mu_av(i, m), mu_mx(i, m)] = compute_coherence(D);
        gd_err(i, m) = trace(((D' * D) - eye(size(D, 2))) * ((D' * D) - eye(size(D, 2)))');
        del_D = D * (D' * D - eye(size(D, 2)));
        upd_D = D - step_size * del_D;
        D = upd_D;
    end
    D_con = D;
    phi_con = D * psi';
    save(strcat('../designed-matrices/coherence-opt/2ddct/vanilla/opt-mat-sanei-16-M', num2str(M), '.mat'), 'phi_org', 'phi_con', 'D_org', 'D_con');
end

% Visualizing trends
% figure;
% for i = 1:size(measurements, 2)
% plot(mu_av(:, i));
% hold on
% end
% xlabel('Iterations');
% ylabel('\mu_{av}');
% legend(strtrim(cellstr(num2str((measurements/N)'))'));
% title('Optimizing sensing matrix by minimizing \mu_{av} [Abolghasemi 2010]');