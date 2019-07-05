% TSRMFIELD     Removes all instances of a field from the specified level
%
%   Syntax:  TSrmfield(Level,field,SupQuery)
%
%   Level is a string specifying the level of the Experiment structure from
%   which the field is to be removed. It must be one of the following:
%          'Experiment' 'Subject' 'Session' 'Trial'
%   field is a string specifying the name of the field to be removed
% SupQuery allows the suppression of the query


function TSrmfield(Level,field,SupQuery)

if evalin('base','isempty(who(''global'',''Experiment''))')        % Verifies that an Experiment structure exists
    error('There is no experiment structure defined.');    % Will not execute if no Experiment has been set up
elseif ~strcmp(Level,{'Experiment' 'Subject' 'Session' 'Trial'})
    fprintf('\nFirst argument must be one of the following level-identifying words:\n    Experiment Subject Session Trial\nenclosed in single quotes\n')
    return
end

global Experiment;

if nargin<3
    SupQuery=false;
end

if SupQuery
    
    switch Level
    
    case 'Experiment'

        Experiment = rmfield(Experiment,field);

    case 'Subject'

        Experiment.Subject = rmfield(Experiment.Subject,field);

    case 'Session'
        
        for S=1:Experiment.NumSubjects

            Experiment.Subject(S).Session = rmfield(Experiment.Subject(S).Session,field);
        end
        
    case 'Trial'
        
        trialname = Experiment.Info.ActiveTrialType; % active trial
       
        if strcmp('all',Experiment.Info.ActivePhases)
            AS = TSgetlimit(Experiment.Info.ActiveSubjects,Experiment.NumSubjects);
            % vector of active subjects
            APs = unique([Experiment.Subject(AS(1)).Session.Phase]);
            % vector of active phases
        else
            APs = Experiment.Info.ActivePhases;
        end

        for S = 1:Experiment.NumSubjects
            for s = 1:Experiment.Subject(S).NumSessions
                if ismember(Experiment.Subject(S).Session(s).Phase,APs) &&...
                        isfield(Experiment.Subject(S).Session(s),trialname)

                    Experiment.Subject(S).Session(s).(trialname).Trial =...
                        rmfield(Experiment.Subject(S).Session(s).(trialname).Trial,field);
                end
            end
        end
    end
    
else % don't suppress query to user
    
    switch Level

        case 'Experiment'

            if strcmp('y',input(sprintf('\nDo you want to remove the field %s from the Experiment level? [y/n] ',field),'s'))

                try
                    Experiment = rmfield(Experiment,field);
                catch ME
                    disp(getReport(ME))
                    return
                end
            else
                return
            end

        case 'Subject'

            if strcmp('y',input(sprintf('\nDo you want to remove the field %s from the Subject level? [y/n] ',field),'s'))
                try
                    Experiment.Subject = rmfield(Experiment.Subject,field);
                catch ME
                    disp(getReport(ME))
                    return
                end
            else
                return
            end

        case 'Session'

            if strcmp('y',input(sprintf('\nDo you want to remove the field %s from the Session level? [y/n] ',field),'s'))

                for S=1:Experiment.NumSubjects
                    try
                        Experiment.Subject(S).Session = rmfield(Experiment.Subject(S).Session,field);
                    catch ME
                        disp(getReport(ME))
                        fprintf('\nSubject %d, field %s\n',S,field)
                        if strcmp('y',input('Continue w further subjects? (y/n)','s'))
                            continue
                        else
                            return
                        end
                    end
                end
            else
                return
            end

        case 'Trial'

            trialname = Experiment.Info.ActiveTrialType; % active trial
            
            if strcmp('y',input(sprintf('\nDo you want to remove the field %s from the Trials of Type %s? [y/n] ',field,trialname),'s'))
                
                if strcmp('all',Experiment.Info.ActivePhases)
                    AS = TSgetlimit(Experiment.Info.ActiveSubjects,Experiment.NumSubjects);
                    % vector of active subjects
                    APs = unique([Experiment.Subject(AS(1)).Session.Phase]);
                    % vector of active phases
                else
                    APs = Experiment.Info.ActivePhases;
                end

                for S = 1:Experiment.NumSubjects
                    for s = 1:Experiment.Subject(S).NumSessions
                        if ismember(Experiment.Subject(S).Session(s).Phase,APs)
                            
                            Experiment.Subject(S).Session(s).(trialname).Trial =...
                                rmfield(Experiment.Subject(S).Session(s).(trialname).Trial,field);
                        end
                    end
                end
            else
                return
            end
    end
end