function dilated = dilate_them(imgout,handles,dilated,matches)
colour_list = handles.colour_list;
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
            RGB(row, column,1) = colour_list{matches}(1);
            RGB(row, column,2) = colour_list{matches}(2);
            RGB(row, column,3) = colour_list{matches}(3);
        end
    end
end
dilated = RGB;