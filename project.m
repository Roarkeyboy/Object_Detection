function varargout = project(varargin)
% PROJECT MATLAB code for project.fig
%      PROJECT, by itself, creates a new PROJECT or raises the existing
%      singleton*.
%
%      H = PROJECT returns the handle to a new PROJECT or the handle to
%      the existing singleton*.
%
%      PROJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJECT.M with the given input arguments.
%
%      PROJECT('Property','Value',...) creates a new PROJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before project_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to project_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help project

% Last Modified by GUIDE v2.5 11-May-2020 09:07:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @project_OpeningFcn, ...
                   'gui_OutputFcn',  @project_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before project is made visible.
function project_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to project (see VARARGIN)

% Choose default command line output for project
handles.output = hObject;
object_list = {'battery','calculator','canned_beans','cologne','deodorant','drink_holder','eraser','highlighter','lip_balm','minion','pallet','phone','sauce_jar','shoe','snack_bar','sunglasses','ue_boom','vitamins','wallet_1','wallet_2'};
handles.object_list = object_list;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes project wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%% 
% --- Outputs from this function are returned to the command line.
function varargout = project_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%
%% Seperate objects - DELETE THIS
% 
function [label,total] = bounding_box(handles)
bw_image = imbinarize(handles.image_file,0.55);
se = strel('disk',2);
after_erosion = imerode(~bw_image,se);
se = strel('disk',6);
after_dilate = imdilate(after_erosion,se);
[label,total] = bwlabel(after_dilate,8);
%canny_image = edge(bw_image,'canny');
%CH = bwconvhull(canny_image);


%% CROP OUT INDIVIDUAL OBJECTS (CROP BUTTON)
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[label,total] = bounding_box(handles);
bounding_boxes = regionprops(label,'BoundingBox');
figure();
disp(strcat('Found :',num2str(total),' objects'));
for ii = 1:total
    coord = bounding_boxes(ii).BoundingBox;
    cropped_image = imcrop(handles.image_file, [coord(1), coord(2), coord(3), coord(4)]);
    subplot(4,5,ii);
    imshow(cropped_image);
end

%% LOAD IN IMAGE (LOAD SCENE BUTTON)
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file_name,file_path]= uigetfile('*'); % Get the jpg data from the users selection
full_name = [file_path file_name]; 
global current_scene
current_scene = file_name(1:strfind(file_name,'.')-1);
image_file = imread(full_name); % Read in image at given path
image_file = imresize(image_file,0.25);
image_file_rgb = image_file; % Save a copy of image before conversion
imagesc(image_file); axis(handles.axes1, 'equal','tight','off')% Using axes1 % Display the image onto the axes
if (size(image_file,3) == 3) % If image is RGB, convert to gray
    image_file = rgb2gray(image_file);
end
colormap(gray) % display grayscale
imwrite(image_file,strcat('found_objects/',current_scene,'/',current_scene,'.pgm'),'pgm');
handles.image_file = image_file;
handles.image_file_rgb = image_file_rgb;
guidata(hObject,handles);

%% REWRITE OBJECTS AS PGM (RENAME BUTTON)
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global current_scene
[label,total] = bounding_box(handles);
bounding_boxes = regionprops(label,'BoundingBox');
for ii = 1:total
    coord = bounding_boxes(ii).BoundingBox;
    cropped_image = imcrop(handles.image_file, [coord(1), coord(2), coord(3), coord(4)]);
    imwrite(cropped_image,strcat('found_objects/',current_scene,'/image_',num2str(ii),'.pgm'),'pgm');
end

%% DRAW OUTLINE ON SINGLE OBJECT (DRAW OUTLINE BUTTON)
% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA
global current_scene
figure();
subplot(2,2,1);
image_pgm = imread(strcat('found_objects/',current_scene,'/image_2.pgm'));
imshow(image_pgm);
%canny_image = edge(image_pgm,'canny',0.3);
%CH_objects = bwconvhull(canny_image,'Objects');
bw_image = im2bw(image_pgm,0.55);
se = strel('disk',2);
after_erosion = imerode(~bw_image,se);
se = strel('disk',6);
after_dilate = imdilate(after_erosion,se);
subplot(2,2,2);
bw_image = ~bw_image;
imshow(bw_image);
label = bwlabel(bw_image,8);
stat=regionprops(label,'Centroid','Area','PixelIdxList');
[maxValue,index] = max([stat.Area]);
[row col] = size(stat);
for i=1:row
    if (i~=index)
       bw_image(stat(i).PixelIdxList) = 0; % Remove all small regions except large area index
    end
