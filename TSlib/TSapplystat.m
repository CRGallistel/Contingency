% TSAPPLYSTAT   Apply a function to a statistic or statistics to
% generate another statistic or statistics or to make a graph
%
% Syntax  ER = TSAPPLYSTAT(NEWSTAT,USESTATS,FUN,arg1,arg2,etc)
% NEWSTAT is a string or cell array of strings; USESTATS is likewise a
% string or cell array of strings; FUN is a function to be applied to the
% USESTATS field(s) to generate statistics in the NEWSTAT field(s). arg1
% etc are optional additional arguments to be passed to FUN
% Having NEWSTAT be a cell array has not been implemented; I tried it & it
% didn't work and I see nothing in the code that provides for it.--CRG
% 2/8/11
% 
% TSapplystat applies a specified function to any statistic (or statistics)
% in the Experiment structure and stores the result under a new name at the
% same level in the Experiment hierarchy. TSapplystat requires the name for
% the new statistic (statname), the name of the statistic(s) to which the
% function will be applied (usestats), a function handle for the function
% that will be applied (funhand), and any additional arguments that will be 
% passed to funhand.
% 
% If usestats is a single string, specified function will be passed usestat
% as its first argument and any remaining arguments that were given as arg1, 
% arg2, etc... If usestats is a cell array of statistic names, each one will 
% be passed in order to the given function, followed by the additional arguments.
% Statname can also be either a string or a cell array or strings. If multiple 
% strings are passed, then the extra fields are used to store additional 
% outputs from the function. It is an error to ask for more outputs than 
% funhandle provides.
% 
% If two single quotes ('') are used for statname, then the function will be 
% applied, but no new output statistic will be created. This is VERY useful 
% for applying procedures that create graphs of data. You can also simply 
% leave out statname and the same behavior will result.
% 
% If statname and usestat are the same, TSapplystat will replace usestat with 
% the computed statistic. Unless space is a major concern, however, we 
% discourage this, because there is substantial benefit to keeping a record 
% of the computations made in the course of the analysis. If you overwrite 
% the old statistic, then you don't have a complete record of the intermediate 
% values used.
% 
%
%	See also TSTRIALSTAT, TSSESSIONSTAT, TSCOMBINEOVER, TSLIMIT
%
% Updated: 9/18/2009 by Adam King

% Revised Feb 2012 by CRG
% This revision implements two features that the above documentation claims
% the function had, but which it did not in fact have: 1) One can specify
% more than one new statistic, that is, NEWSTAT can be a cell array with each
% cell being the name of a new statistic, provided, of course, that FUN
% provides as many outputs as there are statistics specified in newstat;
% 2) NEWSTAT can be empty. Usually, this is because FUN is a plotting
% function. Thus, for example, TSapplystatRev('','Latencies',@cdfplot)
% would make a cdfplot of the data in the field named Latencies.
%
% Further revision in May 2012

function ER = TSapplystat(newstat, usestats, funhand, varargin)


%%-------------------------------------------------------------------------
%%%%% This same code exists in TStrialstat.
if nargout>0 % error output requested
    ER = cell(0,1); % initializing optional error output
end


if evalin('base','isempty(who(''global'',''Experiment''))')     % Verifies that an Experiment structure exists
    error('There is no experiment structure defined.');
end;
global Experiment;  % Access the global Experiment

ShowProg = Experiment.Info.ShowProgress;                        % Flag if showing progress
if ShowProg;
    disp(' ');
    disp(['--- Runing TSapplystat ---']);
    disp(' ');
end;

if Experiment.NumSubjects == 0                                  % Make sure that there are subjects in the experiment
    error('There are no Subjects');
end

trialname = Experiment.Info.ActiveTrialType;                        % Get the curent trial type and
overwritemode = Experiment.Info.OverWriteMode;                  % Determine if in overwrit mode

if (ischar(funhand)) funhand = str2func(funhand);end;           % Convert a quoted function name to a function handle


%if ~exist(char(funhand))                                        % Check to see if specified function exists
%    error(['There is no such function ' char(funhand)]);
%end;
% I had to take out this check to see if the function specified exists
% because Matlab doesn't recognize anonymous functions as existing.

