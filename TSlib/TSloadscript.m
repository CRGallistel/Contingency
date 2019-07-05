function TSloadscript(FN)
% Reads the script that created and filled the Experiment structure into
% the Experiment structure in a field named Script at the Experiment level.
% Most useful when analysis is complete and one is archiving the structure.
% FN specifies the name of the .m script to be read in--WITHOUT THE .m
% EXTENSION
global Experiment

if isempty(Experiment)
    fprintf('\n\nNo Experiment structure in the workspace\n')
    return
end

if (isfield(Experiment,'Script')  && ~isempty(Experiment.Script) ... % there is already a non-empty Script field 
     &&   strcmp('n',...
    input('\n\nThere is a non-empty Experiment.Script field.\nOverwrite it? [y/n] ','s'))) % & user does not want to overwrite it
    return % bail
end

if nargin<1
    [FN,PN] = uigetfile('.m','Find Script');
    Experiment.Script = readtextfile_local([PN FN]); % reads the script into a
    % field named Script at the Experiment level
    
elseif exist([FN '.m'],'file')
    Experiment.Script = readtextfile_local([FN '.m']); % reads the script 
    % field named Script at the Experiment level
    
else % Can't find file
    if strcmp('y',input(['\n\nCannot find ' FN '.m.\nBrowse for it? [y/n] '],'s'))
        [FN,PN] = uigetfile('.m','Find Script');
        Experiment.Script = readtextfile_local([PN FN]); % reads the script into a
        % into a field named Script at the Experiment level
    end
end

fprintf('\n\nThe m-file %s has been written into Experiment.Script\n',FN)

function tab=readtextfile_local(FN)

% Read a text file into a matrix with one row per input line

% and with a fixed number of columns, set by the longest line.

% Each string is padded with NUL (ASCII 0) characters

%

% open the file for reading
disp (['Reading... ' filename])
ip = fopen(filename,'rt');          % 'rt' means read text

if (ip < 0)

    error(['could not open ' filename]);   % just abort if error

end;

% find length of longest line
max=0;                              % record length of longest string

cnt=0;                              % record number of strings

s = fgets(ip);                      % get a line

while (ischar(s))                   % while not end of file

   cnt = cnt+1;

   if (length(s) > max)           % keep record of longest

        max = length(s);

   end;

    s = fgets(ip);                  % get next line

end;

% rewind the file to the beginning

frewind(ip);

% create an empty matrix of appropriate size

tab=char(zeros(cnt,max));           % fill with ASCII zeros

% load the strings for real

cnt=0;

s = fgets(ip);

while (ischar(s))

   cnt = cnt+1;

   tab(cnt,1:length(s)) = s;      % slot into table

    s = fgets(ip);

end;

% close the file and return

fclose(ip);
disp ('Done.')