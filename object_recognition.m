function varargout = object_recognition(varargin)
% OBJECT_RECOGNITION MATLAB code for object_recognition.fig
%      OBJECT_RECOGNITION, by itself, creates a new OBJECT_RECOGNITION or raises the existing
%      singleton*.
%
%      H = OBJECT_RECOGNITION returns the handle to a new OBJECT_RECOGNITION or the handle to
%      the existing singleton*.
%
%      OBJECT_RECOGNITION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OBJECT_RECOGNITION.M with the given input arguments.
%
%      OBJECT_RECOGNITION('Property','Value',...) creates a new OBJECT_RECOGNITION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before object_recognition_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to object_recognition_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help object_recognition

% Last Modified by GUIDE v2.5 25-May-2020 11:47:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @object_recognition_OpeningFcn, ...
                   'gui_OutputFcn',  @object_recognition_OutputFcn, ...
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


% --- Executes just before object_recognition is made visible.
function object_recognition_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to object_recognition (see VARARGIN)

% Choose default command line output for object_recognition
handles.output = hObject;
% Created colour list for dynamic colouring for objects
colour_list = {[124,252,0],[255,0,0],[255,255,0],[139,0,0],[128,0,128],[0,0,0],[255,255,255],[0,255,0],[0,0,255],[0,255,255],[255,0,255],[192,192,192],[128,128,128],[128,128,0],[0,128,0],[0,128,128],[0,0,128],[128,0,0],[255,69,0],[255,215,0]};
handles.colour_list = colour_list;
% Created object list to index through
object_list = {'bandaids','battery','book','calculator','canned_beans','card_1','card_2','cd','deodorant','drink_holder','migoreng','minion','mints','pest_paper','shoe','snack_bar','strepsils','toothpaste','up_go','wallet_2'};
handles.object_list = object_list;
set(handles.axes1,'Visible','off'); % Start with left axis not visible
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes object_recognition wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = object_recognition_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file_name,file_path]= uigetfile('full_size_images/scenes/*.jpg'); % Get the jpg data from the users selection
full_name = [file_path file_name]; 
global current_scene
current_scene = file_name(1:strfind(file_name,'.')-1);
image_file = imread(full_name); % Read in image at given path
image_file = imresize(image_file,0.25);
image_file_rgb = image_file; % Save a copy of image before conversion
imagesc(image_file); axis(handles.axes1, 'equal','tight','off')% Using axes2 % Display the image onto the axes
if (size(image_file,3) == 3) % If image is RGB, convert to gray
    image_file = rgb2gray(image_file);
end
colormap(gray) % display grayscale
%imwrite(image_file,strcat('found_objects/',current_scene,'/',current_scene,'.pgm'),'pgm');
%imwrite(image_file,strcat('input_images/scenes/',current_scene,'.pgm'),'pgm');
handles.image_file = image_file;
handles.image_file_rgb = image_file_rgb;
guidata(hObject,handles);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global current_scene;
scene_pgm = strcat('input_images/scenes/',current_scene,'.pgm');
disp(current_scene);
new_data = 0;
max = 0;
matches = 0;
best = 0;
best_homo = 0;
best_match_loc1 = 0;
best_match_loc2 = 0;
dilated = 0;
new_db = cell(1,20);
scale = cell(1,20);
text_string = cell(1,20);
first_flag = 1;
handles.text3.String = ('SEARCHING');
set(handles.text3,'BackgroundColor','red');
full_run(current_scene,handles,hObject,scene_pgm,new_data,max,matches,best,best_homo,best_match_loc1,best_match_loc2,dilated,new_db,scale,text_string,first_flag);

set(handles.text3,'BackgroundColor','green');
handles.text3.String = ('FINISHED SEARCHING');
% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)

outlined_app = handles.outlined;
not_outlined = handles.not_outlined;
scene_pgm = handles.scene_pgm;
app2 = handles.app2;
new_db = handles.new_db;
matches = handles.matches;
scale = handles.scale;
if((get(handles.checkbox1,'Value') == 1) && (get(handles.checkbox2,'Value') == 1))
    draw_new_lines(scene_pgm,outlined_app,app2,new_db,matches,scale,hObject,handles);
elseif((get(handles.checkbox1,'Value') == 1) && (get(handles.checkbox2,'Value') == 0))
    draw_new_lines(scene_pgm,not_outlined,app2,new_db,matches,scale,hObject,handles);
elseif(get(handles.checkbox1,'Value') == 0) && (get(handles.checkbox2,'Value') == 0)
    imagesc(handles.not_outlined); axis(handles.axes1, 'equal','tight','off')
else
    imagesc(handles.outlined); axis(handles.axes1, 'equal','tight','off')
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
outlined_app = handles.outlined;
not_outlined = handles.not_outlined;
scene_pgm = handles.scene_pgm;
app2 = handles.app2;
new_db = handles.new_db;
matches = handles.matches;
scale = handles.scale;

if(get(handles.checkbox1,'Value') == 0) && (get(handles.checkbox2,'Value') == 0)
    imagesc(handles.not_outlined); axis(handles.axes1, 'equal','tight','off')
elseif(get(handles.checkbox1,'Value') == 0) && (get(handles.checkbox2,'Value') == 1)
    imagesc(handles.outlined); axis(handles.axes1, 'equal','tight','off')
elseif(get(handles.checkbox1,'Value') == 1) && (get(handles.checkbox2,'Value') == 1)
    draw_new_lines(scene_pgm,outlined_app,app2,new_db,matches,scale,hObject,handles);
else
    draw_new_lines(scene_pgm,not_outlined,app2,new_db,matches,scale,hObject,handles);
end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
