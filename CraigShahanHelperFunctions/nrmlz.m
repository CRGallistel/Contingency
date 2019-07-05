function PRn = nrmlz(PR)
M = max(PR,[],2); % max peck rate for each bird
NF = repmat(M,1,size(PR,2)); % making array same size as PR
PRn = PR./NF; % dividing by normalizing factor