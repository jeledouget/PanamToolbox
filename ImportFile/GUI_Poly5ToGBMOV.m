function varargout = GUI_Poly5ToGBMOV(varargin)
% GUI_POLY5TOGBMOV MATLAB code for GUI_Poly5ToGBMOV.fig
%      GUI_POLY5TOGBMOV, by itself, creates a new GUI_POLY5TOGBMOV or raises the existing
%      singleton*.
%
%      H = GUI_POLY5TOGBMOV returns the handle to a new GUI_POLY5TOGBMOV or the handle to
%      the existing singleton*.
%
%      GUI_POLY5TOGBMOV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_POLY5TOGBMOV.M with the given input arguments.
%
%      GUI_POLY5TOGBMOV('Property','Value',...) creates a new GUI_POLY5TOGBMOV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_Poly5ToGBMOV_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_Poly5ToGBMOV_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_Poly5ToGBMOV

% Last Modified by GUIDE v2.5 11-Sep-2014 16:40:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_Poly5ToGBMOV_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_Poly5ToGBMOV_OutputFcn, ...
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


% --- Executes just before GUI_Poly5ToGBMOV is made visible.
function GUI_Poly5ToGBMOV_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_Poly5ToGBMOV (see VARARGIN)

% Choose default command line output for GUI_Poly5ToGBMOV
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_Poly5ToGBMOV wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_Poly5ToGBMOV_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
close(handles.figure1);

