% This function takes the scene image or if has had outlines drawn on it,
% it takes that image. This keeps adding outlines to one image and passing
% it back to this function as it updates.

function dilated = dilate_them(imgout,handles,dilated,matches)
colour_list = handles.colour_list;
image = imgout;
if (dilated == 0) % hasnt been drawn on yet
    rgb_image = handles.image_file_rgb;
else
    rgb_image = dilated;
end

se = strel('disk',2);
after_dilate = imdilate(image,se); % dilate image
[height, width] = size(after_dilate);
RGB = rgb_image;
for column = 1 : width
    for row = 1 : height
        if (after_dilate(row, column) == 1) % if the binary image is 1 (can draw)
            % access the defined colour dictionary to update r, g, b values
            RGB(row, column,1) = colour_list{matches}(1);
            RGB(row, column,2) = colour_list{matches}(2);
            RGB(row, column,3) = colour_list{matches}(3);
        end
    end
end
dilated = RGB; % return drawn on image (not actually drawn but individual pixels updated)