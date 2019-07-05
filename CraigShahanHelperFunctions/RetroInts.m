function [RbcktoP,RndTbcktoP] = RetroInts(D,P,R)
% computes the retrospective intervals necessary to compute the
% retrospective contingency, the intervals looking back from reinforcements
% to the most recent peck and the distribution looking back from randomly
% chosen points in time to the most recent peck. D is the data from the
% TSData field of a session; P is the numerical code for the Peck event; R
% is the numerical code for the Reinforcement event

LVp = D(:,2)==P; % flags pecks

if sum(LVp)==0 % if no pecks
    RbcktoP = []; % return empty values
    RndTbcktoP = [];
    return % terminate
end

rRw = find(D(:,2)==R); % reinforcement row numbers

n = numel(rRw); % number of reinforcements

RbcktoP = nan(n,1); % initializing vector

RndTbcktoP = nan(n,1); % initializing vector

%% computing intervals back from reinforcements
for i = 1:n % stepping through the reinforcements
    
    LV = LVp & D(:,1)<D(rRw(i),1); % flags pecks earlier than reinforcement
    % time: D(rRw(i),1) is the reinforcement time
    
    PrePcks = D(LV,1); % times for pecks preceding the reinforcement
    try
        RbcktoP(i) = D(rRw(i),1) - PrePcks(end);
    catch
        continue % sometimes a reinforcement is the first event, in which
        % case there is no retrospective interval
    end
end % of stepping though reinforcements computing intervals back to most
% recent peck

%% computing intervals back from random times

PckTms = D(LVp,1); % peck time vector

t = unifrnd(PckTms(1),D(rRw(end),1),n,1); % draws n times from distribution
% uniform on  the interval from the first peck to the last reinforcement,
% which is at time D(rRw(end),1)

A = sortrows([[t ones(size(t))];[PckTms zeros(size(PckTms))]],1);
% 2-col array combining random session times and peck times, with the
% random times flagged by 1's and the pecks times flagged by 0s. Array is
% sorted by event time

tRw = find(A(:,2)>0); % rows in A that contain random times

LVp2 = A(:,2)<1; % flags pecks in the A array

for i = 1:n % stepping through the random-time rows
    
    LVp3 = LVp2 & (A(:,1)<A(tRw(i),1)); % (A(:,1)<A(tRw(i),1)) flags the rows
    % less than the random time row. ANDing it with the peck flag flags the
    % pecks less than the random time
    
    PrePcks = A(LVp3,1); % peck times preceding the current random time
    
    RndTbcktoP(i) = A(tRw(i),1)-PrePcks(end); % interval from random time
    % back to the first preceding peck    
end