% --- Executes on button press in realgait.
function realgait_Callback(hObject, eventdata, handles)
% hObject    handle to realgait (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of realgait


% --- Executes on button press in virtualgait.
function virtualgait_Callback(hObject, eventdata, handles)
% hObject    handle to virtualgait (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of virtualgait


% --- Executes on button press in restrecording.
function restrecording_Callback(hObject, eventdata, handles)
% hObject    handle to restrecording (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of restrecording


% --- Executes on button press in membresup.
function membresup_Callback(hObject, eventdata, handles)
% hObject    handle to membresup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of membresup


% --- Executes on button press in realgait_ai.
function realgait_ai_Callback(hObject, eventdata, handles)
% hObject    handle to realgait_ai (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of realgait_ai



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



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles, 'filename_new') && ~isempty(handles.filename_new)
    wsVars = evalin('base','who');
    switch get(get(handles.uipanel1,'SelectedObject'),'Tag')
        case 'realgait'
            temp = Poly5ToGBMOV_LFP_RealGait(handles.filename_new);
            varName = temp.Infos.FileName;
            if ~any(strcmpi(varName, wsVars))
                assignin('base',varName, temp);
            else
                answer = questdlg([varName ' already exists in workspace. Do you want to replace it ?'],'Variable name issue','Yes', 'No', 'No');
                switch answer
                    case 'Yes'
                        assignin('base',varName, temp);
                    case 'No'
                        return;
                end
            end
        case 'virtualgait'
            temp = Poly5ToGBMOV_LFP_VirtualGait(handles.filename_new);
            varName = temp.Infos.FileName;
            if ~any(strcmpi(varName, wsVars))
                assignin('base',varName, temp);
            else
                answer = questdlg([varName ' already exists in workspace. Do you want to replace it ?'],'Variable name issue','Yes', 'No', 'No');
                switch answer
                    case 'Yes'
                        assignin('base',varName, temp);
                    case 'No'
                        return;
                end
            end
        case 'restrecording'
            temp = Poly5ToGBMOV_LFP_Rest(handles.filename_new);
            varName = temp.Infos.FileName;
            if ~any(strcmpi(varName, wsVars))
                assignin('base',varName, temp);
            else
                answer = questdlg([varName ' already exists in workspace. Do you want to replace it ?'],'Variable name issue','Yes', 'No', 'No');
                switch answer
                    case 'Yes'
                        assignin('base',varName, temp);
                    case 'No'
                        return;
                end
            end
        case 'membresup'
            temp = Poly5ToGBMOV_LFP_MSup(handles.filename_new);
            varName = temp.Infos.FileName;
            if ~any(strcmpi(varName, wsVars))
                assignin('base',varName, temp);
            else
                answer = questdlg([varName ' already exists in workspace. Do you want to replace it ?'],'Variable name issue','Yes', 'No', 'No');
                switch answer
                    case 'Yes'
                        assignin('base',varName, temp);
                    case 'No'
                        return;
                end
            end
        case 'realgait_ai'
            temp = Poly5ToGBMOV_LFP_RealGaitAi(handles.filename_new);
            varName = temp.Infos.FileName;
            if ~any(strcmpi(varName, wsVars))
                assignin('base',varName, temp);
            else
                answer = questdlg([varName ' already exists in workspace. Do you want to replace it ?'],'Variable name issue','Yes', 'No', 'No');
                switch answer
                    case 'Yes'
                        assignin('base',varName, temp);
                    case 'No'
                        return;
                end
            end
    end
    handles.filename_new = '';
    set(handles.text13,'String','');
    guidata(hObject,handles);
else
    errordlg('No file selected. Please Select file.')
end



% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
structNum= get(handles.popupmenu2,'Value');
allStruct = get(handles.popupmenu2,'String');
structName = allStruct{structNum};
if isfield(handles, 'filename_add') && ~isempty(handles.filename_add)
    try
        switch get(get(handles.uipanel1,'SelectedObject'),'Tag')
            case 'realgait'
                struct = evalin('base',structName);
                temp = Poly5ToGBMOV_LFP_RealGait_Add(struct,handles.filename_add);
                assignin('base',structName, temp);
            case 'virtualgait'
                struct = evalin('base',structName);
                temp = Poly5ToGBMOV_LFP_VirtualGait_Add(struct,handles.filename_add);
                assignin('base',structName, temp);
            case 'restrecording'
                struct = evalin('base',structName);
                temp = Poly5ToGBMOV_LFP_Rest_Add(struct,handles.filename_add);
                assignin('base',structName, temp);
            case 'membresup'
                struct = evalin('base',structName);
                temp = Poly5ToGBMOV_LFP_MSup_Add(struct,handles.filename_add);
                assignin('base',structName, temp);
            case 'realgait_ai'
                struct = evalin('base',structName);
                temp = Poly5ToGBMOV_LFP_RealGaitAi_Add(struct,handles.filename_add);
                assignin('base',structName, temp);
        end
    catch err
        disp(err.message);
        errordlg('Impossible to add this file to the selected structure');
    end
    handles.filename_add = '';
    set(handles.text14,'String', '');
    guidata(hObject,handles);
else
    errordlg('No file selected. Please Select file.')
end


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
structNum= get(handles.popupmenu3,'Value');
allStruct = get(handles.popupmenu3,'String');
structName = allStruct{structNum};
if isfield(handles, 'filename_synchro') && ~isempty(handles.filename_synchro)
    try
        switch get(get(handles.uipanel1,'SelectedObject'),'Tag')
            case 'realgait'
                struct = evalin('base',structName);
                temp = Poly5ToGBMOV_LFP_RealGait_Synchronisation(struct,handles.filename_synchro);
                assignin('base',structName, temp);
            case 'realgait_ai'
                struct = evalin('base',structName);
                temp = Poly5ToGBMOV_LFP_RealGaitAi_Synchronisation(struct,handles.filename_synchro);
                assignin('base',structName, temp);
            otherwise
                errordlg('No possible synchronisation for this type of structure');
        end
    catch err
        disp(err.message);
        errordlg('Impossible to synchronize this file with the selected structure');
    end
    handles.filename_add = '';
    set(handles.text14,'String', '');
    guidata(hObject,handles);
else
    errordlg('No file selected. Please Select file.')
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.Poly5');
set(handles.text13, 'String',filename);
handles.filename_new = [pathname filename];
guidata(hObject, handles);

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.Poly5');
set(handles.text14, 'String',filename);
handles.filename_add = [pathname filename];
guidata(hObject, handles);

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.xls;*.csv;*.xlsx'});
set(handles.text15, 'String',filename);
handles.filename_synchro = [pathname filename];
guidata(hObject, handles);

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
temp = evalin('base','who');
set(hObject, 'String',temp);


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
temp = evalin('base','who');
set(hObject, 'String',temp);
