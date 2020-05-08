function im = appendimages2(image1, image2,scene1,count,matches)

% Select the image with the fewest rows and fill in enough empty rows
%   to make it the same height as the other image.

[rows1, cols1] = size(image1); % image 2 size
[rows2, cols2] = size(image2); % image 2 size
[rows3, cols3] = size(scene1); % scene size

image1 = imresize(image1,[(matches-1)*rows3/matches, (matches-1) * cols1/matches]);
image2 = imresize(image2,[rows3/matches,(matches-1) * cols1/matches]);
%image1 = imresize(image1,[(count-1)*rows3/count, (matches-1) * cols1/matches]);
%image2 = imresize(image2,[rows3/count,(matches-1) * cols1/matches]);
% Now append both images.
im = [image1; image2];     