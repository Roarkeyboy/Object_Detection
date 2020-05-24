function appendimagescolour()
scene_path = ('input_images/scenes/scene_1.jpg');
image1 = imread(scene_path);
image1 = imresize(image1,0.25);

image2_path = ('input_images/objects/battery/1.jpg');
image2 = imread(image2_path);
image2 = imresize(image2,0.25);

rows1 = size(image1,1);
cols1 = size(image1,2);
rows2 = size(image2,1);
cols2 = size(image2,2);

if (rows1 < rows2)
     image1(rows2,1) = 0;
else
     image2(rows1,1) = 0;
end
imApp = [image1 image2];
figure()
imshow(imApp);