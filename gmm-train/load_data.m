function [patches] = load_data(path, num_patches, dim, mode)
% Generate a large set of patches from a database of images
% Input:
%   path: String containing path to directory of database
%   num_patches: n (1 x 1) Number of patches required
%   dim: p (1 x 1); Patches are (p x p) each
%   mode: 'random' or 'exhaustive', depending on the sampling pattern. When
%         mode is 'exhaustive', num_patches is not read - all patches in
%         path are extracted and returned.
% Output:
%   patches: (n x p^2) Matrix of generated patches
% Written by Dhruv Ilesh Shah (dhruv.ilesh@gmail.com)
%% init
fprintf('Extracting patches from database ... \n');

if strcmp(mode, 'random')
    % files = strcat(path, ls(strcat(path, '*.jpg')));
    files = dir(strcat(path, '*.jpg'));
    img_count = size(files, 1);
    patch_sets = max(int32(num_patches / img_count), 1);
    patches = zeros(num_patches, dim^2);

    for i = 1:img_count
        patch_i = get_patches(imread(strcat(path, files(i, :).name)), patch_sets, dim, 'random');
        patches((i - 1)* patch_sets + 1 : i*patch_sets, :) = patch_i;
    end
elseif strcmp(mode, 'exhaustive')
    files = dir(strcat(path, '*.jpg'));
    I = imread(strcat(path, files(1, :).name)); % Assume all images same dim
    img_count = size(files, 1);
    height = int32(size(I, 2) / dim);
    width = int32(size(I, 1) / dim);
    patch_sets = height*width;
    patches = zeros(img_count*patch_sets, dim^2);

    
    for i = 1:img_count
        patch_i = get_patches(imread(strcat(path, files(i, :).name)), 0, dim, 'exhaustive');
        patches((i - 1)* patch_sets + 1 : i*patch_sets, :) = patch_i;
    end
    
end