% num = match(image1, image2)
%
% This function reads two images, finds their SIFT features, and
%   displays lines connecting the matched keypoints.  A match is accepted
%   only if its distance is less than distRatio times the distance to the
%   second closest match.
% It returns the number of matches displayed.
%
% Example: match('scene.pgm','book.pgm');

function [match_loc1,match_loc2,num] = ransac_match(image1, image2,corrPtIdx,display)

% Find SIFT keypoints for each image
[im1, des1, loc1] = sift(image1);
[im2, des2, loc2] = sift(image2);

% For efficiency in Matlab, it is cheaper to compute dot products between
%  unit vectors rather than Euclidean distances.  Note that the ratio of 
%  angles (acos of dot products of unit vectors) is a close approximation
%  to the ratio of Euclidean distances for small angles.
%
% distRatio: Only keep matches in which the ratio of vector angles from the
%   nearest to second nearest neighbor is less than distRatio.
distRatio = 0.6;    % 0.6 Changed by Afaq

% For each descriptor in the first image, select its match to second image.
des2t = des2';                          % Precompute matrix transpose
for i = 1 : size(des1,1)
   dotprods = des1(i,:) * des2t;        % Computes vector of dot products
   [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results

   % Check if nearest neighbor has angle less than distRatio times 2nd.
   if (vals(1) < distRatio * vals(2))
      match(i) = indx(1);
   else
      match(i) = 0;
   end
end
indexer = 1;
for ii = 1:size(des1,1)
    if (match(ii) > 0)   
        if indexer ~= corrPtIdx
            match(ii) = 0;
        end  
        indexer = indexer + 1;        
    end
end
if (display)
    % Create a new image showing the two images side by side.
    im3 = appendimages(im1,im2);

    % Show a figure with lines joining the accepted matches.
    figure('Position', [0 0 size(im3,2)/2 size(im3,1)/2]); % Changed from figure('Position', [100 100 size(im3,2) size(im3,1)]);
    colormap('gray');
    imagesc(im3);
    hold on;
    cols1 = size(im1,2);

    for i = 1: size(des1,1)
      if (match(i) > 0)
        line([loc1(i,2) loc2(match(i),2)+cols1], ...
             [loc1(i,1) loc2(match(i),1)], 'Color', 'c');
      end
    end
    hold off;
end
num = sum(match > 0);
fprintf('After RANSAC Found %d matches.\n', num);

idx1 = find(match);
idx2 = match(idx1);
x1 = loc1(idx1,2);
x2 = loc2(idx2,2);
y1 = loc1(idx1,1);
y2 = loc2(idx2,1);
match_loc1 = [x1,y1];
match_loc2 = [x2,y2];


