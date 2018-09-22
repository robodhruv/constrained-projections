function [x, ind] = aMAP_decoder(y, phi, weights, sigma, mean, comp, noise, premult)
% Approximate MAP decoder (MAC-Perpinan, 2000; Zoran & Weiss, 2011)
% Input:
%   y: compressive measurement (m x 1)
%   phi: measurement/projection matrix (m x n)
%   weights: mixture weights of the prior GMM model (1 x c)
%   sigma: covariance matrices of mixture components (n^2 x c)
%   mean: mean vector of mixture components (n x c)
%   comp: number of mixture components (c)
%   noise: noise level
% Output:
%   x: estimate of original signal (n x 1)
%   ind: index of mixture component 'x' may belong to
% Written by Dhruv Ilesh Shah (dhruv.ilesh@gmail.com)

if (mean == 0)
    % Placeholder for mean not available
    mu_x = ones([size(phi, 2), 1]) * y(end);
    mu_y = phi * mu_x;
end
cond_weights = ones([comp, 1]);
for i = 1:comp
    if (mean ~= 0)
        % Using mean of learned mixture components
        mu_x = mean(:, i);
        mu_y = phi * mu_x;
    end
    cov = (phi * sigma(:, :, i) * phi') + (eye(numel(y))*noise^2);
    cond_weights(i) = log(weights(i)) + loggausspdf2(y-mu_y, cov);
end

[~, ind] = max(cond_weights); %Identifying mode

% Weiner filter estimate
S = sigma(:, :, ind);
if (nargin < 8)
    x = mu_x + (S * phi' / (((phi * S * phi')  + (eye(size(phi, 1)) * (noise.^2)))) * (y - mu_y));
else
    x = mu_x + premult(:, :, ind) * (y - mu_y);
end