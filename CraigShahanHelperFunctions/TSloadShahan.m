function [Success,ExpID,SubID,Phase,Box,MatlabStartDate,Duration,tsdata,...
    Notes,Weight,Program,FileReportedUnits] = TSloadShahan(filename)
% loads files from Shahan lab
%%
Success = 0;
raw = fileread(filename); % reads file
%%
r = strfind(raw,'!'); % start of date
str = raw(r+1:r+16); % string containing the start date
%
MatlabStartDate = datenum([str2num(regexprep(str,'-|_|h',' ')) 0]); % computes
% start date in Matlab serial number format. This is one of the outputs

%%
r=strfind(raw,'Subject'); % indices where 'Subject' begins
SubID = str2num(raw(r(1)+7:r(1)+14)); % subject's ID # is found in these
% positions)
%%
ExpID = 1000; % ID # for the experiment
%%
r = strfind(raw,'Group: ');
Phase = str2num(raw(r+7:r+9)); % Phase, i.e., condition code
%%
r = strfind(raw,'Box: ');
Box = str2num(raw(r+5:r+7)); % box number
%%
r = strfind(raw,'0:  '); % r(1) = start of A array
C = textscan(raw(r(1)+3:r(1)+67),'%u32');
try
    Notes = sprintf('VI = %s s, R delay = %s hundreths of a s',num2str(C{1}(1,:)),...
        num2str(C{1}(5,:)+1)); % puts condition parameters in the Notes output
catch ME
    fprintf('\nProblem with %s\n',filename)
    disp(getReport(ME))
end
%%
rb = strfind(raw,'C:'); % start of C array
re = strfind(raw,'D:'); % start of D array (following end of C array)
txtdata = raw(rb(2) + 2:re-1); % just the array btw C: and D:
txtdata=regexprep(txtdata,'\r\n|\n|\r',''); % takes out the line returns
txtdata=regexprep(txtdata,'\d+:',''); % takes out what was the 1st col (line #s)
D = str2num(txtdata)'; % converts to numerical column vector
tsdata=[floor(D) 100*(D - floor(D))]; % data array w time in MedPC ticks

%%
DayDur=24*3600*100; % duration of a day in hundreths of a second
Dur = tsdata(end,1)/DayDur; % duration of the session as a fraction of
% a day (24 hrs)
MatlabEndDate = MatlabStartDate + Dur;
Duration = []; % duration of session computed in TSloadSessions
Weight = [];
Program = '';
FileReportedUnits = .01;
Success = 1;

%%

%


