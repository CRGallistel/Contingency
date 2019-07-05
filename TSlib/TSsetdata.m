% TSSETDATA  Set the currently active data.
%   TSSETDATA(DATANAME) sets DATANAME as the active data that will be used
%   for computing statistics.
%
%	See also TSSETTRIAL, TSSESSIONSTAT


function [result] = TSsetdata(dataname)

result = 0;

if evalin('base','isempty(who(''global'',''Experiment''))')
    error('There is no experiment structure');
    return;
end;

global Experiment;

Experiment.Info.ActiveData = dataname;

result = 1;


               