% TSCOMBINEOVER  Combine Time Stamped Data one level up the heirarchy.
%   TSCOMBINEOVER(STATNAME,USESTAT, MODEFLAGS) creates a stat called
%   STATNAME that is the collection of USESTAT (appended end to end) and
%   stored a level up in the Experiment hierarchy.  Statname represents the
%   name for the new stat and USESTAT represents the stat to collect. The
%   data is vertically concatenated.
%
%   MODEFLAG should be a string, either the empty string or containing one
%   or more of the modeflag characters:
%   't' - Tags the tsdata with a column of integer tags
%   'm' - Integrates within-trial or within-session times across trials or
%           sessions creating times that are strictly increasing, as they
%           would be if recorded from a clock that ran only during a trial
%           or only during a session
%   'c' - Simply places each usestat in a different cell of cell array
%
%   A MODEFLAG of 't' tags onto the data (on the right) a column that
%   includes the number of the trial, session, or subject that the data
%   came from.
%
%   A MODEFLAG of 'm' assumes that the first column of the data
%   is time and it will then "merge" the times to form a continuous time
%   sequence. If you are combining over trials, the times are merged by using
%   a clock the runs continuously during TRIAL TIME. If times are combined
%   over sessions, then the times are merged based on a clock that only runs
%   during session time. Merging time stamps across subjects is not
%   allowed.
%
%   A MODEFLAG of 'c' puts each USESTAT into successive bins in a cell
%   array. This is offered as an alternative to MODEFLAG 't'. Any of these
%   flags can be combined, although combining 't' and 'c' may not be
%   useful.
%
%   Using modeflag 't':
%
%   After combining to create a stat with modeflag 't' on, it will now
%   contain 3 columns instead of standard 2 column tsdata. The first 2
%   columns are the same, they are all the tsdata appended together.
%   However, the third column tags each data entry with an integer
%   representing which number piece it came from. So all data pieces from
%   the same segment will have the same number, and this data column will
%   generally be a series of integers, most of which are the same for large
%   streches followed by increments of 1.
%
%   To find the positions where different data pieces start, this is a
%   handy vectorized solution:
%
%   find(diff([-1 tsdata(:,3)]) ~= 0)
%
%   This works by finding where the difference between successive tags is
%   nonzero. A -1 is appended at the start so that the first entry is
%   always considered to be the start of a data piece.
%
%   If you do not want the third column in your combined data but still
%   need to seperate the different pieces, you can use modeflag 'c' instead
%   and then you will just get a cell array of standard 2 column TSdata,
%   which you can iterate over in a for loop.

% apk 11/15/09 6:29PM

function TScombineover(statname,usestat,modeflags)
% statname is the stat to be created one level up, usestat is the stat to
% operate on, and modeflags is a string that can contain 't', 'm', or 'c'.


if evalin('base','isempty(who(''global'',''Experiment''))')        % Verifies that an Experiment structure exists
    error('There is no experiment structure defined.');            % Will not execute if no Experiment has been set up
end;
global Experiment;                                                 % Access the global Experiment

ShowProg=Experiment.Info.ShowProgress;                             % Flag if showing the progress
if ShowProg;
    disp(' ');
    disp('--- Runing TScombineover ---');
    disp(' ');
end;

if Experiment.NumSubjects == 0                                     % Make sure there are subjects
    error('There are no Subjects');
end


trialname = Experiment.Info.ActiveTrialType;                           % Get the active trial
overwritemode = Experiment.Info.OverWriteMode;                     % Determine if in overwrite mode

tmode = false; % Don't tag on trial, session, etc.. by default
mmode = false; % Don't merge time by default
cmode = false; % Don't create cell array by default
defaultresult = []; % Default result is an empty array, unless it is set to empty cell by cmode below.

if nargin>2
    if any('t' == modeflags) tmode=true;end;   % Checks if a modeflag was given
    if any('m' == modeflags) mmode=true;end;
    if any('c' == modeflags) cmode=true;defaultresult = {}; end; % For cell option, default is the empty cell array
