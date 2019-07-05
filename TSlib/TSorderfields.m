function TSorderfields(lvl,NwOrder)
% Syntax     TSorderfields(lvl,NwOrder)
% Reorders the fields at the level of the Experiment hierarchy specified by
% lvl (must be either 'Experiment' or 'Subject' or 'Session' or 'Trial').
% NwOrder must be a cell array containing in each cell one field name that
% exactly matches an existing field name at the specified level. There must
% be the same number of cells as there are field names. When the level is
% Trial, the reodering will apply to the fields of the active trial type.

global Experiment

switch lvl
    
    case 'Experiment'
        FldNms = fieldnames(Experiment);
        if length(NwOrder)==length(FldNms)
            try
                NwExp = orderfields(Experiment,NwOrder);
            catch ME
                EM = getReport(ME);
                fprintf('\nFailed to reorder fields at Experiment level\n%s\n',EM)
                return
            end
            
            Experiment=NwExp;
        else
            fprintf('\nFailed to reorder fields at Experiment level\nbecause length NwOrder cell array ~= # fields\n')
        end
        
    case 'Subject'
        
            FldNms = fieldnames(Experiment.Subject);
            if length(NwOrder)==length(FldNms)
                try
                    NwSb = orderfields(Experiment.Subject,NwOrder);
                catch ME
                    EM = getReport(ME);
                    fprintf('\nFailed to reorder fields at Subject level:\n%s\n',EM)
                end
                
                Experiment.Subject = NwSb;
            else
                fprintf('\nFailed to reorder fields at Subject level\nbecause length NwOrder cell array ~= # fields\n')
            end
        
        
    case 'Session'
        
        for sub = 1:Experiment.NumSubjects
            
            FldNms = fieldnames(Experiment.Subject(sub).Session);
            if length(NwOrder)==length(FldNms)
                try
                    NwSes = orderfields(Experiment.Subject(sub).Session,NwOrder);
                catch ME
                    EM = getReport(ME);
                    fprintf('Failed to reorder fields at Session level for Subject %d:%s\n',sub,EM)
                    continue
                end
                Experiment.Subject(sub).Session = NwSes;
            else
                 fprintf('Failed to reorder fields at Session level for Subject %d:\nbecause length of NwOrder not same as # of fields\n',sub)
                 continue
            end
            
        end % looping through subjects
        
    case 'Trial'
        trialname = Experiment.Info.ActiveTrialType;
        for sub = 1:Experiment.NumSubjects
            for ses = 1:Experiment.Subject(sub).NumSessions
                FldNms =fieldnames(Experiment.Subject(sub).Session(ses).(trialname).Trial);
                if length(FldNms)==length(NwOrder)
                    try
                        NwTrl = orderfields(Experiment.Subject(sub).Session(ses).(trialname).Trial,NwOrder);
                    catch ME
                        EM = getReport(ME);
                        fprintf('\nFailed to reorder fields for Trial Type %s of Subject(%d), Session(%d):\n%s\n',...
                            trialname,sub,ses,EM)
                        continue
                    end
                    Experiment.Subject(sub).Session(ses).(trialname).Trial = NwTrl;
                else
                    fprintf('\nFailed to reorder fields for Trial Type %s of Subject(%d), Session(%d)\n because length of NwOrder ~= # of fields\n',...
                        trialname,sub,ses)
                    continue
                end
                
            end
        end
end
                    
            
                