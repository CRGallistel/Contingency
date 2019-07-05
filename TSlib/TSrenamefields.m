function TSrenamefields(Lev,Old,New)
% Renames the fields at level Lev whose names are given in the 'Old' cell
% array  with the new names given in the corresponding cells of the 'New'
% cell array. The Lev input must be one of the following strings:
% 'Experiment','Subject','Session','Trial' or 'Info'
%
% Syntax TSrenamefields(Lev,Old,New)
%
% When the Session level is specified, the name changes will occur only for
% the fields of the active subjects. When the Trial level is specified, the
% name changes will occur only for the active trial type in the active
% sessions of the active subjects. 'Info' is included among the possible
% values for Lev to allow changing the 'ActiveTrials' field to
% 'ActiveTrialType'. This was created 12/26/2016 and has not been well
% tested--CRG. Have used it several times as of 3/15/2018 & it worked every
% time
global Experiment
Old = reshape(Old,numel(Old),1);
New = reshape(New,numel(New),1);

if length(New)~=length(Old)
    fprintf('\nInput error:\nOld and New inputs must be cell arrays with same number of cells\n')
    return
end

if ~any(strcmp(Lev,{'Experiment' 'Subject' 'Session' 'Trial'}))
    fprintf('\nInput error:\nLev must be one of the following strings:\n''Experiment'', ''Subject'', ''Session'', ''Trial'' or ''Info''\n')
end

switch Lev
    case 'Experiment'
        FldNames = fieldnames(Experiment); % cell array with the names of 
        % all the fields at the Experiment level
        %%
        for c = 1:length(Old) % stepping through the old names
            FldNames{strcmp(Old{c},FldNames)} = New{c}; % puts the new field
            % name in the cell that contains the old one
        end
        %%
        c = struct2cell(Experiment); % converts Experiment structure to a
        % cell array
        Experiment = cell2struct(c,FldNames); % converts back again, but
        % using the modified FldNames cell array for the field names
        
    case 'Subject'
        FldNames = fieldnames(Experiment.Subject); % cell array with the  
        % names of all the fields at the Subject level
        for c = 1:length(Old) % stepping through the old names
            if isfield(Experiment.Subject,Old{c})
                FldNames{strcmp(Old{c},FldNames)} = New{c}; % puts the new 
            % field name in the cell that contains the old one
            else
                continue
            end
        end

        c = struct2cell(Experiment.Subject); % converts Experiment structure to a
        % cell array
        Experiment.Subject = cell2struct(c,FldNames); % converts back again, 
        % but using the modified FldNames cell array for the field names
        
    case 'Session'
        %%
        for S = TSgetlimit(Experiment.Info.ActiveSubjects,Experiment.NumSubjects)
            FldNames = fieldnames(Experiment.Subject(S).Session); % cell   
            % array with the names of all the fields at the Session level
            % for this subject
            %%
            for c = 1:length(Old) % stepping through the old names
                if isfield(Experiment.Subject(S).Session,Old{c})
                    FldNames{strcmp(Old{c},FldNames)} = New{c}; % puts the  
                % new field name in the cell that contains the old one
                else
                    continue
                end
            end
%%
            c = struct2cell(Experiment.Subject(S).Session); % converts
            % Experiment.Subject(S).Session structure to a cell array
            Experiment.Subject(S).Session = cell2struct(c,FldNames); % converts
            %  back again, but using the modified FldNames cell array for
            % the field names
        end
    case 'Trial'
        %%
        for S = TSgetlimit(Experiment.Info.ActiveSubjects,Experiment.NumSubjects)
            for s = TSgetlimit(Experiment.Info.ActiveSessions,Experiment.Subject(S).NumSessions)
                if isfield(Experiment.Subject(S).Session(s),Experiment.Info.ActiveTrialType)
                    FldNames = fieldnames(Experiment.Subject(S).Session(s).(Experiment.Info.ActiveTrialType).Trial); % cell   
                    % array with the names of all the fields at the Session level
                    % for this subject
                    %%
                    for c = 1:length(Old) % stepping through the old names
                        if isfield(Experiment.Subject(S).Session(s).(Experiment.Info.ActiveTrialType).Trial,Old{c})
                            FldNames{strcmp(Old{c},FldNames)} = New{c}; % puts the  
                        % new field name in the cell that contains the old one
                        else
                            continue
                        end
                    end
        %%
                    c = struct2cell(Experiment.Subject(S).Session(s).(Experiment.Info.ActiveTrialType).Trial); 
                    % % converts Experiment.Subject(S).Session.(Experiment.Info.ActiveTrialType).Trial
                    % structure to a cell array
                    Experiment.Subject(S).Session(s).(Experiment.Info.ActiveTrialType).Trial = cell2struct(c,FldNames); % 
                    %  converts back again, but using the modified FldNames 
                    % cell array for the field names
                else
                    continue
                end
            end
        end
        
    case 'Info'
        FldNames = fieldnames(Experiment.Info); % cell array with the names of 
        % the fields in Experiment.Info
        %%
        for c = 1:length(Old) % stepping through the old names
            FldNames{strcmp(Old{c},FldNames)} = New{c}; % puts the new field
            % name in the cell that contains the old one
        end
        %%
        c = struct2cell(Experiment,Info); % converts Experiment.Info
        %  structure to a cell array
        Experiment.Info = cell2struct(c,FldNames); % converts back again, 
        % but using the modified FldNames cell array for the field names
end