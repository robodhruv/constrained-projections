% example of extracting patches from images
 
% filename to load, change to a valid filename...
filename = 'bsds500/train/181079.jpg';
 
% load an image
I = im2double( rgb2gray( imread( filename ) ) );
width  = size( I, 2 );
height = size( I, 1 );
 
% load an image
[x,y] = meshgrid( 1:width, 1:height );
 
% window offset from central pixel, patch will be win pixels either side of
% the central pixel. pwidth is the width of the patch, in pixels and N
% is the number of pixels in the patch
win    = 20;
pwidth = 2*win+1;
N      = pwidth^2;
 
% patch center location, here assuming an MxM array of output patches, we
% generate a Np=M*M patch center location randomly, constraining the
% centers to be at least win pixels from the image border to avoid edge
% cases
M  = 16;
Np = M*M;
px = randi( [win,width-win],  Np, 1 );
py = randi( [win,height-win], Np, 1 );
 
% Y will store the patch dictionary, with each patch packed as a column in
% the N*Np matrix. Each patch pixel is looped over and the appropriate row
% of Y is generated via the interp2 function using nearest neighbor
% interpolation
Y = zeros( N, Np );
id = 1;
for i=-win:win,
    for j=-win:win,
        Y( id, : ) = interp2( I, px+i, py+j, 'nearest' );
        id = id+1;
    end
end
 
% generate the patch database image by reshaping each column into a
% pwidth*pwidth image to check that the above doesn't transpose the image
% or do other weird things...
P = zeros( M*pwidth, M*pwidth );
id = 1;
for i=1:M,
    for j=1:M,
        P( (i-1)*pwidth+1:i*pwidth, (j-1)*pwidth+1:j*pwidth ) = reshape( Y(:,id), [pwidth,pwidth] );
        id = id+1;
    end
end
% show the result
imshow( P );