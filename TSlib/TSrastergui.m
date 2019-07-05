function varargout = TSrastergui(varargin)
% TSrastergui(trial, tsdata)
%   This function generates raster plots based on user input collected from
%   a gui window. Supports tabbed browsing of raster plots.
%
%   Mandatory Argument
%       tsdata  - session tsdata

%
% TSRASTERGUI M-file for TSrastergui.fig
%      TSRASTERGUI, by itself, creates a new TSRASTERGUI or raises the existing
%      singleton*.
%
%      H = TSRASTERGUI returns the handle to a new TSRASTERGUI or the handle to
%      the existing singleton*.
%
%      TSRASTERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TSRASTERGUI.M with the given input arguments.
%
%      TSRASTERGUI('Property','Value',...) creates a new TSRASTERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TSrastergui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TSrastergui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help TSrastergui

% Last Modified by GUIDE v2.5 22-Aug-2005 19:39:56

% TODO: Make this not suck anymore.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TSrastergui_OpeningFcn, ...
                   'gui_OutputFcn',  @TSrastergui_OutputFcn, ...
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


% --- Executes just before TSrastergui is made visible.
function TSrastergui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TSrastergui (see VARARGIN)

set(hObject, 'Name', 'TSrastergui');
set(hObject, 'DockControls', 'off');
set(hObject, 'CloseRequestFcn', 'TSrastergui(''CloseRasterGui'', gcbo, [], guidata(gcbo)); closereq');

if (length(varargin) == 1)
    handles.tsdata = varargin{1};
else
    disp('Incorrect number of arguments. Type ''help TSrastergui'' for more info.');
    close(hObject);
    return;
end

% Extrapolate trial definitions from the root level of the Experiment
% structure. Trials are designated as cell arrays with names beginning with
% the word 'Trial'.

% Populates trial dropdown with trial definitions designated by the prefix
% 'Trial' in the root level of the Experiment structure.

handles.trialdefs = {};
names = evalin('base', 'fieldnames(Experiment)');
set(handles.popupmenu6, 'String', {});
for i=1:length(names)
    if (strncmpi('Trial', names(i), 5))
        handles.trialdefs{end+1} = evalin('base', ['Experiment.' char(names(i)) ';']);
        set(handles.popupmenu6, 'String', [get(handles.popupmenu6, 'String'); names(i)]);
    end
end
set(handles.popupmenu6, 'String', [get(handles.popupmenu6,'String'); {'Other'}]);

%Current setting should always default to 1.
handles.currentsetting = 1; 
if ~ispref('TSLib', 'TSrastergui_settings')
    %The settings object needs to be loaded in each time rastergui starts up.
    handles.settings.eventcodes = {};
    handles.settings.eventcodenames = {};
    handles.settings.trialdef = {[]}; %must be codes
    handles.settings.markers = {};
    handles.settings.offsets = {};
    handles.settings.labels = {};
    handles.settings.name = 'Raster 1';

    if numel(handles.trialdefs) >= 1
        handles.settings.trialdef = handles.trialdefs{1};
    end
    setpref('TSLib', 'TSrastergui_settings', handles.settings);
else
    %Load in settings from preference
    handles.settings = getpref('TSLib', 'TSrastergui_settings');
end
ApplySettingsChange(handles);

handles.rasterhandle = {};
handles.rastertypename = {};
handles.rasteraxeshandle = {};

handles.lastlistboxclick = [];

% Populate the event dropdowns with only those events that occur in the
% given tsdata from the greater set of all matlab event codes.
handles.eventcodestruct = TSdeclareeventcodes;

acceptedfields = {};
fn = fieldnames(handles.eventcodestruct);
for (x = 1:length(fn))
    %if ismember(getfield(handles.eventcodestruct, fn{x}), handles.tsdata(:,2))
        acceptedfields = [acceptedfields; {fn{x}}];
    %end
end

set(handles.popupmenu1, 'String', [acceptedfields; {'Other'}]);
set(handles.popupmenu2, 'String', [{'None'}; acceptedfields; {'Other'}]);

popupmenu1_Callback(handles.popupmenu1, eventdata, handles);
popupmenu2_Callback(handles.popupmenu2, eventdata, handles);
checkbox2_Callback(handles.checkbox2, eventdata, handles);

