function [Success,ExperimentID,SubID,Phase,Box,MatlabStartDate,...
    Duration,tsdata,Notes,Weight,Program,FileReportedUnits] = ...
    TSloadBalsamRaw(filename)
% reads Balsam's raw data files, which have text headers followed by a
% single column of raw data in which the last 4 digits are event codes, and
% the times in 0.1 s are the digits to the left of the 6th digit from the
% right.
ExperimentID = 2000; % ID # for the experiment. This was assigned after data
% collection and is not anywhere in file name or data, so must be put in
% here when this code is run
Notes = [];
Weight = [];
Program = [];
FileReportedUnits = [];

Success = 0;
raw = fileread(filename); % reads entire file into one humongous 1-line string
%%
r = strfind(raw,'Subject:')+9; % start of subject ID
SubID = str2double(raw(r:r+2)); % subject ID; % one of the outputs
%% Start Date and Duration
r = strfind(raw,'Start Date:')+12; % start of start date
mo = str2double(raw(r:r+1));
dy = str2double(raw(r+3:r+4));
yr = str2double(raw(r+6:r+7))+2000;
r = strfind(raw,'Start Time:')+12; % start of start time
hr = str2double(raw(r:r+1));
mn = str2double(raw(r+3:r+4));
sc = str2double(raw(r+6:r+7));

DateVec = [yr mo dy hr mn sc]; % Matlab date vector for start

MatlabStartDate = datenum(DateVec); % One of the outputs: start date in
% Matlab's serial date number format
%% Duration
r = strfind(raw,'End Date:')+10; % start of start date
mo = str2double(raw(r:r+1));
dy = str2double(raw(r+3:r+4));
yr = str2double(raw(r+6:r+7))+2000;
r = strfind(raw,'End Time:')+10; % start of start time
hr = str2double(raw(r:r+1));
mn = str2double(raw(r+3:r+4));
sc = str2double(raw(r+6:r+7));
Duration = datenum([yr mo dy hr mn sc]) - MatlabStartDate;
% duration in Matlab serial date format. One of the outputs

%%
r = strfind(raw,'Group: ')+7; % start of text specifying Group/Phase
% I need to ask Peter what the different codes are and then convert them to
% numbers
Phase = str2double(raw(r));
% Grp = raw(r:r+6);
% switch Grp
%     case 'CS30Fix'
%         Phase = 1; % Phase, i.e., condition code; another output
%     case 'CS30Var'
%         Phase = 2;
%     case 'CS50Fix'
%         Phase = 3;
%     case 'CS50Var'
%         Phase = 4;
% end
%%
r = strfind(raw,'Box: ')+5;
Box = str2double(raw(r:r+2)); % box number; another output
%%
r = strfind(raw,'0:  '); % r(1) = start of A array
C = textscan(raw(r(1)+3:r(1)+67),'%u32');
% try
%     Notes = sprintf('VI = %s s, R delay = %s hundreths of a s',num2str(C{1}(1,:)),...
%         num2str(C{1}(5,:)+1)); % puts condition parameters in the Notes output
% catch ME
%     fprintf('\nProblem with %s\n',filename)
%     disp(getReport(ME))
% end
%%
r = strfind(raw,'W:')+1; % start of data
txtdata=raw(r:end); % raw data, but with line returns and line #s
txtdata=regexprep(txtdata,'\r\n|\n|\r',''); % takes out the line returns
txtdata=regexprep(txtdata,'\d+:',''); % takes out what was the 1st col (line #s)
D = str2num(txtdata(2:end))'; % converts to numerical column vector
%%
tsdata = [floor(D/10^5)/10  D-((floor(D/(10^5)))*(10^5))];
% converting data to time in MedPC clock ticks (col 1) and event codes (col
% 2); another output
Success=true;
