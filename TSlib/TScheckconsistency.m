function TScheckconsistency(mode)
% TScheckconsistency( MODE )
%   TScheckconsistency checks the consistency of the Experiment structure.
%   It recursively loops over all the substructures and checks that those
%   that have the same name, e.g. Subject, Session, Trial, etc., have the
%   same fields. If not it makes note of the differences and locations.
%   This is useful for checking that applystat and such worked, and it is
%   useful for showing that a set of applied limits worked.
%
%   Mode can be empty or can be a string with 'v' in it to signal verbose
%   output.

if evalin('base','~ismember(''Experiment'',who)')        % Verifies that an Experiment structure exists
    error('There is no expriment structure defined.');    % Will not execute if no Experiment has been set up
    result=0;
    return; 
end;

global Experiment;

structnames = {};
fields = {};
paths = {};
count = {};

[structnames, fields, paths, count] = myHelper(Experiment, 'Experiment', 'Experiment', structnames, fields, paths, count); %Gets all various struct data from recursive helper call

structnamescopy = structnames;

disp(' ');

disp (['There were ' int2str(length(structnames)) ' different structure types detected:']);

[structnamescopy{2,:}] = deal(', ');
%structnames{2, 1} = ['   , '];
structnamescopy{2, end} = '.';


disp (['  ' [structnamescopy{:}]]);

disp(' ');

for x = 1:length(structnames)
    disp([structnames{x} ':']);
    
    if (length(fields{x}) < 2)
        disp(['  All ' int2str(count{x}{1}) ' examples found were consistent.']);
    else
        %c = [count{x}{:}];
        %for (i
        intersectionoffields = fields{x}{1};
        for y = 2:length(fields{x})			%Intersects all the sets of field names iteratively
            intersectionoffields = intersect(fields{x}{y}, intersectionoffields);
        end
        
        %intersectionoffieldscopy = intersectionoffields;
        
        disp(['  ' int2str(length(fields{x})) ' inconsistent forms of ' structnames{x} ' were found.']);
        disp(' ');
        disp(['  These ' int2str(length(intersectionoffields)) ' fields were common to all examples:']);
        disp(' ');
        disp([repmat(' ', length(intersectionoffields), 4) char(intersectionoffields)]);
        
        totalcount = int2str(sum([count{x}{:}]));
        
        for y = 1:length(fields{x})
            uniquefields = setdiff(fields{x}{y}, intersectionoffields);		%Gets the set difference with the intersection set to find unique fields to this version of struct.
            
            if length(uniquefields) == 0
                disp(' ');
                disp(['  ' int2str(count{x}{y}) ' of ' totalcount ' cases had no additional fields:']);
            else
                disp(' ');
                disp(['  ' int2str(count{x}{y}) ' of ' totalcount ' cases had the following ' int2str(length(uniquefields)) ' fields:']);
                disp(' ');
            
                disp([repmat(' ', length(uniquefields), 4) char(uniquefields)]);
            end
            
            if nargin > 0 && ischar(mode) && any(mode == 'v')
                disp(' ');
                disp([repmat(' ', length(paths{x}{y}), 4) char(paths{x}{y})]);
                disp(' ');
            end
        end
        
    end
    
    disp(' ');
end

function [structnames, fields, paths, count] = myHelper(s, name, currentpath, structnames, fields, paths, count)
% Helper function which iteratively crawls over every nested structure, adding its name to the cell of struct names,
% its fields list to the cell of fields, the string to the cell of paths, and incrementing the count of different
% versions found.

fn = fieldnames(s);     % Get remaining field names.
[tf, loc] = ismember(name, structnames); %Check if this structure's name is in the list already.
if tf
    %Structure of this name is already on record, now check their field names to see if they are the same
    x = 1;
    foundit = false;
    while x <= length(fields{loc}) && ~foundit
        if all(ismember(fields{loc}{x}, fn)) && all(ismember(fn, fields{loc}{x})) %If all the fields of this are in record, and all the record are members of this ones fields, then they are the same set
            paths{loc}{x}{end+1} = currentpath; %Add current path to the list of examples of this type of struct
            count{loc}{x} = count{loc}{x} + 1;  %Increase the count for how many examples have been found of this type 
            foundit = true;
        end
        x = x + 1;
    end
    if ~foundit  %Found structure name already existed but did not match any recorded examples, create new entry created
        fields{loc}{end+1} = fn;
        paths{loc}{end+1} = {currentpath};
        count{loc}{end+1} = 1;
    end
else % Structure name did not exist on record, adding to the list
    structnames{end+1} = name;
    fields{end+1} = {fn};
    paths{end+1} = {{currentpath}};
    count{end+1} = {1};
end

for y = 1:prod(size(s)) % If this is a struct array, iterate through all of it.
for x = 1:length(fn)    % Now, for each field,
    if isstruct(s(y).(fn{x}))  % check if it is a struct
        [structnames, fields, paths, count] = myHelper(s(y).(fn{x}), fn{x}, [currentpath '(' int2str(y) ').' fn{x} ], structnames, fields, paths, count); % if so then traverse recursively into it and save any possible changes.
    end
end
end