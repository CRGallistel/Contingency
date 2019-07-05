% TSDEFINETRIALTYPE  Define a trial type.
%   TSDEFINETRIALTYPE(TRIALNAME,CODES) defines a trial named <TRIALNAME>  
%   where <TRIALNAME> is a name of your choosing, such as, for example,
%   "CS1". CODES sequence of MATCHCODES specifying what constitutes this
%   kind of trial--see TSmatch for an explanation of matchcodes.
%   The code number 0 can be used to indicate the start of a session and
%   and the code number Inf can be used to indicate the end of a session.
%
%   TSdeclareeventcodes must be executed before TSDEFINETRIALTYPE so that 
%   the "dictionary" is in Matlab's workspace. The dictionary relates
%   text-specified events to the corresponding numerical event codes in the
%   data. (TSdeclareeventcodes will have been executed if the Experiment
%   structure has been loaded into the workspace using TSloadexperiment.)
%
%   Examples:
%
%       Simplest example would be:
%
%       TSdefinetrialtype('CS',[CSon CSoff]);
%       or
%       TSdefinetrialtype('IRI',[Feed Feed]);
%
%       A trial type may be defined by more than one matchcode sequence:
%
%       TSdefinetrialtype('ITI',{[CS1off CS1on] [CS1off CS2on] [CS2off CS2on] [CS2off CS1on]});
%
%       Negative event codes indicate events whose occurrence negates what
%       would otherwise be a trial sequence
%
%       TSdefinetrialtype('CS1iti', [CS1off -CS2on CS1on])
%       
%       Matchcode sequences, hence trial definitions, may be very complex
%           --see TSmatch documentation (and Chapter in Manual)
%
%	See also TSMATCH, TSSETTRIAL


function [result] = TSdefinetrialtype(trialname,varargin)

if evalin('base','isempty(who(''global'',''Experiment''))')    % Verifies that an Experiment structure exists
    error('There is no experiment structure');
    result=0;
    return;
end;

global Experiment;

name=['Trial' trialname];

if numel(varargin) == 1
varargin = varargin{:};
end

if isfield(Experiment, name) && ~isequal(Experiment.(name), varargin)
   warning('USER ATTEMPTED TO REDEFINE AN EXISTING TRIAL.');
   disp ('To continue with this operation, you must delete all existing references to this trial or');
   disp ('risk undefined behavior. To continue, please choose using the popup menu.');
   k = menu(['Really delete ' name '?'], 'No.','Yes, delete and use new definition.');
   if (k == 1)
       disp ('Operation aborted.');
       return;
   end
   TSrmfield(name);
   disp ('Operation succesful.');
end

Experiment.(name) = varargin;
Experiment.Info.ActiveTrialType = name;