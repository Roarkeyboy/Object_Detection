function varargout = GUI_testing(varargin)
% GUI_TESTING MATLAB code for GUI_testing.fig
%      GUI_TESTING, by itself, creates a new GUI_TESTING or raises the existing
%      singleton*.
%
%      H = GUI_TESTING returns the handle to a new GUI_TESTING or the handle to
%      the existing singleton*.
%
%      GUI_TESTING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_TESTING.M with the given input arguments.
%
%      GUI_TESTING('Property','Value',...) creates a new GUI_TESTING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_testing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_testing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_testing

% Last Modified by GUIDE v2.5 25-May-2020 05:54:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_testing_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_testing_OutputFcn, ...
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


% --- Executes just before GUI_testing is made visible.
function GUI_testing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_testing (see VARARGIN)

% Choose default command line output for GUI_testing
handles.output = hObject;
object_list = {'battery','calculator','canned_beans','card_1','card_2','cd','deodorant','dice','drink_holder','forklift','minion','mints','opener','sauce_jar','shoe','snack_bar','strepsils','vitamins','wallet_1','wallet_2'};
handles.object_list = object_list;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_testing wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%% 
% --- Outputs from this function are returned to the command line.
function varargout = GUI_testing_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% LOAD IN IMAGE (LOAD SCENE BUTTON)
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)

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
imwrite(image_file,strcat('found_objects/',current_scene,'/',current_scene,'.pgm'),'pgm'); % save scene as Pgm
handles.image_file = image_file;
handles.image_file_rgb = image_file_rgb;
guidata(hObject,handles);

%% REWRITE OBJECTS AS PGM (RENAME BUTTON)
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
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
global current_scene
image_pgm = imread(strcat('input_images/objects/calculator/image_2.pgm'));
%canny_image = edge(image_pgm,'canny',0.3);
%CH_objects = bwconvhull(canny_image,'Objects');
bw_image = im2bw(image_pgm,0.55);
se = strel('disk',2);
after_erosion = imerode(~bw_image,se);
se = strel('disk',6);
after_dilate = imdilate(after_erosion,se);
bw_image = ~bw_image;
label = bwlabel(bw_image,8);
stat=regionprops(label,'Centroid','Area','PixelIdxList');
[maxValue,index] = max([stat.Area]);
[row col] = size(stat);
for i=1:row
    if (i~=index)
       bw_image(stat(i).PixelIdxList) = 0; % Remove all small regions except large area index
    end
end
%[rows cols] = size(CH_objects)
dim = size(bw_image);
cols = round(dim(2)/2);
rows = min(find(bw_image(:,cols)));
boundary = bwtraceboundary(bw_image,[rows, cols],'N');
figure()
imshow(image_pgm)
hold on;
plot(boundary(:,2),boundary(:,1),'g','LineWidth',3); % Change colour each time it iterates
hold off;
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
image_pgm = strcat('input_images/objects/canned_beans/image_1.pgm');
match(scene_pgm, image_pgm,1);

%% SIFT MATCH OF ALL IMAGES OF OBJECT IN SCENE (SIFT MATCHES BUTTON)
% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
global current_scene
scene_pgm = strcat('found_objects/',current_scene,'/',current_scene,'.pgm');

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
%% ADD EACH DETECTED OBJECT BESIDE MAIN IMAGE (APPEND BUTTON)
% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
global current_scene;
scene1 = handles.image_file_rgb;

image1 = imread('input_images/objects/battery/1.jpg');
image2 = imread('input_images/objects/battery/2.jpg');


