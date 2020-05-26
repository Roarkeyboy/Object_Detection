%% GUI Testing code for the various GUI buttons
% This gui is for the testing and demonstration of the functions that the
% system will perform on given data. It converts input images to pgm files,
% calculates sift data values for given images. 


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

% Last Modified by GUIDE v2.5 26-May-2020 14:15:55

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
% Created colour list for dynamic colouring for objects
colour_list = {[124,252,0],[255,0,0],[255,255,0],[139,0,0],[128,0,128],[0,0,0],[255,255,255],[0,255,0],[0,0,255],[0,255,255],[255,0,255],[192,192,192],[128,128,128],[128,128,0],[0,128,0],[0,128,128],[0,0,128],[128,0,0],[255,69,0],[255,215,0]};
handles.colour_list = colour_list;
% Created object list to index through
object_list = {'bandaids','battery','book','calculator','canned_beans','card_1','card_2','cd','deodorant','drink_holder','migoreng','minion','mints','pest_paper','shoe','snack_bar','strepsils','toothpaste','up_go','wallet_2'};
handles.object_list = object_list;
% Set up path for initial scene to be read in
file_name = ('scene_10.jpg');
file_path = ('full_size_images/scenes/'); 
full_name = [file_path file_name]; 
% Use a global variable to pass and use in most functions
global current_scene
current_scene = file_name(1:strfind(file_name,'.')-1);
image_file = imread(full_name); % Read in image at given path
image_file = imresize(image_file,0.25); % Scale image down to 25%
image_file_rgb = image_file; % Save a copy of image before conversion
imagesc(image_file); axis(handles.axes1, 'equal','tight','off')% Using axes1 % Display the image onto the axes
if (size(image_file,3) == 3) % If image is RGB, convert to gray
    image_file = rgb2gray(image_file);
end
colormap(gray) % display grayscale
imwrite(image_file,strcat('input_images/scenes/',current_scene,'.pgm'),'pgm'); % save scene as Pgm
handles.image_file = image_file;
handles.image_file_rgb = image_file_rgb;

handles.best_test = ('input_images/objects/card_1/image_3.pgm'); % Incase RANSAC best button is pressed first
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


%% SIFT MATCH OF SINGLE OBJECT WITH SCENE (SIFT MATCH BUTTON)
% As this GUI is more of an example, preset scene and image are used to
% display
% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
global current_scene
scene_pgm = strcat('found_objects/',current_scene,'/scene_10.pgm');
image_pgm = ('input_images/objects/card_1/image_3.pgm');
match(scene_pgm, image_pgm,1); % Pass 1 as third parameter to display match
axis(handles.axes1, 'equal','tight','off')

%% SIFT MATCH OF ALL IMAGES OF OBJECT IN SCENE (SIFT MATCHES BUTTON)
% As this GUI is more of an example, preset scene and image are used to
% display
% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
global current_scene
scene_pgm = strcat('found_objects/',current_scene,'/',current_scene,'.pgm');
for ii = 6 %1:length(handles.object_list)    % Using 6 as it equates to card_1 in object list
    type = char(handles.object_list(ii)); % Access object_list with an index point to retrieve object name
    d = strcat('input_images/objects/',type,'/');
    files = dir(fullfile(d,'*.pgm'));
    for jj = 1:numel(files) % iterate over all pgm files
        image_pgm = strcat('input_images/objects/',type,'/image_',num2str(jj),'.pgm');
        try
            match(scene_pgm, image_pgm,1); % match with display
        catch
            continue;
        end
        axis(handles.axes1, 'equal','tight','off')
    end
end

%% SAVE LOCATIONS AND DESCRIPTORS AS MATLAB DATA (SAVE ALL SIFT DATA BUTTON)
% This iterates over the input_images folder to and takes all of the scenes
% and saves their sift data to a file. It then iterates over all objects
% and their orientations and saves their sift data. This process saves a
% lot of time later on if we choose to use this "trained" data
% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
for ii = 1:30 % All scenes
    scene_pgm = strcat('input_images/scenes/scene_',num2str(ii),'.pgm');
    [im1, des1, loc1] = sift(scene_pgm);
    save(strcat('input_images/scenes/scene_',num2str(ii),'.mat'),'im1', 'des1','loc1'); % write im1,des1,loc1 to m file
end
for ii = 1:length(handles.object_list)  % all objects  
    type = char(handles.object_list(ii));
    d = strcat('input_images/objects/',type,'/');
    files = dir(fullfile(d,'*.pgm'));
    for jj = 1:numel(files) % all orientations
        image_pgm = strcat('input_images/objects/',type,'/image_',num2str(jj),'.pgm');
        [im2, des2, loc2] = sift(image_pgm);
        save(strcat('input_images/objects/',type,'/image_',num2str(jj),'.mat'), 'im2','des2','loc2');
    end
end
disp('All SIFT data saved!');