if ~iscell(usestats); usestats = {usestats};end;
% If only a sigle usestat is given, change it to a cell array

if ~isempty(newstat) && ~iscell(newstat);newstat = {newstat};end
% If only a single newstat is given, change it to a cell array, unless it's
% empty

foundstat = false;                                              % Flag to see if the appropriate stat(s) were found.
%DW
alreadyfound = false;

UsingAllPhases = isequal(Experiment.Info.ActivePhases,'all');         % Determine if using all phases
if (~UsingAllPhases) ActivePhases = Experiment.Info.ActivePhases;end; % If not, then only use phases given in ActivePhases

activesubjects = TSgetlimit(Experiment.Info.ActiveSubjects,Experiment.NumSubjects); % Determine the active subjects
T=[];
% Check to make sure that all specified subjects actually exist
if any(activesubjects>Experiment.NumSubjects)
    error(['Subject limits specify a non-existent subject index: ' num2str(activesubjects)]);end;

%%-------------------------------------------------------------------------


% Searches throughout entire hierarchy of Experiment for levels, all of them at the same level
try % Experiment level
    level = Experiment;                                     % Set the level we are looking at (experiment level)
    if ((all(ismember(usestats, fieldnames(level))) &&...    % Check to see if all of the usestats are present at the Experiment level
            (overwritemode || all(~isfield(level,newstat)))))   % And either we are overwriting or the newstat(s) has/have not been created
        Lvl = 'Exp'; % This variable enables functions called by TSapplystat
        % to reach into its workspace and determine the level of the
        % Experiment structure from which the data came
        foundstat = true;
        dataargs = {};
        for lp = numel(usestats):-1:1                       % Get all of the values referred to in the usestats
            dataargs{lp} = level.(usestats{lp});
        end
        if isempty(newstat)
            funhand(dataargs{:},varargin{:});
            % DW- make note that you've found it already
            alreadyfound = true;
        else
            FunOut = cell(1,length(newstat)); % initializing output    
            [FunOut{1:length(newstat)}] = funhand(dataargs{:},varargin{:});
    %         if ~iscell(FunOut); FunOut = {FunOut};end
            for i = 1:length(newstat) % stepping through requested outputs
                if (overwritemode || ~isfield(level,newstat{i}) || isempty(level.(newstat{i}))) % if we're overwriting or it's not a field or it's empty
                    Experiment.(newstat{i}) = FunOut{i};
                end
            end
        end

    end;
catch ME
    str1 = getReport(ME);

    str2 = []; % initializing string
    for cl = 1:length(usestats) % building string
        str2 =[str2 ' ' usestats{cl}];
    end

    if nargout>0
        ER{end+1} = sprintf('\nApplystat error at Experiment level:\nUsestat field(s):\n%s\n\n%s\n',str2,str1);
    else
        fprintf('\nApplystat error at Experiment level:\nUsestat field(s):\n%s\n\n%s\n',str2,str1)
    end
end % of Experiment level searching


