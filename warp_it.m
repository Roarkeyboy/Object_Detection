%% https://au.mathworks.com/matlabcentral/fileexchange/30849-image-mosaic-using-sift
function imgout = warp_it(H,best,scene_pgm,tform)
image_pgm = best;
image = imread(image_pgm);

%img21 = imwarp(image,tform); % reproject img2

canny = edge(image,'canny',0.5);
img21 = imwarp(canny,tform);

[M1 N1 dim] = size(scene_pgm);
[M2 N2 ~] = size(image);
% do the mosaic
pt = zeros(3,4);
pt(:,1) = H*[1;1;1];
pt(:,2) = H*[N2;1;1];
pt(:,3) = H*[N2;M2;1];
pt(:,4) = H*[1;M2;1];
x2 = pt(1,:)./pt(3,:);
y2 = pt(2,:)./pt(3,:);
up = round(min(y2));
Yoffset = 0;
if up <= 0
	Yoffset = -up+1;
	up = 1;
end
left = round(min(x2));
Xoffset = 0;
if left<=0
	Xoffset = -left+1;
	left = 1;
end
[M3 N3 ~] = size(img21);
imgout(up:up+M3-1,left:left+N3-1,:) = img21;
	% img1 is above img21
%imgout(Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1,:) = scene_pgm;

imgout(Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1,:) = 0;
imgout(up:up+M3-1,left:left+N3-1,:) = img21;
imgout = imresize(imgout,[M1 N1]);