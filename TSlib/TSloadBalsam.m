function [Success,ExpID,SubID,Phase,Box,MatlabStartDate,Duration,tsdata,...
    Notes,Weight,Program,FileReportedUnits] = TSloadBalsam(filename)

D = dlmread(filename); % D is 2 columns of data, with first 12 columns being
% header info

Success = false;

SubID = D(8,1);

Duration = D(end,1);

tsdata = D(13:end,:);

ExpID = D(7,1);

Phase = D(9,1);

Box = D(10,1);

MatlabStartDate = datenum([D(3,1) D(1,1) D(2,1)]);

Notes=[];

Weight = [];
Program = [];
FileReportedUnits =[];

Success=true;