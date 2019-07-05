function TSimporteventcodes(filename,inter)
% TSIMPORTEVENTCODES Imports event codes to the Experiment from a textfile.
%   TSimporteventcodes(filename) imports codes from an ascii textfile. This
%   can be a file made with TSexporteventcodes or made in a text editor.
%   This codeset will overwrite whatever codes were already on the
%   experiment. THERE MUST NOT BE ANY SPACES WITHIN THE EVENT CODES
%   THEMSELVES!! (Spaces before and after '=' are no problem)
%
%   You should use this function if you have multiple experiments each with
%   different event codes. You should also use this if you are publishing
%   your experiment file, so that people will have your codes when they
%   browse your structure.
%
%   If you want to use a codeset but do not have an Experiment structure
%   available, use TSsetdefaulteventcodes. This sets the codes that are
%   used by the TSlib routines when no Experiment is loaded.
%
%   You can use this to import a backup code set or someone else's code
%   set.
%
%   If the filename is left out, a UI dialog will pop up to choose a
%   file to load.
%
%   An example text file would be:
%
%   StartTrial = 121;
%   EndTrial = 131;
%   StartSession = 151;
%   EndSession = 141;
%   
%   LightOn1 = 41;
%   LightOff1 = 31;
%   LightOn1 = 42;
%   LightOff1 = 32;
%
%   PokeOn1 = 1011;
%   PokeOff1 = 1001;
%
%   ...
%
%   The text file is loaded and each line is evaled in matlab, one at a
%   time. The lines could in theory say anything; they are not parsed by
%   this function. However, you cannot use a for loop or while loop unless
%   it is all on one line, or else you will get an error.
%
%   After each line is evaluated, we check to see if any new variables were
%   created. If any were created, then a field is created in the code
%   structure with its name and value. If any were deleted, i.e. if you
%   used clear <varname> in the code file, then this will also be detected
%   and removed from the structure.
%
%   The only legal event codes are positive integers, and codes 10 and
%   below are reserved. Any variable defined in this file will become a
%   code, so if a for loop is used, the counter variable will become a code
%   unless it is cleared at the end of the code list file.
%
%   If there is a 2nd argument in the call, then the code will not open and
%   read an event codes file; rather it will interrogate the user in order
%   to obtain and pass on the parameters that need to be set
%
%   Calling this command with the same event names but different numerical
%   codes will overwrite the current contents of the EventCodes field in
%   the Experiment structure
global Experiment

if evalin('base','isempty(who(''global'',''Experiment''))');
    error('There is no Experiment structure defined');
end

if nargin < 1
    % Call up a file window for replacement code list
    [filename, pathname] = uigetfile('*', 'Find the Event Codes file'); % Changed to '*' -- not sure why *.* not working APK
	filename = [pathname filename];
end

if nargin > 1 % if there is a 2nd argument in the call. The value of
    % that 2nd argument is irrelevant; if there is a 2nd argument, that
    % means that the user is to be interrogated by the code that follows
