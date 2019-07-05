function TSplot(varargin)
% Graphics helper function for TSapplystat. MUST BE CALLED BY TSAPPLYSTAT!!
% Uses Matlab's plot function. Makes multiple plots (panels) per figure
% and labels them with Subject, or Subject & Session, or Subject, Session &
% Trial and/or Phase. Makes both line and scatter plots and allows more
% than one variable to be plotted on each panel.
%
% Syntax: TSapplystat('',usestats,@TSplot,varargin)
%
% usestats is the name of one or more fields in the Experiment structure
% containing the data to be plotted. When the data come from two different
% fields, usestats is a 2-cell cell array with one field name in each cell.
% The data from these fields are passed in in the first one or more cells
% of varargin. The number of varargin cells occupied by these data arrays
% is equal to the number of fields specified in usestats. WHEN THE DATA
% COME FROM MORE THAN ONE FIELD, THEY ARE CONCATENATED TO FORM A SINGLE
% ARRAY PRIOR TO PLOTTING. THEREFORE, THE ARRAYS IN THE DIFFERENT FIELDS
% MUST BE EITHER HORIZONTALLY CONCATENABLE (SAME # OF ROWS) OR VERTICALLY
% CONCATENABLE (SAME # OF COLUMNS)
%
% The varargin are, with one exception Variable-Value pairs specifying any 
% or all of the following:
%    - labels for the x- and y-axes ('Xlbl' & 'Ylbl')
%    - which columns are which ('Xcol' & 'Ycol')
%    - the number of rows and columns of panels on one figure ('Rows' &
%      'Cols')
%    - limiting values for the data rows to be plotted ('FrstRow' &
%       'LstRow')
%    - the x-axis & y-axis limits, 'Xlm' & 'Ylm'
%    - symbols for scatter plots ('Scat')
%    - The axes into which the plot is to be made ['Ax' + an axis handle
%        from, for example, and H=sublot(R,C,P) command
%    - Phase (the only singleton argument) to indicate that the phase (aka
%       Condition or Group) is to be included in the panel labels
%    - 'Ax' indicates that the next argument is the handle to an axes, into
%        which the plot is to be made
%
% The default figure layout is 4 rows by 2 columns of panels.
%
% When usestat is a single field name, the x- and y-axes are not labeled
% unless the 'Xlbl' and 'Ylbl' Variable-Value pairs are specified after the
% call to @TSplot in the input arguments to TSapplystat
%
% When the usestats field(s) is/are at the Subject level, each panel is
% labeled with 'S#', where # is the subject's index number. When the field(s)
% is/are at the Session level, each panel is labeled with 'S#,s#',
% where 's#' is the session number. When the field)s) is/are at the Trial
% level, each panel is labeled with 'S#,s#,T#'
%
% To have Phase information (aka Condition or Group) included in
% the panel labels, include 'Phase' among the input arguments. If the usestat
% field(s) is/are at the Session level or Trial level, the Phase information
% is taken from the Phase field of the session from which the data came. If
% the usestat field(s) is/are at the Subject level, then the phase
% information is taken from the Phase field of the first of the currently
% active sessions
%
% Variable-value pairs may be specified in any order and 'Phase' may appear
% anywhere in the sequence of input arguments, provided only that it does 
% NOT appear BETWEEN a variable and its value
%
% 'Xcol" and 'Ycol' may appear more than once, in which case the column
% specified by the first occurrence of the Ycol Variable-Value pair is
% plotted against the column specified by the first occurrence of the Xcol
% pair, and so on for each successive pair of Variable-Value pairs, with
% the multiple plots appearing on the same panels, as when one wants to
% compare, for example, data from two Groups/Conditions/Phases. The column
% numbers in these Variable-Value pairs (that is, the "values") must be
% those of the array formed by horizontally concatenating the arrays passed
% in as data
%
% The Xlm and Ylm Variable-Value pairs require for their values the same 2D
% vectors required by Matlab's xlim and ylim commands (1st values specifies
% lower limit of axis, 2nd value the upper limit)
%
% The default plots are line plots (without markers on the data points). If
% scatter plots are desired instead (markers for the data points, but no
% lines connecting them), the Variable-Value pair is 'Scat' followed by a
% string containing as many of Matlab's one-character marker symbols as
% there are data sets to be plotted on any single panel.
%
% Examples
%
%   TSapplystat('',usestat,@TSplot)  plots the data in the 2nd column of the
%   usestat field against the data in the 1st column. No axis labels
%
%   TSapplystat('',{usestat1 usestat2},@TSplot)  plots the data in the 1st
%   column of usestat1 against the data in the first column of usestat2. Axis
%   labels are the respective field names
%
%   TSapplystat('',{usestat1 usestat2},@TSplot,'Xlbl','Days','Ylbl','Weight'...
%    'Rows',6,'Cols,3,'Xcol',2,'Ycol',5,'Phase')  horizontally concatenates the
%   data arrays in usestat1 and usestat2 and plots Column 5 of the resulting
%   array against Column 2, labels the x-axis 'Days' and the y-axis 'Weight',
%   makes 6 rows and 3 columns of panels on each figure and includes the
%   Phase (Condition, Group) number in the panel labels
%
%   TSapplystat('',{usestat1 usestat2},@TSplot,'Xcol',1,'Ycol',2,'Xcol',3,'Ycol',4,'Rows',1,'Cols',1)
%   two plots on a single panel with only one panel in the figure--the
%   arrangement when data are at the Experiment level and one wants to
%   compare two conditions. Example assumes that there are two fields at
%   the Experiment level, each containing x-data in a 1st column and
%   y-data in a 2nd column
%
%   TSapplystat('',{usestat1 usestat2},@TSplot,'Xcol',1,'Ycol',2, ...
%      'Xcol',3,'Ycol',4,'Rows',1,'Cols',1,'Scat','*o')
%   makes a single-panel figure with two scatter plots, with the data from
%   the first data set marked with black asterisks and the data from the 
%   second with red open circles. (Matlab varies the color sequence in a
%   manner described by Matlab's plot command, which, is called by this TS
%   function.)


NC = evalin('caller','numel(dataargs)');
% number of arrays passed in as to-be plotted data; hence, the number of
% cells in varargin containing to-be-plotted data. dataargs is a cell array
% variable in the TSapplystat workspace. It has as the same number of cells
% as the number of input fields that the user specified in the usestat
% argument of TSapplystat

dataargs = varargin(1:NC); % cell array containing data arrays from the
% the to-be-plotted fields whose contents were passed in by TSapplystat

%% Initializing
Rows = 4;
Cols = 2;
Xcol = [];
Ycol = [];
Xlbl = '';
Ylbl = '';
Phase = false;
Xlm = [];
Ylm = [];
Scat = false;
Ax = [];
NoXcol = false;
FrstRow = 1;
LstRow = size(dataargs{1},1);
%% Evaluating varargin
% the cells after the data-containing cells contain variable-value pairs
if length(varargin) > NC % if there are additional arguments
    
    for c = NC+1:length(varargin) % stepping through the cells of varargin
        
        strng = varargin{c};
        
        if ischar(strng)

            switch  strng % returns the name of a variable
                case 'Xcol' % specifying which columns of data are to be
                    % treated as x-axis values
                    if ~isempty(varargin{c+1})
                        Xcol(end+1) = varargin{c+1}; % vector of x columns
                    else
                        NoXcol = true;
                    end

                case 'Ycol' % specifying which columns of data are to be
                    % treated as y-axis values
                    Ycol(end+1) = varargin{c+1}; % vector of y columns

                case 'Phase' % put Phase into titles on panels. This is NOT
                    % a variable-value pair
                    Phase = true;

                case 'Rows' % # of rows of panels on each figure
                    Rows = varargin{c+1};

                case 'Cols'  % # of columns of panels on each figure
                    Cols = varargin{c+1};

                case 'Xlbl' % label for x axis
                    Xlbl = varargin{c+1};
                    if ~ischar(Xlbl)
                        fprintf('\nInput error:\nValue for ''Xlbl'' must be string\n')
                        return
                    end

                case 'Ylbl' % label for y axes
                    Ylbl = varargin{c+1};
                    if ~ischar(Ylbl)
                        fprintf('\nInput error:\nValue for ''Ylbl'' must be string\n')
                        return
                    end
                case 'Xlm' % limits on x axis
                    Xlm = varargin{c+1};
                    if ~all(size(Xlm)==[1 2]) || ~(Xlm(1)<Xlm(2))
                        fprintf('\nInput err(or:\n''Xlm'' must be 2D row vector\nwith 1st value < 2nd\n')
                        return
                    end
                case 'Ylm' % limits on y axis
                    Ylm = varargin{c+1};
                    if ~all(size(Ylm)==[1 2]) || ~(Ylm(1)<Ylm(2))
                        fprintf('\nInput error:\n''Ylm'' must be 2D row vector\nwith 1st value < 2nd\n')
                        return
                    end
                case 'Scat' % scatter plot rather than line plot; the value
                    % of this variable specifies the marker symbol
                    Scat = true;
                    Symbs = varargin{c+1};
                    if ~iscell(Symbs)
                        Symbs = {Symbs};
                    end
                case 'Ax' % handle on already existing axes into which plot
                    % is to be made
                    Ax = varargin{c+1};
                case 'FrstRow'
                    FrstRow = varargin{c+1};
                case 'LstRow'
                    LstRow = varargin{c+1};
            end % of switch
            
        end % of if ischar
    end % of processing non-empty varargin
    
    if (~isempty(Xcol)&&~isempty(Ycol)) && (~all(size(Xcol) == size(Ycol)))
        fprintf('\nInput error:\n''Xcol'' & ''Ycol'' vectors must be same size\n')
        return
    end
end

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
else % it exists in caller workspace (this is not the first call)
    FCount = evalin('caller','FCount'); % get its value = # of figures
    RCount = evalin('caller','RCount'); % get value of row count
    CCount = evalin('caller','CCount'); % get value of the column count
    PltCount = evalin('caller','PltCount'); % get value of plot count
end

%% Determining level in Experiment hierarchy from which data come

if evalin('caller','isfield(Experiment,usestats{1})')  % data are in a field
    % or fields at the level of the Experiment. usestats is a cell array
    % variable in the TSapplystat workspace
    
    Lev ='E';
        
    
elseif evalin('caller','isfield(Experiment.Subject,usestats{1})')
    % data are in a field or fields at the level of the Subjects
    
    S = evalin('caller','sub'); % gets subject index # from TSapplystat
    
    Lev = 'S';
    
elseif evalin('caller','isfield(Experiment.Subject(sub).Session,usestats{1})')
    
    S = evalin('caller','sub'); % gets subject index # from TSapplystat
    
    s = evalin('caller','ses'); % ditto for session #
    
    Lev = 's'; % data are in a field or fields at the level of the Sessions
    
elseif evalin('caller','isfield(Experiment.Subject(sub).Session(ses).(trialname),usestats{1})')
    % data are in a field or fields at the Trial level
    S = evalin('caller','sub'); % gets subject index # from TSapplystat
    
    s = evalin('caller','ses'); % ditto for session #
    
    T = evalin('caller','tri'); % ditto for trial #
    
    Lev = 'T';
    
    TT = evalin('caller','Experiment.Info.ActiveTrialType');
    
end % of finding level at which data to be plotted are found

%% Determining phase (=experimental condition),which is only specified at
% the Session level in a field named Phase

if Phase && strcmp(Lev,'s') || strcmp(Lev,'T')
    P = evalin('caller','Experiment.Subject(sub).Session(ses).Phase');
elseif Phase % usestats come from Subject level. In that case, we assume
    % that the subject was in the same condition in every session, or at
    % least in every currently active session. So we will look for the
    % phase info in the first of the currently active sessions
    sesnum = evalin('caller','Experiment.Info.ActiveSessions(1)'); % first of
    % the currently active sessions
    if ischar(sesnum);sesnum=1;end
    str = sprintf('Experiment.Subject(sub).Session(%d).Phase',sesnum);
    P = evalin('caller',str);
else
    P = [];
end

%% Checking acceptability of input

OK = true;
for c = 1:length(dataargs) % stepping through the cells of dataargs, which 
    % SHOULD (but may not) contain data
    if isempty(dataargs{c}) % cell with no data
        str = sprintf('usestats{%d};',c); % build string for evalin
        FldName = evalin('caller',str); % get from TSapplystat workspace the
        % name of the empty fields
        
        switch Lev % display  supplemental information about source of error
            % To make appropriate error report, we need to know which level
            % of hierachy the data came from
            case 'E' % they came from Experiment level
                sprintf('\n\nusestats field %s is empty\n',FldName)
            case 'S' % Subject level
                sprintf('For S%d, usestats field %s is empty',S,FldName)
            case 's' % Session level
                sprintf('For S%d,s%d, usestats field %s is empty',S,s,FldName)
            case 'T' % Trial level
                sprintf('For S%d,s%d,T%d, usestats field %s is empty',S,s,T,FldName)
        end
        OK = false; % data input not okay
    end
end

try % if data come from different fields, the arrays may not have the same
    % number of rows, in which case, horizontally concatenating them will
    % fail
    if size(dataargs{1},1)<size(dataargs{1},2) % more columns than rows, so
        % assume data are in row vector rather than column vectors
        D = vertcat(dataargs{:})'; % vertically concatenate & transpose
        % contents of the cell array
    else
        D = [dataargs{:}]; % horizontally concatenating the arrays in the cells
        % of dataargs. This only works if the arrays all have same # rows
    end
    
catch ME % error message generated when concatenation fails
    disp(getReport(ME)) % display error message
    switch Lev % display  supplemental information about source of error
        case 'E'
            sprintf('The arrays in the Experiment level fields specified\nin usestats cannot be horizontally concatenated')
        case 'S'
            sprintf('For S%d, the arrays in the fields specified\nin usestats cannot by horizontally concatenated',S)
        case 's'
            sprintf('For S%d,s%d, the arrays in the fields specified\nin usestats cannot by horizontally concatenated',S,s)
        case 'T'
            sprintf('For S%d,s%d,T%d, the arrays in the fields specified\nin usestats cannot by horizontally concatenated',S,s,T)
    end
    
    OK = false; % data input not okay
end

if ~OK % plotting blank panel with text
    
    if RCount > Rows % if next row to be plotted is greater than # rows/figure
        RCount = 1;
        CCount = 1;
        PltCount = 1;
        FCount = FCount+1;
        figure; % open another figure
    end
    
    if ~isempty(Ax)
        axes(Ax)
    else
        subplot(Rows,Cols,PltCount)
    end

    text(.1,.5,'No or unplottable data')
    
    % Labeling panel when data cannot be plotted, so user knows where the 
    % problem data are
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
                    title(sprintf('S%d,s%d,P%d,T%d',S,s,P,T))
                else   
                    title(sprintf('S%d,s%d,T%d',S,s,T))
                end
        end    
    else

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
                    text(.05,.9,sprintf('S%d,s%d,P%d,T%d',S,s,P,T))
                else   
                    text(.05,.9,sprintf('S%d,s%d,T%d',S,s,T))
                end
        end
    end % if Rows <4
 
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
    
    return
end

if isempty(Xlbl) && NC==2 % No axes labels specified & 2 arrays passed in

    Xlbl = evalin('caller','usestats{1}'); % default label for x axis
    Ylbl = evalin('caller','usestats{2}'); % default label for y axis
end


%% Has end of current figure been reached?

if RCount > Rows % if next row to be plotted is greater than # rows/figure
    RCount = 1;
    CCount = 1;
    PltCount = 1;
    FCount = FCount+1;
    figure; % open another figure
end

if ~isempty(Ax)
    axes(Ax)
else
    subplot(Rows,Cols,PltCount)
end
    
if ~NoXcol && isempty(Xcol) && (size(D,2)==2)
    Xcol = 1;
    Ycol = 2;
end

if size(D,2)<2 || (~isempty(Ycol) && isempty(Xcol)) % Only one data vector,
    % so plot(Y)
    if Scat
        plot(D(FrstRow:LstRow),Symbs{1})
    else
    
       plot(D(FrstRow:LstRow))
    end
    
elseif length(Xcol)<2 % only one plot per panel
    
    if Scat % scatter plot
        str = ['plot(D(FrstRow:LstRow,' num2str(Xcol(1)) '),D(FrstRow:LstRow,' num2str(Ycol(1)) '),''' Symbs{1} ''')'];
        % building string to be fed to eval. This string has to be a valid
        % plot command. 
        eval(str)
    else % line plot  
        plot(D(FrstRow:LstRow,Xcol),D(FrstRow:LstRow,Ycol))
    end
    
    if ~isempty(Ax) % will further plots be made into the same axes?
        hold on % turn hold on so that next plot into these axes does not
        % erase plot just made
    end
    
    if all(isnan(D(FrstRow:LstRow,Xcol))) || all(isnan(D(FrstRow:LstRow,Ycol)))
        text(.05,.5,'One or both all NaNs')
    end
    
else % more than one plot per panel
    
    if Scat % scatter plots
        str = ['D(:,' num2str(Xcol(1)) '),D(:,' num2str(Ycol(1)) '),''' Symbs{1} ''''];

        for st = 2:length(Xcol) % building plot string
            str = [str ',D(FrstRow:LstRow,' num2str(Xcol(st)) '),D(FrstRow:LstRow,' num2str(Ycol(st)) '),''' Symbs{st} ''''];
        end
       
    else % default line plots
        str = ['D(FrstRow:LstRow,' num2str(Xcol(1)) '),D(FrstRow:LstRow,' num2str(Ycol(1)) ')'];

        for st = 2:length(Xcol) % build plot string
            str = [str ',D(FrstRow:LstRow,' num2str(Xcol(st)) '),D(FrstRow:LstRow,' num2str(Ycol(st)) ')'];
        end
        
    end % if scatter plot or line plot (building argument string)
    
    str = ['plot(' str ')']; % complete the string 

    eval(str) % evaluate the string, i.e., call Matlab's plot function
     
    if ~isempty(Ax)
        hold on
    end
end

if isempty(Xlm) && isempty(Ylm)
    axis tight
end

if ~isempty(Xlm)
    if (size(Xlm,2)==2) && Xlm(1)<Xlm(2)
        xlim(Xlm)
    else
        disp('Xlm not properly specified')
    end
end

if ~isempty(Ylm)
    if (size(Ylm,2)==2) && Ylm(1)<Ylm(2)
        ylim(Ylm)
    else
        disp('Ylm not properly specified')
    end
end

title('') % initializing (default is no title)

xlabel('') % ditto
    
Xlm = xlim; % for later use

Ylm = ylim; % for later use

if CCount==1;ylabel(Ylbl);else ylabel('');end

if Rows<=4 % labeling panel
    
    switch Lev
        
        case 'S'
            if Phase
                title(sprintf('S%d,P%d',S,P)) % subject index # and Phase #
                % (
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
                title(sprintf('S%d,s%d,P%d,T%d',S,s,P,T))
            else   
                title(sprintf('S%d,s%d,T%d',S,s,T))
            end
    end    
else
    switch Lev % labeling panel
        case 'S'
            if Phase
                text(Xlm(1)+.05*(Xlm(2)-Xlm(1)),Ylm(1)+.9*(Ylm(2)-Ylm(1)),sprintf('S%d,P%d',S,P))
            else
                text(Xlm(1)+.05*(Xlm(2)-Xlm(1)),Ylm(1)+.9*(Ylm(2)-Ylm(1)),sprintf('S%d',S))
            end
        case 's'
            if Phase
                text(Xlm(1)+.05*(Xlm(2)-Xlm(1)),Ylm(1)+.9*(Ylm(2)-Ylm(1)),sprintf('S%d,s%d,P%d',S,s,P))
            else
                text(Xlm(1)+.05*(Xlm(2)-Xlm(1)),Ylm(1)+.9*(Ylm(2)-Ylm(1)),sprintf('S%d,s%d',S,s))
            end
        case 'T'
            
            if Phase
                text(Xlm(1)+.05*(Xlm(2)-Xlm(1)),Ylm(1)+.9*(Ylm(2)-Ylm(1)),sprintf('S%d,s%d,P%d,TT%s,T%d',S,s,P,TT,T))
            else
                text(Xlm(1)+.05*(Xlm(2)-Xlm(1)),Ylm(1)+.9*(Ylm(2)-Ylm(1)),sprintf('S%d,s%d,TT%s,T%d',S,s,TT,T))
            end
    end
end

%% Adding label to x-axis
if Rows <= 4
    xlabel(Xlbl)    
else
    Yoffset = .04*Rows; % Don't use xlabel to add label to x-axis
    %  when there are more than 4 rows because it radically shrinks the
    % y-extent of ALL the plot panels

    text(Xlm(1)+.2*(Xlm(2)-Xlm(1)),Ylm(1)-Yoffset*(Ylm(2)-Ylm(1)),Xlbl) % adding xlabels
end

%% Updating counts (in TSapplystat workspace)
if isempty(Ax)
    PltCount = PltCount+1; % updating plot count

    CCount = CCount + 1; % updating column count

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
end
