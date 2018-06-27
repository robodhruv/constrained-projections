%% Visualizing reconstruction results using various methods
%  Written by Dhruv Ilesh Shah (dhruv.ilesh@gmail.com)

patch_dim = 16;
h = size(I, 2);
w = size(I, 1);
img = zeros(h, w);
img_org = im2double(I);
figure('Position', [200, 200, 1000, 500]);
for l = 1:size(recon, 3)
    p = recon(:, :, l);
    if (l==1)
        mode = '\Phi_{uniform}^{L1}';
    elseif (l==2)
        mode = '\Phi_{Sanei}^{L1}';
    elseif (l==3)
        mode = '\Phi_{uniform}^{SCS}';
    else
        mode = '\Phi_{MMSE Opt}^{SCS}';
    end
    
    for i = 1:h/patch_dim
        for j = 1:w/patch_dim
            img((i-1)*patch_dim+1:i*patch_dim, (j-1)*patch_dim+1:j*patch_dim) = reshape(p(:, (i-1)*(w/patch_dim) + j), [patch_dim, patch_dim])';
        end
    end
    mse = mean2((img' - img_org).^2);
    [ssimval, ssimap] = ssim(img', img_org);
    psnr = 10 * log10(1 / mse);
    subplot(3, 2, l + 2);
    imshow(img');
    % imwrite(img', strcat(num2str(l), '.png')); % Write to file
    colormap gray
    title({mode, strcat('PSNR: ', num2str(psnr), '; SSIM: ', num2str(ssimval))});
end

subplot(3, 2, [1, 2]);
imshow(img_org);
title('Original Image');