function out = compute_RIC(A, s)
% Computes the Restricted Isometry Constant combinatorially.
% Input:
%	A: input matrix (m x n)
%	s: sparsity level at which RIC is desired
% Output:
%	out: RIC value of matrix A at sparsity s
% Written by Alankar Kotwal (alankarkotwal13@gmail.com)

	A = normc(A);
	nT = size(A, 2);
	combs = combnk(1:nT, s);
	out = 0;
    disp(size(combs, 1))
	parfor i = 1:size(combs, 1)
        if mod(i, 10000) == 0
            disp(i)
        end
		subsA = A(:, combs(i, :));
		dots = subsA' * subsA;
		dotsSub = dots - eye(size(dots));

		maxEig = max(abs(eig(dotsSub)));
		out = max(out, maxEig);

	end

end