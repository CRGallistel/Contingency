% TSTRIALSTATMULT  Computes multiple within-trial statistics. This is a
% version of TSTRIALSTAT modified 6/11/16 by CRG to output multiple
% statistics. It needs to be tested whether this version substitutes w/o
% problem for the tried and true long-standing version of TSTRIALSTAT
%   ER = TSTRIALSTAT(STATNAME,FUNHAND,VARARGIN) creates a one or more
%   trial-level statistics by running the function FUNHAND (passed in as a
%   function handle or a string) on the current trial's active data (usually TSData)
%   and the remaining arguments given in VARARGIN. If STATNAME is a cell
%   array of field names and FUNHAND is a custom function that will
%   generate outputs for each of those fields when given a segment of
%   TSData (and, possibly, some additional arguments), then there will be a
%   field for each name in STATNAME
%
%   Any functions written for use with TSTRIALSTAT must take TSDATA (or an
%   equivalent active tsd field as itsfirst argument.  Any other arguments
%   will come from VARARGIN.
%
%   See also TSAPPLYSTAT, TSCOMBINEOVER, TSSETTRIAL, TSSETDATA
%
% Updated: 9/18/2009 by Adam King
% Updated with cache to hold TSmatch results from prior calls 2/1/2014 CRG
%
% The (optional) ER output is a cell array containing reports of any errors.
% These reports attempt to identify the subject, session, trial type, and
% trial where the error arose. Ordinarily, the function will pass over the
% error and continue with subsequent data sets. Thus, when the expected
% results are missing from some subjects, sessions, or trials, call the
% function with the ER output so as to learn as much as possible about
% where the error occurred and what the problem was

function ER=TStrialstatMult(stat, funhand, varargin)

ER = cell(0,1); % cell array to contain error reports x

persistent Cache % makes this a persistent variable so that it remains
            % in the workspace of this function from one call to next

if evalin('base','isempty(who(''global'',''Experiment''))')     % Verifies that an Experiment structure exists
    error('There is no experiment structure defined.');
end;
global Experiment;  % Access the global Experiment

ShowProg = Experiment.Info.ShowProgress;                        % Flag if showing progress
if ShowProg;
    disp(' ');
    disp('--- Runing TStrialstat ---');
    disp(' ');
end;

if Experiment.NumSubjects == 0                                  % Make sure that there are subjects in the experiment
    error('There are no Subjects');
end

trialname = Experiment.Info.ActiveTrialType;                        % Get the curent trial type and 
if strcmp(trialname,'none')                                     %    halts if there is no active trial
    error('There is currently no active trial');
end;
overwritemode = Experiment.Info.OverWriteMode;                  % Determine if in overwrit mode

if ischar(funhand)
    funhand = str2func(funhand);
end           % Convert a quoted function name to a function handle

%if ~exist(char(funhand))                                        % Check to see if specified function exists
%    error(['There is no such function ' char(funhand)]);
%end;
% I had to take out this check to see if the function specified exists
% because Matlab doesn't recognize anonymous functions as existing.


UsingAllPhases = isequal(Experiment.Info.ActivePhases,'all'); 
% Determine if using all phases
if ~UsingAllPhases
    ActivePhases = Experiment.Info.ActivePhases;
end % If not, then only use phases given in ActivePhases

activesubjects = TSgetlimit(Experiment.Info.ActiveSubjects,Experiment.NumSubjects); % Determine the active subjects


%%
% Check to make sure that all specified subjects actually exist
if sum(activesubjects>Experiment.NumSubjects)>0
    error(['Subject limits specify a non-existent subject index: ' num2str(activesubjects)]);end;

if iscell(stat)
    newstat = stat;
end
for sub = activesubjects; % Do for each active subject
    if ShowProg;disp(['Subject= ' num2str(sub)]);end;

    for ses = TSgetlimit(Experiment.Info.ActiveSessions,Experiment.Subject(sub).NumSessions)    % Do for each active ses
        if (ses>Experiment.Subject(sub).NumSessions)
            warning(['Session ' int2str(ses) ' does not exist for Subject: ' int2str(sub)]);
            continue;
        end;
        phase = Experiment.Subject(sub).Session(ses).Phase;                  % Get the session's phase
        if isempty(phase)
            error('Empty Phase field; fill in the ''Phase'' fields at Session Level')
        end
            
        if  ~UsingAllPhases && ~ismember(phase,ActivePhases) continue; end;  % If not using this phase, skip this session
        if ShowProg;disp(['   Session=' num2str(ses) '. Phase=' num2str(phase)]);end
        if ~isfield(Experiment.Subject(sub).Session(ses),Experiment.Info.ActiveData) % Make sure that data field exists
            warning(['Active data was not found in Experiment.Subject(' int2str(sub) ').Session(' int2str(ses)']);
            continue;
        end;

        % Do the trials for this session unless we are overwriting
        %  and the trial type statistic have already been created for this
        %  session
        if (~overwritemode && isfield(Experiment.Subject(sub).Session(ses),trialname) && ...
                ~isempty(Experiment.Subject(sub).Session(ses).(trialname)) && ...
                isfield(Experiment.Subject(sub).Session(ses).(trialname), stat) && ...
                ~isempty(Experiment.Subject(sub).Session(ses).(trialname).(stat)))
            continue;
        end;

        tsdata = Experiment.Subject(sub).Session(ses).(Experiment.Info.ActiveData);
        % Get the tsdata for this session

        %% New code setting up a Cache as a persistent variable (structure)
        % 3/21/2014

        activesessions = TSgetlimit(Experiment.Info.ActiveSessions,Experiment.Subject(sub).NumSessions);

        samesearch=false;

        if isempty(Cache) % Cache structure was not created by a previous call

            Cache = struct('TrialDef',[],'ASubs',[],'ASes',[],'APhases',[],'ATrls',[],...
                'Data',[],'Sub',struct('Ses',struct('matches',[],'bindings',[],'Length',[])),'OldSearch',false);
            % The Cache structure holds the information from previous calls to
            % TStrialstat, so that if the present call is to perform the same
            % search as the preceding call, the often very time consuming search
            % will not have to be repeated, because the results for each subject
            % will be stored in Cache.Resultsm and Cache.Resultsb

        elseif (~isempty(Cache.TrialDef)...   % structure has been written to in a previous call
               && length(Cache.Sub) >= sub... % this subject has been written to previously
               && length(Cache.Sub(sub).Ses) >= ses... % this session has been written to previously
               && isequal(length(tsdata),Cache.Sub(sub).Ses(ses).Length)... % no new data in TSData field 
               && isequal(Cache.TrialDef,Experiment.(trialname))... % same trial type and definition
               && isequal(Cache.ASubs,activesubjects)... % same active subjects
               && isequal(Cache.ASes,activesessions)... % same active sessions
               && isequal(Cache.APhases,Experiment.Info.ActivePhases)... % same active phases
               && strcmp(Cache.Data,Experiment.Info.ActiveData)... % same active data
               && isequal(Cache.ATrls,Experiment.Info.ActiveTrials)...% same active trials
               && Cache.OldSearch) % whenever at least one subject requires a new search, this is false
                  % thereby insuring that a new search is done for every subject 

           samesearch = true; % use previous search results stored in Cache
        end 
        %% end new code 3/21/2014 further revised 11/7/2014

        % Only recompute the bindings for the trial if we are overwriting or the trial does not exist
        %  or the trial is empty
        if (overwritemode || ~isfield(Experiment.Subject(sub).Session(ses), trialname) || ...
                isempty(Experiment.Subject(sub).Session(ses).(trialname)))

            %% following if/else inserted 3/21/2014 by CRG. x
            % Previously, only
            % [matches,bindings] = TSmatch(tsdata,Experiment.(trialname));
            % occupied the space now occupied by the if/else

            try
                if samesearch
                   matches = Cache.Sub(sub).Ses(ses).matches; % use matches from previous search
                   bindings = Cache.Sub(sub).Ses(ses).bindings; % use bindings from previous search
                else % make new search
                    Cache.OldSearch = false;
                    [matches,bindings] = TSmatch(tsdata,Experiment.(trialname));
                    % Get the search results by calling TSmatch
                    Cache.Sub(sub).Ses(ses).matches = matches;
                    Cache.Sub(sub).Ses(ses).bindings = bindings;
                    Cache.Sub(sub).Ses(ses).Length = length(tsdata);
                    Cache.TrialDef = Experiment.(trialname);
                    Cache.ASubs = activesubjects;
                    Cache.ASes = activesessions;
                    Cache.APhases = Experiment.Info.ActivePhases;
                    Cache.Data = Experiment.Info.ActiveData;
                    Cache.ATrls = Experiment.Info.ActiveTrials;
                    if sub==activesubjects(end) % this is the
                        % last active subject
                        Cache.OldSearch = true;
                    end
                end
            catch ME
                CacheReport = getReport(ME);
                fprintf('\n\nTrialstat error: S%d s%d Phase %d TrlTyp: %s\n\n%s;\n\nCache structure in next cell of ER',...
                    sub,ses,phase,trialname,CacheReport)
                assignin('base','TrlStatCache',Cache)
                ER{end+1} = sprintf('Trialstat error: S%d s%d Phase %d TrlTyp%s\n%s',...
                    sub,ses,phase,trialname,CacheReport);
                ER{end+1} = Cache;

                continue 
            end
            %% of if/else that checks whether matches and bindings from
            % previous search may be used again 

            % Set the relevant fields for each trial.
            for numtrials=length(matches):-1:1        % Ran for loop in reverse to preallocate the struct array
                sloc=bindings{numtrials}(1);          % Finds beginning of trial
                eloc=bindings{numtrials}(end);        % Finds end of trial
                st=tsdata(sloc,1);                    % Finds Start time of trial
                et=tsdata(eloc,1);                    % Finds end time of trial
                % Sets Start time, End time, and duration of active trial
                Experiment.Subject(sub).Session(ses).(trialname).Trial(numtrials).StartTime=st;
                Experiment.Subject(sub).Session(ses).(trialname).Trial(numtrials).EndTime=et;
                Experiment.Subject(sub).Session(ses).(trialname).Trial(numtrials).TrialDuration= et-st;
                Experiment.Subject(sub).Session(ses).(trialname).Trial(numtrials).sloc = sloc;
                Experiment.Subject(sub).Session(ses).(trialname).Trial(numtrials).eloc = eloc;
            end;
        end;

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
            try
                if ShowProg disp(['      Trial ' num2str(tri) ' of ' trialname]);end
                % Only do the stat for this trial if overwriting or the stat is
                % missing or empty
                if (overwritemode || ~isfield(Experiment.Subject(sub).Session(ses).(trialname).Trial(tri), stat) ...
                        || isempty(Experiment.Subject(sub).Session(ses).(trialname).Trial(tri).(stat)))

                    trialdata = tsdata(Experiment.Subject(sub).Session(ses).(trialname).Trial(tri).sloc:Experiment.Subject(sub).Session(ses).(trialname).Trial(tri).eloc,:);
                    result = []; % make sure that there is a result -- shouldn't be needed, but just in case funhand call doesn't work
                    if ~iscell(stat)
                        result = funhand(trialdata,varargin{:});  % Executes function handle with trial data and extra arguments
                        Experiment.Subject(sub).Session(ses).(trialname).Trial(tri).(stat) = result; % Store the result for stat
                    else % cell array of output stats
                        [FunOut{1:length(newstat)}] = funhand(trialdata,varargin{:});
                        for i = 1:length(newstat) % stepping through requested outputs
                            if (overwritemode || ~isfield(level,newstat{i}) || isempty(level.(newstat{i}))) % if we're overwriting or it's not a field or it's empty
                                Experiment.Subject(sub).Session(ses).(trialname).Trial(tri).(newstat{i}) = FunOut{i};
                            end
                        end
                    end
                    
                elseif ShowProg disp('         : Not Recomputed');
                end;
            catch ME
                TrlReport = getReport(ME);
                fprintf('Trialstat error: S%d s%d Phase %d TrlTyp%s T%d\n%s',...
                    sub,ses,phase,trialname,tri,TrlReport)
                ER{end+1} = sprintf('Trialstat error: S%d s%d Phase %d TrlTyp%s T%d\n%s',...
                    sub,ses,phase,trialname,tri,TrlReport);
                continue 
            end % of try
        end; % Trial loop
    end; % Session and Phase loop
end; %Subject loop


