% TSSESSIONSTAT  Compute within-session statistics.
%   TSSESSIONSTAT(STATNAME,FUNHAND,VARARGIN) creates a stat called STATNAME
%   that is determined by running the function FUNHAND (passed in as a
%   function handle) on the current session data (usually TSData) and the
%   remaining arguments given in VARARGIN.  
%
%   Any functions written for use with TSSESSIONSTAT must take TSDATA as
%   its first argument.  Any other arguments will come from VARARGIN
%
%   The necessity of VARAGIN is dependent upon whether the function called
%   by FUNHAND requires an argument or arguments. TSparse, for example,
%   requires a string argument specifying a computation and a vector or
%   cell array of vectors argument specifying what is to be searched for
%
%	See also TSTRIALSTAT, TSAPPLYSTAT, TSCOMBINEOVER


function TSsessionstat(stat, funhand, varargin)


if evalin('base','isempty(who(''global'',''Experiment''))') % Verifies that an Experiment structure exists
    error('There is no experiment structure defined.');     % Will not execute if no Experiment has been set up
end;
global Experiment;

ShowProg=Experiment.Info.ShowProgress;   % Flag if showing the progress
sesdata = Experiment.Info.ActiveData;    % We are applying the stat to the TSdata

if ShowProg
    fprintf('\n--- Runing TSsessionstat ---\n')    
end

if ~isfield(Experiment.Info,'ActiveTrialType') ...
        || isempty(Experiment.Info.ActiveTrialType)
    str = char({'';'Either Experiment.Info does not contain an ActiveTrialType';...
        'field or it does, but the field is empty. Use TSsettrialtype to set';...
        'an active trial type. If no trial type has been defined, set';...
        'the active trial type to ''none''';''});
    disp(str)
    return
end

trial = Experiment.Info.ActiveTrialType(6:end); % save the active trial
% (without prepended 'Trial')
    
TSsettrial('none'); % so that apply stat doesn't check at the trial level
                        
try
    TSapplystat(stat,sesdata,funhand,varargin{:});   % Apply the stat
catch ME
    display(getReport(ME))
    if ~isempty(trial)
        TSsettrial(trial); % Restore active trial type setting when there
        % is an error
    end
        
    rethrow(lasterror);
end;

if ~isempty(trial) 
    TSsettrial(trial); % Restore active trial type setting when there
    % is an error
end