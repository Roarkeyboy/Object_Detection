function im = appendimages2(image1, image2,scene1,matches)

% Select the image with the fewest rows and fill in enough empty rows
%   to make it the same height as the other image.

[rows1, cols1,~] = size(image1); % image 1 size
[rows2, cols2,~] = size(image2); % image 2 size
[rows3, cols3,~] = size(scene1); % scene size

if (matches == 2)
    image1 = imresize(image1,[rows3/matches, cols1]);
    image2 = imresize(image2,[rows3/matches, cols1]);
else
    image1 = imresize(image1,[(matches-1)*rows3/matches, cols1]);
    image2 = imresize(image2,[rows3/matches, cols1]);
end
%image1 = imresize(image1,[(matches-1)*rows3/matches, cols1]);

%image2 = imresize(image2,[rows3/matches, cols1]);


% Now append both images.
im = [image1; image2];     