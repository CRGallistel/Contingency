function TSplotcdfs(varargin)
% Graphics helper function for TSapplystat.
% Plots cumulative distribution functions and labels them with subject
% and/or session, Trial and/or phase. Will plot multiple cdfs on single 
% panels and multiple panels per figure. MUST BE CALLED BY TSAPPLYSTAT!!
%
% Syntax:   TSapplystat('',usestat,@TSplotcdfs,varargin)
%
% The recognized varargin are:
%   'Rows' 'Cols' 'DataCols' 'Xlbl' 'Xlm' 'Ylm' 'Phase' 'AxH' 'Handle'
%
% When called by TSapplystat, TSplotcdfs(usestat) makes one cdf plot for
% each column in the usestat field(s), superimposing the plots on a single panel.
% If the call to TSapplystat specifies more than one usestat field, then
% each column in each field yields a cdfplot on the same panel--unless the
% columns are specified by a 'DataCols' Variable-Value pair--see below.
%
% The columns in usestat fields from which cdfplots on a single panel are  
% to be made may be specified using the DataCols Variable-Value pair. The 
% value of the 'DataCols' variable must be a cell array, with as many cells 
% as there are usetstat fields passed in by 2nd argument of TSapplystat.
% Each cell must contain a row vector specifying the to-be-plotted columns
% in the corresponding usestat field.
%
% The color code for the cdf plots on one panel is black, red, green, blue,
% yellow, then repeat this color sequence, so only five different plots on
% one panel may be distinguished by color.
%
% The default figure layout is 4 rows by 2 columns of panels. These
% defaults may be changed using 'Rows' and 'Cols' Variable-Value pairs.
%
% The default xlabel is the usetat field name. This may be changed by using
% a 'Xlbl' Variable-Value pair. The y-axis label is 'Cum Frac'
%
% xlimits and ylimits may be set by using the 'Xlm' and 'Ylm'
% Variable-Value pairs (specifying a 2D row vector for the Value, as in
% Matlab's xlim and ylim commands)
%
% Include 'Phase' among the varargin if you want the phase (aka Group or
% Condition) included in the panel titles
%
% If you want a handle or handle vector for the figure or figures created,
% then use the variable-value pair 'Handle', HANDLENAME. A variable with
% that name will appear in the base workspace and can be used to change or
% add figure properties

% Examples
%
% TSapplystat('','SwitchLatencies',@TSplotcdfs)   makes figure with 4 rows
% and 2 cols of plot panels. Each panel contains a cdfplot of the columns
% in the SwitchLatencies field, labeled with S (subject), s (session, if
% usestat field is at session level or lower), phase (if usestat field
% is at session level or lower) and trial (if usestat field is at Trial
% level
%
% TSapplystat('','SwitchLatencies',@TSplotcdfs,'FigRows',1,'FigCols',1,...
% 'Xlabel','Switch Latencies (s)')     makes only one panel per figure and
% labels the x axis 'Switch Latencies (s)'
%
% TSapplystat('','SwitchLatencies',@TSplotcdfs,'DataCols',1) makes figure
% with 4 rows and 2 cols of plot panels, but each panel plots only the
% first column of the SwitchLatencies field
%
% TSapplystat(''.{'Switch1' 'Switch2'},'DataCols',{[1 3] 2}) would plot the
% 1st and 3rd columns of the array in Switch1 and the 2nd col of the array
% in Switch2.
%
% Variable-Value pairs may be specified in any order

%% Determining the cells in varargin that contain the data passed in by
% TSapplystat

NC = evalin('caller','numel(dataargs)');
% number of arrays passed in as to-be plotted data; hence, the number of
% cells in varargin containing to-be-plotted data

dataargs = varargin(1:NC); % cell array containing data arrays from the
% the to-be-plotted fields whose contents were passed in by TSapplystat

%% Initializing (assigning default values)
Rows = 4;
Cols = 2;
DataCols = cell(1,NC); % initializing
for f = 1:NC % stepping through the data fields putting their column
    % numbers into the cells of DataCols. 
    DataCols{f} = 1:size(dataargs{f},2); % The default assumption is that
    % all columns of all fields passed in are to be plotted. This will be
    % overwritten if a DataCols variable-value pair is specified--see
    % Evaluating varargin
end
hndl=false; % don't put handle to figure in base workspace
Xlbl = evalin('caller','usestats{1}'); % default label for x axis;
Xlm = [];
Ylm = [];
Phase = false;
%% Evaluating varargin

if length(varargin) > NC % if there are additional arguments
    
    for c = NC+1:length(varargin) % stepping through the cells of varargin
        
        strng = varargin{c};
        
        if ischar(strng)
            switch  strng % returns the name of a variable
                case 'DataCols'
                    DataCols = varargin{c+1}; % cell array with vectors of
                    % data columns. This overwrites the above default value
                    % for DataCols
                    if numel(DataCols)~=numel(dataargs)
                        fprintf('\nInput error:\nNumber of cells in ''DataCols'' cell array does not\nmatch number of cells in usestats\n')
                        return
                    end
                    
                    for cc = 1:length(DataCols)
                        if isempty(DataCols{cc}) || (size(DataCols{cc},1)~=1)
                            fprintf('\nInput error:\nEach cell of ''DataCols'' must contain\na row vector of column indices\n')
                            return
                        end
                        
                        if max(DataCols{cc}) > size(dataargs{cc},2)
                            fprintf('\nInput error:\nCol # specified in Cell %d of ''DataCols''greater than # columns\nin corresponding field of usestats\n',c)
                            return
                        end
                    end    
                case 'Phase'    
                    Phase = true;
                case 'Rows'
                    Rows = varargin{c+1};
                case 'Cols'
                    Cols = varargin{c+1};
                case 'Xlbl'
                    Xlbl = varargin{c+1};
                    if ~ischar(Xlbl)
                        fprintf('\nInput error: Value for ''Xlbl'' must be string\n')
                        return
                    end
                case 'Xlm'
                    Xlm = varargin{c+1};
                    if ~all(size(Xlm)==[1 2]) || ~(Xlm(1)<Xlm(2))
                        fprintf('\nInput error:\n''Xlm'' must be 2D row vector\nwith 1st value < 2nd\n')
                        return
                    end
                    
                case 'Ylm'
                    Ylm = varargin{c+1};
                    if ~all(size(Ylm)==[1 2]) || ~(Ylm(1)<Ylm(2))
                        fprintf('\nInput error:\n''Ylm'' must be 2D row vector\nwith 1st value < 2nd\n')
                        return
                    end% of if ~all...
                    
                case 'Handle'
                    hndl = true;
                    hstr = varargin{c+1};
            end % of switch
        end % of if ischar
    end % of processing non-empty varargin        
end % if there are arguments in addition to the arrays from the usestat fields

%% Determining the figure count, row count, column count and plot counts        
% The counts are computed in this function but kept in the workspace of 
% TSapplystat (the 'caller')

FCount = evalin('caller','exist(''FCount'',''var'')'); % does the variable
% 'FCount' exist in the TSapplystat workspace

if ~FCount % if it does not exist, then this is the first call
    FCount = 1; % intialize figure count
    RCount = 1; % initialize row count
    CCount = 1; % initialize column count
    PltCount = 1; % initialize plot count
    figure; % open first figure
    HH = gcf;
else % it exists in caller workspace (this is not the first call)
    FCount = evalin('caller','FCount'); % get its value = # of figures
    RCount = evalin('caller','RCount'); % get value of row count
    CCount = evalin('caller','CCount'); % get value of the column count
    PltCount = evalin('caller','PltCount'); % get value of plot count
    HH = evalin('caller','Handle'); % get the handle vector
end

%% Determining level in Experiment hierarchy from which data come
if evalin('caller','isfield(Experiment,usestats{1})')  % data are in a field
    % or fields at the level of the Experiment
    
    Lev ='E';
    
elseif evalin('caller','isfield(Experiment.Subject,usestats{1})')
    % data are in a field or fields at the level of the Subjects
    
    S = evalin('caller','sub'); % gets subject index # from TSapplystat
    
    Lev = 'S';
    
elseif evalin('caller','isfield(Experiment.Subject(sub).Session,usestats{1})')
    
    S = evalin('caller','sub'); % gets subject index # from TSapplystat
    
    s = evalin('caller','ses'); % ditto for session #
    
    Lev = 's'; % data are in a field or fields at the level of the Sessions
    
elseif evalin('caller','isfield(Experiment.Subject(sub).Session(ses).(trialname).Trial,usestats{1})')
    % data are in a field or fields at the Trial level
    S = evalin('caller','sub'); % gets subject index # from TSapplystat
    
    s = evalin('caller','ses'); % ditto for session #
    
    TT = evalin('caller','trialname'); % ditto for trial type
    
    T = evalin('caller','tri'); % ditto for trial #
    
    Lev = 'T';
    
end % of finding level at which data to be plotted are found

%% Determining phase

if Phase && (strcmp(Lev,'s') || strcmp(Lev,'T'))
    P = evalin('caller','Experiment.Subject(sub).Session(ses).Phase');
elseif Phase % usestats come from Subject level
    sesnum = evalin('caller','Experiment.Info.ActiveSessions(1)'); % first of
    % the currently active sessions
    if ischar(sesnum)
        sesnum=1;
    end
    str = sprintf('Experiment.Subject(sub).Session(%d).Phase',sesnum);
    P = evalin('caller',str);
else
    P = [];
end
%% Checking for acceptable input

if ~isempty(DataCols) && numel(DataCols) ~= numel(dataargs)
    sprintf('\nDataCols cell array in varargin does not have\same number of cells as there are fields in usestats\n')
    return
end

OK = true;

for c = 1:length(dataargs)
    if isempty(dataargs{c})
        OK = false;
        switch Lev % display  supplemental information about source of error
            case 'E'
                sprintf('\nField %d in usestats is empty\n',c)
            case 'S'
                sprintf('\nFor S%d, Field %d is empty\n',S,c)
            case 's'
                sprintf('\nFor S%d,s%d, Field %d usestats is empty\n',S,s,c)
            case 'T'
                sprintf('\nFor S%d,s%d,TT%s,T%d, Field %d in usestats is empty\n',S,s,T)
        end % of switch

    elseif ~isempty(DataCols) && max(DataCols{c})>size(dataargs{c},2)
        OK = false;
        switch Lev % display  supplemental information about source of error
            case 'E'
                sprintf('\nDataCols{%d} specifies a Col #\n> than # cols in corresponding data array\n',c)
            case 'S'
                sprintf('\n For S%d, DataCols{%d} specifies a Col #\n> than # cols in corresponding data array\n',S,c)
            case 's'
                sprintf('\nFor S%d,s%d, DataCols{%d} specifies a Col #\n> than # cols in corresponding data array\n',S,s,c)
            case 'T'
                sprintf('\nFor S%d,s%d,TT%s,T%d, DataCols{%d} specifies a Col #\n> than # cols in corresponding data array\n',S,s,TT,T)
        end % of switch
    end % if unacceptable input detected    
end % of stepping through dataargs

if ~OK % plotting blank panel with text
    
    if RCount > Rows % if next row to be plotted is greater than # rows/figure
        RCount = 1;
        CCount = 1;
        PltCount = 1;
        FCount = FCount+1;
        figure; % open another figure
        HH(end+1) = gcf;
    end

    subplot(Rows,Cols,PltCount)
    text(.1,.5,'No data or unacceptable input')
    
%% Labeling panel when data could not be plotted
    if Rows<=4

        switch Lev

            case 'S'
                if Phase
                    title(sprintf('S%d,P%d',S,P))
                else
                    title(sprintf('S%d',S))
                end
            case 's'
                if Phase
                    title(sprintf('S%d,s%d,P%d',S,s,P))
                else
                    title(sprintf('S%d,s%d',S,s))
                end
            case 'T'
                if Phase
                    title(sprintf('S%d,s%d,P%d,TT%s,T%d',S,s,P,TT,T))
                else   
                    title(sprintf('S%d,s%d,TT%s,T%d',S,s,TT,T))
                end
        end    
    else % use text to label panels

        switch Lev

            case 'S'
                if Phase
                    text(.05,.9,sprintf('S%d,P%d',S,P))
                else
                    text(.05,.9,sprintf('S%d',S))
                end
            case 's'
                if Phase
                    text(.05,.9,sprintf('S%d,s%d,P%d',S,s,P))
                else
                    text(.05,.9,sprintf('S%d,s%d',S,s))
                end
            case 'T'
                if Phase
                    text(.05,.9,sprintf('S%d,s%d,P%d,TT%s,T%d',S,s,P,TT,T))
                else   
                    text(.05,.9,sprintf('S%d,s%d,TT%s,T%d',S,s,TT,T))
                end
        end
    end
 
    PltCount = PltCount+1;
    CCount = CCount + 1;
    
    if CCount > Cols
        CCount=1;
    end
    
    if Cols==1 || mod(PltCount,Cols)==1
        RCount = RCount+1;
    end
    
    assignin('caller','PltCount',PltCount); % update value in TSapplystat
    % workspace
    assignin('caller','RCount',RCount); % ditto
    assignin('caller','CCount',CCount); % ditto
    assignin('caller','FCount',FCount); % ditto
    asignin('caller','Handle',HH);
    % sets the user-provided handle to H
    if hndl % handle to figures to be placed in base workspace
        cmd=sprintf('assignin(''base'',''%s'',HH)',hstr);
        eval(cmd) % execute
    end
    return
end % of plotting blank panel

%% Creating subpanel with plot(s)

if RCount > Rows % if next row to be plotted is greater than # rows/figure
    RCount = 1;
    CCount = 1;
    PltCount = 1;
    FCount = FCount+1;
    figure; % open another figure
    HH(end+1)=gcf;
end

subplot(Rows,Cols,PltCount)

p = 1; % initializing count of plots made

for C = 1:length(dataargs) % stepping through the cells
    
    for cl = DataCols{C} % stepping through the to-be-plotted columns in each cell
        try 
            H = cdfplot(dataargs{C}(:,cl)); % stepping through to-be-plotted columns

            hold on

            set(H,'LineWidth',2)
            set(gca,'FontSize',12)
            title('')

            switch mod(p,5) % plot color sequence
                case 1
                    set(H,'Color','k')
                case 2
                    set(H,'Color','r')
                case 3
                    set(H,'Color','g')
                case 4
                    set(H,'Color','b')
                case 0
                    set(H,'Color','y')
            end % setting color of plot
        catch
            text(.05,.5,'Data Error')
        end
        p = p+1;

    end % stepping through cols within a cell
            
end % of stepping through cells of dataargs

if isempty(Xlm)
    Xlm = xlim;
else
    xlim(Xlm)
end
    
if isempty(Ylm)
    Ylm = ylim;
else
    ylim(Ylm)
end

%% Labeling panel
if Rows<=4 % use title
    switch Lev        
        case 'S'
            if Phase
                title(sprintf('S%d,P%d',S,P))
            else
                title(sprintf('S%d',S))
            end
        case 's'
            if Phase
                title(sprintf('S%d,s%d,P%d',S,s,P))
            else
                title(sprintf('S%d,s%d',S,s))
            end
        case 'T'
            if Phase
                title(sprintf('S%d,s%d,P%d,TT%s,T%d',S,s,P,TT,T))
            else   
                title(sprintf('S%d,s%d,TT%s,T%d',S,s,TT,T))
            end
    end % of switch   
else % more than 4 rows: don't use title; use text statement inside panel    
    switch Lev        
        case 'S'
            if Phase
                text(.05,.9,sprintf('S%d,P%d',S,P))
            else
                text(.05,.9,sprintf('S%d',S))
            end
        case 's'
            if Phase
                text(.05,.9,sprintf('S%d,s%d,P%d',S,s,P))
            else
                text(.05,.9,sprintf('S%d,s%d',S,s))
            end
        case 'T'
            if Phase
                text(.05,.9,sprintf('S%d,s%d,P%d,TT%s,T%d',S,s,P,TT,T))
            else   
                text(.05,.9,sprintf('S%d,s%d,TT%s,T%d',S,s,TT,T))
            end
    end % of switch
end % labeling panels

%% Axis labels

if CCount==1;ylabel('Cum Fraction');else ylabel('');end

if Rows <= 4
    xlabel(Xlbl)    
else
    if RCount > Rows-1
        xlabel(Xlbl)
    else
        xlabel('')
    end
end

%% Incrementing counts
PltCount = PltCount+1;

CCount = CCount + 1;

if CCount > Cols
    CCount=1;
end

if Cols==1 || mod(PltCount,Cols)==1
    RCount = RCount+1;
end

%% Putting counts in TSapplystat's workspace
assignin('caller','PltCount',PltCount); % update value in TSapplystat
% workspace
assignin('caller','RCount',RCount); % ditto
assignin('caller','CCount',CCount); % ditto
assignin('caller','FCount',FCount); % ditto
assignin('caller','Handle',HH); % ditto
if hndl % handle to figures to be placed in base workspace
    cmd=sprintf('assignin(''base'',''%s'',HH)',hstr);
    eval(cmd) % execute
end