% scene1 = imread(strcat('found_objects/',current_scene,'/',current_scene,'.pgm');
% image1 = imread('found_objects/scene_1/image_1.pgm');
% image2 = imread('found_objects/scene_1/image_2.pgm');
% image3 = imread('found_objects/scene_1/image_3.pgm');
% image4 = imread('found_objects/scene_1/image_4.pgm');
app = appendimages(scene1,image1);
app2 = image1;
for ii = 2:4
    %im = imread(strcat('found_objects/scene_1/image_',num2str(ii),'.pgm')); % make this read the detected image
    im = imread(strcat('input_images/objects/battery/',num2str(ii),'.jpg'));
    app2 = appendimages2(app2,im,scene1,ii); % apends images downwards
    app = appendimages(scene1,app2);
    imagesc(app); axis(handles.axes1, 'equal','tight','off')
end

colormap(gray)

%% Read Folder and Crop, Covert to PGM button
% Used this to iterate over folders of images and convert them to PGM
% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
%type = 'wallet_2';
for jj = 1:20 % Object list index
    type = char(handles.object_list(jj));
    d = strcat('input_images/objects/',type);
    files = dir(fullfile(d,'*.jpg'));
    %figure()
    for kk = 1:numel(files)
        file_name = fullfile(d,files(kk).name);
        image = imread(file_name);
        image = imresize(image,0.25);
        image_rgb = image;
        if (size(image,3) == 3) % If image is RGB, convert to gray
            image = rgb2gray(image);
        end
        bw_image = imbinarize(image,0.5);
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
            cropped_image = imcrop(image_rgb, [coord(1), coord(2), coord(3), coord(4)]);
            temp = cropped_image;
            [r, c, ~] = size(temp);
            [r2, c2, ~] = size(max);
            if (r * c > r2 * c2)
                max = temp;
            end
        end
        %subplot(2,3,kk);
        %imshow(max);
        imwrite(max,strcat('input_images/objects/',type,'/',num2str(kk),'.jpg'),'jpg');
        imwrite(max,strcat('input_images/objects/',type,'/image_',num2str(kk),'.pgm'),'pgm');
    end
end

%% Best Match Button
% this compares the found object with the actual object and its
% orientations
% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
global current_scene
max = 0;
temp = 0;
best = 0;
scene_pgm = strcat('found_objects/',current_scene,'/',current_scene,'.pgm');
for jj = 3:3 % Object list index - 3 is Canned Beans
    type = char(handles.object_list(jj));
    for ii = 1:6 % Orienation index
        image_pgm = strcat('input_images/objects/',type,'/image_',num2str(ii),'.pgm');
        %match(scene_pgm, image_pgm,1);
        num = match(scene_pgm, image_pgm,0);
        temp = num;
        if (temp > max)
            max = temp;
            best = image_pgm;
        end
    end
match(scene_pgm, best,1);

%imagesc(imread(best)); axis(handles.axes1, 'equal','tight','off')
end
handles.best_test = best;
guidata(hObject,handles);

%% Test Outline Button (Draws outlines over all objects) (likely delete this)
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
dilated = 0;
scene = imread(scene_pgm);
new_db = cell(1,20);
scale = cell(1,20);
firstFlag = 1;
dont_draw_lines = 0;
for ii = 1:20%:length(handles.object_list)
    scene = imread(scene_pgm);
    type = char(handles.object_list(ii));
    disp('--------------------------------------');
    printer = ['Searching for ',type];
    disp(printer);
    for jj = 1:6
        image_pgm = strcat('input_images/objects/',type,'/image_',num2str(jj),'.pgm');
        try
            disp('---- GETTING MATCHES ----');
            [match_loc1, match_loc2, match_results,des1,loc1,loc2] = new_match(scene_pgm,image_pgm,0);
            disp('---- RANSAC MATCHES ----');
            printer = ['Performing RANSAC on ',strcat(type,'/image_',num2str(jj),'.pgm')];
            disp(printer);
            [H, corrPtIdx] = findHomography(match_loc2',match_loc1');
            [match_loc1,match_loc2,num] = ransac_match(scene_pgm,image_pgm,corrPtIdx,match_results,des1,loc1,loc2,0);
            temp = num;
            if temp > max 
                if (temp > 7) % need at least 7 matches 
                    max = temp;
                    best = image_pgm;
                    best_homo = H;
                    best_match_loc1 = match_loc1;
                    best_match_loc2 = match_loc2; 
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
 %%  UNCOMMENT THIS WHEN WORKING ON THE OUTLINE SECTION 

%         [tform, ~, ~] = estimateGeometricTransform(best_match_loc2, best_match_loc1, 'affine');
%         imgout = warp_it(best_homo,best,scene,tform); 
%         [rows, cols, ~] = size(imgout);
%         [rows2, cols2, ~] = size(scene);
%         if (rows*cols <= rows2*cols2)  
%             dilated = dilate_them(imgout,handles,dilated);
%         else
%             disp('ERROR TRANSFORMING');
%         end
 %%
    end 
    if (matches == 1 && firstFlag)
        %best(end-4)
        %image = imread(best);
        image = imread(strcat('input_images/objects/',type,'/',best(end-4),'.jpg'));
        scene = handles.image_file_rgb;
        app = appendimages(scene,image);
        app2 = image;
        scale(1) = {[1,1]};
        imwrite(app2,strcat('found_objects/',current_scene,'/append_',num2str(matches),'.pgm'),'pgm');
        imagesc(app); axis(handles.axes1, 'equal','tight','off')
        firstFlag = 0;
    elseif (matches > 1)
        try
            %im_2 = imread(best);
            im_2 = imread(strcat('input_images/objects/',type,'/',best(end-4),'.jpg'));
            scene = handles.image_file_rgb;
            [app2,scale] = appendimages2(app2,im_2,scene,matches,scale); % appends images downwards
            imwrite(app2,strcat('found_objects/',current_scene,'/append_',num2str(matches),'.pgm'),'pgm');
            app = appendimages(scene,app2);
            imagesc(app); axis(handles.axes1, 'equal','tight','off')
        catch
            continue
        end
    end
    
    if (matches > 0)
       %try
       draw_new_lines(scene_pgm,app,app2,new_db,matches,scale)
       axis(handles.axes1, 'equal','tight','off')
       if (dont_draw_lines)
            imagesc(app); axis(handles.axes1, 'equal','tight','off')
       end
       %catch
       %    continue
       %end
    end

best = 0;
max = 0;
end

%%


%% RANSAC Best Match button
% performs RANSAC on best image found in Best Match Button
% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
global current_scene;
best = handles.best_test;
scene_pgm = strcat('found_objects/',current_scene,'/',current_scene,'.pgm');
image_pgm = best;
[match_loc1, match_loc2, match_results,des1,loc1,loc2] = new_match(scene_pgm,image_pgm,0);
printer = ['Performing RANSAC on ',best];
disp(printer);
[H, corrPtIdx] = findHomography(match_loc2',match_loc1');
[match_loc1,match_loc2,num] = ransac_match(scene_pgm,image_pgm,corrPtIdx,match_results,des1,loc1,loc2,1);
           
 %% IGNORE THIS          
        %[tform, ~, ~] = estimateGeometricTransform(best_match_loc2(1:4,:), best_match_loc1(1:4,:), 'projective');
        %[tform, ~, ~] = estimateGeometricTransform(best_match_loc2, best_match_loc1, 'affine');
        
       
%         figure()  
%         subplot(1,2,1);
%         imshow(handles.image_file);
%         hold on
%         plot(best_match_loc1(:,1), best_match_loc1(:,2),'r*');
%         hold off
%         
%         subplot(1,2,2);
%         imshow('input_images/objects/calculator/image_1.pgm');
%         hold on
%         plot(best_match_loc2(:,1), best_match_loc2(:,2),'g*');
%         hold off
        

        %%[x,y] = transformPointsForward(tform,best_match_loc2, best_match_loc1);
        
%         U = transformPointsForward(tform,best_match_loc2);
%         figure()  
%         imshow(handles.image_file);
%         hold on
%         plot(U(:,1),U(:,2),'b*');
%         hold off
