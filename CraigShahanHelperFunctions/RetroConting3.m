function Cont = RetroConting3(RbcktoPints,RndTbcktoPints,fig)
% computes an estimate of the retorcontingency given the 
% precision (in bits) with which intervals are assumed to be represented.
% The precision is determined by the assumed Weber fraction. An assumed
% fraction of .125 implies 4 bits of precision, which is to say a standard
% deviation of 1/2^(bts-1) = 1/2^3 = 1 part in 8 of the mean; whereas an
% assumed fraction of .25 implies 3 pits of precision, which is to say a
% standard deviation of 1/2^2 = 1 part in 4 of the mean. It returns a row
% vector of 4 estimates. Element 1 assumes 3-bit representation of the
% intervals with linear bin widths; Element 2 assumes 3-bit rep w log bin
% widths; Element 3 assumes 4-bit rep w linear bin widths; Element 4
% assumes 4-bit rep w log bin widths. This is the code that revealed the
% minimum contingency when the entropies of hang-fire delay distributions 
% are computed using linear partitions.  
%
if isempty(fig)
    fig = false;
end
Cont = nan(1,4);
LRbcktoPints = log10(RbcktoPints);
LRndTbcktoPints = log10(RndTbcktoPints);
%
Mn = min([LRbcktoPints;LRndTbcktoPints]);
LRbcktoPintsT = abs(Mn) + LRbcktoPints; % all logs >=0
LRndTbcktoPintsT = abs(Mn) + LRndTbcktoPints; % ditto
%
Mxlin = max([RbcktoPints;RndTbcktoPints]); % longest interval
Mx = max([LRbcktoPintsT;LRndTbcktoPintsT]); % biggest log

Lvls8 = 8; % # number of distinguishable intervals; hence # of bins in
% plug=in entropy; hence # of distinct probabilities
Lvls16 = 16;
dF8 = 1/Lvls8; % delta fraction
dF16 = 1/Lvls16;
%
CVf8 = [.5*dF8 dF8*(1:(Lvls8-1))+.5*dF8]'; % critical levels within the range
EdgesLog8 = [0;CVf8*Mx]; % logarithmic bin edges
EdgesLin8 = [0;CVf8*Mxlin]; % linear bin edges

CVf16 = [.5*dF16 dF16*(1:(Lvls16-1))+.5*dF16]'; % critical levels within the range
EdgesLog16 = [0;CVf16*Mx]; % logarithmic bin edges
EdgesLin16 = [0;CVf16*Mxlin]; % linear bin edges
%
N8 = histc(LRbcktoPintsT,EdgesLog8); % counts for the conditional distribution
% using logarithmic bins
Nl8 = histc(RbcktoPints,EdgesLin8);

N16 = histc(LRbcktoPintsT,EdgesLog16); % counts for the conditional distribution
% using 16 logarithmic bins
Nl16 = histc(RbcktoPints,EdgesLin16); % ditto for linear bins

if fig
    S=evalin('caller','sub');
    figure
    subplot(4,2,1)
        bar(EdgesLin8,Nl8,'hist');title('CondCnts Lin8');xlabel('P<?R (s)')
    subplot(4,2,2)
        bar(EdgesLog8+Mn,N8,'hist');title('CondCnts Log8');xlabel('log_1_0(P<?R)')
    subplot(4,2,5)
        bar(EdgesLin16,Nl16,'hist');title('CondCnts Lin16');xlabel('P<?R (s)')
    subplot(4,2,6)
        bar(EdgesLog16+Mn,N16,'hist');title('CondCnts Log16');xlabel('log_1_0(P<?R)')
end
p8 = N8/sum(N8); % counts into log bins converted to probabilities
pl8 = Nl8/sum(Nl8); % counts into linear bins converted to probabilities

p16 = N16/sum(N16); % counts into log bins converted to probabilities
pl16 = Nl16/sum(Nl16); % counts into linear bins converted to probabilities

H_Rb8 = nansum(p8.*log(1./p8)); % estimated entropy of the RbcktoP, the
%  entropy of the conditional distribution using 8 log bins
H_RbL8 = nansum(pl8.*log(1./pl8)); % ditto using 8 linear bins

H_Rb16 = nansum(p16.*log(1./p16)); % estimated entropy of the RbcktoP, the
%  entropy of the conditional distribution using 16 log bins
H_RbL16 = nansum(pl16.*log(1./pl16));

N8 = histc(LRndTbcktoPintsT,EdgesLog8); % counts in log bins for Pck<-RndT
Nl8 = histc(RndTbcktoPints,EdgesLin8); % ditto for linear bins

N16 = histc(LRndTbcktoPintsT,EdgesLog16); % counts in log bins for Pck<-RndT
Nl16 = histc(RndTbcktoPints,EdgesLin16); % ditto for linear bins
if fig
    subplot(4,2,3)
        bar(EdgesLin8,Nl8,'hist');title('UnCondCnts Lin8');xlabel('P<?rndT (s)')
    subplot(4,2,4)
        bar(EdgesLog8+Mn,N8,'hist');title('UnCondCnts Log8');xlabel('log_1_0(P<?rndT)')
    subplot(4,2,7)
        bar(EdgesLin16,Nl16,'hist');title('UnCondCnts Lin16');xlabel('P<?rndT (s)')
    subplot(4,2,8)
        bar(EdgesLog16+Mn,N16,'hist');title('UnCondCnts Log16');xlabel('log_1_0(P<?rndT)')
end   
P8 = N8/sum(N8); % converted to probabilities
Pl8 = Nl8/sum(Nl8);

P16 = N16/sum(N16); % converted to probabilities
Pl16 = Nl16/sum(Nl16);

H_rndTb8 = nansum(P8.*log(1./P8)); % entropy of the RndTbcktoP, the entropy
% of the uncondtional or basal distribution, using log bins
H_rndTbL8 = nansum(Pl8.*log(1./Pl8)); % ditto for linear bins

H_rndTb16 = nansum(P16.*log(1./P16)); % entropy of the RndTbcktoP, the entropy
% of the uncondtional or basal distribution, using log bins
H_rndTbL16 = nansum(Pl16.*log(1./Pl16)); % ditto for linear bins

Cont(1,1) = (H_rndTbL8 - H_RbL8)/H_rndTbL8; % subjective contingency w
% linear bins and 3 bit temporal resolution
Cont(1,2) = (H_rndTb8 - H_Rb8)/H_rndTb8; % subjective contingency using log
% bins and 3 bit temporal resolutions

Cont(1,3) = (H_rndTbL16 - H_RbL16)/H_rndTbL16; % subjective contingency w
% linear bins and 4 bit temporal resolution
Cont(1,4) = (H_rndTb16 - H_Rb16)/H_rndTb16; % subjective contingency using
% log bins and 4 bit temporal resolutions

