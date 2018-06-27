function [mu_av, mu_mx] = compute_coherence(D)
% Computes the coherence of a given effective dictionary, and
% returns its value in the average (Frob-norm) and maximum (Inf-norm) sense
% Input:
%   D: Effective dictionary of size (m x n)
% Output:
%   mu_av: average coherence (Frob) of D
%	mu_mx: maximum coherence (Inf) of D
% Written by Dhruv Ilesh Shah (dhruv.ilesh@gmail.com)
%% init
    for j = 1:size(D, 2)
        % Normalizing D
        D(:, j) = D(:, j) / sqrt(sum(D(:, j).^2)); 
    end
    G = D' * D; % Gram matrix
    dim = size(G, 1);
    rem_diag = 1 - eye(dim);
    mu_mx = max(max(abs(G.*rem_diag)));
    mu_av = sum(sum(abs(G.*rem_diag))) / (dim * (dim - 1));
end