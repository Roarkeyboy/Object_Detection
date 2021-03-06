% UWA CITS4402 Computer Vision
% Group 19
% Roarke Holland 21742366
% Jayden Kur 21988713
% Andrew Ha 22246801 

%% Presentation GUI
% This is the GUI to which can automatically display object matches on a
% given scene. It appends the objects to the objects found listbox as well as
% appending their images and drawing outlines and lines. It requires an
% input scene and then the detection can begin.

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

% Last Modified by GUIDE v2.5 26-May-2020 18:41:16

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
% Created [RGB] colour list for dynamic colouring for objects
colour_list = {[124,252,0],[255,0,0],[255,255,0],[139,0,0],[128,0,128],[128,128,0],[0,128,0],[0,128,128],[0,0,0],[255,255,255],[0,255,0],[0,0,255],[0,255,255],[255,0,255],[192,192,192],[128,128,128],[0,0,128],[128,0,0],[255,69,0],[255,215,0]};
handles.colour_list = colour_list;
% Created object list to index through
object_list = {'bandaids','battery','book','calculator','canned_beans','card_1','card_2','cd','deodorant','drink_holder','migoreng','minion','mints','pest_paper','shoe','snack_bar','strepsils','toothpaste','up_go','wallet_2'};
handles.object_list = object_list;
% For calculating accuracy, numbers in array are numbers of known objects
% in scene
objects_in_images_list = {4,4,4,4,4,6,6,6,6,8,4,5,3,3,3,3,3,3,3,3,8,3,3,5,3,4,5,7,5,12};
handles.objects_in_images_list  = objects_in_images_list;
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
handles.image_file = image_file;
handles.image_file_rgb = image_file_rgb;
% get scene index number (etc. scene_2 is 2)
index = strcat(file_name(1+strfind(file_name,'_'):strfind(file_name,'.')-1),'');
index = str2double(index);
handles.index_file = index;
handles.text6.String = ('N/A'); % start with no accuracy
drawnow()
guidata(hObject,handles);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global current_scene;
scene_pgm = strcat('input_images/scenes/',current_scene,'.pgm');
index_file = handles.index_file;
objects_in_images_list = handles.objects_in_images_list;
new_data = handles.new_data;
% initialization 
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
% update Status Bar, Status Colour and Accuracy of matches
handles.text3.String = ('SEARCHING');
set(handles.text3,'BackgroundColor','red');
handles.text6.String = ('N/A');
drawnow(); % update 
% do not allow user input to draw lines or draw object outlines
set(handles.checkbox1,'Enable','off')
set(handles.checkbox2,'Enable','off')
set(handles.checkbox3,'Enable','off')
drawnow();
% main automation function to update gui with matches (lines, outlines and
% total)
total_matches = full_run(current_scene,handles,hObject,scene_pgm,new_data,max,matches,best,best_homo,best_match_loc1,best_match_loc2,dilated,new_db,scale,text_string,first_flag);
% allow user input to draw lines or draw object outlines
set(handles.checkbox1,'Enable','on')
set(handles.checkbox2,'Enable','on')
set(handles.checkbox3,'Enable','on')
% update Status Bar, Status Colour and Accuracy of matches
set(handles.text3,'BackgroundColor','green');
handles.text3.String = ('FINISHED SEARCHING');
accuracy = 100*(total_matches/objects_in_images_list{index_file}); 
handles.text6.String = strcat(num2str(accuracy),'%');

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% get all the handles to pass to draw_new_lines function
outlined_app = handles.outlined;
not_outlined = handles.not_outlined;
scene_pgm = handles.scene_pgm;
app2 = handles.app2;
new_db = handles.new_db;
matches = handles.matches;
scale = handles.scale;
% check other checkboxes values in order to display lines appropriately
if((get(handles.checkbox1,'Value') == 1) && (get(handles.checkbox2,'Value') == 1))
    draw_new_lines(scene_pgm,outlined_app,app2,new_db,matches,scale,hObject,handles); % with outline
elseif((get(handles.checkbox1,'Value') == 1) && (get(handles.checkbox2,'Value') == 0))
    draw_new_lines(scene_pgm,not_outlined,app2,new_db,matches,scale,hObject,handles); % without outline
elseif(get(handles.checkbox1,'Value') == 0) && (get(handles.checkbox2,'Value') == 0)
    imagesc(handles.not_outlined); axis(handles.axes1, 'equal','tight','off')
else
    imagesc(handles.outlined); axis(handles.axes1, 'equal','tight','off')
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% get all the handles to pass to draw_new_lines function
outlined_app = handles.outlined;
not_outlined = handles.not_outlined;
scene_pgm = handles.scene_pgm;
app2 = handles.app2;
new_db = handles.new_db;
matches = handles.matches;
scale = handles.scale;
% check other checkboxes values in order to display lines appropriately
if(get(handles.checkbox1,'Value') == 0) && (get(handles.checkbox2,'Value') == 0)
    imagesc(not_outlined); axis(handles.axes1, 'equal','tight','off') % without outline 
elseif(get(handles.checkbox1,'Value') == 0) && (get(handles.checkbox2,'Value') == 1)
    imagesc(outlined_app); axis(handles.axes1, 'equal','tight','off') % with outline
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


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% check checkbox3 values to use trained model or not
if(get(handles.checkbox3,'Value') == 1)
    handles.new_data = 0;
elseif(get(handles.checkbox3,'Value') == 0)
    handles.new_data = 1;
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function checkbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.new_data = 0; % set new_data to 0, indicating that it wont be using the new data search
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function checkbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','off') % start disabled

% --- Executes during object creation, after setting all properties.
function checkbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','off') % start disabled