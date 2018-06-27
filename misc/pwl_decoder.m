function [x, ind] = pwl_decoder(y, phi, sigma, mean, comp, noise, S_det_log, S_inv, premult)
% Piecewise linear decoder  for statistical compressive sensing (Yu & Sapiro 2011).
% Input:
%   y: compressive measurement (m x 1)
%   phi: measurement/projection matrix (m x n)
%   comp: number of mixture components (c)
%   mean: mean vector of mixture components (n x c)
%   sigma: covariance matrices of mixture components (n^2 x c)
%   noise: noise level
%   (optional) S_det_log: log of determinant of mixture covariances (c x 1)
%   (optional) S_inv: inverse of mixture covariances (n^2 x c)
%   (optional) premult: premultification factor in order to make decoder faster (n^2 x c)
% Output:
%   x: estimate of original signal (n x 1)
%   ind: index of mixture component 'x' may belong to
% Written by Dhruv Ilesh Shah (dhruv.ilesh@gmail.com)

if nargin < 7
    % if no premult  & S_inv given
    S_inv = zeros(size(sigma));
    for i = 1:comp
        S = sigma(:, :, i);
        S_inv(:, :, i) = inv(S);
        S_det_log(i) = log(det(S));
        premult(:, :, i) = S * phi' / (((phi * S * phi')  + (eye(size(phi, 1)) * (noise.^2))));
    end
end

dec_x = zeros(size(phi, 2), comp);
neg_log_apost = zeros(comp, 1);

for i = 1:comp
    % Calculating the MAP estimate for each component Gaussian
    mu = mean(:, i);
    dec_x(:, i) = mu + premult(:, :, i) * (y - (phi * mu));
    x_hat = dec_x(:, i) - mu;
    neg_log_apost(i) = S_det_log(i) + x_hat' * S_inv(:, :, i) * x_hat;
end

[min_err, ind] = min(neg_log_apost);
x = dec_x(:, ind);
