% Built on the similar functions match and new_match but without the SIFT
% matching (same parts have comments in other files)
% Returns match locations and number of matches

function [match_loc1,match_loc2,num] = ransac_match(image1, image2,corrPtIdx,matches,des1,loc1,loc2,display)
match = matches; 
indexer = 1; 
for ii = 1:size(des1,1)
    if (match(ii) > 0)   
        if indexer ~= corrPtIdx % corrPtIdx are the points indices that are the inlier values found from previous calcs.
            match(ii) = 0; % remove matches that are outliers
        end  
        indexer = indexer + 1; % increment index value
    end
end
if (display) % if display == 1 then draw
    % Create a new image showing the two images side by side.
    im1 = imread(image1);
    im2 = imread(image2);
    im3 = appendimages(im1,im2);
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
