function varargout = TSexperimentbrowser(varargin)
% TSEXPERIMENTBROWSER
%   Loads the TSexperimentbrowser GUI interface. This allows you to browse the 
%   fields and substructures of the Experiment, view their details or modify them,
%   load, save, or start an experiment, and customize the custom buttons to run
%   userdefined code on fields of the structure when clicked. These can be custom
%   plotting functions specific to the type of data, calls to external guis, 
%   functions that make some quick computations and display to the command
%   window, or whatever else you may find useful. These settings can also
%   be exported and imported to and from .mat files.

% TSEXPERIMENTBROWSER M-file for TSexperimentbrowser.fig
%      TSEXPERIMENTBROWSER, by itself, creates a new TSEXPERIMENTBROWSER or raises the existing
%      singleton*.
%
%      H = TSEXPERIMENTBROWSER returns the handle to a new TSEXPERIMENTBROWSER or the handle to
%      the existing singleton*.
%
%      TSEXPERIMENTBROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TSEXPERIMENTBROWSER.M with the given input arguments.
%
%      TSEXPERIMENTBROWSER('Property','Value',...) creates a new TSEXPERIMENTBROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TSexperimentbrowser_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TSexperimentbrowser_OpeningFcn via
%      varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help TSexperimentbrowser

% TODO: PCode this file
% TODO: Ensure robustness
% TODO: Run M-lint on this and apply corrections

% Last Modified by GUIDE v2.5 02-Dec-2014 16:56:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TSexperimentbrowser_OpeningFcn, ...
                   'gui_OutputFcn',  @TSexperimentbrowser_OutputFcn, ...
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

%HOW THIS WORKS:
% If you have used the browser, you know that the browsing works by using
% list boxes. There are 5 structure browsing list boxes. The first is
% Experiment level, and it has one member, and it is very small. The second
% is Subject level, then Session, TrialType, and Trial. These are listboxes
% 1 - 5 in the code below, in that order. The listbox 6 is the variable
% browsing one.
%
% There are 3 important cell objects being built up every time you go up a
% step or down a step with the Experiment browser. These are: selected,
% path and to a lesser extent, vars. Selected and path are exactly the same
% size as the level of depth to which you have delved into the structure.
%
% Selected, at each index simply holds the value that the corresponding
% list box holds. In theory it could be converted to a scalar array. I have
% decided not to go back into this code and start changing it all around.
%
% Path is more complicated. Path basically holds all the different "paths"
% that you could take within the tree of nested structure arrays, and at
% each index, it holds that paths that could be taken from that point. In
% fact, since each element in one of the structure panes represents a
% substructure, there are exactly as many paths as there are options for
% each pane. 
%
% Here is an example of what I call a "path" in this structure tree:
% 
% Experiment.Subject(2).Session(4).TrialProbe.Trial(7).tsdata
%
% This is a full path, from the root Experiment to the data field at the
% end. Each node of this path is handled by the different listboxes. For
% example, 'Subject(2).' would be a partial path step. I decided to
% represent this node as a 2 part cell array, the first holding the
% substructure name, 'Subject', and the second holding the index, 2.
% Sometimes the index is unnecessary, if it is a plane old structure, not a
% structure array. So the full, selected path if you used the Experiment
% browser to browse to this point is: 
% { {'Subject' 2} {'Session' 4} {'TrialProbe'}{'Trial' 7} }
%
% This is what the function GetSelectedPath returns, and what StructInfo
% and related helper functions take as a path. GetSelectedPath is able to
% get this because every time a listbox figures out what to display as
% substructure options for the user to select, it also generates a cell
% array containing each of their path bits. These large cell arrays
% generated by the listboxes are in turn ordered by the listbox in the
% paths cell array. So, paths{2} might contain:
% {{'Subject' 1} {'Subject' 2}{'Subject' 3}{'Info'}{'EventCodes'}}
%
% These paths are in exactly the same order as the Strings displayed in the
% list box, so that the correspond exactly, and the index which you clicked
% on in the listbox, (which is stored for each listbox in the Selected cell
% array) is used to reference that cell array which you see above.
%
% You might find it odd that I did not include {'Experiment'} as the first
% node in the path above, and that I in GetSelectedPath start indexing at 2
% rather than 1. Why is this? The ultimate goal of the path concept is to
% make it quick to find any point in the structure, using recursive helper
% functions such as GetSubStruct, GetStructField, etc. These functions take
% a structure, a path to the point, and in the case of GetStructField, the
% variable name at the end. They do this by popping off nodes from the
% front of the path object and dereferencing the passed structure
% successively until they run out of nodes, then returning that
% (GetSubStruct) or returning a field of it (GetStructField). So,
% Experiment is not a node in this sense. Experiment is the structure that
% gets passed. We arent dereferencing the Experiment member of anything,
% we are using it as a starting point.
%
% So, heres the great thing about the Paths structure. It has all the
% information you could possibly need at each index. Anything you can click
% on, we have the path to already. You can click on a different one in the
% same structure, and that path is already there as well. We dont have to
% move any data structures or anything. Just change the index in selected
% and then GetSelectedPath points somewhere else.
%
% So, you click on a structure using the listbox. What happens? First
% selected is updated. Then GetSelectedPath is called to get the total path
% to where you just clicked, and very fast, since most information is
% already stored. Then GetSubStruct actually dereferences this path, to get
% the structure. This is passed to the StructInfo function.
%
% The StructInfo function is what returns most of the information that
% makes it to the screen. It returns the 'vars', 'vals', 'substructs', and
% 'paths', as you can see from its function header. These are all cell
% strings. Vars is a cell string containing the names of any field, aka in
% our lingo, a non structure field. This, in fact, brings us back to the
% vars member of the handles structure. It is simply this return, the list
% of non-structure fields of the most recently clicked on structure.
%
% Vals is a cell containing string representations of each of those fields,
% to be displayed in the fields listbox in the lower left, to the right of
% the field names. These string representations come from the GetString
% function.
%
% Substructs is a cell containing the sub structures, or, all the fields
% that were structures. This is passed to the next listbox inline, which
% will now be enabled to display the new substructure options.
%
% Lastly Paths is the cell array we described before which exists for each
% listbox. This cell array is appended directly onto the paths cell array,
% and corresponds with the order of Substructs.
%
% Thats pretty much how the browser works. For getting and setting
% individual fields, the value of the field listbox is used to reference
% the vars variable. This is passed to GetStructField or SetStructField or
% what have you. For the fbuttons, the special variables Var Val and Path
% are derived from these. Var is the variable name, Val is the result of
% GetStructFielding it, and Path is what results when you take a path and
% convert it to its string form, e.g.
% 'Experiment.Subject(2).Session(4).TrialProbe.Trial(7).tsdata'. Large
% amounts of generic, copied-6-times-with-tiny-changes code keep it all
% running, except when cell arrays will do.