for sub = activesubjects; % Do for each active subject
    try % Subject level searching
        if ShowProg;disp(['Subject=' num2str(sub)]);end
        level = Experiment.Subject(sub);                        % Set the level we are looking at (subject level)
        if (all(ismember(usestats, fieldnames(level))) &&...    % Check to see if all of the usestats are present at the Subject level
                (overwritemode || all(~isfield(level,newstat))))   % And either we are overwriting or the newstat(s) has/have not been created
            Lvl = 'Sub';% This variable enables functions called by TSapplystat
                % to reach into its workspace and determine the level of the
                % Experiment structure from which the data came
            foundstat = true;
            dataargs = {};                                     % See above, doing same at subject level
            for lp = numel(usestats):-1:1
                dataargs{lp} = level.(usestats{lp});
            end
            if isempty(newstat)
                funhand(dataargs{:},varargin{:});
                %DW- make note that you've found it already
                alreadyfound = true;
            else
                FunOut = cell(1,length(newstat));    
                [FunOut{1:length(newstat)}] = funhand(dataargs{:},varargin{:});
    %             if ~iscell(FunOut); FunOut = {FunOut}; end
                for i = 1:length(newstat) % stepping through requested outputs
                    if (overwritemode || ~isfield(level,newstat{i}) || isempty(level.(newstat{i}))) % if we're overwriting or it's not a field or it's empty
                        Experiment.Subject(sub).(newstat{i}) = FunOut{i};
                    end
                end;
            end
            % Consider adding an elseif that checks if ANY of the usestat
            % fields is found at Subject level (ditto session level and
            % trial level) and if so, set newstat fields to []. Also, why
            % does it continue to look at lower levels, once it has found
            % the usestat fields at a given level?
     
        end % of if the usestat fields are found at the Subject level
        
    catch ME
        str1 = getReport(ME);

        str2 = []; % initializing string
        for cl = 1:length(usestats) % building string
            str2 =[str2 ' ' usestats{cl}];
        end

        if nargout>0 % deteriming which form of error display
            ER{end+1} = sprintf('\nApplystat error at Subject level:\nS%d\n\nUsestat field(s):\n%s\n\n%s\n',sub,str2,str1);
            continue
        else
            fprintf('\nApplystat error at Subject level:\nS%d\n\nUsestat field(s):\n%s\n\n%s\n',sub,str2,str1)
            continue
        end
    end % of try/catch for finding usestats at Subject level  


    for ses = TSgetlimit(Experiment.Info.ActiveSessions,Experiment.Subject(sub).NumSessions)
        try
            if ses > length(Experiment.Subject(sub).Session) % altered 10/31/14 by CRG: was compared to Experiment.Subject(sub).NumSessions
