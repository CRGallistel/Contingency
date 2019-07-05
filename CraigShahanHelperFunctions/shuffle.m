function GD = shuffle(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10)
% rearranges the data from 10 fields into a single field to permit a
% simple graphics commands for each of the 4 subplots in a 2 panel x 2
% panel figure. CA is a 10-cell cell array. First 9 cells contain the
% computed restrospective contingencies for 9 delay conditions and 8
% subjects; 10th cell contains the normalized mean peck rates from the 15
% delay-of-reinforcement conditions
CA ={(C1) (C2) (C3) (C4) (C5) (C6) (C7) (C8) (C9) (C10)};
GD = double.empty(0,5); % initializing
for c = 1:9 % stepping through the contingency columns
    GD(end+1:end+8,1:4) = [CA{c}(:,1) CA{c}(:,2) CA{c}(:,3) CA{c}(:,4)];
end
CA{10}(:,[1 2 6 7 11 12])=[]; % deleting unused conditions (.1 & .04)
GD(:,5) = [reshape(CA{10}(:,[1 4 7]),24,1);reshape(CA{10}(:,[2 5 8]),24,1);...
    reshape(CA{10}(:,[3 6 9]),24,1)];