% --- Executes just before TSexperimentbrowser is made visible.
function TSexperimentbrowser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TSexperimentbrowser (see VARARGIN)
set(hObject, 'name', 'TSexperimentbrowser');
set(hObject, 'DockControls','off');

% Makes figure a little shorter, there is noticable space otherwise on PC
% version.
if (ispc)
    set(hObject,'Position',get(hObject,'Position') + [0 0 0 -.5]);
end

%Expand the "Experiment" listbox for Macs otherwise text gets clipped off
defaultExperimentListBoxHieght = 1.2538461538461552; %number from GUIDE
ExperimentListBoxPos = get(handles.listbox1, 'Position');
if (ispc)
    ExperimentListBoxPos(4) = defaultExperimentListBoxHieght;
else
    ExperimentListBoxPos(4) = defaultExperimentListBoxHieght * 1.25; % 25 percent increase in heihgt on Macs.
end
set(handles.listbox1, 'Position', ExperimentListBoxPos);

% Choose default command line output for TSexperimentbrowser
handles.output = hObject;
handles.selected = {[]};
handles.paths = { {} };
handles.vars = {};
%handles.show_substructs = false; % Randy took out
handles.mostrecentexperimentname = '';

try
    %load TSexperimentbrowser_settings.mat fbutton_isactive fbutton_name fbutton_script
    
    handles.fbutton_isactive = getpref('TSLib','TSexperimentbrowser_fbutton_isactive');%fbutton_isactive;
    handles.fbutton_name = getpref('TSLib','TSexperimentbrowser_fbutton_name');%fbutton_name;
    handles.fbutton_script = getpref('TSLib','TSexperimentbrowser_fbutton_script');%fbutton_script;
catch
    %disp(lasterr);
    handles.fbutton_isactive = [1 0 0 1 1 0 0 1];
    handles.fbutton_name = {'Plot' '' '' 'TSbrowser' 'Bar' '' '' 'TSraster'};
    handles.fbutton_script = {{'figure;'; '[r,c] = size(val);'; 'if (c >= 2)'; 'plot(val(:,1),val(:,2));';'else';'plot(val);';'end'} {''} {''} {'TSdatabrowser(val)'} {'figure;'; '[r,c] = size(val);'; 'if (c >= 2)'; 'bar(val(:,1),val(:,2));';'else';'bar(val);';'end'} {''} {''} {'TSrastergui(val);'}};
end

% These values were obtained from GUIDE. They are hard coded. Do not screw
% with them lol. The default was set up for the expanded view. The reduced
% button values are computed, these are dimensions that result when you
% check the advanced buttons checkbox. Values used by
% Set_Button_Panel_Visibillity function.
handles.default_y_edit1 = [6.923076923076923, 10.692307692307693];
handles.default_y_basic_buttons = [4.923,1.7692307692307696];

handles.reduced_y_basic_buttons = [0.5384615384615385,1.7692307692307696];
handles.reduced_y_edit1 = [sum(handles.reduced_y_basic_buttons) + handles.default_y_edit1(1)-sum(handles.default_y_basic_buttons)];
handles.reduced_y_edit1 = [handles.reduced_y_edit1, handles.default_y_edit1(2) + abs(handles.default_y_edit1(1)-handles.reduced_y_edit1(1))];
 
Set_Button_Panel_Visibillity(handles);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TSexperimentbrowser wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TSexperimentbrowser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

% The listbox callbacks are basically all the same, i copy pasted them and
% changed a few hard coded constants. In this case the constant is 1, in
% the next it will be 2, etc.
if evalin('base','isempty(who(''global'',''Experiment''))')
    set(handles.text6, 'Visible', 'on');
    disp('There is no experiment structure in the workspace');
    clearGui(handles, eventdata);
    return;
end;
set(handles.text6, 'Visible', 'off');

if (length(get(hObject, 'Value')) ~= 1) || (isempty(get(hObject, 'String')))
    return;
end

global Experiment

handles.mostrecentexperimentname = Experiment.Name;

handles.selected{1} = get(hObject,'Value');
handles.selected = handles.selected(1:1-isempty(get(hObject,'Value'))); %truncate both of these cells to at least this size, or smaller if this one is also empty.
handles.paths = handles.paths(1:1-isempty(get(hObject,'Value')));
%handles.
setwindows(handles);

sel = handles.selected{1};
if (length(sel) == 1)
    %This calls the StructInfo recursive struct traversing function, which
    %gets information from a structure given a selected path.
    [vars, vals, substructs, paths] = StructInfo(GetSubStruct(Experiment,GetSelectedPath(handles)));
    
    dd = cellstr([char(vars) repmat(':   ',length(vars),1) char(vals)]);
    handles.vars = vars;
    
    set(handles.listbox6, 'Value', []);
    set(handles.listbox6, 'String', dd);
    set(handles.listbox6, 'Enable', 'on');
    set(handles.listbox6, 'Visible', 'on');
    
    if (length(substructs) > 0)
    set(handles.listbox2, 'Value', []);
    set(handles.listbox2, 'String', substructs);
    set(handles.listbox2, 'Enable', 'on');
    set(handles.listbox2, 'Visible', 'on');
    handles.paths{2} = paths;
    end
