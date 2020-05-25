function [im,scale] = appendimages2(image1, image2,scene1,matches,scale)

% Select the image with the fewest rows and fill in enough empty rows
%   to make it the same height as the other image.

[rows1, cols1,~] = size(image1); % image 1 size
[rows2, cols2,~] = size(image2); % image 2 size
[rows3, cols3,~] = size(scene1); % scene size

im1_scale = (rows1/matches)*cols1;
im2_scale = rows2*cols2;
scale(matches) = {[im2_scale/im1_scale,cols2/cols1]};

if (matches == 2)
    image1 = imresize(image1,[rows3/matches, cols1]);
    image2 = imresize(image2,[rows3/matches, cols1]);
else
    image1 = imresize(image1,[(matches-1)*rows3/matches, cols1]);
    image2 = imresize(image2,[rows3/matches, cols1]);
end

im = [image1; image2];     