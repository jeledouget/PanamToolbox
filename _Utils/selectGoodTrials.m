function varargout = selectGoodTrials(varargin)
% SELECTGOODTRIALS MATLAB code for selectGoodTrials.fig
%      SELECTGOODTRIALS, by itself, creates a new SELECTGOODTRIALS or raises the existing
%      singleton*.
%
%      H = SELECTGOODTRIALS returns the handle to a new SELECTGOODTRIALS or the handle to
%      the existing singleton*.
%
%      SELECTGOODTRIALS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTGOODTRIALS.M with the given input arguments.
%
%      SELECTGOODTRIALS('Property','Value',...) creates a new SELECTGOODTRIALS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before selectGoodTrials_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to selectGoodTrials_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help selectGoodTrials

% Last Modified by GUIDE v2.5 04-May-2015 19:23:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @selectGoodTrials_OpeningFcn, ...
                   'gui_OutputFcn',  @selectGoodTrials_OutputFcn, ...
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


% --- Executes just before selectGoodTrials is made visible.
function selectGoodTrials_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to selectGoodTrials (see VARARGIN)

% Choose default command line output for selectGoodTrials
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

goodTrials = varargin{1};
badTrials = varargin{2};

% to ensure the character array has the right dimenisons for both lisbox1 and listbox2
maxT = max([goodTrials badTrials]); 

set(handles.listbox1, 'String', [goodTrials maxT]);
set(handles.listbox2, 'String', [badTrials maxT]);
tmp1 = get(handles.listbox1, 'String');
tmp2 = get(handles.listbox2, 'String');
set(handles.listbox1, 'String', tmp1(1:end-1,:));
set(handles.listbox2, 'String', tmp2(1:end-1,:));
set(handles.listbox1,'Max',2,'Min',0);
set(handles.listbox2,'Max',2,'Min',0);

% UIWAIT makes selectGoodTrials wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = selectGoodTrials_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
tmp = get(handles.listbox2, 'String');
varargout{1} = sort(str2num(tmp)');
tmp = get(handles.listbox1, 'String');
varargout{2} = sort(str2num(tmp)')
close(handles.figure1);


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


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val1 = get(handles.listbox1, 'Value');
str1 = get(handles.listbox1, 'String');
str2 = get(handles.listbox2, 'String');
if val1(end) == size(str1,1)
    set(handles.listbox1, 'Value',1);
end
set(handles.listbox2, 'String', [str2 ; str1(val1,:)]);
if size(val1,2) ~= size(str1,1)
    set(handles.listbox1, 'String', str1(setdiff(1:size(str1,1), val1),:));
else
    set(handles.listbox1, 'String', []);
end



% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val2 = get(handles.listbox2, 'Value');
str1 = get(handles.listbox1, 'String');
str2 = get(handles.listbox2, 'String');
if val2(end) == size(str2,1)
    set(handles.listbox2, 'Value',1);
end
set(handles.listbox1, 'String', [str1 ; str2(val2,:)]);
if size(val2,2) ~= size(str2,1)
    set(handles.listbox2, 'String', str2(setdiff(1:size(str2,1), val2),:));
else
    set(handles.listbox2, 'String', []);
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
