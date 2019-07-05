function D = FixEventCodes(tsd)
LV=tsd(:,2)<15;
tsd(LV,2)=20;
tsd(~LV,2)=40;
D=tsd;