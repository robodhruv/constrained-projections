function A_proj = get_projection(A, mode, n_levels)
% Generate practically realisable projections
% This function projects the elements of matrix A on a subspace defined by
% the 'mode' argument. If the mode involves quantization, the number of
% quantization levels must also be passed.
% Input:
%	A: input matrix (m x n)
%	mode: string 'positive_unquant' or 'positive_quant' denoting mode of projection
%	n_levels: in case of 'positive_quant', number of quantization levels
% Output:
%	A_proj: projected matrix (m x n)
% Written by Dhruv Ilesh Shah (dhruv.ilesh@gmail.com)

eps = 1e-3;
if nargin < 2
    mode = 'positive_unquant';
    n_levels = 1;
end

if strcmp(mode, 'positive_unquant')
    A_proj = min(1, max(0, A));
elseif strcmp(mode, 'positive_quant')
    dec_reg = linspace(0, 1, n_levels+1);
    levels = (dec_reg(2:end) + dec_reg(1:n_levels)) / 2;
    A_lin = reshape(A, [numel(A), 1]);
    A_lin(A_lin==0) = eps;
    proj_ind = sum(bsxfun(@gt, A_lin, dec_reg), 2);
    A_proj = reshape(levels(proj_ind), size(A));
end