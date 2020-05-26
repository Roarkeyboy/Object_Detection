% Function detects edges using canny edge detector and creates a final
% image that is the size of the scene image so it can draw the outline over
% the scene.
% This is an alteration of a function found online with the link below
% https://au.mathworks.com/matlabcentral/fileexchange/30849-image-mosaic-using-sift

function imgout = warp_it(H,best,scene_pgm,tform)
image_pgm = best;
image = imread(image_pgm);
canny = edge(image,'canny',0.5); % canny detection with a 0.5 threshold
image_warped = imwarp(canny,tform); % imwarp using the transform object
[M1, N1, ~] = size(scene_pgm);
[M2, N2, ~] = size(image);
% Perform 'mosaic' 
pt = zeros(3, 4);
pt(:,1) = H*[1; 1; 1];
pt(:,2) = H*[N2; 1; 1];
pt(:,3) = H*[N2; M2; 1];
pt(:,4) = H*[1; M2; 1];
x2 = pt(1, :)./pt(3, :);
y2 = pt(2, :)./pt(3, :);
up = round(min(y2));
Yoffset = 0;
if up <= 0
	Yoffset = -up + 1;
	up = 1;
end
left = round(min(x2));
Xoffset = 0;
if left <= 0
	Xoffset = -left + 1;
	left = 1;
end
[M3, N3, ~] = size(image_warped);
imgout(up:up + M3 - 1, left:left + N3 - 1, :) = image_warped;
imgout(Yoffset+1:Yoffset + M1, Xoffset + 1:Xoffset + N1, :) = 0;
imgout(up:up + M3 - 1, left:left + N3 - 1, :) = image_warped;
imgout = imresize(imgout, [M1 N1]);