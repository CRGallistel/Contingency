function TSaddeventcodes(varargin)
% TSADDEVENTCODES Adds individual event codes to the Experiment structure
%   TSaddcodes( name, value ) adds event code definitions to the
%   Experiment structure. Name is a string for 1 code or a cellstr for 
%   multiple codes, indicating the names of the codes to add, and Value is
%   a scalar for one code or a vector for multiple codes indicating the
%   values the corresponding codes should have.
%
%   These codes are added to the current Experiment. They are not added to
%   the global workspace, so it is highly recommended to call
%   TSdeclareeventcodes after this function to ensure that all codes are
%   updated. It is not an error to overwrite a code using this function but
%   a warning will be issued. However, this may change, and we may adopt a
%   system which makes it an error to modify a code or load a new codeset
%   after declaring any trial definitions or performing any statistics, so
%   you are encouraged not to use this for that purpose. If you need to
%   know if a code is a member of the current Experiment, you can test
%   by calling: isfield(Experiment.EventCodes, 'codename')


if evalin('base', 'isempty(who(''global'',''Experiment''))')
    error('No experiment structure defined.');
    return;
end

global Experiment;

if ~isfield(Experiment,'EventCodes')
    Experiment.EventCodes = struct;
end

while numel( varargin ) > 1
name = varargin{1};
value = varargin{2};
if isnumeric(value) %if value is not numeric then this is hopeless
    if ischar(name)     %if name is a single string, then we only have 1 code to add
        if isfield(Experiment.EventCodes,name) %give a warning if it is already a field
            warning('TSaddeventcodes:CodeOverwritten','The code %s already existed with value %d, overwriting with value %d', name, Experiment.Codes.(name), value(1));
        end
        Experiment.EventCodes.(name) = value(1); %use name to reference the new location, and value(1) to handle the case that they mistakenly passed a vector or matrix                         
    end
end
varargin(1:2) = [];
end