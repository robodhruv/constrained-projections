function [patches] = get_patches(img, num, dim, mode)
% Extract (non-overlapping) patches randomly from a grayscale image.
% Input: 
%   img: h x w Image
%   num: k (1 x 1) Number of patches to be extracted
%   dim: p (1 x 1) Dimension of the required patches
%   mode: 'random' or 'exhaustive', depending on the sampling pattern. When
%         mode is 'exhaustive', num_patches is not read - all patches in
%         path are extracted and returned.
% Output:
%   patches: k x p^2 Matrix of patches
% Written by Dhruv Ilesh Shah (dhruv.ilesh@gmail.com)
%% init
if size(img, 3) == 1
    I = im2double(img);
else
    I = im2double(rgb2gray(img));
end
if strcmp(mode, 'random') 
    height = int32(size(I, 1) / dim);
    width = int32(size(I, 2) / dim);
    patches = zeros(num, dim*dim);

    for i = 1:num
        xind = randi(width - 1) * dim;
        yind = randi(height - 1) * dim;
        patches(i, :) = reshape(I(yind:yind+dim-1, xind:xind+dim-1), 1, []);
    end
elseif strcmp(mode, 'exhaustive')
    height = int32(size(I, 2) / dim);
    width = int32(size(I, 1) / dim);
    patches = zeros(height*width, dim*dim);
    
    for i = 1:height
        xind = max((i - 1) * dim, 1);
        for j = 1:width
            yind = max((j - 1) * dim, 1);
            patches((i-1)*width + j, :) = reshape(I(yind:yind+dim-1, xind:xind+dim-1), 1, []);
        end
    end
end