end;

errorcount=[];

% sublevel = false; % moved this to Line 118 (CRG 3/6/2014(
% seslevel = false; % setting this here presupposes that if the usestat
% field exists for some subject & session, it must exist for all subjects
% and sessions, but that turns out not to be the case. It can happen that a
% usestat field exists at the session level for some subjects but not
% others. The way this was written, with the initialization here, once
% seslevel got set to true, it remained there for all the subjects and that
% produced a crash. Therefore, I moved the initialization of seslevel to
% near the beginning of the subject for loop, so that it is reinitialized for
% each new subject
% trilevel = false; % On the assumption that the same problem could
% conceivably arise at this level, I moved this initialization to near the
% beginning of the session loop, so that it is reinitialized for each new
% session [CRG 3/6/2014]


if isfield(Experiment, usestat)                                    % Determine if the stat exists at the Experiment level
    warning('Cannot combine statistics at the experiment level');  %   and if so, warn that these can't be combined (there is only 1!)
    % Only a warning as usestat may appear at other levels too
end;

UsingAllPhases = isequal(Experiment.Info.ActivePhases,'all');         % Set flag if using all phases
if (~UsingAllPhases) ActivePhases = Experiment.Info.ActivePhases;end; % If not, then only use phases given in ActivePhases

sublevel = false;                                         % Assume the usestat is not at the subject level
if (isfield(Experiment.Subject,usestat)) && ...           % If the usestat does exist at the subject level, then if either:
        (overwritemode || ...                             %    a) We are overwrite mode
        ~isfield(Experiment, statname) ||  ...            %    b) The stat has not been computed yet
        isempty(Experiment.(statname)))                   %    c) The stat is empty
    resultsub=defaultresult;                              % Then set the default result and prepare to combine over subjects
    sublevel = true;
end;

activesubjects = TSgetlimit(Experiment.Info.ActiveSubjects,Experiment.NumSubjects); % Determine the active subjects
% Check to make sure that all specified subjects actually exist
if any(activesubjects>Experiment.NumSubjects)
    error(['Subject limits specify a non-existent subject index: ' num2str(activesubjects)]);end;

for sub = activesubjects; % Do for each active subject
    if ShowProg;disp(['Subject=' num2str(sub)]);end
    if (sublevel)                                                          % Check if doing a stat at the subject level
        resultsubtmp=Experiment.Subject(sub).(usestat);                    %    Get the stat
        if ~isempty(resultsubtmp)                                          %    Only use mode flags is the stat is non-empty
            if tmode resultsubtmp(:,end+1)=sub;end;                        %    If tmode, tag the subject number to end
            if cmode resultsubtmp = {resultsubtmp}; end;                   %    If cmode, turn in a cell array
            % Note: Doesn't check here for mmode because merging times across
            % subjects is non-sensical
        end
        
        try
            resultsub = [resultsub;resultsubtmp]; % Concatenate vertically
            % current subject's field with previously concatenated fields
        catch ME
            report = getReport(ME);
            fprintf('\nS=%d: %s\n',sub,report)
            if errorcount>10
                fprintf('\nprocessing discontinued because of recurring error\n')
                return
            else
                fprintf('\nprocessing subsequent subjects continued\n')
                errorcount = errorcount+1;
                continue
            end
        end
    end
    
    seslevel = false;                                                          % Assume the usestat is not at the session level
    if (isfield(Experiment.Subject(sub).Session,usestat) && ...                % If the usestat does exist at the session level, then if either:
            (overwritemode || ...                                              %    a) We are overwrite mode
            ~isfield(Experiment.Subject(sub), statname) ||...                  %    b) The stat has not been computed yet
            isempty(Experiment.Subject(sub).(statname))))                      %    c) The stat is empty
        resultses=defaultresult;                                               % Then set the default result and prepare to combine over sessions
        seslevel = true;
    end;
    
    cumsesdur = 0;                                                               % Used for mmode to keep track of cummulative session time
    SessionRange = TSgetlimit(Experiment.Info.ActiveSessions,Experiment.Subject(sub).NumSessions); % Determine the active sessions
    for ses = SessionRange
