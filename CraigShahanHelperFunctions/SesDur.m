function DurInMins = SesDur(ED,SD)

DurInMins = []; % always begin by assigning an empty output, so that if the
% helper function does not succeed; it nonetheless returns a result

if isempty(ED) || isempty(SD) % always check for empty inputs
    return
else
    DrFrac = ED-SD; % the fraction of a day
    DurInMins = DrFrac*60*24;
end