function MnR = MeanPckRatesV2(R,cond)
% computes the mean peck rate for the phases specified by cond argument,
% values for which are 'VI', 'Gratis' and 'Delay'
switch cond
    case 'VI'
        LV30 = R(:,2)<11; % logical vector flagging sessions for 1 phase
        LV165 = (R(:,2)>10)&(R(:,2)<21);
        LV300 = (R(:,2)>20)&(R(:,2)<31);
        MnR(1) = mean(R(LV30));
        MnR(2) = mean(R(LV165));
        MnR(3) = mean(R(LV300));
    case 'Gratis'
        LV167 = (R(:,2)>255)&(R(:,2)<276);
        LV56 = (R(:,2)>275)&(R(:,2)<316);
        LV28 = (R(:,2)>315)&(R(:,2)<356);
        LV0 = R(:,2)>355;
        MnR(1) = mean(R(LV167));
        MnR(2) = mean(R(LV56));
        MnR(3) = mean(R(LV28));
        MnR(4) = mean(R(LV0));
    case 'Delay'
        LV150 = (R(:,2)>30)&(R(:,2)<46);
        LV151 = (R(:,2)>45)&(R(:,2)<61);
        LV154 = (R(:,2)>60)&(R(:,2)<76);
        LV1516 = (R(:,2)>75)&(R(:,2)<91);
        LV1564 = (R(:,2)>90)&(R(:,2)<106);
        LV600 = (R(:,2)>105)&(R(:,2)<121);
        LV601 = (R(:,2)>120)&(R(:,2)<136);
        LV604 = (R(:,2)>135)&(R(:,2)<151);
        LV6016 = (R(:,2)>150)&(R(:,2)<166);
        LV6064 = (R(:,2)>165)&(R(:,2)<181);
        LV2400 = (R(:,2)>180)&(R(:,2)<196);
        LV2401 = (R(:,2)>195)&(R(:,2)<211);
        LV2404 = (R(:,2)>210)&(R(:,2)<226);
        LV24016 = (R(:,2)>225)&(R(:,2)<241);
        LV24064 = (R(:,2)>240)&(R(:,2)<256);
        MnR(1) = mean(R(LV150));
        MnR(2) = mean(R(LV151));
        MnR(3) = mean(R(LV154));
        MnR(4) = mean(R(LV1516));
        MnR(5) = mean(R(LV1564));
        MnR(6) = mean(R(LV600));
        MnR(7) = mean(R(LV601));
        MnR(8) = mean(R(LV604));
        MnR(9) = mean(R(LV6016));
        MnR(10) = mean(R(LV6064));
        MnR(11) = mean(R(LV2400));
        MnR(12) = mean(R(LV2401));
        MnR(13) = mean(R(LV2404));
        MnR(14) = mean(R(LV24016));
        MnR(15) = mean(R(LV24064));
end
