function varargout = helpGUI(varargin)
% HELPGUI MATLAB code for helpGUI.fig
%      HELPGUI, by itself, creates a new HELPGUI or raises the existing
%      singleton*.
%
%      H = HELPGUI returns the handle to a new HELPGUI or the handle to
%      the existing singleton*.
%
%      HELPGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HELPGUI.M with the given input arguments.
%
%      HELPGUI('Property','Value',...) creates a new HELPGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before helpGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to helpGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help helpGUI

% Last Modified by GUIDE v2.5 08-May-2016 17:07:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @helpGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @helpGUI_OutputFcn, ...
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


% --- Executes just before helpGUI is made visible.
function helpGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to helpGUI (see VARARGIN)

% Choose default command line output for helpGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes helpGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

axes(handles.axes1);
hema = imread('hemacytometer.jpg');
imshow(hema);


% --- Outputs from this function are returned to the command line.
function varargout = helpGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonHelp.
function pushbuttonHelp_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  structure with the following fields
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'radiobutton3'
        axes(handles.axes1);
        hema = imread('hemacytometer.jpg');
        imshow(hema);
        %errordlg('Ok the call back is linked');
    case 'radiobutton4'
        axes(handles.axes1);
        hema = imread('dicty92.bmp');
        imshow(hema);
        %errordlg('Ok the call back is linked');
end
