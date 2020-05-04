function im = appendimages2(image1, image2,scene1,count)
% Select the image with the fewest rows and fill in enough empty rows
%   to make it the same height as the other image.
[rows1, cols1] = size(image1);
[rows2, cols2] = size(image2);
[rows3, cols3] = size(scene1);
image1 = imresize(image1,[(count-1)*rows3/count,cols1]);
image2 = imresize(image2,[rows3/count,cols1]);

%figure
%imshow(image2);
% Now append both images side-by-side.
im = [image1; image2];     