%         if ses>355;keyboard;end

        phase = Experiment.Subject(sub).Session(ses).Phase;
%         if phase==23;keyboard;end
        trilevel = false; 
        
        if (~UsingAllPhases && ~ismember(phase,ActivePhases)) continue; end;          % Kick out of this session if not using this phase
        if ShowProg;disp(['   Session=' num2str(ses) '. Phase=' num2str(phase)]);end
        if (seslevel)                                                            % Check if doing a stat at the subject level
            resulttmp=Experiment.Subject(sub).Session(ses).(usestat);            %      Get the stat
            if ~isempty(resulttmp)                                               %      Only use mode flags is the stat is non-empty
                if tmode resulttmp(:,end+1)=ses;end;                                 %      If tmode, tag the session number to end
                if cmode resulttmp = {resulttmp}; end;                               %      If cmode, turn in a cell array
                if mmode && ~isempty(resulttmp)                                      %      If mmode, then we must merge the session time
                    resulttmp(:,1)=resulttmp(:,1)+cumsesdur;
                    if (~isempty(Experiment.Subject(sub).Session(ses).MatlabStartDate) && ...
                            ~isempty(Experiment.Subject(sub).Session(ses).MatlabEndDate))
                        cumsesdur = cumsesdur + 24*3600*...                          % Matlab dates are in days, convert to seconds
                            (Experiment.Subject(sub).Session(ses).MatlabEndDate-Experiment.Subject(sub).Session(ses).MatlabStartDate);
                    else cumsesdur = cumsesdur + ...
                            Experiment.Subject(sub).Session(ses).(Experiment.Info.ActiveData)(end,1); % Use last time stamp for length
                    end;                                                                              %   if no startdate/enddate given
                end;
            else
                % added by Chris Kourtev 5/19/2010, to combat the effect of
                % not adding time for cases when the usestat happens to be
                % empty
                if mmode                                    %      If mmode, then we must merge the session time
                    if (~isempty(Experiment.Subject(sub).Session(ses).MatlabStartDate) && ...
                            ~isempty(Experiment.Subject(sub).Session(ses).MatlabEndDate))
                        cumsesdur = cumsesdur + 24*3600*...                          % Matlab dates are in days, convert to seconds
                            (Experiment.Subject(sub).Session(ses).MatlabEndDate-Experiment.Subject(sub).Session(ses).MatlabStartDate);
                    elseif (~isempty(Experiment.Subject(sub).Session(ses).(Experiment.Info.ActiveData))) 
                        cumsesdur = cumsesdur + ...
                            Experiment.Subject(sub).Session(ses).(Experiment.Info.ActiveData)(end,1); % Use last time stamp for length
                    end;                                                                              %   if no startdate/enddate given
                end;
            end;
            try
                resultses = [resultses;resulttmp]; % concatenating vertically current session with previous sessions
            catch ME
                report=getReport(ME);
                fprintf('\nS=%d, s=%d: %s\n',sub,ses,report)
                if errorcount>10
                    fprintf('\nprocessing discontinued because of recurring error\n')
                    return
                else
                    fprintf('\nprocessing subsequent sessions continued\n')
                    errorcount = errorcount+1;
                    continue
                end
            end
        end; % member session
        
        if strcmp(trialname,'none') continue;end; % If no trial is active, can't search for trial stats
        
        if ~(isfield(Experiment.Subject(sub).Session(ses),trialname))
            Experiment.Subject(sub).Session(ses).(trialname)=[];
            Experiment.Subject(sub).Session(ses).(trialname).Trial=[];
        elseif ~(isfield(Experiment.Subject(sub).Session(ses).(trialname),'Trial'))
            Experiment.Subject(sub).Session(ses).(trialname).Trial=[];
        end
                                                                       % Assume the usestat is not at the session level
        if (isfield(Experiment.Subject(sub).Session(ses).(trialname).Trial, usestat) &&...% If usestat exist at trial level, then if either:
                (overwritemode || ...                                                     %    a) We are overwrite mode
                ~isfield(Experiment.Subject(sub).Session(ses),statname) || ...            %    b) The stat has not been computed yet
                isempty(Experiment.Subject(sub).Session(ses).(statname))))                %    c) The stat is empty
            resulttri=defaultresult;                                                      % Then set the default result and
            trilevel = true;                                                              %   prepare to combine over trials
        else % usestat does not exist at the trial level for this subject
            continue % this forestalls the carrying over of data from
            % previous subject when current subject does not have the
            % usestat field at the trial level but an earlier subject does
            % have it. CRG added this else clause 12/22/13
        end;
        
        if  (trilevel) && isfield(Experiment.Subject(sub).Session(ses).(trialname),'NumTrials')                                                                         % Check if doing the trial level
            totaltrials = Experiment.Subject(sub).Session(ses).(trialname).NumTrials;
            cumtrialtime = 0;                                                                   % Track cum trial time for m mode
            for tri = TSgetlimit(Experiment.Info.ActiveTrials,totaltrials)                      % Do for each trial
                if ShowProg;disp(['      Trial ' num2str(tri) ' of ' trialname]);end
                resulttmp=Experiment.Subject(sub).Session(ses).(trialname).Trial(tri).(usestat);% Get the stat
                if ~isempty(resulttmp)
                    if tmode resulttmp(:,end+1)=tri;end;                     % Tags if tmode
                    if cmode resulttmp = {resulttmp}; end;                   % Place in cell array if cmode
                    if mmode
                        resulttmp(:,1)=resulttmp(:,1)+cumtrialtime;
                        cumtrialtime = cumtrialtime+Experiment.Subject(sub).Session(ses).(trialname).Trial(tri).TrialDuration;
                    end;
                else
                    % added by Chris Kourtev 5/19/2010, to combat the effect of
                    % not adding time for cases when the usestat happens to be
                    % empty
                    if isfield(Experiment.Subject(sub).Session(ses).(trialname).Trial,'TrialDuration')
                        cumtrialtime = cumtrialtime+Experiment.Subject(sub).Session(ses).(trialname).Trial(tri).TrialDuration;
                    else
                        cumtrialtime = cumtrialtime+Experiment.Subject(sub).Session(ses).(trialname).Trial(tri).Duration;
                    end % [if/else added by CRG 12/25/2016 to deal with case where analyzing old Experiment structures
                end;
                try
                    resulttri = [resulttri;resulttmp]; % concatenating vertically current trial with previous trial
                catch ME
                    report=getReport(ME);
                    fprintf('\nS=%d, s=%d, Trl=%d: %s\n',sub,ses,tri,report)
                    if errorcount>10
                        fprintf('\nprocessing discontinued because of recurring error\n')
                        return
                    else
                        fprintf('\nprocessing subsequent trials continued\n')
                        errorcount = errorcount+1;
                        continue
                    end
                end
                
            end;  % tri for
        end; % trilevel
        if (trilevel)
            Experiment.Subject(sub).Session(ses).(statname) = resulttri;                % Generate the final cum stat
            %Experiment.Subject(sub).Session(ses).(['statname-dur']) = cumtrialtime;     % Set the total duration for further combinovers
        end;
    end; % ses for
    if (seslevel) Experiment.Subject(sub).(statname) = resultses;end;
end; % sub for
if (sublevel) Experiment.(statname) = resultsub;end;

if all([~sublevel ~seslevel ~trilevel])

    disp(sprintf('\nWarning: \nFor one or more subjects and/or sessions and/or trials,\n a field named ''%s'' was not found at the Subject level, \n the Session Level, or the Trial level for active trial %s',...
        usestat,trialname))
end