end
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
    p = get(hObject,'Position');
    set(hObject,'Position',[p(1:3) 1.2538461538461552]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2

if evalin('base','isempty(who(''global'',''Experiment''))')
    disp('There is no experiment structure defined');
    clearGui(handles, eventdata);
    return;
end;

if isempty(get(hObject, 'Value'))
    listbox1_Callback(handles.listbox1, eventdata, handles);
    return;
end

if (length(get(hObject, 'Value')) ~= 1) || (length(get(hObject, 'String')) == 0)
    return;
end

global Experiment

handles.selected{2} = get(hObject,'Value');
handles.selected = handles.selected(1:2-isempty(get(hObject,'Value')));
handles.paths = handles.paths(1:2-isempty(get(hObject,'Value')));
setwindows(handles);

set(handles.listbox1, 'Value', []);
sel = handles.selected{1};
if (length(sel) == 1)
    [vars, vals, substructs, paths] = StructInfo(GetSubStruct(Experiment,GetSelectedPath(handles)));
    
    dd = cellstr([char(vars) repmat(':   ',length(vars),1) char(vals)]);
    handles.vars = vars;

    set(handles.listbox6, 'Value', []);
    set(handles.listbox6, 'String', dd);
    set(handles.listbox6, 'Enable', 'on');
    set(handles.listbox6, 'Visible', 'on');
    
    if (length(substructs) > 0)
    set(handles.listbox3, 'Value', []);
    set(handles.listbox3, 'String', substructs);
    set(handles.listbox3, 'Enable', 'on');
    set(handles.listbox3, 'Visible', 'on');
    handles.paths{3} = paths;
    end
end
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3

if evalin('base','isempty(who(''global'',''Experiment''))')
    disp('There is no experiment structure defined');
    clearGui(handles, eventdata);
    return;
end;

if (length(get(hObject, 'Value')) == 0)
    listbox2_Callback(handles.listbox2, eventdata, handles);
    return;
end

if (length(get(hObject, 'Value')) ~= 1) || (length(get(hObject, 'String')) == 0)
    return;
end

global Experiment

handles.selected{3} = get(hObject,'Value');
handles.selected = handles.selected(1:3-isempty(get(hObject,'Value')));
handles.paths = handles.paths(1:3-isempty(get(hObject,'Value')));
setwindows(handles);

set(handles.listbox1, 'Value', []);
sel = handles.selected{1};
if (length(sel) == 1)
    [vars, vals, substructs, paths] = StructInfo(GetSubStruct(Experiment,GetSelectedPath(handles)));
    
    dd = cellstr([char(vars) repmat(':   ',length(vars),1) char(vals)]);
    handles.vars = vars;
    
    set(handles.listbox6, 'Value', []);
    set(handles.listbox6, 'String', dd);
    set(handles.listbox6, 'Enable', 'on');
    set(handles.listbox6, 'Visible', 'on');
    
    if (length(substructs) > 0)
    set(handles.listbox4, 'Value', []);
    set(handles.listbox4, 'String', substructs);
    set(handles.listbox4, 'Enable', 'on');
    set(handles.listbox4, 'Visible', 'on');
    handles.paths{4} = paths;
    end
end
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in listbox4.
function listbox4_Callback(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox4

if evalin('base','isempty(who(''global'',''Experiment''))')
    disp('There is no experiment structure defined');
    clearGui(handles, eventdata);
    return;
end;

if (length(get(hObject, 'Value')) == 0)
    listbox3_Callback(handles.listbox3, eventdata, handles);
    return;
end

if (length(get(hObject, 'Value')) ~= 1) || (length(get(hObject, 'String')) == 0)
    return;
end

global Experiment

handles.selected{4} = get(hObject,'Value');
handles.selected = handles.selected(1:4-isempty(get(hObject,'Value')));
handles.paths = handles.paths(1:4-isempty(get(hObject,'Value')));
setwindows(handles);

set(handles.listbox1, 'Value', []);
sel = handles.selected{1};
if (length(sel) == 1)
    [vars, vals, substructs, paths] = StructInfo(GetSubStruct(Experiment,GetSelectedPath(handles)));
    
    dd = cellstr([char(vars) repmat(':   ',length(vars),1) char(vals)]);
    handles.vars = vars;
    
    set(handles.listbox6, 'Value', []);
    set(handles.listbox6, 'String', dd);
    set(handles.listbox6, 'Enable', 'on');
    set(handles.listbox6, 'Visible', 'on');
    
    if (length(substructs) > 0)
    set(handles.listbox5, 'Value', []);
    set(handles.listbox5, 'String', substructs);
    set(handles.listbox5, 'Enable', 'on');
    set(handles.listbox5, 'Visible', 'on');
    handles.paths{5} = paths;
    end
end
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function listbox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in listbox5.
function listbox5_Callback(hObject, eventdata, handles)
% hObject    handle to listbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox5

if evalin('base','isempty(who(''global'',''Experiment''))')
    disp('There is no experiment structure defined');
    clearGui(handles, eventdata);
    return;
end;

if (length(get(hObject, 'Value')) == 0)
    listbox4_Callback(handles.listbox4, eventdata, handles);
    return;
end

if (length(get(hObject, 'Value')) ~= 1) || (length(get(hObject, 'String')) == 0)
    return;
end

global Experiment

handles.selected{5} = get(hObject,'Value');
handles.selected = handles.selected(1:5-isempty(get(hObject,'Value')));
handles.paths = handles.paths(1:5-isempty(get(hObject,'Value')));
setwindows(handles);

set(handles.listbox1, 'Value', []);
sel = handles.selected{1};
if (length(sel) == 1)
    [vars, vals, substructs, paths] = StructInfo(GetSubStruct(Experiment,GetSelectedPath(handles)));
    
    dd = cellstr([char(vars) repmat(':   ',length(vars),1) char(vals)]);
    handles.vars = vars;
    
    set(handles.listbox6, 'Value', []);
    set(handles.listbox6, 'String', dd);
    set(handles.listbox6, 'Enable', 'on');
    set(handles.listbox6, 'Visible', 'on');
end
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function listbox5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function listbox6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in listbox6.
function listbox6_Callback(hObject, eventdata, handles)
% hObject    handle to listbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox6

if evalin('base','isempty(who(''global'',''Experiment''))')
    disp('There is no experiment structure defined');
    clearGui(handles, eventdata);
    return;
end;

if (length(get(hObject, 'Value')) ~= 1) || (length(get(hObject, 'String')) == 0)
    DeactivateFieldTools(handles);
    return;
end

global Experiment
try
var = handles.vars{get(hObject, 'Value')};
catch
    handles.vars
    get(hObject, 'Value')
    var = handles.vars{get(hObject, 'Value')};
end
set(handles.edit2, 'String', var);

pathstr = 'Experiment.';
path = GetSelectedPath(handles);
for (x = 1:length(path))
    if (length(path{x}) == 1)
        pathstr = [pathstr path{x}{1} '.'];
    elseif(length(path{x}) == 2)
        pathstr = [pathstr path{x}{1} '(' num2str(path{x}{2}) ').'];
    end
end
pathstr = [pathstr var];
set(handles.edit4, 'String', pathstr);

val = GetStructField(Experiment, path, var);
[r, c] =size(val);

if (r > 1 || ischar(val) || iscellstr(val))
    set(handles.edit1, 'String', GetLargeString(val));
else
    set(handles.edit1, 'String', GetString(val));
end
if (1==numel(val))
    set(handles.edit3, 'String', class(val));
else
    temp = {'str'};
    set(handles.edit3, 'String', [regexprep(num2str(size(val)), '\s*', ' x ') ' ' class(val) temp{iscellstr(val)}]);
end

ActivateFieldTools(handles);

if (r <= 1 || ischar(val) || iscellstr(val))
    set(handles.pushbutton1, 'String', 'Set');
    set(handles.pushbutton1, 'Enable', 'on');
else
    set(handles.pushbutton1, 'String', 'Edit');
    set(handles.pushbutton1, 'Enable', 'on');
    if (ispc)
    set(handles.edit1, 'Enable', 'inactive');
    end
end
drawnow;
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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%var = handles.vars{get(handles.listbox6, 'Value')};
if evalin('base','isempty(who(''global'',''Experiment''))')
    disp('There is no experiment structure defined');
    clearGui(handles, eventdata);
    return;
end;

global Experiment

var = handles.vars{get(handles.listbox6, 'Value')};
val = GetStructField(Experiment, GetSelectedPath(handles), var);

if(strcmp(get(hObject,'String'),'Edit'))
    disp('opening array editor...');
    openvar(get(handles.edit4, 'String'));
    return;
end

if(ischar(val) || iscellstr(val))
    temp = get(handles.edit1, 'String');
    if ischar(val)
        temp = char(temp);
    elseif iscellstr(val)
        temp = cellstr(temp);
    end
    Experiment = SetStructField(Experiment, GetSelectedPath(handles), var, temp);
else
    
    if(~strcmp(get(handles.edit1,'String'), '') && ~strcmp(get(handles.edit1,'String'), ' '))
    try
    Experiment = SetStructField(Experiment, GetSelectedPath(handles), handles.vars{get(handles.listbox6, 'Value')}, evalin('base',get(handles.edit1,'String')));
    catch
        disp('An error occurred when trying to eval:');
        disp(lasterr);
    end
    else
    Experiment = SetStructField(Experiment, GetSelectedPath(handles), handles.vars{get(handles.listbox6, 'Value')}, []);
    end
end

%set(handles.listbox6, 'Value', []);
RefreshVarWindow(handles);
listbox6_Callback(handles.listbox6, eventdata, handles);

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


% % --- Executes on button press in fbutton2.
% function fbutton2_Callback_old(hObject, eventdata, handles)
% % hObject    handle to fbutton2 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% if evalin('base','isempty(who(''global'',''Experiment''))')
%     disp('There is no experiment structure defined');
%     clearGui(handles, eventdata);
%     result=0;
%     return;
% end;
% 
% global Experiment
% 
% [rows, cols] = size(GetStructField(Experiment, GetSelectedPath(handles), handles.vars{get(handles.listbox6, 'Value')}));
% 
% if (rows <= 20)
% evalin('base', [ get(handles.edit2, 'String') ' = ' get(handles.edit4, 'String')]);
% else
% evalin('base', [ get(handles.edit2, 'String') ' = ' get(handles.edit4, 'String') ';']);
% end
% 
% set(handles.listbox6, 'Value', []);
% RefreshVarWindow(handles);
% listbox6_Callback(handles.listbox6, eventdata, handles);


% % --- Executes on button press in fbutton4.
% function fbutton4_Callback_old(hObject, eventdata, handles)
% % hObject    handle to fbutton4 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% if evalin('base','isempty(who(''global'',''Experiment''))')
%     disp('There is no experiment structure defined');
%     clearGui(handles, eventdata);
%     result=0;
%     return;
% end;
% 
% global Experiment
% 
% TSbrowser(GetStructField(Experiment, GetSelectedPath(handles), handles.vars{get(handles.listbox6, 'Value')}));
% 
% %set(handles.listbox6, 'Value', []);
% RefreshVarWindow(handles);
% listbox6_Callback(handles.listbox6, eventdata, handles);

% % --- Executes on button press in fbutton3.
% function fbutton3_Callback_old(hObject, eventdata, handles)
% % hObject    handle to fbutton3 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% if evalin('base','isempty(who(''global'',''Experiment''))')
%     disp('There is no experiment structure defined');
%     clearGui(handles, eventdata);
%     result=0;
%     return;
% end;
% 
% global Experiment
% 
% val = GetStructField(Experiment, GetSelectedPath(handles), handles.vars{get(handles.listbox6, 'Value')});
% 
% [rows, cols] = size(val);
% 
% if(cols > rows)
%     val = val';
%     [rows, cols] = size(val);
% end
% 
% figure;
% 
% if (cols == 2)
%     plot(val(:,1), val(:,2));
% else
%     plot(val);
% end
% title(handles.vars{get(handles.listbox6, 'Value')});
% 
% %set(handles.listbox6, 'Value', []);
% RefreshVarWindow(handles);
% listbox6_Callback(handles.listbox6, eventdata, handles);


% % --- Executes on button press in fbutton6.
% function fbutton6_Callback_old(hObject, eventdata, handles)
% % hObject    handle to fbutton6 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% if evalin('base','isempty(who(''global'',''Experiment''))')
%     disp('There is no experiment structure defined');
%     clearGui(handles, eventdata);
%     result=0;
%     return;
% end;
% 
% global Experiment
% 
% val = GetStructField(Experiment, GetSelectedPath(handles), handles.vars{get(handles.listbox6, 'Value')});
% 
% [rows, cols] = size(val);
% 
% if(cols > rows)
%     val = val';
%     [rows, cols] = size(val);
% end
% 
% figure;
% 
% if (cols == 2)
%     bar(val(:,1), val(:,2), 1);
% else
%     bar(val,1);
% end
% title(handles.vars{get(handles.listbox6, 'Value')});
% 
% %set(handles.listbox6, 'Value', []);
% RefreshVarWindow(handles);
% listbox6_Callback(handles.listbox6, eventdata, handles);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if evalin('base','isempty(who(''global'',''Experiment''))')
    disp('There is no experiment structure defined');
    clearGui(handles, eventdata);
    result=0;
    return;
end;

global Experiment

val = GetStructField(Experiment, GetSelectedPath(handles), handles.vars{get(handles.listbox6, 'Value')});

%if (isnumeric(val) || islogical(val))
disp(' ');
disp([handles.vars{get(handles.listbox6, 'Value')} ' = ']);
disp(val);
%end

RefreshVarWindow(handles);
listbox6_Callback(handles.listbox6, eventdata, handles);

% --- Executes on button press in fbutton5.
function fbutton5_Callback_old(hObject, eventdata, handles)
% hObject    handle to fbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try

if evalin('base','isempty(who(''global'',''Experiment''))')
    disp('There is no experiment structure defined');
    clearGui(handles, eventdata);
    result=0;
    return;
end;

global Experiment

val = GetStructField(Experiment, GetSelectedPath(handles), handles.vars{get(handles.listbox6, 'Value')});

TSrastergui(val);

RefreshVarWindow(handles);
listbox6_Callback(handles.listbox6, eventdata, handles);

catch
    disp(lasterr);
end

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if evalin('base','isempty(who(''global'',''Experiment''))')
    disp('There is no experiment structure defined');
    clearGui(handles, eventdata);
    result=0;
    return;
end;

global Experiment

TSfielddetails(0, char(get(handles.edit4,'String')));
%val = GetStructField(Experiment, GetSelectedPath(handles), handles.vars{get(handles.listbox6, 'Value')});

%Experiment = SetStructField(Experiment, GetSelectedPath(handles), handles.vars{get(handles.listbox6, 'Value')}, TSstringeditor(0,val));

RefreshVarWindow(handles);
listbox6_Callback(handles.listbox6, eventdata, handles);


% --- Additional Helper functions:
function setwindows(handles)
% This function collapses the Subject/Session/TrialTypes/Trial viewing
% panes based on the size of the "selected" cell array. Selcted

selected = handles.selected;

if(length(selected) < 5)
    set(handles.listbox5, 'Value', []);
    set(handles.listbox5, 'String', 'Cannot Display');
    set(handles.listbox5, 'Enable', 'off');
    set(handles.listbox5, 'Visible', 'off');
else
    set(handles.listbox5, 'Enable', 'on');
    set(handles.listbox5, 'Visible', 'on');
end

if(length(selected) < 4)
    set(handles.listbox4, 'Value', []);
    set(handles.listbox4, 'String', 'Cannot Display');
    set(handles.listbox4, 'Enable', 'off');
    set(handles.listbox4, 'Visible', 'off');
else
    set(handles.listbox4, 'Enable', 'on');
    set(handles.listbox4, 'Visible', 'on');    
end

if(length(selected) < 3)
    set(handles.listbox3, 'Value', []);
    set(handles.listbox3, 'String', 'Cannot Display');
    set(handles.listbox3, 'Enable', 'off');
    set(handles.listbox3, 'Visible', 'off');
else
    set(handles.listbox3, 'Enable', 'on');
    set(handles.listbox3, 'Visible', 'on');
end


if(length(selected) == 0 || any(selected{1} ~= 1))
set(handles.listbox2, 'Value', []);
set(handles.listbox2, 'String', 'Cannot Display');
set(handles.listbox2, 'Enable', 'off');
set(handles.listbox2, 'Visible', 'off');
else
    set(handles.listbox2, 'Enable', 'on');
    set(handles.listbox2, 'Visible', 'on');
end

DeactivateFieldTools(handles);

function [result] = GetSelectedPath(handles)
result = {};
for x=2:length(handles.selected)
    result{end+1} = handles.paths{x}{handles.selected{x}(1)};
end


function [vars, vals, substructs, paths] = StructInfo(s)
fn = fieldnames(s);
vars = {};
vals = {};
    
substructs = {};
paths = {};
    
for x = 1:length(fn)
    if ~isstruct(getfield(s, fn{x}))
        vars{end+1} = fn{x};
        vals{end+1} = GetString(getfield(s, fn{x}));
    else
        if strcmp(fn{x},'Subject')
            for (y = 1:prod(size(getfield(s, fn{x}))))
                substructs{end+1} = [num2str(y) ': ' num2str(s.Subject(y).SubId)]; % Mofified by CRG
                % if it crashes, replace Id with Id or vice versa
                paths{end+1} = {fn{x} y};
            end
        elseif (strcmp(fn{x}, 'Session') && prod(size(getfield(s, fn{x}))))
            for (y = 1:prod(size(getfield(s, fn{x}))))
                substructs{end+1} = [num2str(y) ': ' s.Session(y).Date]; % Modified by CRG
                paths{end+1} = {fn{x} y};
            end
        else
            if (prod(size(getfield(s, fn{x}))) == 1)
                substructs{end+1} = fn{x};
                paths{end+1} = {fn{x}};
            else
                for (y = 1:prod(size(getfield(s, fn{x}))))
                    substructs{end+1} = [fn{x} '(' num2str(y) ')'];
                    paths{end+1} = {fn{x} y};
                end
            end
        end
    end
end
    
function [result] = GetLargeString(data)
if (isnumeric(data) || islogical(data))
    if (length(data) <= 100)
        data = data * 100;
        data = round(data);
        data = data / 100;
        result = num2str(data);
    else
        l = length(data);
        data = data([1:50 end-49:end],:);
        data = data * 100;
        data = round(data);
        data = data / 100;
        result = cellstr(num2str(data));
        result = [result(1:50); cellstr(['< ' num2str(l-100) ' rows were truncated.>']); result(51:100)];
    end
elseif (iscell(data) && ~iscellstr(data))
    [rows, cols] = size(data);
    if (rows > 1)
        result = {};
        for (x = 1:rows)
           result{x} = GetLargeString(data(x,:))
        end
        result = char(result);
    else
        if (cols == 1)
            result = ['{ ' GetLargeString(data{1}) ' }'];
        elseif (cols == 0)
            result = '{  }';
        else
            result = '{ ';
            for (x = 1:length(data)-1)
                result = [result GetLargeString(data{x}) ' , '];
            end
            result = [result GetLargeString(data{end}) ' }'];
        end
    end
else
    result = cellstr(char(data));
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

function [result] = GetSubStruct(result, path)
if (length(path) ~= 0)
	if (length(path{1}) == 1)
		result = GetSubStruct( result.(path{1}{1}), path(2:end));
	elseif (length(path{1}) == 2)
		result = GetSubStruct( result.(path{1}{1})(path{1}{2}), path(2:end));
	end
end

function ActivateFieldTools(handles)
set(handles.edit1, 'Enable', 'on');
set(handles.edit2, 'Enable', 'inactive');
set(handles.edit3, 'Enable', 'inactive');
set(handles.edit4, 'Enable', 'on');
set(handles.pushbutton1, 'Enable', 'on');
set(handles.pushbutton6, 'Enable', 'on');
set(handles.pushbutton8, 'Enable', 'on');
set(handles.fbutton1, 'Enable', 'on');
set(handles.fbutton2, 'Enable', 'on');
set(handles.fbutton3, 'Enable', 'on');
set(handles.fbutton4, 'Enable', 'on');
set(handles.fbutton5, 'Enable', 'on');
set(handles.fbutton6, 'Enable', 'on');
set(handles.fbutton7, 'Enable', 'on');
set(handles.fbutton8, 'Enable', 'on');

function DeactivateFieldTools(handles)
set(handles.edit1, 'Enable', 'off');
set(handles.edit2, 'Enable', 'off');
set(handles.edit3, 'Enable', 'off');
set(handles.edit4, 'Enable', 'off');
set(handles.pushbutton1, 'Enable', 'off');
set(handles.pushbutton6, 'Enable', 'off');
set(handles.pushbutton8, 'Enable', 'off');
set(handles.fbutton1, 'Enable', 'off');
set(handles.fbutton2, 'Enable', 'off');
set(handles.fbutton3, 'Enable', 'off');
set(handles.fbutton4, 'Enable', 'off');
set(handles.fbutton5, 'Enable', 'off');
set(handles.fbutton6, 'Enable', 'off');
set(handles.fbutton7, 'Enable', 'off');
set(handles.fbutton8, 'Enable', 'off');


function RefreshVarWindow(handles)
global Experiment
[vars, vals, substructs, paths] = StructInfo(GetSubStruct(Experiment,GetSelectedPath(handles)));
    
dd = cellstr([char(vars) repmat(':   ',length(vars),1) char(vals)]);
handles.vars = vars;

%set(handles.listbox6, 'Value', []);
set(handles.listbox6, 'String', dd);
set(handles.listbox6, 'Enable', 'on');
set(handles.listbox6, 'Visible', 'on');

function [result] = GetStructField(result, path, field)
if (length(path) == 0)
	result = getfield(result, field);
else
	if (length(path{1}) == 1)
		result = GetStructField( result.(path{1}{1}), path(2:end), field);
	elseif (length(path{1}) == 2)
		result = GetStructField( result.(path{1}{1})(path{1}{2}), path(2:end), field);
	end
end

function [result] = RemoveStructField(result, path, field)
if (length(path) == 0)
	result = rmfield(result, field);
else
	if (length(path{1}) == 1)
		result = RemoveStructField( result.(path{1}{1}), path(2:end), field);
	elseif (length(path{1}) == 2)
		result = RemoveStructField( result.(path{1}{1})(path{1}{2}), path(2:end), field);
	end
end

function [result] = SetStructField(result, path, field, value)
if (length(path) == 0)
	result = setfield(result, field, value);
else
	if (length(path{1}) == 1)
		result.(path{1}{1}) = SetStructField( result.(path{1}{1}), path(2:end), field, value);
	elseif (length(path{1}) == 2)
		result.(path{1}{1})(path{1}{2}) = SetStructField( result.(path{1}{1})(path{1}{2}), path(2:end), field, value);
	end
end

function clearGui(handles, eventdata)
handles.selected = {[]};
handles.paths = { {} };
handles.vars = {};
set(handles.listbox6, 'Value', []);
set(handles.listbox6, 'String', 'Cannot Display');
set(handles.listbox6, 'Enable', 'off');
set(handles.listbox6, 'Visible', 'off');
set(handles.listbox1,'Value',[]);
setwindows(handles);
set(handles.listbox2, 'Value', []);
set(handles.listbox2, 'String', 'Cannot Display');
set(handles.listbox2, 'Enable', 'off');
set(handles.listbox2, 'Visible', 'off');

function Refresh_Path(hObject, eventdata, handles)
disp('Refresh path attempted');

if evalin('base','isempty(who(''global'',''Experiment''))')
    disp('There is no experiment structure defined');
    clearGui(handles, eventdata);
    result=0;
    return;
end;

global Experiment
var = handles.vars{get(handles.listbox6, 'Value')};

pathstr = 'Experiment.';
path = GetSelectedPath(handles);
for (x = 1:length(path))
    if (length(path{x}) == 1)
        pathstr = [pathstr path{x}{1} '.'];
    elseif(length(path{x}) == 2)
        pathstr = [pathstr path{x}{1} '(' num2str(path{x}{2}) ').'];
    end
end
pathstr = [pathstr var];
set(handles.edit4, 'Enable', 'inactive');
set(handles.edit4, 'Enable', 'on');
set(handles.edit4, 'String', pathstr);
disp(pathstr);
drawnow;

function Set_Attempt(hObject, eventdata, handles)
disp('set attempt');
set(handles.pushbutton1, 'Enable', 'on');

function Set_Button_Panel_Visibillity(handles)
if (1 == get(handles.checkbox1,'Value'))
    p = get(handles.edit1,'Position');
    set(handles.edit1,'Position',[p(1) handles.default_y_edit1(1) p(3) handles.default_y_edit1(2)]);
    p = get(handles.pushbutton1,'Position');
    set(handles.pushbutton1,'Position',[p(1) handles.default_y_basic_buttons(1) p(3) handles.default_y_basic_buttons(2)]);
    p = get(handles.pushbutton6,'Position');
    set(handles.pushbutton6,'Position',[p(1) handles.default_y_basic_buttons(1) p(3) handles.default_y_basic_buttons(2)]);
    p = get(handles.pushbutton8,'Position');
    set(handles.pushbutton8,'Position',[p(1) handles.default_y_basic_buttons(1) p(3) handles.default_y_basic_buttons(2)]);
    p = get(handles.checkbox1,'Position');
    set(handles.checkbox1,'Position',[p(1) handles.default_y_basic_buttons(1) p(3) handles.default_y_basic_buttons(2)]);

else
    p = get(handles.edit1,'Position');
    set(handles.edit1,'Position',[p(1) handles.reduced_y_edit1(1) p(3) handles.reduced_y_edit1(2)]);
    p = get(handles.pushbutton1,'Position');
    set(handles.pushbutton1,'Position',[p(1) handles.reduced_y_basic_buttons(1) p(3) handles.reduced_y_basic_buttons(2)]);
    p = get(handles.pushbutton6,'Position');
    set(handles.pushbutton6,'Position',[p(1) handles.reduced_y_basic_buttons(1) p(3) handles.reduced_y_basic_buttons(2)]);
    p = get(handles.pushbutton8,'Position');
    set(handles.pushbutton8,'Position',[p(1) handles.reduced_y_basic_buttons(1) p(3) handles.reduced_y_basic_buttons(2)]);
    p = get(handles.checkbox1,'Position');
    set(handles.checkbox1,'Position',[p(1) handles.reduced_y_basic_buttons(1) p(3) handles.reduced_y_basic_buttons(2)]);

    
    set(handles.fbutton1,'Visible','off');
    set(handles.fbutton2,'Visible','off');
    set(handles.fbutton3,'Visible','off');
    set(handles.fbutton4,'Visible','off');
    set(handles.fbutton5,'Visible','off');
    set(handles.fbutton6,'Visible','off');
    set(handles.fbutton7,'Visible','off');
    set(handles.fbutton8,'Visible','off');
end

update_fbuttons(handles);

% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function New_Callback(hObject, eventdata, handles)
% hObject    handle to New (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Experiment
if evalin('base','~isempty(who(''global'',''Experiment''))')
    %disp('There is an experiment structure already defined');
    
    bn = questdlg(char({'This operation will clear the existing Experiment structure from memory!', ...
        '', ...
        'Are you sure you want to continue?'}), 'TSexperimentbrowser', 'OK', 'Cancel', 'OK');
    
    if (~strcmp(bn, 'OK'))
        result=0;
        return;
    end
end;

expinfo = inputdlg({'Name of Experiment:' 'ID Number of Experiment' 'Subject(s): (please seperate ID nums with spaces or commas) ' 'Species:' 'Lab:'}, 'New Experiment');
if length(expinfo) >= 3
    clear global Experiment
    TSinitexperiment(expinfo{1}, str2num(expinfo{2}), str2num(expinfo{3}), expinfo{4}, expinfo{5});
    clearGui(handles, eventdata);
end

% --------------------------------------------------------------------
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Experiment
if evalin('base','~isempty(who(''global'',''Experiment''))')
    %disp('There is an experiment structure already defined');
    
    bn = questdlg(char({'This operation will clear the existing Experiment structure from memory!', ...
        '', ...
        'Are you sure you want to continue?'}), 'TSexperimentbrowser', 'OK', 'Cancel', 'OK');
    
    if (~strcmp(bn, 'OK'))
        result=0;
        return;
    end
end;

%answer = inputdlg({'Please type the name of the experiment to be loaded.'}, 'Load Experiment', 1, {handles.mostrecentexperimentname});
[answer, path] = uigetfile('*.mat','Load Experiment'); 
if (ischar(answer))
    curdir = cd;
    cd(path);
    f = strfind(answer,'.');
    answer = answer(1:f(end)-1);
    TSloadexperiment(answer);
    cd(curdir);
end
clearGui(handles, eventdata);
set(handles.listbox1, 'Value', [1]);
listbox1_Callback(handles.listbox1, eventdata, handles)
% --------------------------------------------------------------------
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if evalin('base','isempty(who(''global'',''Experiment''))')
    disp('There is no experiment structure defined');
    clearGui(handles, eventdata);
    result=0;
    return;
end;

global Experiment

TSsaveexperiment;
disp(['Experiment ' Experiment.Name ' saved.']);

% --------------------------------------------------------------------
function Save_As_Callback(hObject, eventdata, handles)
% hObject    handle to Save_As (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if evalin('base','isempty(who(''global'',''Experiment''))')
    disp('There is no experiment structure defined');
    clearGui(handles, eventdata);
    result=0;
    return;
end;

global Experiment

[filename,path] = uiputfile('*.mat','Save Experiment');
if (ischar(filename))
    currentdir = cd;
    cd(path);
    f = strfind(filename,'.');
    filename= filename(1:f(end)-1);
    TSsaveexperiment(filename);
    disp(['Experiment ' Experiment.Name ' saved.']);
    cd(currentdir);
end

% --------------------------------------------------------------------
function Clear_Callback(hObject, eventdata, handles)
% hObject    handle to Clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Experiment
if evalin('base','~isempty(who(''global'',''Experiment''))')
    %disp('There is an experiment structure already defined');
    
    bn = questdlg(char({'This operation will clear the existing Experiment structure from memory!', ...
        '', ...
        'Are you sure you want to continue?'}), 'TSexperimentbrowser', 'OK', 'Cancel', 'OK');
    
    if (~strcmp(bn, 'OK'))
        result=0;
        return;
    end
end;

clear global Experiment
clearGui(handles, eventdata);

% --------------------------------------------------------------------
function edit_fbuttons_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fbuttons (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Editing fbuttons...');
edit_fbuttons(hObject,eventdata,handles);

% --------------------------------------------------------------------
function Actions_Callback(hObject, eventdata, handles)
% hObject    handle to Actions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in fbutton1.
function fbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to fbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exec_fbutton(1,eventdata,handles);

function fbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to fbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exec_fbutton(2,eventdata,handles);

function fbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to fbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exec_fbutton(3,eventdata,handles);

function fbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to fbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exec_fbutton(4,eventdata,handles);

function fbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to fbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exec_fbutton(5,eventdata,handles);

function fbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to fbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exec_fbutton(6,eventdata,handles);


% --- Executes on button press in fbutton7.
function fbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to fbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exec_fbutton(7,eventdata,handles);

% --- Executes on button press in fbutton8.
function fbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to fbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exec_fbutton(8,eventdata,handles);

function exec_fbutton(which_button,eventdata,handles)
% handles.fbutton_isactive  logical vector
% handles.fbutton_name      cellstr
% handles.fbutton_script    cell of cellstrs/strs
n = floor(which_button);
which_button = n;
if (n < 1 || n > length(handles.fbutton_isactive)) return; end
if handles.fbutton_isactive(n)
    
    if evalin('base','isempty(who(''global'',''Experiment''))')
        disp('There is no experiment structure defined');
        clearGui(handles, eventdata);
        result=0;
        return;
    end;

    global Experiment

    currently_executing_script = [char(handles.fbutton_script{n}) repmat('  ',length(handles.fbutton_script{n}),1)]';
    
    var = handles.vars{get(handles.listbox6, 'Value')};
    val = GetStructField(Experiment, GetSelectedPath(handles), var);
    path = char(get(handles.edit4,'String'));

    eval_with_no_scope(currently_executing_script,var,val,path);
    
end

RefreshVarWindow(handles);
listbox6_Callback(handles.listbox6, eventdata, handles);

function eval_with_no_scope (currently_executing_script, var, val, path)
global Experiment
%TSdeclareeventcodes;
eval(currently_executing_script);

function edit_fbuttons(hObject, eventdata, handles)
% handles.fbutton_isactive  logical vector
% handles.fbutton_name      cellstr
% handles.fbutton_script    cell of cellstrs/strs
if isempty(handles.fbutton_isactive)
    handles.fbutton_isactive(1) = strcmp('on',get(handles.fbutton1,'Visible'));
    handles.fbutton_isactive(2) = strcmp('on',get(handles.fbutton2,'Visible'));
    handles.fbutton_isactive(3) = strcmp('on',get(handles.fbutton3,'Visible'));
    handles.fbutton_isactive(4) = strcmp('on',get(handles.fbutton4,'Visible'));
    handles.fbutton_isactive(5) = strcmp('on',get(handles.fbutton5,'Visible'));
    handles.fbutton_isactive(6) = strcmp('on',get(handles.fbutton6,'Visible'));
    handles.fbutton_isactive(7) = strcmp('on',get(handles.fbutton7,'Visible'));
    handles.fbutton_isactive(8) = strcmp('on',get(handles.fbutton8,'Visible'));
    handles.fbutton_name{1} = char(get(handles.fbutton1,'String'));
    handles.fbutton_name{2} = char(get(handles.fbutton2,'String'));
    handles.fbutton_name{3} = char(get(handles.fbutton3,'String'));
    handles.fbutton_name{4} = char(get(handles.fbutton4,'String'));
    handles.fbutton_name{5} = char(get(handles.fbutton5,'String'));
    handles.fbutton_name{6} = char(get(handles.fbutton6,'String'));
    handles.fbutton_name{7} = char(get(handles.fbutton7,'String'));
    handles.fbutton_name{8} = char(get(handles.fbutton8,'String'));
    [handles.fbutton_script{:}] = deal({''});
end

%disp('About to call button editor');
results = TSbrowserbuttoneditor(handles.fbutton_isactive,handles.fbutton_name,handles.fbutton_script);
%uiwait(handles.figure1);
[handles.fbutton_isactive,handles.fbutton_name,handles.fbutton_script] = deal(results{1:3});
update_fbuttons(handles);   % this is the function call that leads to the error at line 1643- so problem has already happened
save_fbutton_settings(handles);
guidata(hObject,handles);
%uiresume(handles.figure1);


function update_fbuttons(handles)
disp(handles.checkbox1);    % works- it's not that handles gets deleted??
disp('update_fbuttons');
if (0 == get(handles.checkbox1,'Value'))
    return;
end
if (handles.fbutton_isactive(1))
set(handles.fbutton1,'Visible','on');
set(handles.fbutton1,'String', handles.fbutton_name{1});
else
set(handles.fbutton1,'Visible','off');
end
if (handles.fbutton_isactive(2))
set(handles.fbutton2,'Visible','on');
set(handles.fbutton2,'String', handles.fbutton_name{2});
else
set(handles.fbutton2,'Visible','off');
end
if (handles.fbutton_isactive(3))
set(handles.fbutton3,'Visible','on');
set(handles.fbutton3,'String', handles.fbutton_name{3});
else
set(handles.fbutton3,'Visible','off');
end
if (handles.fbutton_isactive(4))
set(handles.fbutton4,'Visible','on');
set(handles.fbutton4,'String', handles.fbutton_name{4});
else
set(handles.fbutton4,'Visible','off');
end
if (handles.fbutton_isactive(5))
set(handles.fbutton5,'Visible','on');
set(handles.fbutton5,'String', handles.fbutton_name{5});
else
set(handles.fbutton5,'Visible','off');
end
if (handles.fbutton_isactive(6))
set(handles.fbutton6,'Visible','on');
set(handles.fbutton6,'String', handles.fbutton_name{6});
else
set(handles.fbutton6,'Visible','off');
end
if (handles.fbutton_isactive(7))
set(handles.fbutton7,'Visible','on');
set(handles.fbutton7,'String', handles.fbutton_name{7});
else
set(handles.fbutton7,'Visible','off');
end
if (handles.fbutton_isactive(8))
set(handles.fbutton8,'Visible','on');
set(handles.fbutton8,'String', handles.fbutton_name{8});
else
set(handles.fbutton8,'Visible','off');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

Set_Button_Panel_Visibillity(handles);
% Update handles structure
guidata(hObject, handles);

function save_fbutton_settings(handles)
%if (0 == exist('TSexperimentbrowser_settings.mat'))
%    save TSexperimentbrowser_settings.mat -struct handles fbutton_isactive fbutton_name fbutton_script -V6
%else
%    save(which('TSexperimentbrowser_settings.mat'),'-struct','handles','fbutton_isactive','fbutton_name','fbutton_script','-V6');
%end
setpref ('TSLib','TSexperimentbrowser_fbutton_isactive',handles.fbutton_isactive);
setpref ('TSLib','TSexperimentbrowser_fbutton_name',handles.fbutton_name);
setpref ('TSLib','TSexperimentbrowser_fbutton_script',handles.fbutton_script);
disp('fbutton settings saved.');


% --------------------------------------------------------------------
function Remove_Field_Callback(hObject, eventdata, handles)
% hObject    handle to Remove_Field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%handles.paths{:}
%for (x = 1:length(handles.paths))
%    handles.paths{x}{:}
%end

if evalin('base','isempty(who(''global'',''Experiment''))')
    disp('There is no experiment structure defined');
    clearGui(handles, eventdata);
    result=0;
    return;
end;

lbox6 = get(handles.listbox6,'Value');

if (length(lbox6) ~= 1)
    p = GetSelectedPath(handles)
    item = p{end}{1};
else
    item = handles.vars{lbox6};
end

bn = questdlg(char({['This operation will permanently delete every instance of ' item ' at every level of the Experiment Structure!'], ...
        '', ...
        'Are you sure you want to continue?'}), 'TSrmfield', 'OK', 'Cancel', 'Cancel');

if (strcmp(bn, 'OK'))
    TSrmfield(item);

    set(handles.listbox6, 'Value', []);
    %listbox6_Callback(handles.listbox6, eventdata, handles);
    RefreshVarWindow(handles);
    listbox1_Callback(handles.listbox6, eventdata, handles);
end



% --------------------------------------------------------------------
function Load_Settings_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, path] = uigetfile('*.mat','Import Button Settings');
if ischar(filename)
    %try
        cd(path);
        s = load(filename);
%, isactive, name, script);
        handles.fbutton_isactive = s.isactive;
        handles.fbutton_name = s.name;
        handles.fbutton_script = s.script;

        %setfields(handles);
        %setbuttons(handles);
        update_fbuttons(handles);
        save_fbutton_settings(handles);
        guidata(hObject,handles);
    %catch
    %    disp('Error: File is not valid.');
    %end
end

% --------------------------------------------------------------------
function Save_Settings_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, path] = uiputfile('*.mat', 'Export Button Settings');
if ischar(filename)
cd(path);
isactive = handles.fbutton_isactive;
name = handles.fbutton_name;
script = handles.fbutton_script;
save(filename,'isactive', 'name', 'script');
%save TSexperimentbrowser_settings.mat -struct handles isactive name script -V6
end


% --------------------------------------------------------------------
function Restore_Default_Buttons_Callback(hObject, eventdata, handles)
% hObject    handle to Restore_Default_Buttons (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.fbutton_isactive = [1 0 0 1 1 0 0 1];
handles.fbutton_name = {'Plot' '' '' 'TSbrowser' 'Bar' '' '' 'TSraster'};
handles.fbutton_script = {{'figure;'; '[r,c] = size(val);'; 'if (c >= 2)'; 'plot(val(:,1),val(:,2));';'else';'plot(val);';'end'} {''} {''} {'TSdatabrowser(val)'} {'figure;'; '[r,c] = size(val);'; 'if (c >= 2)'; 'bar(val(:,1),val(:,2));';'else';'bar(val);';'end'} {''} {''} {'TSrastergui(val);'}};
update_fbuttons(handles);
save_fbutton_settings(handles);
guidata(hObject,handles);
disp('Factory Default Buttons restored.');


% --------------------------------------------------------------------
function Get_Callback(hObject, eventdata, handles)
% hObject    handle to Get (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

TSsetloadparameters('INTER')
% --------------------------------------------------------------------
function Event_Callback(hObject, eventdata, handles)
% hObject    handle to Event (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

TSimporteventcodes('',1)