% Choose default command line output for TSrastergui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TSrastergui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TSrastergui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
checkvisibillity(handles, eventdata);
contents = get(hObject,'String');
set(handles.edit1, 'String', contents{get(hObject,'Value')});


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
checkvisibillity(handles, eventdata);

% If the second event dropdown is set to 'None' then we are dealing with a
% point event. Thus the representation changes from a color to a marker.
contents = get(hObject,'String');
if(strcmp(contents{get(hObject,'Value')}, 'None'))
    set(handles.popupmenu3, 'Visible', 'on');   % make marker dropdown visible
    set(handles.popupmenu5, 'Visible', 'off');  % hide color dropdown
else
    set(handles.popupmenu5, 'Visible', 'on');   % make color dropdown visible
    set(handles.popupmenu3, 'Visible', 'off');  % hide marker dropdown
end


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3



% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
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

s = handles.currentsetting;

%try
    % Pull event codes from the two event popup menus and populate the
    % currenteventcode array.
    currenteventcode = zeros(2,1);
    eventcodename = {'', ''};
    contents = get(handles.popupmenu1, 'String');
    if (strcmp(contents{get(handles.popupmenu1, 'Value')}, 'Other'))
        eventstr = get(handles.edit2, 'String');
        if (iscell(eventstr))
            currenteventcode(1) = str2num(eventstr{1});
            eventcodename{1} = eventstr{1};
        else
            currenteventcode(1) = str2num(eventstr);
            eventcodename{1} = eventstr;
        end
    else
        currenteventcode(1) = handles.eventcodestruct.(contents{get(handles.popupmenu1, 'Value')});
        eventcodename{1} = contents{get(handles.popupmenu1, 'Value')};
    end
       
    % Pulling event from the second event popup menu.
    contents = get(handles.popupmenu2, 'String');
    if (strcmp(contents{get(handles.popupmenu2, 'Value')}, 'None'))
        currenteventcode(2) = 0;
        eventcodename{2} = 'None';
    elseif (strcmp(contents{get(handles.popupmenu2, 'Value')}, 'Other'))
        eventstr = get(handles.edit2, 'String');
        if (iscell(eventstr))
            currenteventcode(2) = str2num(eventstr{1});
            eventcodename{2} = eventstr{1};
        else
            currenteventcode(2) = str2num(eventstr);
            eventcodename{2} = eventstr;
        end
    else
        currenteventcode(2) = handles.eventcodestruct.(contents{get(handles.popupmenu2, 'Value')});
        eventcodename{2} = contents{get(handles.popupmenu2, 'Value')};
    end
   
    % Get the value from the marker popup menus.
    if(strcmp(contents{get(handles.popupmenu2,'Value')}, 'None'))
        c = popupstr(handles.popupmenu3);
    else
        c = popupstr(handles.popupmenu5);
    end
    c2 = popupstr(handles.popupmenu7);
    
    c = c(1:min(find(c == ' '))-1); %Truncate everything after the first space
    c2 = c2(1:min(find(c2 == ' '))-1);
   
    % Use the trial definition selected or populate from the edit box if
    % 'Other' is selected.
    if (strcmp(popupstr(handles.popupmenu6), 'Other'))
        trial = eval(get(handles.edit6, 'String'));
    else
        trial = handles.trialdefs{get(handles.popupmenu6, 'Value')};
    end
    
    handles.settings(s).eventcodes{end+1} = currenteventcode;
    handles.settings(s).eventcodenames{end+1} = eventcodename;
    handles.settings(s).markers{end+1} = [c2 c];   % Take the first character of the marker menu
    handles.settings(s).offsets{end+1} = get(handles.popupmenu4, 'Value'); % The offset from the popup menu
    handles.settings(s).labels{end+1} = get(handles.edit1, 'String'); % The label from the edit box
    handles.settings(s).trialdef = trial;

    ApplySettingsChange (handles);
    handles.lastlistboxclick = [];
    
    guidata(hObject, handles);
    
%catch
%end

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

%disp('listbox1_Callback');

contents = get(hObject,'String');
value = get(hObject,'Value');