%%
    % User-interrogation code here
    if isfield(Experiment.Subject(1),'Session') ...
            && isfield(Experiment.Subject(1).Session,'TSData') ...
            && ~isempty(Experiment.Subject(1).Session(1).TSData) % there are ts data
        
        EC = unique(Experiment.Subject(1).Session(1).TSData(:,2)); % the
        % event codes in the data from Subject(1), Session(1)
        EC(EC<=10)=[]; % deleting illegal event codes. These can occur as parameter
        % values at the beginning of TSData in the fully automated
        % situation
        fprintf('\n\nJudging by the data in the first session for the first subject,\nthese are the numerical event codes in the data:\n')
        fprintf('%d\n',EC') % displaying in the work space the event code
        % numbers found in the data
        
        if strcmp('n',input('Does this list include all the events\nto which you want to refer in your code? [y/n] ','s'))
            % list incomplete
            NewNum = true;
            while NewNum
                NewNm = input('Add an event code number to the list (hit rtn if done adding): ');
                if isempty(NewNm) % done adding to list of event code #s
                    NewNum = false;
                elseif NewNm<=10
                    fprintf('\n\nIllegal event code number; event code numbers must be >10\n')
                else % supplied another event code #
                    % Note to Xiatao: The user MAY enter an event code
                    % number that is already in an event code field, either
                    % because: 1) they made a mistake (typo or whatever) OR
                    % because they want to give that event a new name.
                    % Write code that checks whether is number is already
                    % in a field in event codes and if so, tells user this
                    % and asks "Was this a mistake or do you want to rename
                    % this event? [Answer m or r] " If it's a mistake,
                    % continue; if renaming, then remove the current field
                    % that contains this number from the event code fields
                    % and add this number to the NewNm vector
                    EC(end+1) = NewNm; % add to list of event code numbers
                    % to which event code names may be assigned
                end
            end % while loop that completes an incomplete list of event code numbers
        end % if list incomplete
                
    else % no data yet in structure

        fprintf('\nYou appear not to have loaded data.\nIt is better to do this after loading data,\nso that the event codes #s you give can be\nchecked against those actually in the raw data.\n\n')

        if strcmp('y',input('Continue nonetheless? [y/n] ','s')) % continue nonetheless
            % Xiaotao: Call embedded function that interrogates for event code names
            % and numbers without checking #s agains the list of actually 
            % used #s and which makes each name supplied a field in
            % Experiment.EventCodes and puts the corresponding # in it. NB.
            % This embedded subfunction must begin by declaring Experiment
            % a global variable. Function must be written!
            return % when that function is done running, we're done
            
        else % don't continue because there is no list of event code numbers
            % hence no events to which to assign names
            return
        end % continue nonetheless or don't continue
        
    end % Getting list of event code numbers (or doing without it)
    
    % Xiatao: If execution gets to here, then there is a non-empty NewNm
    % vector of event codes. This list can only have been obtained by
    % looking in 2nd col of TSData field. User MAY have added event code
    % numbers to this list. And, it may be the case that the user is adding
    % some events to the event codes already in the structure. In the
    % latter case, the user may unwittingly give an event name that is
    % already a field in the event codes structure, so check that each name
    % supplied is not already the name of a field in the event code
    % structure
       
    % Call embedded function that goes through the event code numbers (EC)
    % one by one, asking for each number whether user if s/he wants to
    % assign a name to that event. Then entering into the
    % Experiment.EventCodes field a field with the assigned name and
    % putting in it the corresponding event code #. NB This embedded
    % function must begin by declaring Experiment a global variable. 
    
    return % the code inside this if fills in the EventCodes field
    % of the Experiment structure. Therefore, it should end with a return, 
    % so that the rest of this code does not execute
    
end % of the user-interrogation code that operates when there is a 2nd
% input argument in the call to this function

script = {};
fid = fopen(filename);

if fid == -1 
    error('File I/O error; Matlab fopen function returned invalid file handle. Check that the file is in the path.');
    return
end

temp = fgetl(fid);
while ischar(temp)
    script{end+1} = temp;
    temp = fgetl(fid);
end
fclose(fid);

% purging spaces and other illegal characters
for i = 1:numel(script)
    while 1
        [b,e] = regexp(script{i},'\w\W\w','start','end'); % finds occurrences
        % of word characters followed by non word characters followed by
        % more word characters
        if isempty(b)
            break % when all offending characters removed
        else
            fprintf('\nDeleting illegal character from event code name\n')
            script{i} = [script{i}(1:b(1)) script{i}(e(1):end)]; % purging
            % first offending non-word character
        end % of if
    end
end % of purging non-word characters from variable names

% Script is now a character matrix containing the whole file. We will
% execute one line at a time until all are executed, and each time we add
% any new variables that have been created to the out struct. Any variables
% that get deleted we remove from the out struct. This ensures that codes
% are created in the out struct in the same order they are removed.

out = struct;
names = {};
oldnames = {};
i = 1;
j = 1;

for i = 1:numel(script)
    oldnames = who;
    % need to insert in this loop a check for spaces within the event code
    % names and delete those spaces
    eval(script{i});
    names = who;
    temp = setdiff(names, oldnames);
    if ~isempty(temp)
        for j = 1:numel(temp)
            out.(temp{j}) = eval(temp{j});
        end
    end
    
    temp = setdiff(oldnames, names);
    if ~isempty(temp)
        out = rmfield(out, temp);
    end
end

Experiment.EventCodes = out;

clearvars -except Experiment

TSdeclareeventcodes;

%% Embed a function here that asks user for names for events in the list of
% event code numbers and makes a field under Experiment.EventCodes out of
% each such name and assigns to it the corresponding numerical value