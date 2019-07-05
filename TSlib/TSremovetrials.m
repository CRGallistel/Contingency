function TSremovetrials(S,s,TT,trls,sup)
% removes trials from the specified trials from the specified trial type
% for the specified session of the specified subject.
%
% Syntax: TSremovetrials(Subject idx #,Session idx #,Trial type,trial #s,sup)
% sup is optional; if true, it suppresses the query

if nargin==4
    sup=false;
end
if sup
    Experiment.Subject(S).Session(s).(TT).trls=[];
    Experiment.Subject(S).Session(s).(TT).NumTrials = ...
        Experiment.Subject(S).Session(s).(TT).NumTrials-length(trls);
elseif strcmp('y',input('Do you want to remove Trials %d of Trial Type %s from Session %d of Subject %d? (y/n)')) 
    Experiment.Subject(S).Session(s).(TT).trls=[];
    Experiment.Subject(S).Session(s).(TT).NumTrials = ...
        Experiment.Subject(S).Session(s).(TT).NumTrials-length(trls);
end