if numel(value) ~= 1
    set(handles.edit7,'String','');
    set(handles.edit8,'String','');
    set(handles.edit9,'String','');
    set(handles.edit10,'String','');
    set(handles.edit7,'Enable','off');
    set(handles.edit8,'Enable','off');
    set(handles.edit9,'Enable','off');
    set(handles.edit10,'Enable','off');
else
    s = handles.currentsetting;
    set(handles.edit7,'String',handles.settings(s).eventcodenames{value}{1});
    set(handles.edit8,'String',handles.settings(s).eventcodenames{value}{2});
    set(handles.edit9,'String',handles.settings(s).markers{value});
    set(handles.edit10,'String',int2str(handles.settings(s).offsets{value}));
    set(handles.edit7,'Enable','inactive');
    set(handles.edit8,'Enable','inactive');
    set(handles.edit9,'Enable','inactive');
    set(handles.edit10,'Enable','inactive');
    
    if isequal(handles.lastlistboxclick, value)
        i = value;
        eventcodes = handles.settings(s).eventcodes{i};
        eventcodenames = handles.settings(s).eventcodenames{i};
        markers = handles.settings(s).markers{i};
        label = handles.settings(s).labels{i};
        offset = handles.settings(s).offsets{i};
        
        if isempty(str2num(eventcodenames{1})) && ismember(eventcodenames{1}, get(handles.popupmenu1, 'String'))
            [tf, loc] = ismember(eventcodenames{1}, get(handles.popupmenu1, 'String'));
            set(handles.popupmenu1, 'Value', loc);
        else
            set(handles.popupmenu1, 'Value', numel(get(handles.popupmenu1, 'String')));
            set(handles.edit2, 'String', eventcodenames{1});
        end
    
        if isempty(str2num(eventcodenames{2})) && ismember(eventcodenames{2}, get(handles.popupmenu2, 'String'))
            [tf, loc] = ismember(eventcodenames{2}, get(handles.popupmenu2, 'String'));
            set(handles.popupmenu2, 'Value', loc);
        else
            set(handles.popupmenu2, 'Value', numel(get(handles.popupmenu2, 'String')));
            set(handles.edit3, 'String', eventcodenames{2});
        end
        checkvisibillity(handles, eventdata);
    
        loc = strmatch(markers(1), get(handles.popupmenu7,'String'));
        if numel(loc) == 1
            set(handles.popupmenu7,'Value', loc);
        end
        loc = strmatch(markers(2:end), get(handles.popupmenu5,'String'));
        if numel(loc) == 1
            set(handles.popupmenu5,'Value', loc);
        end
        loc = strmatch(markers(2:end), get(handles.popupmenu3,'String'));
        if numel(loc) == 1
            set(handles.popupmenu3,'Value', loc);
        end
        set(handles.popupmenu4,'Value', offset);
        set(handles.edit1,'String',label);
    end
end

handles.lastlistboxclick = value;

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

i = get(handles.listbox1, 'Value');
s = handles.currentsetting;

if(length(handles.settings(s).eventcodes) < 1)
    disp('There is nothing to delete.');
    return;
end

% Delete the event selected in the Events listbox.
handles.settings(s).eventcodes(i) = [];
handles.settings(s).eventcodenames(i) = [];
handles.settings(s).markers(i) = [];
handles.settings(s).labels(i) = [];
handles.settings(s).offsets(i) = [];

set(handles.listbox1, 'String', handles.settings(s).labels);
set(handles.listbox1, 'Value', []);

listbox1_Callback(handles.listbox1, eventdata, handles);

ApplySettingsChange (handles);

handles.lastlistboxclick = [];

