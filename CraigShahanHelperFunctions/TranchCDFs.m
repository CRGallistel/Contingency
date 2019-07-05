function TranchCDFs(pkrates,IRIs,Phase,Xlm)
% makes vertical tranches through the distribution of
% InterReinforcementIntervals (vertical axis) versus IRI peck rates
% (horizontal axis) and plots the cdfs for the tranches on a common plot.
% The tranches are the quintiles of the peck rate distribution
%
A = [pkrates IRIs];
Q = quantile(pkrates,[.2 .4 .6 .8]);
Mx = max(pkrates);
LV(:,1) = pkrates<=Q(1);
LV(:,2) = pkrates>Q(1)&pkrates<=Q(2);
LV(:,3) = pkrates>Q(2)&pkrates<=Q(3);
LV(:,4) = pkrates>Q(3)&pkrates<Q(4);
LV(:,5) = pkrates>Q(4);
%
S = evalin('caller','sub'); % subject
if S<2
    figure
end
subplot(4,2,S)
cdfplot(A(LV(:,1),2))
set(gca,'FontSize',12)
hold on
cdfplot(A(LV(:,2),2))
cdfplot(A(LV(:,3),2))
cdfplot(A(LV(:,4),2))
cdfplot(A(LV(:,5),2))
xlim(Xlm)
if S<2
    legend('Q1','Q2','Q3','Q4','Q5','location','SE')
end
if mod(S,2)>0
    ylabel({'Cum Fraction';'w/i Tranche IRIs'})
end
if S>6
    xlabel('IRI')
end
title(['Phase ' Phase ': S' num2str(S)])

