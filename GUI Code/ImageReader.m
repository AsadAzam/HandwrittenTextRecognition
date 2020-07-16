function varargout = ImageReader(varargin)
% ImageReader MATLAB code for ImageReader.fig
%      ImageReader, by itself, creates a new ImageReader or raises the existing
%      singleton*.
%
%      H = ImageReader returns the handle to a new ImageReader or the handle to
%      the existing singleton*.
%
%      ImageReader('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ImageReader.M with the given input arguments.
%
%      ImageReader('Property','Value',...) creates a new ImageReader or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImageReader_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImageReader_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageReader

% Created 03-Feb-2020 15:18:00
% Last Modified by GUIDE v2.5 1-Apr-2019 19:52:09


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImageReader_OpeningFcn, ...
                   'gui_OutputFcn',  @ImageReader_OutputFcn, ...
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

% --- Executes just before ImageReader is made visible.
function ImageReader_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImageReader (see VARARGIN)

% Choose default command line output for ImageReader
handles.output = hObject;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ImageReader wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ImageReader_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function recognizedText_Callback(hObject, eventdata, handles)
% hObject    handle to recognizedText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of recognizedText as text
%        str2double(get(hObject,'String')) returns contents of recognizedText as a double
get(hObject,'String');


% --- Executes during object creation, after setting all properties.
function recognizedText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to recognizedText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in preprocessing.
function preprocessing_Callback(hObject, eventdata, handles)
% hObject    handle to preprocessing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Input Image
originalImage = handles.originalImage;
% Show image
imshow(originalImage,'parent',handles.axes1);
% Convert to binary image
threshold = graythresh(originalImage);
binaryImage =~im2bw(originalImage,threshold);
% Remove all object containing fewer than 30 pixels
moddedImage = bwareaopen(binaryImage,30);
pause(1)
% Show image binary image
imshow(~moddedImage,'parent',handles.axes3);
% Label connected components
[L,Ne]=bwlabel(moddedImage);
% Measure properties of image regions
propied=regionprops(L,'BoundingBox');
hold on
% Plot Bounding Box
for n=1:size(propied,1)
    rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2)
end
hold off
pause (1)
% Image Segmentation
for n=1:Ne
    [r,c] = find(L==n);
    n1=moddedImage(min(r):max(r),min(c):max(c));
    n1 = imgaussfilt(im2double(n1),1);
    n1 = padarray(imresize(n1,[20 20],'bicubic'),[4 4],0,'both');
    fullFileName = fullfile('segmentedImages', sprintf('image%d.png', n));
    imwrite(n1, fullFileName);
    pause(1)
end
handles.Ne=Ne;
guidata(hObject,handles);


% --- Executes on button press in trainNetwork.
function trainNetwork_Callback(hObject, eventdata, handles)
% hObject    handle to trainNetwork (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('network.mat');
Ne=handles.Ne;
for i=1:Ne
    segImage=reshape(double(imread(fullfile('segmentedImages', sprintf('image%d.png', i)))) , 784, 1);
    outputMatrix=net(segImage);
    row=find(ismember(outputMatrix, max(outputMatrix(:))));
    rowMatrix(i,1)=row;
end
handles.rowMatrix=rowMatrix;
guidata(hObject,handles);

% --- Executes on button press in recognition.
function recognition_Callback(hObject, eventdata, handles)
% hObject    handle to recognition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles = guidata(hObject);
for i=1:handles.Ne
    detectedWord(1,i)=imageLabeler(handles.rowMatrix(i,1));
end
%detectedText=fprintf('Detected Text: %s\n',detectedWord);
handles.detectedWord=detectedWord;
set(handles.recognizedText, 'String', detectedWord);
guidata(hObject,handles);

% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
user_response = modaldlg('Title','Confirm Close');
switch user_response
case 'No'
	% take no action
case 'Yes'
	% Prepare to close application window
	delete(ImageReader)
end
        
% --- Executes on button press in selectImage.
function selectImage_Callback(hObject, eventdata, handles)
% hObject    handle to selectImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname]= uigetfile({'*.png';'*.jpg';'*.bmp';'*.jpeg'},'Select an Image');
if isequal(filename,0) || isequal(pathname,0)
    uiwait(msgbox('User Pressed Cancel','failed','modal'))
    [filename,pathname]= uigetfile({'*.png';'*.jpg';'*.bmp';'*.jpeg'},'Select an Image');
    hold off;
else
    uiwait(msgbox('Image added Successfully','success','modal'))
    hold off;
    originalImagePath= strcat(pathname,filename);
    originalImage = imread(originalImagePath);
    imshow(originalImage,'Parent',handles.axes1) 
end
handles.originalImage = originalImage;
guidata(hObject,handles);
