function TSplotcumrecs(varargin)
% Graphics helper function for TSapplystat. MUST BE CALLED BY TSAPPLYSTAT!
% Plots one or more cumulative records per panel. If more than one, then
% they must be against a common x axis and against either one or two
% ordinates (left and right y axes, using Matlab's plotyy command). When
% the data in a column are strictly ascending, they are plotted against the
% x axis, on the assumption that they are successive event times. The event
% count (1 2 3 4 etc) is plotted against the left axis. When the data are
% not strictly ascending, their cumsum is plotted against the left axis and
% the trial count is plotted against the x-axis, on the assumption that the
% data come from measures made on successive trials. The sole exception to
% this rule is when XY=0, which indicates that 2 cols of data are to be
% plotted against one another, in which case, the 2nd column is plotted
% against the first (after cumsumming if they are not strictly increasing)
% 
%
% Syntax: TSapplystat('',usestat',@TSplotcumrecs,varargin)
%
% The recognized varargin are:
%  'Dcols' 'XY' 'Xlbl' 'LeftYlbl' 'RightYlbl' 'Rows' 'Cols'
%  'LeftYlm' 'RigthYlm'  'Phase'
%
% All of the varargin are Variable-Value pairs except 'Phase'.
%
%   When not all of the columns in every field of usestat are to be plotted
%   (the default), then the value of the 'Dcols' variable must be a cell
%   array with the same number of cells as the usestat array, each cell
%   containing a row vector of the index numbers of of the to-be-plotted
%   columns in the corresponding field of the usestats cell array.
%
%   The value of the 'XY' variable specifies how the data are to be plotted
%   when there are two and only two columns to be plotted. The default
%   value (when 'XY' does not appear in the varargin) is 1, in which case
%   the data are both plotted against the x axis when they are strictly
%   ascending or their cumsums are plotted against the y axis if they are
%   not. In either case, the count vectors (1 2 3 4 ... length(D)) are
%   plotted against the other axis. If the value of 'XY' is 2, then
%   Matlab's plotyy function is used as follows: If the data in both
%   columns are not strictly ascending, the cumsum of the 1st column is
%   plotted against the left y axis and the cumsum of the 2nd against the
%   right y axis, with the corresponding count vectors plotted against the
%   x axis. If the data in both columns are strictly ascending, then the
%   they are both plotted against the x axis, with the corresponding count
%   vectors being plotted against the left and right y axes. If one data
%   column is strictly ascending and the other not, the plot is blank       
%
%   'Xlbl', [string] specifies label for x axis
%   'LeftYlbl',[string] specifies label for left y axis on yy plots
%   'RightYlbl',[string] specifies label for right y axis on yy plots
%   'Xlm', [2D row vector] specifies limits on x axis
%   'LeftYlm', [2D row vector] specifies limits on left y axis
%   'RightYlm', [2D row vector] specifies limits on right y axis
%   'Rows' [integers 1 to max of 10] specifies number of rows of
%       subplots on one figure. Default = 4
%   'Cols' [integers 1 to max of 5] specifies number of columns of
%       subplots on one figure. Default = 2
%   'Phase' if included in varargin, sets Phase to true, so that the phase
%   (aka Group or Condition) is included in the labeling of the panels
%
% The default figure layout is 4 rows by 2 columns of panels. These
% defaults may be changed using 'Rows' and 'Cols' Variable-Value pairs.
%
% Variable-Value pairs may be specified in any order, but the specification
% of the value must always follow the variable immediately in the sequence
% of comma separated arguments in varargin

NC = evalin('caller','numel(dataargs)');
% number of arrays passed in as to-be plotted data; hence, the number of
% cells in varargin containing to-be-plotted data

dataargs = varargin(1:NC); % cell array containing data arrays from the
% the to-be-plotted fields whose contents were passed in by TSapplystat

%% Initializing
Rows = 4;
Cols = 2;
Dcols = [];
XY = 1;
Xlbl = evalin('caller','usestats{1}'); % default label for x axis
LeftYlbl = '';
RightYlbl = '';
Phase = false;
Xlm = [];
LeftYlm = [];
RightYlm = [];
%% Evaluating varargin

if length(varargin) > NC % if there are additional arguments
    
    for c = NC+1:length(varargin) % stepping through the cells of varargin
        
        strng = varargin{c};
        
        if ischar(strng)
        
            switch  strng % returns the name of a varargin variable
                case 'Dcols'
                    if iscell(varargin{c+1})
                        Dcols = varargin{c+1}; % cell array, each cell of
                        % which contains row vector of column #s
                    else
                        Dcols = {varargin{c+1}};
                    end
                    
                    if numel(Dcols)~=numel(dataargs)
                        fprintf('\nInput error:\nNumber of cells in ''Dcols'' cell array does not\nmatch number of cells in usestats\n')
                        return
                    end
                    
                    for cc = 1:length(Dcols)
                        if isempty(Dcols{cc}) || (size(Dcols{cc},1)~=1)
                            fprintf('\n\nInput error:\nEach cell of ''Dcols'' must contain\na row vector of column indices\n')
                            return
                        end
                        
                        if max(Dcols{cc}) > size(dataargs{cc},2)
                            fprintf('\n\nInput error:\nCol # specified in Cell %d of ''Dcols''greater than # columns\nin corresponding field of usestats\n',c)
                            return
                        end
                    end                    
                    
                case 'XY'
                    XY = varargin{c+1};
                    
                    if ~ismember(XY,[0 1 2]) % improper value for XY
                        fprintf('\n\nInput error:\nValue for ''XY'' must be one of the integers from 0 to 2\n')
                         return
                    end
                                     
                    if any([numel(dataargs)>2 ... % more than two usestat fields passed in
                            (numel(dataargs)==1 && size(dataargs{1},2)~=2) ... % only 1 field passed in but it has > 2 cols
                            (numel(dataargs)==2 && ((size(dataargs{1},2)+size(dataargs{2},2))~=2)) ... % 2 fields passed in and their combined column # > 2
                            (numel(dataargs)==2 && length(dataargs{1})~=length(dataargs{2}))]) % 2 fields passed in but of differing lengths
                        str = ['\n\nInput Error:\nWhen XY=0,' ...
                        'there must be 2 and only 2 columns of data\n' ...
                        'passed in from the usestat field(s), and they must be the\n' ...
                        'same length in order to be plotted one against the other.\n'];
                        fprintf(str)
                        return
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
                        fprintf('\nInput error:\nValue for ''Xlbl'' must be string\n')
                        return
                    end

                case 'LeftYlbl'
                    LeftYlbl = varargin{c+1};
                    if ~ischar(LeftYlbl)
                        fprintf('\nInput error:\nValue for ''LeftYlbl'' must be string\n')
                        return
                    end
                    
                case 'RightYlbl'
                    RightYlbl = varargin{c+1};
                    if ~ischar(RightYlbl)
                        fprintf('\nInput error:\nValue for ''RightYlbl'' must be string\n')
                        return
                    end
                    
                case 'Xlm'
                    Xlm = varargin{c+1};
                    if ~all(size(Xlm)==[1 2]) || ~(Xlm(1)<Xlm(2))
                        fprintf('\nInput error:\n''Xlm'' must be 2D row vector\nwith 1st value < 2nd\n')
                        return
                    end
                    
                case 'LeftYlm'
                    LeftYlm = varargin{c+1};
                    if ~all(size(LeftYlm)==[1 2]) || ~(LeftYlm(1)<LeftYlm(2))
                        fprintf('\nInput error:\n''LeftYlm'' must be 2D row vector\nwith 1st value < 2nd\n')
                        return
                    end
                    
                case 'RightYlm'
                    RightYlm = varargin{c+1};
                    if ~all(size(RightYlm)==[1 2]) || ~(RightYlm(1)<RightYlm(2))
                        fprintf('\nInput error:\n''RightYlm'' must be 2D row vector\nwith 1st value < 2nd\n')
                        return
                    end
            end % of switch
        end % if cell of varargin is a string
    end % of processing varargin
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
    
elseif evalin('caller','isfield(Experiment.Subject(sub).Session(ses).(trialname),usestats{1})')
    % data are in a field or fields at the Trial level
    S = evalin('caller','sub'); % gets subject index # from TSapplystat
    
    s = evalin('caller','ses'); % ditto for session #
    
    T = evalin('caller','tri'); % ditto for trial #
    
    Lev = 'T';
    
    TT = evalin('caller','Experiment.Info.ActiveTrialType');
    
end % of finding level at which data to be plotted are found

%% Determining phase

if Phase && strcmp(Lev,'s') || strcmp(Lev,'T')
    P = evalin('caller','Experiment.Subject(sub).Session(ses).Phase');
elseif Phase % usestats come from Subject level
    sesnum = evalin('caller','Experiment.Info.ActiveSessions(1)'); % first of
    % the currently active sessions
    str = sprintf('Experiment.Subject(sub).Session(%d).Phase',sesnum);
    P = evalin('caller',str);
else
    P = [];
end

%% Creating cell array with one to-be-plotted data column per cell

Ldataargs = length(dataargs); % number of fields passed in

Dcell = cell(1,0);

if isempty(Dcols) % data columns not specified in the call; ergo all
    % columns of all fields
    for c1 = 1:Ldataargs % stepping through the fields
        for c2 = 1:size(dataargs{c1},2) % stepping through the columns in a field
            Dcell{end+1} = dataargs{c1}(:,c2);
        end
    end
else % Dcols are specified  
        
    for c1 = 1:Ldataargs            
        for c2 = Dcols{c1} % stepping through the row of column indices
            Dcell{end+1} = dataargs{c1}(:,c2);
        end % stepping through specified columns within a field
    end % stepping through the fields
end

NDcols = length(Dcell); % # of data columns to be plotted

%% Checking for acceptability: all data columns must be either strictly
% ascending or all not

A = true(1,NDcols); % logical row vector w same dimension as NDcols
for c3 = 1:NDcols % stepping through the cell array of data columns
    A(c3) = all(diff(Dcell{c3})>0); % strictly increasing data in that cell
end

if all(A) % all data strictly increasing
   Xax = true;  % all data columns to be plotted against x axis
elseif all(~A) % all data columns to be cumsummed & plotted against y axis
   Xax = false;
else % inconsistent data
    switch Lev
    case 'S'
        fprintf('\nFor S%d, some data stricty ascending, some not\n',S)
    case 's'
        fprintf('\nFor S%d,s%d, some data stricty ascending, some not\n',S,s)
    case 'T'
        fprintf('\nFor S%d,s%d,T%d, some data stricty ascending, some not\n',S,s,T)
    end
    return
end

%% Checking if new figure required

if RCount > Rows % if next row to be plotted is greater than # rows/figure
    RCount = 1;
    CCount = 1;
    PltCount = 1;
    FCount = FCount+1;
    figure; % open another figure
end
                
%% Making subplot
 
subplot(Rows,Cols,PltCount)

switch NDcols
    
    case 1 % only 1 data column to be plotted
        Count = 1:length(Dcell{1}); % vector of succesive positive integers
  
        if Xax % data strictly increasing
            stairs(Dcell{1},Count)

        else % data not strictly increasing
            stairs(Count,cumsum(Dcell{1}))
            
        end % of data strictly increasing or not
        
         if ~isempty(LeftYlbl)
             ylabel(LeftYlbl)
        
         end
    case 2 % only 2 data columns to be plotted
        Count1 = 1:length(Dcell{1}); % vector of counts for 1st data col
        Count2 = 1:length(Dcell{2}); % vector of counts for 2nd data col
        
        switch XY
            case 1 % only 1 y axis
 
                if Xax % both strictly increasing
                    
                    stairs(Dcell{1},Count1)
                    hold on
                    stairs(Dcell{2},Count2,'r')
                    
                else % both not strictly increasing
                    
                    stairs(Count1,cumsum(Dcell{1}))
                    hold on
                    stairs(Count2,cumsum(Dcell{2}),'r')
                    
                end                    
                
            case 2 % yy plot requested (2 y axes)
                
                if Xax % both strictly increasing
                    
                    Ax = plotyy(Dcell{1},Count1,Dcell{2},Count2,@stairs);

                else % both not strictly increasing

                    Ax = plotyy(Count1,cumsum(Dcell{1}),Count2,cumsum(Dcell{2}),@stairs);
                end
               
            case 0 % to be plotted one against the other
                
                if Xax % both strictly increasing
                    stairs(Dcell{1},Dcell{2})
                else % both not strictly increasing
                    stairs(cumsum(Dcell{1}),cumsum(Dcell{1}))
                end
        end % of switch XY
                
    otherwise % more than two data columns to be plotted
        Color = 'krgb';
        if Xax % all strictly ascending

            for dd = 1:NDcols

                H = stairs(Dcell{dd},1:length(Dcell{dd}));
                set(H,'Color',Color(mod(dd,4)))

            end

        else % all not strictly ascending
            
            for dd = 1:NDcols

                H = stairs(1:length(Dcell{dd}),cumsum(Dcell{dd}));
                    set(H,'Color',Color(mod(dd,4)))
            end
        end
end % of switch NDcols

%% Setting axes limits and panel labels and axes labels                 
if isempty(Xlm)
    Xlm = xlim;
else
    xlim(Xlm)
end % setting x limits

if isempty(LeftYlm)
    LeftYlm = ylim;
else
    ylim(LeftYlm)
end


if (XY==2) % a double-y plot
    
    if ~isempty(RightYlm)
        set(Ax(2),'YLim',RightYlm)
    end % setting right y limit
    
    if ~isempty(LeftYlbl)
        ylabel(LeftYlbl)
    end % setting left axis label
    
    if ~isempty(RightYlbl)
        set(get(Ax(2),'YLabel'),'String',RightYlbl)
    end % setting right axis label
    
    if Rows<=4
        if ~isempty(Xlbl)
            xlabel(Xlbl)
        end
        
        switch Lev % title for panel
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
        end  % of Switch Lev
        
    else % more than 4 rows of panels
        
        if ~isempty(Xlbl)
            Yoffset = .04*Rows; % I don't use xlabel to add label to x-axis
            %  when there are more than 4 rows because it radically shrinks the
            % y-extent of all the plot panels

            text(Xlm(1)+.2*(Xlm(2)-Xlm(1)),LeftYlm(1)-Yoffset*(LeftYlm(2)-LeftYlm(1)),Xlbl)
            % adding xlabel as text just below axis
        end % applying xlabel when Rows > 4
        
        switch Lev % labeling panel using text rather than title, to put label
            % just below top of panel
        case 'S'
            if Phase
                text(Xlm(1)+.05*(Xlm(2)-Xlm(1)),LeftYlm(1)+.9*(LeftYlm(2)-LeftYlm(1)),sprintf('S%d,P%d',S,P))
            else
                text(Xlm(1)+.05*(Xlm(2)-Xlm(1)),LeftYlm(1)+.9*(LeftYlm(2)-LeftYlm(1)),sprintf('S%d',S))
            end
        case 's'
            if Phase
                text(Xlm(1)+.05*(Xlm(2)-Xlm(1)),LeftYlm(1)+.9*(LeftYlm(2)-LeftYlm(1)),sprintf('S%d,s%d,P%d',S,s,P))
            else
                text(Xlm(1)+.05*(Xlm(2)-Xlm(1)),LeftYlm(1)+.9*(LeftYlm(2)-LeftYlm(1)),sprintf('S%d,s%d',S,s))
            end
        case 'T'
            
            if Phase
                text(Xlm(1)+.05*(Xlm(2)-Xlm(1)),LeftYlm(1)+.9*(LeftYlm(2)-LeftYlm(1)),sprintf('S%d,s%d,P%d,TT%s,T%d',S,s,P,TT,T))
            else
                text(Xlm(1)+.05*(Xlm(2)-Xlm(1)),LeftYlm(1)+.9*(LeftYlm(2)-LeftYlm(1)),sprintf('S%d,s%d,TT%s,T%d',S,s,TT,T))
            end
        end % Switch Lev: labeling panel when Rows > 4 & it's double-y
        
    end % more than 4 rows or not (& double-y plots)

else % not a double-y plot
    if Rows <= 4
        if ~isempty(Xlbl)
            xlabel(Xlbl)
        end % setting x axis label when Rows <=4 & not double-y
        
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
        end  % of Switch Lev labeling of panels when Rows <=4
        
    else % more than 4 rows (& not a double-y plot)
        if ~isempty(Xlbl)
            Yoffset = .04*Rows; % I don't use xlabel to add label to x-axis
            %  when there are more than 4 rows because it radically shrinks the
            % y-extent of all the plot panels

            text(Xlm(1)+.2*(Xlm(2)-Xlm(1)),LeftYlm(1)-Yoffset*(LeftYlm(2)-LeftYlm(1)),Xlbl) % adding xlabels
        end
        
        switch Lev % labeling panel using text rather than title, to put label
            % just below top of panel
        case 'S'
            if Phase
                text(Xlm(1)+.05*(Xlm(2)-Xlm(1)),LeftYlm(1)+.9*(LeftYlm(2)-LeftYlm(1)),sprintf('S%d,P%d',S,P))
            else
                text(Xlm(1)+.05*(Xlm(2)-Xlm(1)),LeftYlm(1)+.9*(LeftYlm(2)-LeftYlm(1)),sprintf('S%d',S))
            end
        case 's'
            if Phase
                text(Xlm(1)+.05*(Xlm(2)-Xlm(1)),LeftYlm(1)+.9*(LeftYlm(2)-LeftYlm(1)),sprintf('S%d,s%d,P%d',S,s,P))
            else
                text(Xlm(1)+.05*(Xlm(2)-Xlm(1)),LeftYlm(1)+.9*(LeftYlm(2)-LeftYlm(1)),sprintf('S%d,s%d',S,s))
            end
        case 'T'
            
            if Phase
                text(Xlm(1)+.05*(Xlm(2)-Xlm(1)),LeftYlm(1)+.9*(LeftYlm(2)-LeftYlm(1)),sprintf('S%d,s%d,P%d,TT%s,T%d',S,s,P,TT,T))
            else
                text(Xlm(1)+.05*(Xlm(2)-Xlm(1)),LeftYlm(1)+.9*(LeftYlm(2)-LeftYlm(1)),sprintf('S%d,s%d,TT%s,T%d',S,s,TT,T))
            end
        end % of Switch Lev labeling of panels (when Rows>4)
        
    end % if Rows <= 4 or not
    
end % if double-y plot or not
    

%% Updating counts   

PltCount = PltCount+1;

CCount = CCount + 1;

if CCount > Cols
    CCount=1;
end

if Cols==1 || mod(PltCount,Cols)==1
    RCount = RCount+1;
end

%% Updating caller workspace
assignin('caller','PltCount',PltCount); % update value in TSapplystat
% workspace

assignin('caller','RCount',RCount); % ditto

assignin('caller','CCount',CCount); % ditto

assignin('caller','FCount',FCount); % ditto

