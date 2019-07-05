function varargout = TSfielddetails(varargin)
% TSFIELDDETAILS M-file for TSfielddetails.fig
%      TSFIELDDETAILS, by itself, creates a new TSFIELDDETAILS or raises the existing
%      singleton*.
%
%      H = TSFIELDDETAILS returns the handle to a new TSFIELDDETAILS or the handle to
%      the existing singleton*.
%
%      TSFIELDDETAILS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TSFIELDDETAILS.M with the given input arguments.
%
%      TSFIELDDETAILS('Property','Value',...) creates a new TSFIELDDETAILS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TSfielddetails_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TSfielddetails_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help TSfielddetails

% Last Modified by GUIDE v2.5 07-Aug-2004 12:44:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TSfielddetails_OpeningFcn, ...
                   'gui_OutputFcn',  @TSfielddetails_OutputFcn, ...
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


% --- Executes just before TSfielddetails is made visible.
function TSfielddetails_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TSfielddetails (see VARARGIN)

% Choose default command line output for TSfielddetails
%varargin
%varargin{:}

handles.output = hObject;

guidata(hObject, handles);
% Update handles structure

if (length(varargin) ~= 2)
    closereq;
    return;
end

if evalin('base','~ismember(''Experiment'',who)')
    disp('There is no experiment structure defined');
    closereq;
    return;
end;

global Experiment

try
    handles.path = varargin{2};
    dots = strfind(handles.path, '.');
    handles.field = handles.path(dots(end)+1:end);
    handles.val = evalin('base',handles.path);
    temp = {'str'};
    if (1==numel(handles.val))
        handles.class = [class(handles.val) temp{iscellstr(handles.val)}];
    else
        handles.class = [regexprep(num2str(size(handles.val)), '\s*', ' x ') ' ' class(handles.val) temp{iscellstr(handles.val)}];
    end

    set(handles.edit2, 'String', handles.field);
    set(handles.edit3, 'String', GetString(handles.val));
    set(handles.edit4, 'String', handles.path);
    set(handles.edit5, 'String', handles.class);
    set(handles.edit6, 'String', handles.field);
    
    
catch
    disp(lasterr);
    guidata(hObject, handles);
    closereq;
    return;
end
guidata(hObject, handles);

% UIWAIT makes TSfielddetails wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TSfielddetails_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;



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
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
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
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
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
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if evalin('base','~ismember(''Experiment'',who)')
    disp('There is no experiment structure defined');
    closereq;
    return;
end;

global Experiment

disp(' ');
disp([handles.field ' =']);
disp(handles.val);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if evalin('base','~ismember(''Experiment'',who)')
    disp('There is no experiment structure defined');
    closereq;
    return;
end;

global Experiment

disp([char(get(handles.edit6,'String')) ' = ' handles.path ';']);
evalin('base', [char(get(handles.edit6,'String')) ' = ' handles.path ';']);

function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function [result] = GetString(data)
if (isnumeric(data) || islogical(data))
    [rows, cols] = size(data);
    if(rows > 1)
        result = '<large matrix>';
    else
        result = num2str(data);
        if (cols ~= 1)
            result = ['[' result ']'];
        end
    end
elseif (iscell(data))
    [rows, cols] = size(data);
    if (rows > 1)
        result = '<large cell array>';
    else
        if (cols == 1)
            result = ['{ ' GetString(data{1}) ' }'];
        elseif (cols == 0)
            result = '{  }';
        else
            result = '{ ';
            for (x = 1:length(data)-1)
                result = [result GetString(data{x}) ' , '];
            end
            result = [result GetString(data{end}) ' }'];
        end
    end
else
    result = char(data);
    if (ischar(data))
        [rows,cols] = size(data);
        if (rows == 1)
            result = ['''' result ''''];
        else
            result = result';
            result = [result(:)'];
        end
    end
end
