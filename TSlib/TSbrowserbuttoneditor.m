function varargout = TSbrowserbuttoneditor(varargin)
% TSBROWSERBUTTONEDITOR M-file for TSbrowserbuttoneditor.fig
%      TSBROWSERBUTTONEDITOR, by itself, creates a new TSBROWSERBUTTONEDITOR or raises the existing
%      singleton*.
%
%      H = TSBROWSERBUTTONEDITOR returns the handle to a new TSBROWSERBUTTONEDITOR or the handle to
%      the existing singleton*.
%
%      TSBROWSERBUTTONEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TSBROWSERBUTTONEDITOR.M with the given input arguments.
%
%      TSBROWSERBUTTONEDITOR('Property','Value',...) creates a new TSBROWSERBUTTONEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TSbrowserbuttoneditor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TSbrowserbuttoneditor_OpeningFcn via
%      varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help TSbrowserbuttoneditor

% Last Modified by GUIDE v2.5 09-Jul-2005 13:02:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TSbrowserbuttoneditor_OpeningFcn, ...
                   'gui_OutputFcn',  @TSbrowserbuttoneditor_OutputFcn, ...
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


% --- Executes just before TSbrowserbuttoneditor is made visible.
function TSbrowserbuttoneditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TSbrowserbuttoneditor (see VARARGIN)

% Choose default command line output for TSbrowserbuttoneditor
handles.isactive = varargin{1};
handles.name = varargin{2};
handles.script = varargin{3};
handles.selected = 1;
handles.output = hObject;

setbuttons(handles);
setfields(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TSbrowserbuttoneditor wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TSbrowserbuttoneditor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if (nargout == 1)
varargout{1} = {};
varargout{1}{1} = handles.isactive;
varargout{1}{2} = handles.name;
varargout{1}{3} = handles.script;
elseif (nargout == 3)
varargout{1} = handles.isactive;
varargout{2} = handles.name;
varargout{3} = handles.script;
end
closereq;   %the handle gets deleted her once it jumps back to gui_mainfcn

% --- Executes on button press in fbutton1.
function fbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to fbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (1 ~= handles.selected)
handles = check_before_changing(hObject, eventdata, handles);
end
handles.selected = 1;
setfields(handles);
setbuttons(handles);
guidata(hObject,handles);

% --- Executes on button press in fbutton2.
function fbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to fbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (2 ~= handles.selected)
handles = check_before_changing(hObject, eventdata, handles);
end
handles.selected = 2;
setfields(handles);
setbuttons(handles);
guidata(hObject,handles);

% --- Executes on button press in fbutton3.
function fbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to fbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (3 ~= handles.selected)
handles = check_before_changing(hObject, eventdata, handles);
end
handles.selected = 3;
setfields(handles);
setbuttons(handles);
guidata(hObject,handles);

% --- Executes on button press in fbutton4.
function fbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to fbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (4 ~= handles.selected)
handles = check_before_changing(hObject, eventdata, handles);
end
handles.selected = 4;
setfields(handles);
setbuttons(handles);
guidata(hObject,handles);

% --- Executes on button press in fbutton5.
function fbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to fbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (5 ~= handles.selected)
handles = check_before_changing(hObject, eventdata, handles);
end
handles.selected = 5;
setfields(handles);
setbuttons(handles);
guidata(hObject,handles);

% --- Executes on button press in fbutton6.
function fbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to fbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (6 ~= handles.selected)
handles = check_before_changing(hObject, eventdata, handles);
end
handles.selected = 6;
setfields(handles);
setbuttons(handles);
guidata(hObject,handles);

% --- Executes on button press in fbutton7.
function fbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to fbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (7 ~= handles.selected)
handles = check_before_changing(hObject, eventdata, handles);
end
handles.selected = 7;
setfields(handles);
setbuttons(handles);
guidata(hObject,handles);

% --- Executes on button press in fbutton8.
function fbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to fbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (8 ~= handles.selected)
handles = check_before_changing(hObject, eventdata, handles);
end
handles.selected = 8;
setfields(handles);
setbuttons(handles);
guidata(hObject,handles);


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


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
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
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
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Apply_Button.
function Apply_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Apply_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Applying...');
handles.isactive(handles.selected) = logical(get(handles.checkbox1,'Value'));
handles.name{handles.selected} = get(handles.edit1,'String');
handles.script{handles.selected} = get(handles.edit2,'String');
if (ischar(handles.script{handles.selected}))
    handles.script{handles.selected} = {handles.script{handles.selected}};
end

setbuttons(handles);
setfields(handles);
guidata(hObject,handles);

function setbuttons(handles)
set(handles.fbutton1,'String',handles.name{1});
set(handles.fbutton2,'String',handles.name{2});
set(handles.fbutton3,'String',handles.name{3});
set(handles.fbutton4,'String',handles.name{4});
set(handles.fbutton5,'String',handles.name{5});
set(handles.fbutton6,'String',handles.name{6});
set(handles.fbutton7,'String',handles.name{7});
set(handles.fbutton8,'String',handles.name{8});

function setfields(handles)
set(handles.text1,'String', ['Button ' num2str(handles.selected) ' -- ' handles.name{handles.selected} ':']);
set(handles.checkbox1,'Enable', 'on');
set(handles.edit1,'Enable', 'on');
set(handles.edit2,'Enable', 'on');
set(handles.checkbox1,'Value', handles.isactive(handles.selected));
set(handles.edit1,'String', handles.name{handles.selected});
set(handles.edit2,'String', handles.script{handles.selected});

function close_it(hObject,eventdata,handles)
try
    guidata(hObject, handles);
    uiresume(handles.figure1);
catch
    disp(lasterr);
    delete(hObject);
end % handle not yet deleted

function [handles] = check_before_changing(hObject, eventdata, handles)
script = char(get(handles.edit2,'String'));
if (handles.isactive(handles.selected) == logical(get(handles.checkbox1,'Value')) && ...
    strcmp(handles.name{handles.selected},get(handles.edit1,'String')) && ...
    strcmp(char(handles.script{handles.selected}),script))
    return;
end
answer = questdlg('Apply Changes?','Button Editor', 'Yes', 'No', 'No')
if (strcmp(answer,'Yes'))
    disp('Applying before changing...');
    handles.isactive(handles.selected) = logical(get(handles.checkbox1,'Value'));
    handles.name{handles.selected} = get(handles.edit1,'String');
    handles.script{handles.selected} = get(handles.edit2,'String');
    disp(handles.script{handles.selected});
    if (ischar(handles.script{handles.selected}))
        handles.script{handles.selected} = {handles.script{handles.selected}};
    end
    %guidata(hObject,handles);
end


% --------------------------------------------------------------------
function Load_Settings_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% [filename, path] = uigetfile('*.mat','Import Button Settings');
% if ischar(filename)
%     %try
%         cd(path);
%         s = load(filename)
% %, isactive, name, script);
%         handles.isactive = s.isactive;
%         handles.name = s.name;
%         handles.script = s.script;
% 
%         setfields(handles);
%         setbuttons(handles);
%         guidata(hObject,handles);
%     %catch
%     %    disp('Error: File is not valid.');
%     %end
% end

% --------------------------------------------------------------------
function Save_Settings_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% [filename, path] = uiputfile('*.mat', 'Export Button Settings');
% if ischar(filename)
% cd(path);
% isactive = handles.isactive;
% name = handles.name;
% script = handles.script;
% save(filename,'isactive', 'name', 'script');
% %save TSexperimentbrowser_settings.mat -struct handles isactive name script -V6
% end

% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