end
subplot(2,2,3);
imshow(bw_image);
%[rows cols] = size(CH_objects)
dim = size(bw_image);
cols = round(dim(2)/2);
rows = min(find(bw_image(:,cols)));
boundary = bwtraceboundary(bw_image,[rows, cols],'N');

subplot(2,2,4);
imshow(image_pgm)
hold on;
plot(boundary(:,2),boundary(:,1),'g','LineWidth',3); % Change colour each time it iterates

%% DRAW OUTLINES OVER ALL OBJECTS (DRAW OUTLINES BUTTON)
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global current_scene
figure();
d = strcat('found_objects/',current_scene,'/');
files = dir(fullfile(d,'*.pgm'));
for ii = 1:numel(files)-1
    image_pgm = imread(strcat('found_objects/',current_scene,'/image_',num2str(ii),'.pgm'));
    %canny_image = edge(image_pgm,'canny',0.33); % CHANGE THIS BACK TO 0.5
    %CH_objects = bwconvhull(canny_image,'Objects');
    bw_image = im2bw(image_pgm,0.55);
    se = strel('disk',2);
    after_erosion = imerode(~bw_image,se);
    se = strel('disk',6);
    after_dilate = imdilate(after_erosion,se);
    bw_image = ~bw_image;
    label = bwlabel(bw_image,8);
    stat = regionprops(label,'Centroid','Area','PixelIdxList');
    [maxValue,index] = max([stat.Area]);
    [row col]=size(stat);
    for i=1:row
        if (i~=index)
           bw_image(stat(i).PixelIdxList)=0; % Remove all small regions except large area index
        end
    end
    %[rows cols] = size(CH_objects)
    dim = size(bw_image);
    cols = round(dim(2)/2);
    rows = min(find(bw_image(:,cols)));
    boundary = bwtraceboundary(bw_image,[rows, cols],'N');

    subplot(4,5,ii);
    imshow(image_pgm)
    hold on;
    plot(boundary(:,2),boundary(:,1),'g','LineWidth',1); % Change colour each time it iterates
end

%% SIFT MATCH OF SINGLE OBJECT WITH SCENE (SIFT MATCH BUTTON)
% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
global current_scene
scene_pgm = strcat('found_objects/',current_scene,'/scene_1.pgm');
image_pgm = strcat('found_objects/',current_scene,'/image_2.pgm');
match(scene_pgm, image_pgm,1);

%% SIFT MATCH OF ALL OBJECTS IN SCENE (SIFT MATCHES BUTTON)
% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
global current_scene
scene_pgm = strcat('found_objects/',current_scene,'/',current_scene,'.pgm');
% d = strcat('found_objects/',current_scene,'/');
% files = dir(fullfile(d,'*.pgm'));
% for ii = 1:numel(files)-1
%     image_pgm = strcat('found_objedcts/',current_scene,'/image_',num2str(ii),'.pgm');
%     match(scene_pgm, image_pgm,1);
% end
d = strcat('input_images/objects/canned_beans/');
files = dir(fullfile(d,'*.pgm'));
for ii = 1:numel(files)
    image_pgm = strcat('input_images/objects/canned_beans/image_',num2str(ii),'.pgm');
    match(scene_pgm, image_pgm,1);
end



%% SAVE DESCRIPTORS AS MATLAB DATA (SAVE SIFT BUTTON)
% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
global current_scene
%image_1_pgm = strcat('found_objects/',current_scene,'/image_1.pgm');
%[~, des, ~] = sift(image_1_pgm); % MIGHT NEED LOCAL, NOT SURE!
%save(strcat('found_objects/',current_scene,'/image_1.mat', 'des'));
for ii = 1:6
    image_pgm = strcat('input_images/objects/calculator/image_',num2str(ii),'.pgm');
    [~, des, locs] = sift(image_pgm);
    save(strcat('input_images/objects/calculator/image_',num2str(ii),'.mat'), 'des','locs');
