function Ints = rndtRints(tsd,Peck,Feed)

NumPcks = sum(tsd(:,2)==Peck);

rndt = sort(unifrnd(0,tsd(end,1),1,NumPcks)); % row vector with as many
% randomly chosen points in totalized session time as there are number of
% pecks, sorted so that they strictly increase

RT = tsd(tsd(:,2)==Feed,1); % col vector of the reinforcement times

Ints=nan(NumPcks,1);

r=1;
for t = rndt % stepping through the randomly chosen points    
    try
        Ints(r,1) = RT(find(RT>t,1))-t; % interval to next R
    catch
        continue
    end
    r=r+1;
end