function [Cyx,MI,Hy] = JntDistConting(Dx,Dy,Qx,Qy)
% Computes the extent to which the values in data vector Dy are contingent
% on the values in data vector Dx by discretizing the joint and marginal
% distributions by the quantiles specified in the Qx and Qy vectors.
%
% Syntax:   [Cyx,MI,Hy] = JntDistConting(Dx,Dy,Qx,Qy)
%
% Dx and Dy must be vectors of the same length. Qx and Qy must be vectors
% whose elements are >0 and <1 and that specify quantiles of the Dx and Dy
% vectors, respectively. A Q vector with n elements will partition the
% corresponding data vector into n+1 bins. For example, Q = [.33 .67]
% partitions into thirds, while Q = [.1 .2 .3 .4 .5 .6 .7 .8 .9] partitions
% into deciles. The number of bins in the joint distribution given these
% two Q vectors would be 3x10 = 30 bins. Hy is the source information in
% bits; MI is the mutual information; Cyx = MI/Hy  is the contingency of
% y on x.
%
% The more bins in the joint distribution, the less reliable the estimates
% of the joint probabilities; hence, the less trustworthy the estimate of
% the contingency. On the other hand, having too few bins obscures the true
% structure of the joint distribution. It is good practice to examine the
% effects of varying the numbers of quantiles for the x and y variables
%
if numel(Dx) ~= numel(Dy)
    fprintf('\nInput Error: Data vectors not the same length\n')
    return
end
if any(Qx<=0) || any(Qx>=1) || any(Qy<=0) || any(Qy>=1)
    fprintf('Input Error: Elements of the quantile vectors must be strictly between 0 and 1')
    return
end
xN = length(Qx)+1; % number of bins on x axis
yN = length(Qy)+1; % number of bins on y axis
Xedges = [-inf quantile(Dx,Qx) inf];
Yedges = [-inf quantile(Dy,Qy) inf];

LVx = nan(length(Dx),xN);
for c = 1:xN % filling in the columns of the logical array for the X partition
    LVx(:,c) = Dx>=Xedges(c)&Dx<Xedges(c+1);
end

LVy = nan(length(Dy),yN); 
for c = 1:yN  % filling in the columns of the logical array for the Y partition
    LVy(:,c) = Dy>=Yedges(c)&Dy<Yedges(c+1);
end

%
histmat=nan(xN,yN); % initializing the histogram array. Matlab's hist2 command
% SHOULD compute this array BUT it seems to have a bug; it undercounts the
% upper right bin by 1. Weird!
for c = 1:yN
    for r = 1:xN
        histmat(r,c) = sum(LVx(:,r)&LVy(:,c)); % the count in bin r,c
    end
end
%
Xmarg = sum(histmat,2); % summing across the columns to get the marginal
% totals for Dx
Ymarg = sum(histmat); % summing across the rows to get the marginal
% totals for Dy

pXY = histmat/sum(histmat(:)); % joint probability distribution
pX = Xmarg/sum(Xmarg(:)); % X marginal 
pY = Ymarg/sum(Ymarg(:)); % Y marginal 

Hxy = nansum(pXY(:).*log2(1./pXY(:))); % joint entropy
Hx = sum(pX.*log2(1./pX)); % X entropy
Hy = sum(pY.*log2(1./pY)); % Yentropy

MI = (Hx+Hy-Hxy);

Cyx = MI/Hy;