end
%% ADD EACH DETECTED OBJECT BESIDE MAIN IMAGE (MATCH DISPLAY BUTTON)
% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
global current_scene;
scene1 = imread('found_objects/scene_1/scene_1.pgm');
image1 = imread('found_objects/scene_1/image_1.pgm');
image2 = imread('found_objects/scene_1/image_2.pgm');
image3 = imread('found_objects/scene_1/image_3.pgm');
image4 = imread('found_objects/scene_1/image_4.pgm');
%app = appendimages(scene1,image1);
%app2 = appendimages2(image1,image2,scene1,1);
%app = appendimages(scene1,app2);
app = appendimages(scene1,image1);
app2 = image1;
for ii = 2
    im = imread(strcat('found_objects/scene_1/image_',num2str(ii),'.pgm')); % make this read the detected image
    app2 = appendimages2(app2,im,scene1,ii); % apends images downwards
    app = appendimages(scene1,app2);
    imagesc(app); axis(handles.axes1, 'equal','tight','off')
end

colormap(gray)

% Used this to add folders one and convert to pgm 
% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
%type = 'wallet_2';
for jj = 1:20 % Object list index
    type = char(handles.object_list(jj));
    d = strcat('input_images/objects/',type);
    files = dir(fullfile(d,'*.jpg'));
    figure()
    for kk = 1:numel(files)
        file_name = fullfile(d,files(kk).name);
        image = imread(file_name);
        image = imresize(image,0.25);
        if (size(image,3) == 3) % If image is RGB, convert to gray
            image = rgb2gray(image);
        end
        bw_image = imbinarize(image,0.6);
        se = strel('disk',4);
        after_erosion = imerode(~bw_image,se);
        se = strel('disk',4);
        after_dilate = imdilate(after_erosion,se);
        [label,total] = bwlabel(after_dilate,8);
        bounding_boxes = regionprops(label,'BoundingBox');
        temp = 0;
        max = 0;
        for ii = 1:total
            coord = bounding_boxes(ii).BoundingBox;
            cropped_image = imcrop(image, [coord(1), coord(2), coord(3), coord(4)]);
            temp = cropped_image;
            if (size(temp) > size(max))
                max = temp;
            end
        end
        subplot(2,3,kk);
        imshow(max);
        imwrite(max,strcat('input_images/objects/',type,'/image_',num2str(kk),'.pgm'),'pgm');
    end
end

% this compares the found object with the actual object and its
% orientations
% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
global current_scene
max = 0;
temp = 0;
best = 0;
scene_pgm = strcat('found_objects/',current_scene,'/',current_scene,'.pgm');
for jj = 2:2 % Object list index - 2 is Calculator
    type = char(handles.object_list(jj));
    for ii = 1:6 % Orienation index
        image_pgm = strcat('input_images/objects/',type,'/image_',num2str(ii),'.pgm');
        image_2_pgm = strcat('found_objects/',current_scene,'/image_',num2str(4),'.pgm');
        %match(scene_pgm, image_pgm,1);
        num = match(image_2_pgm, image_pgm,1);
        temp = num;
        if (temp > max)
            max = temp;
            best = image_2_pgm;
        end
    end
imagesc(imread(best)); axis(handles.axes1, 'equal','tight','off')
end


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
global current_scene;
image = handles.image_file;
rgb_image = handles.image_file_rgb;
bw_image = imbinarize(image,0.5);
canny_image = edge(bw_image,'canny');
se = strel('disk',2);
after_dilate = imdilate(canny_image,se);
[label,total] = bwlabel(after_dilate,8);
bounding_boxes = regionprops(label, 'BoundingBox', 'Area');
count = 1;
figure
for k = 1 : length(bounding_boxes)
    coord = bounding_boxes(k).BoundingBox;
    cropped_image = imcrop(image,[coord(1),coord(2),coord(3),coord(4)]);
    % coords = [left, top, width, height]
    [rows, cols, ~] = size(cropped_image);
    if rows*cols > 8000  
        subplot(4,3,count);
        imshow(cropped_image);
        imwrite(cropped_image,strcat('found_objects/',current_scene,'/image_',num2str(count),'.pgm'),'pgm');
        count = count + 1;
        
    end
