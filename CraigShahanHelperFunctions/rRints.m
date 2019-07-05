function Ints = rRints(tsd,Peck,Feed)

PT = tsd(tsd(:,2)==Peck,1)'; % row vector of the peck times

RT = tsd(tsd(:,2)==Feed,1); % vector of the reinforcement times

Ints=nan(length(PT),1);
r = 1;
for t = PT % stepping through the peck times
    try
        Ints(r,1) = RT(find(RT>t,1))-t;
    catch
        continue
    end
    r=r+1;
end