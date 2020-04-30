function im = appendimages2(image1, image2,scene_size)
% Select the image with the fewest rows and fill in enough empty rows
%   to make it the same height as the other image.
%rows1 = size(image1,1);
%rows2 = size(image2,1);
%cols1 = size(image1,2);
%cols2 = size(image2,2);
[rows1, cols1] = size(image1);
[rows2, cols2] = size(image2);

if (cols1 < cols2)
     image1(cols2,1) = 0;
else
     image2(cols1,1) = 0;
end
if (rows1 < rows2)
     image1(rows2,1) = 0;
else
     image2(rows1,1) = 0;
end

% Now append both images side-by-side.
im = cat(1,image1, image2);   