end
figure()
subplot(2,2,1);
imshow(canny_image);
subplot(2,2,2);
imshow(after_dilate);
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
subplot(2,2,3);
imshow(RGB);


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)

global current_scene;
%image = handles.image_file;
scene_pgm = strcat('found_objects/',current_scene,'/',current_scene,'.pgm');
type = char(handles.object_list(2));
image_pgm = strcat('input_images/objects/',type,'/image_1.pgm');
image_2_pgm = strcat('found_objects/',current_scene,'/image_4.pgm');
%match(image_2_pgm, image_pgm,0);

[~, ~, locs] = sift(image_pgm);
[~, ~, locs_2] = sift(image_pgm);

locs(:,3:4) = [];
size_locs = size(locs);
locs = reshape(locs,[size_locs(2) size_locs(1)]);

locs_2(:,3:4) = [];
size_locs_2 = size(locs_2);
locs_2 = reshape(locs,[size_locs_2(2) size_locs_2(1)]);

imwrite(imread(image_pgm),'test.jpg','jpg');
test = imread('test.jpg');
[F, ~, ~] = affinefundmatrix(locs, locs_2);

%A = image_pgm;
% rgb_image = handles.image_file_rgb;
% A = rgb_image;
F
tform = affine2d(F);

output = imwarp(test,tform);
imshow(output);


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
global current_scene;
%image = handles.image_file;
scene_pgm = strcat('found_objects/',current_scene,'/',current_scene,'.pgm');
type = char(handles.object_list(2));
image_pgm = strcat('input_images/objects/',type,'/image_1.pgm');
image_2_pgm = strcat('found_objects/',current_scene,'/image_4.pgm');
%match(image_2_pgm, image_pgm,0);

im = imread(image_pgm);
im_2 = imread(image_2_pgm);

[~, ~, locs] = sift(image_pgm);
[~, ~, locs_2] = sift(image_2_pgm);

locs(:,3:4) = [];
size_locs = size(locs);
locs = reshape(locs,[size_locs(2) size_locs(1)]);
disp(size(locs))
imshow(im);

locs_2(:,3:4) = [];
size_locs_2 = size(locs_2);
locs_2 = reshape(locs_2,[size_locs_2(2) size_locs_2(1)]);
disp(size(locs_2))
imshow(im_2);

x1 = [locs(2,:); locs(1,:); ones(1, length(locs))];
x2 = [locs_2(2,:); locs_2(1,:); ones(1, length(locs))];
t = 0.001;
[F, inliers] = ransacfitfundmatrix(x1,x2,t);

% Display both images overlayed with inlying matched feature points
show(double(image_pgm)+double(image_2_pgm),4), set(4,'name','Inlying matches'), hold on    
plot(locs(2,inliers),locs(1,inliers),'r+');
plot(locs_2(2,inliers),locs_2(1,inliers),'g+');    

for n = inliers
    line([locs(2,n) locs_2(2,n)], [locs(1,n) locs_2(1,n)],'color',[0 0 1])
end

%F = ransacfithomography(locs,locs_2,0.01)

%[newim, ~] = imTrans(image_pgm, F);
%imshow(newim);
%tform = affine2d(F);

%output = imwarp(test,tform);
%imshow(output);


%% https://au.mathworks.com/matlabcentral/fileexchange/30849-image-mosaic-using-sift
% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)