guidata(hObject, handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

s = handles.currentsetting;

if(length(handles.settings(s).eventcodes) < 1)
    disp('There are no events to plot.');
    return;
end

% Use the trial definition selected or populate from the edit box if
% 'Other' is selected.
if (strcmp(popupstr(handles.popupmenu6), 'Other'))
    trial = eval(get(handles.edit6, 'String'));
else
    trial = handles.trialdefs{get(handles.popupmenu6, 'Value')};
end
    
handles.settings(s).trialdef = trial;
    
% Call TSraster with appropriate parameters and place the returned handle
% in the rasterhandle array.
CurrentType = handles.settings(s).name;
[tf,loc] = ismember(CurrentType,handles.rastertypename);

if tf && ~isempty(handles.rasteraxeshandle{loc}) && ishandle(handles.rasteraxeshandle{loc}) && ~get(handles.checkbox2,'Value') %If a valid axes handle exists already for this raster type, and reuse figures is checked, pass the axes handle as an argument. Otherwise dont.
[fighandle axeshandle] = TSraster(handles.tsdata, trial, cell2mat(handles.settings(s).eventcodes)', strvcat(handles.settings(s).markers{:}), [handles.settings(s).offsets{:}], handles.settings(s).labels, handles.rasteraxeshandle{loc});
else
[fighandle axeshandle] = TSraster(handles.tsdata, trial, cell2mat(handles.settings(s).eventcodes)', strvcat(handles.settings(s).markers{:}), [handles.settings(s).offsets{:}], handles.settings(s).labels);
end

set(fighandle, 'Name', CurrentType, 'NumberTitle', 'off');

handles.rasterhandle{end+1} = fighandle;
% Figure handles are kept for all figures ever made by rastergui. This is
% so that when you check tabbed or untabbed they can all be tabbed or
% untabbed.
% Axes handles are kept to maintain the reuse figure feature. More than one
% axes handle of each raster type is not kept.

if tf %If it was found, overwrite axes handle at loc
    handles.rasteraxeshandle{loc} = axeshandle;
else %Otherwise we have a new type, so add it to the list of types and add our axes handle at the end.
    handles.rastertypename{end+1} = CurrentType;
    handles.rasteraxeshandle{end+1} = axeshandle;
end

% If tabbed browsing is checked, dock the raster plot.
if (get(handles.checkbox1, 'Value'))
    set(handles.rasterhandle{end},'WindowStyle','docked');
end

handles.lastlistboxclick = [];

guidata(hObject, handles);


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


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

% Docks or undocks raster plots based on tabbed browsing checkbox.
if(get(hObject, 'Value'))
    for i = 1:length(handles.rasterhandle)
        set(handles.rasterhandle{i},'WindowStyle','docked');
    end
else
    for i = 1:length(handles.rasterhandle)
        set(handles.rasterhandle{i},'WindowStyle','normal');
    end
end


% Makes edit boxes visible if 'Other' is selected in either dropdown.
function checkvisibillity(handles, eventdata)
if (strcmp(popupstr(handles.popupmenu1), 'Other'))
    set(handles.edit2,'Visible', 'on');
else
    set(handles.edit2,'Visible', 'off');
end

if (strcmp(popupstr(handles.popupmenu2), 'Other'))
    set(handles.edit3,'Visible', 'on');
else
    set(handles.edit3,'Visible', 'off');
end
handles.lastlistboxclick = [];

% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6

% If 'Other' is selected as a trial, the edit box is made visible so the
% user can define their own custom trial.
if (strcmp(popupstr(handles.popupmenu6), 'Other'))
    set(handles.edit6,'Visible', 'on');
else
    set(handles.edit6,'Visible', 'off');
end


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

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




% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7


% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2

if get(hObject,'Value')
    set(handles.pushbutton3, 'String', 'Show Raster Plot');
else
    set(handles.pushbutton3, 'String', 'Update Raster Plot');
end
    
guidata(hObject, handles);

% --- Executes on selection change in popupmenu9.
function popupmenu9_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu9 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu9
if handles.currentsetting ~= get(hObject,'Value')
    handles.currentsetting = get(hObject,'Value');
    ApplySettingsChange(handles);
end

% --- Executes during object creation, after setting all properties.
function popupmenu9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --------------------------------------------------------------------
function New_Callback(hObject, eventdata, handles)
% hObject    handle to New (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

response = questdlg('This operation will clear existing raster settings from memory!','TSrastergui','Continue','Abort','Abort');

if isempty(response) || response(1) ~= 'C'
    return;
end

handles = rmfield(handles, 'settings');

%Current setting should always default to 1.
handles.currentsetting = 1; 
%The settings object needs to be loaded in each time rastergui starts up.
handles.settings.eventcodes = {};
handles.settings.eventcodenames = {};
handles.settings.trialdef = {[]}; %must be codes
handles.settings.markers = {};
handles.settings.offsets = {};
handles.settings.labels = {};
handles.settings.name = 'Raster 1';

if numel(handles.trialdefs) >= 1
    handles.settings.trialdef = handles.trialdefs{1};
end

ApplySettingsChange(handles);

guidata(hObject, handles);

% --------------------------------------------------------------------
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, path] = uigetfile('*.mat', 'Load Raster Settings');
response = questdlg('Would you like to:','Loading','Append the file contents to current settings', 'Clear the current settings and just use loaded ones','Clear the current settings and just use loaded ones');
if isempty(response) 
    return;
end
if ischar(filename) && response(1) == 'C'
    oldpath = cd;
    cd(path);
    
    handles = rmfield(handles, 'settings');

    %Current setting should always default to 1.
    handles.currentsetting = 1; 
    
    temp = load(filename);
    handles.settings = temp.settings;
    
    disp(['Loaded settings from ' filename '.']);
    
    ApplySettingsChange(handles);

    guidata(hObject, handles);
    
    cd(oldpath);
elseif ischar(filename) && response(1) == 'A'
    oldpath = cd;
    cd(path);

    loadsettings = load(filename);
    handles.settings(end+1:end+numel(loadsettings.settings)) = loadsettings.settings;
    
    disp(['Loaded settings from ' filename '.']);
    
    ApplySettingsChange(handles);

    guidata(hObject, handles);
    
    cd(oldpath);  
end

% --------------------------------------------------------------------
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, path] = uiputfile('*.mat', 'Save Raster Settings');
if ischar(filename)
    oldpath = cd;
    cd(path);
    temp.settings = handles.settings;
    save(filename, '-struct', 'temp');
    disp(['Saved settings to ' filename '.']);
    cd(oldpath);
end

% --------------------------------------------------------------------
function NewType_Callback(hObject, eventdata, handles)
% hObject    handle to NewType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

newname = inputdlg('What is the name of this raster setting?','New Raster Setting', 1, {['Raster ' num2str(numel(handles.settings)+1)]});

if iscellstr(newname)
    newname= newname{1};
end

if isempty(newname) || ~ischar(newname)
    return;
end

handles.settings(end+1).eventcodes = {};
handles.settings(end).eventcodenames = {};
handles.settings(end).trialdef = {[]}; %must be codes
handles.settings(end).markers = {};
handles.settings(end).offsets = {};
handles.settings(end).labels = {};
handles.settings(end).name = newname;

handles.currentsetting = numel(handles.settings);

if numel(handles.trialdefs) >= 1
    handles.settings(end).trialdef = handles.trialdefs{1};
end


ApplySettingsChange(handles);

guidata(hObject, handles);

% --------------------------------------------------------------------
function RenameType_Callback(hObject, eventdata, handles)
% hObject    handle to RenameType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

s = handles.currentsetting;
oldname = handles.settings(s).name;
newname = inputdlg('What to rename this raster setting?','Rename Raster Setting', 1, {oldname});

handles.settings(s).name = newname{1};

[tf,loc] = ismember(oldname, handles.rastertypename);
if tf
    handles.rastertypename{loc} = handles.settings(s).name;
end

ApplySettingsChange(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function DeleteType_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if numel(handles.settings) <= 1
    disp('You cannot delete the last raster setting.');
    return;
end

response = questdlg('This operation will delete a raster setting!','TSrastergui','Continue','Abort','Abort');

if isempty(response) || response(1) ~= 'C'
    return;
end

s = handles.currentsetting;

name = handles.settings(s).name;

[tf,loc] = ismember(name, handles.rastertypename);
if tf
    handles.rastertypename(loc) = [];
    handles.rasteraxeshandle(loc) = [];
end

handles.settings(s) = [];

handles.currentsetting = 1;

ApplySettingsChange(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Actions_Callback(hObject, eventdata, handles)
% hObject    handle to Actions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function CloseRasters_Callback(hObject, eventdata, handles)
% hObject    handle to CloseRasters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for x = 1:numel(handles.rasterhandle)
    if ishandle(handles.rasterhandle{x})
        close(handles.rasterhandle{x});
    end
end

handles.rasterhandle = {};
handles.rasteraxeshandle = {};
handles.rastertypename = {};

guidata(hObject, handles);

% --- Executes close on X button press.
function CloseRasterGui(hObject, eventdata, handles)
setpref('TSLib', 'TSrastergui_settings', handles.settings);
disp('Saved.');

% --- Executes on button press in uparrow.
function uparrow_Callback(hObject, eventdata, handles)
% hObject    handle to uparrow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

v = get(handles.listbox1, 'Value');
s = handles.currentsetting;

if any(v == 1) 
    return;
end

idx = [1 1+find(diff(v) ~= 1)]; %Finds indices which are the starts of continuous ranges of values
len = diff([idx numel(v)+1]);   %Finds the lengths of these starts, inclusive of the start and end

starts = v(idx);
ends = starts + len - 1;        %We consider ends to be the last element in the range, so that means
                                %that we have to subtract 1.
for x = 1:numel(idx)
    range = starts(x)-1:ends(x);
    mapping = [starts(x):ends(x) starts(x)-1];
    handles.settings(s).eventcodes(range) = handles.settings(s).eventcodes(mapping);
    handles.settings(s).eventcodenames(range) = handles.settings(s).eventcodenames(mapping);
    handles.settings(s).markers(range) = handles.settings(s).markers(mapping);
    handles.settings(s).offsets(range) = handles.settings(s).offsets(mapping);
    handles.settings(s).labels(range) = handles.settings(s).labels(mapping);
end

set(handles.listbox1, 'String', handles.settings(s).labels); % Populate the Events listbox with this setting's label
set(handles.listbox1, 'Value', v-1);
listbox1_Callback(handles.listbox1, [], handles);

handles.lastlistboxclick = [];
guidata(hObject, handles);

% --- Executes on button press in downarrow.
function downarrow_Callback(hObject, eventdata, handles)
% hObject    handle to downarrow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

v = get(handles.listbox1, 'Value');
s = handles.currentsetting;

if any(v == numel(handles.settings(s).eventcodes)) 
    return;
end

idx = [1 1+find(diff(v) ~= 1)]; %Finds indices which are the starts of continuous ranges of values
len = diff([idx numel(v)+1]);   %Finds the lengths of these starts, inclusive of the start and end

starts = v(idx);
ends = starts + len - 1;        %We consider ends to be the last element in the range, so that means
                                %that we have to subtract 1.
for x = 1:numel(idx)
    range = starts(x):ends(x)+1;
    mapping = [ends(x)+1 starts(x):ends(x)];
    handles.settings(s).eventcodes(range) = handles.settings(s).eventcodes(mapping);
    handles.settings(s).eventcodenames(range) = handles.settings(s).eventcodenames(mapping);
    handles.settings(s).markers(range) = handles.settings(s).markers(mapping);
    handles.settings(s).offsets(range) = handles.settings(s).offsets(mapping);
    handles.settings(s).labels(range) = handles.settings(s).labels(mapping);
end

set(handles.listbox1, 'String', handles.settings(s).labels); % Populate the Events listbox with this setting's label
set(handles.listbox1, 'Value', v+1);
listbox1_Callback(handles.listbox1, [], handles);

handles.lastlistboxclick = [];
guidata(hObject, handles);

function ApplySettingsChange (handles)
set(handles.popupmenu9, 'String', {handles.settings.name}');
set(handles.popupmenu9, 'Value', handles.currentsetting);

s = handles.currentsetting;

flag = true;
for i = 1:numel(handles.trialdefs)
    if isequal(handles.trialdefs{i}, handles.settings(s).trialdef)
        set(handles.popupmenu6, 'Value', i);
        flag = false;
    end
end
if flag
    set(handles.popupmenu6, 'Value', numel(handles.trialdefs)+1);
    str = '';
    if iscell(handles.settings(s).trialdef)
        str = '{ ';
        for i = 1:numel(handles.settings(s).trialdef)
            str = [str mat2str(handles.settings(s).trialdef{i}) ' '];
        end
        str(end+1) = '}';
    else
        str = mat2str(handles.settings(s).trialdef);
    end
    set(handles.edit6, 'String', str);
end
popupmenu6_Callback(handles.popupmenu6, [], handles);

set(handles.listbox1, 'String', handles.settings(s).labels); % Populate the Events listbox with this setting's label
set(handles.listbox1, 'Value', []);
listbox1_Callback(handles.listbox1, [], handles);

setpref('TSLib', 'TSrastergui_settings', handles.settings);



