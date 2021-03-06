% Used for appending images horizontally rather than vertically 
% saves the scale of the second appended image with respect to the first,
% to pass on to the draw lines function which translates match positions to
% the correct location

function [im,scale] = appendimages2(image1, image2,scene1,matches,scale)

% Select the image with the fewest rows and fill in enough empty rows
%   to make it the same height as the other image.

[rows1, cols1,~] = size(image1); % image 1 size
[rows2, cols2,~] = size(image2); % image 2 size
[rows3, ~,~] = size(scene1); % scene size


if (matches == 2) % Matches are 2 and dimensions are split equally
    image1 = imresize(image1,[rows3/matches, cols1]);
    image2 = imresize(image2,[rows3/matches, cols1]);
    
    [newrows1, newcols1,~] = size(image1);
    [newrows2, newcols2,~] = size(image2);
    
    scale(1) = {[newrows1/rows1,newcols1/cols1]};  % x scale and y 
    scale(matches) = {[newrows2/rows2,newcols2/cols2]};  % x scale and y scale
    
else
    image1 = imresize(image1,[(matches-1)*rows3/matches, cols1]); % scale the image to be the a portion of the above appended images (i.e. 1/3 size of the 2 match append above)
    image2 = imresize(image2,[rows3/matches, cols1]);
    [newrows2, newcols2,~] = size(image2);
    scale(matches) = {[newrows2/rows2,newcols2/cols2]};  % x scale and y scale
end


im = [image1; image2];     