function [result] = TSrmeventcodes(codes)
% TSRMCODES Removes event codes from the Experiment structure
%   TSrmcodes( codes ) removes event code definitions from the
%   Experiment structure. Codes can be a string indicating the name of the
%   code, a number indicating the value the code has, a cell string
%   containing the names of multiple codes to remove, or a matrix
%   containing multiple values to be removed. 
%
%   These codes are removed from the current Experiment and cleared from
%   the global workspace as well. If the code is not found in the Code
%   structure, it will not be cleared.

result = 0;
if evalin('base', 'isempty(who(''global'',''Experiment''))') %Make sure global Experiment exists
    error('No experiment structure defined.');
    return;
end

global Experiment;

if ~isfield(Experiment,'EventCodes')
    Experiment.EventCodes = struct;
end

if ischar(codes) 
    if ~isfield(Experiment.EventCodes,codes)         %if this code is not a field, throw a warning and skip
        warning('TSrmeventcodes:CodeNotFound','The code %s does not exist, skipping.', codes);
    else                                        %otherwise use rmfield to remove it.
        Experiment.EventCodes = rmfield(Experiment.EventCodes, codes);
        eval(['clear global ' codes]);
    end
    result = 1;
elseif iscellstr(codes)
    try
        Experiment.EventCodes = rmfield(Experiment.EventCodes, codes); %rmfield works for cellstr's, but it throws an error and aborts if one is not found, which is not what we want.
        codes{2,:} = ' ';  %spaces are needed between the strings when it is evaled. we place ' ' below each string so that they are collated when we use [codes{:}].
        eval(['clear global ' [codes{:}]]);
        codes(2,:) = [];
    catch
        for i = 1:numel(codes)                              %if it does throw an error, then do them one at a time and throw individual warnings.
            if ~isfield(Experiment.EventCodes, codes{i})
                warning('TSrmeventcodes:CodeNotFound','The code %s does not exist, skipping.', codes{i});
            else
                Experiment.EventCodes = rmfield(Experiment.EventCodes, codes{i});
                eval(['clear global ' codes{i}]);
            end
        end
    end
    result = 1;
elseif isnumeric(codes)                         %if the code is a singular or a matrix
    codenames = fieldnames(Experiment.EventCodes);   %codenames is the cell of names
    codenums = struct2cell(Experiment.EventCodes);   %codenums is the matching cell of values
    
    [tf, loc] = ismember(codes, [codenums{:}]); %handling the matrix case and scalar case in one call, using ismember
    
    %loc(tf) takes the loc array of indexes returned by ismember and keeps
    %only those that are indices to codes that were found rather than -1's 
    %to indicate failure.
    %since this is a matrix of indices, we use it to reference the
    %codenames cellstring for the corresponding codenames to the codes that
    %were found. These are the names of codes to be removed, and since
    %rmfield takes cellstrings, we just pass it to rmfield.
    
    codenames = codenames(loc(tf));
    
    Experiment.EventCodes = rmfield(Experiment.EventCodes, codenames);
    
    codenames{2,:} = ' '; %spaces are needed between the strings when it is evaled. we place ' ' below each string so that they are collated when we use [codenames{:}].
    eval(['clear global ' [codenames{:}]]);
    codenames(2,:) = [];

    %If all codes are found in Experiment.EventCodes, then tf will be all true.
    %If any are not true, we find those and for each one throw a warning.
    %Then we are done.
    if any(~tf)
        for x = find(~tf)
            warning('TSrmeventcodes:CodeNotFound','The code %d does not exist, skipping.', codes(i));
        end
    end
    result = 1;
end


if (result == 0)
    warning('Bad argument form to TSrmeventcodes, no action taken.');
end