%                 warning(['Session ' int2str(ses) ' does not exist for
%                 Subject: ' int2str(sub)]);--old code commented out here
                warning(sprintf('\nSession %d does not exist for Subject %d,\nalthough Experiment.Subject(%d).NumSessions field=%d\n',...
                    ses,sub,sub,Experiment.Subject(sub).NumSessions)) % new code 10/31/14 --CRG
                break % Changed 10/31/14 by CRG: this was a continue
            end

            phase = Experiment.Subject(sub).Session(ses).Phase;
            if (~UsingAllPhases && ~ismember(phase,ActivePhases)) continue; end;                    % Kick out of this session if not using this phase
            if ShowProg;disp(['   Session=' num2str(ses) '. Phase=' num2str(phase)]);end
            Lvl = 'Ses'; % This variable enables functions called by TSapplystat
                % to reach into its workspace and determine the level of the
                % Experiment structure from which the data came
            level = Experiment.Subject(sub).Session(ses);            % Set the level we are looking at (session level)
            if (all(ismember(usestats, fieldnames(level))) &&...     % Check to see if all of the usestats are present at the Session level
                    (overwritemode || all(~isfield(level,newstat))))    % And either we are overwriting or the newstat has not been created

                dataargs = {};
                foundstat = true;
                for lp = numel(usestats):-1:1
                    dataargs{lp} = level.(usestats{lp});
                end
                if isempty(newstat)
                    funhand(dataargs{:},varargin{:});
                    %DW- make note that you've found it already
                    alreadyfound = true;
                else
                    FunOut = cell(1,length(newstat));    
                    [FunOut{1:length(newstat)}] = funhand(dataargs{:},varargin{:});
    %                 if ~iscell(FunOut); FunOut = {FunOut}; end
                    for i = 1:length(newstat) % stepping through requested outputs
                        if (overwritemode || ~isfield(level,newstat{i}) || isempty(level.(newstat{i}))) % if we're overwriting or it's not a field or it's empty
                            Experiment.Subject(sub).Session(ses).(newstat{i}) = FunOut{i};
                        end
                    end;
                end
                % See suggestion & query at this point in Subject level
                % code
            end;
        catch ME
            str1 = getReport(ME);

            str2 = []; % initializing string
            for cl = 1:length(usestats) % building string
                str2 =[str2 ' ' usestats{cl}];
            end

            if nargout>0 % deteriming which form of error display
                ER{end+1} = sprintf('\nApplystat error at Session level:\nS%d s%d\n\nUsestat field(s):\n%s\n\n%s\n',sub,ses,str2,str1);
                continue
            else
                fprintf('\nApplystat error at Session level:\nS%d s%d\n\nUsestat field(s):\n%s\n\n%s\n',sub,ses,str2,str1)
                continue
            end
        end % of try/catch for Session level


        if strcmp(trialname,'none')||...                                            % Don't do trials if no active trial defined
                (~isfield(Experiment.Subject(sub).Session(ses),trialname))||...
                isempty(Experiment.Subject(sub).Session(ses).(trialname))
            continue;
        end


        % Check to see if the trial type has now been created, and set the
        % number of trials
        if ~(isfield(Experiment.Subject(sub).Session(ses),trialname))
            Experiment.Subject(sub).Session(ses).(trialname)=[];
            Experiment.Subject(sub).Session(ses).(trialname).Trial=[];
        elseif ~(isfield(Experiment.Subject(sub).Session(ses).(trialname),'Trial'))
            Experiment.Subject(sub).Session(ses).(trialname).Trial=[];
        end

        totaltrials = numel(Experiment.Subject(sub).Session(ses).(trialname).Trial);

        Experiment.Subject(sub).Session(ses).(trialname).NumTrials=totaltrials;  % Sets numtrials
        for tri = TSgetlimit(Experiment.Info.ActiveTrials,totaltrials) % Loop over the active trials
            try % Trial level
                if ShowProg disp(['      Trial ' num2str(tri) ' of ' trialname]);end
                Lvl = 'Trl';% This variable enables functions called by TSapplystat
                % to reach into its workspace and determine the level of the
                % Experiment structure from which the data came
                level = Experiment.Subject(sub).Session(ses).(trialname).Trial(tri);            % Set the level we are looking at (trial level)
                if (all(ismember(usestats, fieldnames(level))) &&...            % Check to see if all of the usestats are present at the Trial level
                        (overwritemode || all(~isfield(level,newstat))))           % And either we are overwriting or the newstat has not been created

                    foundstat = true;
                    dataargs = {};
                    for lp = numel(usestats):-1:1
                        dataargs{lp} = level.(usestats{lp});
                    end
                    if isempty(newstat)
                        funhand(dataargs{:},varargin{:});
                        %DW- make note that you've found it already
                        alreadyfound = true;
                    else
                        FunOut = cell(1,length(newstat));    
                        [FunOut{1:length(newstat)}] = funhand(dataargs{:},varargin{:});
    %                     if ~iscell(FunOut); FunOut = {FunOut}; end
                        for i = 1:length(newstat) % stepping through requested outputs
                            if (overwritemode || ~isfield(level,newstat{i}) || isempty(level.(newstat{i}))) % if we're overwriting or it's not a field or it's empty
                                Experiment.Subject(sub).Session(ses).(trialname).Trial(tri).(newstat{i}) = FunOut{i};
                            end
                        end
                    end
                end
            
            catch ME
                str1 = getReport(ME);

                str2 = []; % initializing string
                for cl = 1:length(usestats) % building string
                    str2 =[str2 ' ' usestats{cl}];
                end

                if nargout>0 % deteriming which form of error display
                    ER{end+1} = sprintf('\nApplystat error at Trial level:\nS%d s%d T%d\n\nUsestat field(s):\n%s\n\n%s\n',sub,ses,tri,str2,str1);
                    continue
                else
                    fprintf('\nApplystat error at Trial level:\nS%d s%d T%d\n\nUsestat field(s):\n%s\n\n%s\n',sub,ses,tri,str2,str1)
                    continue
                end
            end % try/catch at Trial level
        end; % Trial loop
    end; % Session loop
end; % Subject loop
if ~foundstat % Check to see if the stat was found somewhere in the hierarchy
    str1 = 'Applystat could not find one or more usestat field(s)';
    str2 = 'anywhere in the Experiment structure. Check spelling';
    str3 = 'of field names. Also check Active Subject, Session';
    str4 = 'TrialType and Phase settings under Experiment.Info';
    str5 = [];
    for cl = 1:length(usestats)
        str5 = [str5 ' ' usestats{cl}];
    end

    fprintf('\n%s\n%s\n%s\n%s\nThe fields for which it searched are:\n%s\n',...
        str1,str2,str3,str4,str5)

    if nargout>0
        ER{end+1} = sprintf('\n%s\n%s\n%s\n%s\nThe fields for which it searched are:\n%s\n',...
            str1,str2,str3,str4,str5);
    end

end
