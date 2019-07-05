% TSINITEXPERIMENT  Create a new Experiment structure named "Experiment".
%   TSINITEXPERIMENT(NAME,IDNUM,SUBJECTS,SPECIES,LAB) creates a global
%   experiment structure called "Experiment" that contains the provided
%   information. NAME is the name of the experiment in String format.
%   IDNUM is the id number of the experiment.  SUBJECTS is an array of the 
%   subject id numbers.  SPECIES is the species of the subjects in String
%   format.  LAB is the lab in which the experiment was conducted in String
%   format.  
%
%   TSINITEXPERIMENT(NAME,IDNUM,SUBJECTS) performs the same task without
%   the optional arguments SPECIES and LAB.
%
%	See also TSLOADEXPERIMENT, TSSAVEEXPERIMENT

function TSinitexperiment(name,idnum,subjects,species,lab)

if evalin('base','~isempty(who(''global'',''Experiment''))') % Examines current base for global variable 'Experiment'
    button = questdlg('An experiment structure already exists. Would you like to overwrite it?','TSinitexperiment','No','Yes','Yes');
    if ~strcmp(button,'Yes')
        return;
    else clear global Experiment;
    end;
end;
        
evalin('base','global Experiment'); % Places global Experiment in base (it didn't exist before)

global Experiment;                  % Places global Experiment in current workspace

[stmp,i] = unique(subjects); % making sure there are no duplicate ID #s

if length(stmp) < length(subjects) % there were duplicate ID #s
    fprintf('\n\nSome Subject ID #s were duplicates.\nOnly the following unique IDs were accepted:\n')
    fprintf('%d\n',subjects(i)')
    fprintf('\n\n')
    subjects = stmp;
end

subsize = size(subjects);
if (subsize(2)==1 && subsize(1)>1) subjects = transpose(subjects); end;
% transposes column vector of subjects into a row vector

subjects = sort(subjects); % make sure subjects are in ascending order by ID

%Initialize fields of Experiment as empty cell arrays
Experiment.ExpNotes = '';
Experiment.Name = '';
Experiment.Id = [];
Experiment.StartDate = '';
Experiment.EndDate = '';
Experiment.Lab = '';
Experiment.Species = '';
Experiment.NumSubjects = [];
Experiment.Subjects = [];

Experiment.Name = name;
Experiment.Id = idnum;
Experiment.NumSubjects = length(subjects);
Experiment.Subjects = subjects;
if nargin>3 Experiment.Species = species; end;     % Stores species if entered
if nargin>4 Experiment.Lab = lab; end;             % Stores lab if entered

for tmpcnt = 1:Experiment.NumSubjects   % Initializes fields for each subject
    
    Experiment.Subject(tmpcnt).SubNotes = '';
	Experiment.Subject(tmpcnt).SubId = Experiment.Subjects(tmpcnt);
	Experiment.Subject(tmpcnt).Strain = '';
	Experiment.Subject(tmpcnt).Sex = '';
	Experiment.Subject(tmpcnt).BirthDate = '';
    Experiment.Subject(tmpcnt).ArrivalDate = '';
    Experiment.Subject(tmpcnt).ArrivalWeight = '';
    Experiment.Subject(tmpcnt).NumSessions = 0;
            
        Experiment.Subject(tmpcnt).Session.SesNotes = '';    
		Experiment.Subject(tmpcnt).Session.Weight = '';
		Experiment.Subject(tmpcnt).Session.Date = '';
		Experiment.Subject(tmpcnt).Session.StartTime = '';
		Experiment.Subject(tmpcnt).Session.Duration = [];
		Experiment.Subject(tmpcnt).Session.MatlabStartDate = [];
		Experiment.Subject(tmpcnt).Session.MatlabEndDate = [];
        Experiment.Subject(tmpcnt).Session.Experiment = [];   % What is this?!?!
        Experiment.Subject(tmpcnt).Session.Phase = [];
        Experiment.Subject(tmpcnt).Session.Box = [];
		Experiment.Subject(tmpcnt).Session.Program = 'No Programs Loaded';
        Experiment.Subject(tmpcnt).Session.TSData = [];
end;

versionstruct = ver('TSLib');   % How does ver work? Can we allow for other names TSLib?
versionstring = [versionstruct.Version ' ' versionstruct.Release];

TSlimit('all'); % Sets the default for all of the limit fields
Experiment.Info.ActiveTrialType = 'none';   % DW changed 7/24 to ActiveTrialType
Experiment.Info.ActiveData = 'TSData';
Experiment.Info.OverWriteMode = true;
Experiment.Info.FilesLoaded = {};
Experiment.Info.TSLibVersion = versionstring;
Experiment.Info.InputTimeUnit = .02;  % By default, raw files are assumed to be time stamped in 1/50 second
Experiment.Info.OutputTimeUnit = 1;   % Within the structure, the time unit defaults to 1 second
Experiment.Info.LoadFunction = 'TSloadMEDPC'; % By default, use the Gallistel Lab Med PC loader
Experiment.Info.FilePrefix = '!';
Experiment.Info.FileExtension = '';
Experiment.Info.ShowProgress=false;

Experiment.EventCodes = struct; % This creates an empty structure

%David added 2/14/07
initPrograms = 'No Programs Loaded';
Experiment.Programs.Program(1) = struct('Name', initPrograms, 'Code',initPrograms);
%end added code
