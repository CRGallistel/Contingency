function TSmakeemptyfield(L,F)
% Makes and empty field at Session or Subject level, so that code that
% assumes existence of a field for that session or subject will operate.
%
% Syntax: TSmakeemptyfield(L,F)
%
% The principal use of this function is for fields at the Session level
% that are looked at by graphics functions and that will not exist if their
% creation depends on fields at the Trial level that have not yet been
% created because it is early in a session and the subject in question has
% not get produced data that constitute a Trial, hence there are no trials
% of a given type yet. L is the level at which the field is to be created:
% Permissible values for L are 'Subject' or 'Session'. F is the name of the
% field to be created (for those active sessions or subjects for which that
% field is missing)
global Experiment
AS = TSgetlimit(Experiment.Info.ActiveSubjects,Experiment.NumSubjects);
% active subjects

switch L
    case 'Session'
        for S=AS % stepping through subjects
            as = TSgetlimit(Experiment.Info.ActiveSessions,Experiment.Subject(S).NumSessions);
                % active sessions
            for s=as % stepping through sessions
                if ~isfield(Experiment.Subject(S).Session(s),F)
                    Experiment.Subject(S).Session(s).(F)=[];
                    fprintf('\nCreated empty %s field for S%d, s%d\n',F,S,s)
                else
                    fprintf('\n%s field already exists for S%d, s%d\n',F,S,s)                    
                end
            end
        end 
    case 'Subject'
        for S=AS % stepping through subjects
            if ~isfield(Experiment.Subject(S),F)
                Experiment.Subject(S).(F)=[];
            end
        end       
end
