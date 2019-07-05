function t = Tms(tsdata,Evnt)
t = tsdata(tsdata(:,2)==Evnt,1);