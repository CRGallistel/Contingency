function stringcells = TStranslate(ECvec)

% Translate numerical event codes into English
%
% translations = TStranslate(ECvec)
%
% this script will return a cell array with the string that corresponds to
% each Event Code given in ECvec. Event Codes with no matching string will
% be left empty.

global Experiment

[r c] = size(ECvec);
ECvec = reshape(ECvec,1,[]);

stringcells = cell(1,length(ECvec));

fnames = fieldnames(Experiment.EventCodes);

for i = 1:length(ECvec)
    
    j = 1;
    
%     for j = length(fnames)
        
    while ~(eval(['Experiment.EventCodes.' fnames{j}])==ECvec(i))
        
        j = j+1;
        
        if j>length(fnames)
            break
%             keyboard
        end
        
    end
    
    if j>length(fnames)
        stringcells{i} = [];
    else
        stringcells{i} = fnames{j};
    end
    
end