%% Read Folder and Crop, Covert to PGM button
% Use this to iterate over folders of scenes and objects and convert to
% pgm after scaling down to 25%. The objects are converted to binary images
% to crop them down to a more appropriate size for later use.
% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
object_list = handles.object_list;
for ii = 1:30 % all scenes
    scene_path = strcat('full_size_images/scenes/scene_',num2str(ii),'.jpg');
    image_file = imread(scene_path); % Read in image at given path
    image_file = imresize(image_file,0.25);
    if (size(image_file,3) == 3) % If image is RGB, convert to gray
        image_file = rgb2gray(image_file);
    end
    imwrite(image_file,strcat('input_images/scenes/scene_',num2str(ii),'.pgm'),'pgm'); % save scene as Pgm
end
for jj = 1:length(object_list)  % all objects
    type = char(object_list(jj));
    d = strcat('full_size_images/objects/',type);
    files = dir(fullfile(d,'*.jpg'));
    for kk = 1:numel(files) % all orientations
        file_name = fullfile(d,files(kk).name);
        image = imread(file_name);
        image = imresize(image,0.25);
        image_rgb = image;
        if (size(image,3) == 3) % If image is RGB, convert to gray
            image = rgb2gray(image);
        end
        bin_value = 0.5; % default binary value for conversion
        if((jj == 1) || (jj == 7) || (jj == 12)) % certain objects had better results when their binary value was changed
            bin_value = 0.35;
        elseif(jj == 16)
            bin_value = 0.55;
        elseif(jj == 17)
            bin_value = 0.46;
        end
        bw_image = imbinarize(image,bin_value); % binarize
        se = strel('disk',4);
        after_erosion = imerode(~bw_image,se); % erode image
        after_dilate = imdilate(after_erosion,se); % dilate image
        [label,total] = bwlabel(after_dilate,8); % find objects
        bounding_boxes = regionprops(label,'BoundingBox'); % find bounding boxes around objects
        max = 0;
        for ii = 1:total % iterate over all objects
            coord = bounding_boxes(ii).BoundingBox;
            cropped_image = imcrop(image_rgb, [coord(1), coord(2), coord(3), coord(4)]); % crop image at coordinates
            temp = cropped_image;
            [r, c, ~] = size(temp);
            [r2, c2, ~] = size(max);
            if (r * c > r2 * c2) % as bounding boxes are iterated, choose the largest one
                max = temp;
            end        
        end  
        imwrite(max,strcat('input_images/objects/',type,'/',num2str(kk),'.jpg'),'jpg'); % write as jpg
        imwrite(max,strcat('input_images/objects/',type,'/image_',num2str(kk),'.pgm'),'pgm'); % write as pgm
    end
end
disp('All images converted to PGM!');

%% Best Match Button
% This finds the best match of a given object and all of its orientations,
% then displays it with the match function
% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
global current_scene
max = 0;
best = 0;
scene_pgm = strcat('found_objects/',current_scene,'/',current_scene,'.pgm');
for jj = 6 % Object list index - 6 is card_1
    type = char(handles.object_list(jj));
    d = strcat('input_images/objects/',type);
    files = dir(fullfile(d,'*.pgm'));
    for ii = 1:numel(files) % all orientations
        image_pgm = strcat('input_images/objects/',type,'/image_',num2str(ii),'.pgm');
        num = match(scene_pgm, image_pgm,0); % get amount of matches
        temp = num;
        if (temp > max) % if iteration provides more matches, change max
            max = temp;
            best = image_pgm;
        end
    end
match(scene_pgm, best,1); % display the final match
axis(handles.axes1, 'equal','tight','off')
end
handles.best_test = best; % save for RANSAC best match function
guidata(hObject,handles);

%% Match and Append (Colour) button
% This is an example of the automation that the completely automated
% version of the software will use. It finds a match with an object and the
% scene, appends it beside the scene and draws lines to the matches.
% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)

