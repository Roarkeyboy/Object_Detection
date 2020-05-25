function dilated = dilate_them(imgout,handles,dilated)
image = imgout;
if (dilated == 0)
    rgb_image = handles.image_file_rgb;
else
    rgb_image = dilated;
end

se = strel('disk',2);
after_dilate = imdilate(image,se);
[height, width] = size(after_dilate);
RGB = rgb_image;
for column = 1 : width
    for row = 1 : height
        if (after_dilate(row, column) == 1)
            RGB(row, column,1) = 0;
            RGB(row, column,2) = 200;
            RGB(row, column,3) = 0;
        end
    end
end
%imshow(RGB);

dilated = RGB;