global current_scene;
scene_pgm = strcat('found_objects/',current_scene,'/',current_scene,'.pgm');
max = 0;
temp = 0;
matches = 0;
best = 0;
best_homo = 0;
best_match_loc1 = 0;
best_match_loc2 = 0;
new_db = cell(1,20);
firstFlag = 1;
for ii = 2:3%:length(handles.object_list)
    type = char(handles.object_list(ii));
    disp('--------------------------------------');
    printer = ['Searching for ',type];
    disp(printer);
    for jj = 1
        image_pgm = strcat('input_images/objects/',type,'/image_',num2str(jj),'.pgm');
        try
            disp('---- GETTING MATCHES ----');
            [match_loc1, match_loc2] = new_match(scene_pgm,image_pgm,0);
            disp('---- RANSAC MATCHES ----');
            printer = ['Performing RANSAC on ',strcat(type,'/image_',num2str(jj),'.pgm')];
            disp(printer);
            [H, corrPtIdx] = findHomography(match_loc2',match_loc1');
            [match_loc1,match_loc2,num] = ransac_match(scene_pgm,image_pgm,corrPtIdx,0);
            temp = num;
            if temp > max 
                if (temp > 3) % need at least 6 matches 
                    max = temp;
                    best = image_pgm;
                    best_homo = H;
                    best_match_loc1 = match_loc1;
                    best_match_loc2 = match_loc2; 
                    %best_loc = match_loc2;
                end      
            end
        catch
            disp('Image load error');
        end
    end
    if (best == 0)
        printer2 = ['No good match for ',type];
        disp(printer2);
    else 
        matches = matches + 1;
        new_db(matches) = {[best_match_loc1,best_match_loc2]};
    end
    scene = imread(scene_pgm);
    if (matches == 1 && firstFlag)
        image = imread(best);
        app = appendimages(scene,image);
        app2 = image;
        imagesc(app); axis(handles.axes1, 'equal','tight','off')
        firstFlag = 0;
    elseif (matches > 1)
        try
            im_2 = imread(best);
            app2 = appendimages2(app2,im_2,scene,ii,matches); % apends images downwards
            app = appendimages(scene,app2);
            imagesc(app); axis(handles.axes1, 'equal','tight','off')
        catch
            continue
        end
    end
    if (matches > 0)
        draw_new_lines(scene,app,new_db,matches)
    end
%     try
%         draw_new_lines(scene,app,best_match_loc1,best_match_loc2);
%     catch
%         disp('COULDNT DRAW');
%         continue
%     end
%imgout = warp_it(best_homo,best,scene_pgm); 
%dilate_them(imgout,handles);
best = 0;
max = 0;
end
%%
function imgout = warp_it(H,best,scene_pgm)
tform = projective2d(H'); % can use this or the below
%tform = maketform('projective',H');
image_pgm = best;
image = imread(image_pgm);
img21 = imwarp(image,tform); % reproject img2  % can use this or the below
%img21 = imtransform(image,tform); % reproject img2
% figure
% subplot(1,2,1)
% imshow(scene_pgm);
% subplot(1,2,2)
% imshow(img21);
[M1 N1 dim] = size(scene_pgm);
[M2 N2 ~] = size(image_pgm);
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
imgout(Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1,:) = scene_pgm;

%figure
%imshow(imgout);

%%
function dilate_them(imgout,handles)

global current_scene;
%image = handles.image_file;
image = imgout;
rgb_image = handles.image_file_rgb;
bw_image = imbinarize(image,0.6);
canny_image = edge(bw_image,'canny');
se = strel('disk',2);
after_dilate = imdilate(canny_image,se);
%[label,total] = bwlabel(after_dilate,8);

%after_dilate = bwpropfilt(after_dilate, 'EulerNumber', [1 1]);
%figure()
%subplot(2,2,1);
%imshow(canny_image);
%subplot(2,2,2);
%imshow(after_dilate);
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
%subplot(2,2,3);
imshow(RGB);

function draw_new_lines(scene,app,new_db,matches)
colour_list = ['b','g','r','c','m','y','k','w','Brown','PaleYellow','Gray','Orange'];
imagesc(app);
disp(matches)
hold on;
rows1 = 0;
cols1 = size(scene,2);
for kk = 1:matches
    best_match_loc1 = new_db{matches}(:,1:2); 
    best_match_loc2 = new_db{matches}(:,3:4);
    if (matches > 1)
        %rows1 = size(scene,2);
        rows1 = size(app,1)/2;
        cols1 = cols1*1.1;
    end
    hold on;
    for i = 1: size(best_match_loc1,1)
        line([best_match_loc1(i,1) best_match_loc2(i,1)+cols1], ...
             [best_match_loc1(i,2) best_match_loc2(i,2)+rows1], 'Color', colour_list(matches));
    end
end
hold off;
