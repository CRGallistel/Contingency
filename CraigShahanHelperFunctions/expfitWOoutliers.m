function Params = expfitWOoutliers(D,Crit)
Params = [];
if ~isempty(D)
    D = D(D<Crit);
    Params = expfit(D);
end