global current_scene;
scene_pgm = strcat('input_images/scenes/',current_scene,'.pgm');
% Initializations
max = 0;
matches = 0;
best = 0;
best_homo = 0;
best_match_loc1 = 0;
best_match_loc2 = 0;
dilated = 0;
new_db = cell(1,20); % saves the coordinates of each match to be passed on to drawing function
scale = cell(1,20); % scale of an appended object compared to the object above it
firstFlag = 1; % first pass flag
for ii = 6 % card_1 index
    scene = imread(scene_pgm);
    type = char(handles.object_list(ii));
    disp('--------------------------------------');
    printer = ['Searching for ',type]; % display what object it is searching for
    disp(printer);
    for jj = 1:6 % all orientations
        image_pgm = strcat('input_images/objects/',type,'/image_',num2str(jj),'.pgm');
        try
            disp('---- GETTING MATCHES ----');
            [match_loc1, match_loc2, match_results,des1,loc1,loc2] = new_match(scene_pgm,image_pgm,0,1,current_scene); % get the sift match data for given images
            disp('---- RANSAC MATCHES ----');
            printer = ['Performing RANSAC on ',strcat(type,'/image_',num2str(jj),'.pgm')]; % display what is being RANSAC
            disp(printer);
            [H, corrPtIdx] = findHomography(match_loc2',match_loc1'); % find the homography matrix calculated with the match locations given
            [match_loc1,match_loc2,num] = ransac_match(scene_pgm,image_pgm,corrPtIdx,match_results,des1,loc1,loc2,0);
            temp = num;
            if temp > max 
                if (temp > 20) % need at least 20 matches to be considered a good match (this helps with transforming the image when drawing the outline)
                    max = temp;
                    % save all the "best" variables for later displaying
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
    if (best == 0) % no object found
        printer2 = ['No good match for ',type];
        disp(printer2);
    else 
        matches = matches + 1; % increment matches
        new_db(matches) = {[best_match_loc1,best_match_loc2]};  % save match locations to database
    end 
    if (matches == 1 && firstFlag) % first image appending
        image = imread(strcat('input_images/objects/',type,'/',best(end-4),'.jpg'));
        scene = handles.image_file_rgb;
        app = appendimages(scene,image); % append image to scene
        app2 = image;
        scale(1) = {[1,1]}; % initial scale 
        imwrite(app2,strcat('found_objects/',current_scene,'/append_',num2str(matches),'.pgm'),'pgm');
        imagesc(app); axis(handles.axes1, 'equal','tight','off')
        firstFlag = 0;
    elseif (matches > 1)
        try
            im_2 = imread(strcat('input_images/objects/',type,'/',best(end-4),'.jpg'));
            scene = handles.image_file_rgb;
            [app2,scale] = appendimages2(app2,im_2,scene,matches,scale); % appends images downwards
            imwrite(app2,strcat('found_objects/',current_scene,'/append_',num2str(matches),'.pgm'),'pgm');
            app = appendimages(scene,app2); % append matched objects with scene 
            imagesc(app); axis(handles.axes1, 'equal','tight','off')
        catch
            continue
        end
    end    
    if (matches > 0)
       draw_new_lines(scene_pgm,app,app2,new_db,matches,scale,hObject,handles) % draw lines connecting scene match with object match
       axis(handles.axes1, 'equal','tight','off')
    end
best = 0;
max = 0;
end

%% RANSAC Best Match button
% performs RANSAC on best matchfound from the Best Match Button
% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
global current_scene;
best = handles.best_test;
scene_pgm = strcat('input_images/scenes/',current_scene,'.pgm');
image_pgm = best;
[match_loc1, match_loc2, match_results,des1,loc1,loc2] = new_match(scene_pgm,image_pgm,0,0,current_scene); % perform match and return results
printer = ['Performing RANSAC on ',best];
disp(printer);
[H, corrPtIdx] = findHomography(match_loc2',match_loc1'); % find homography
[match_loc1,match_loc2,num] = ransac_match(scene_pgm,image_pgm,corrPtIdx,match_results,des1,loc1,loc2,1); % run RANSAC match function which removes outliers and displays new match image
axis(handles.axes1, 'equal','tight','off')

%% Draw Outline (Colour) button
% Same as match and append button but does not append or draw lines, just
% draws outlines (comments carry over from there)
% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)

global current_scene;
scene_pgm = strcat('input_images/scenes/',current_scene,'.pgm');
% initializations
max = 0;
matches = 0;
best = 0;
best_homo = 0;
best_match_loc1 = 0;
best_match_loc2 = 0;
dilated = 0;
new_db = cell(1,20);
for ii = 6 % card_1
    scene = imread(scene_pgm);
    type = char(handles.object_list(ii));
    disp('--------------------------------------');
    printer = ['Searching for ',type];
    disp(printer);
    for jj = 1:6 % all orientations
        image_pgm = strcat('input_images/objects/',type,'/image_',num2str(jj),'.pgm');
        try
            disp('---- GETTING MATCHES ----');
            [match_loc1, match_loc2, match_results,des1,loc1,loc2] = new_match(scene_pgm,image_pgm,0,1,current_scene);
            disp('---- RANSAC MATCHES ----');
            printer = ['Performing RANSAC on ',strcat(type,'/image_',num2str(jj),'.pgm')];
            disp(printer);
            [H, corrPtIdx] = findHomography(match_loc2',match_loc1');
            [match_loc1,match_loc2,num] = ransac_match(scene_pgm,image_pgm,corrPtIdx,match_results,des1,loc1,loc2,0);
            temp = num;
            if temp > max 
                if (temp > 20) % need at least 20 matches 
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
        [tform, ~, ~] = estimateGeometricTransform(best_match_loc2, best_match_loc1, 'affine'); % calculate a transformation object based on match locations (affine specified)
        imgout = warp_it(best_homo,best,scene,tform); % return a warped image based on the transformation object
        [rows, cols, ~] = size(imgout);
        [rows2, cols2, ~] = size(scene);
        if (rows*cols <= rows2*cols2)  % catch size errors
            dilated = dilate_them(imgout,handles,dilated,matches); % draws the outlines of an object onto the scene as pixel colours
        else
            disp('ERROR TRANSFORMING');
        end
    end 
best = 0;
max = 0;
end
