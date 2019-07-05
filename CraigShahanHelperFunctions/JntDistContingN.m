function [Cyx,MI,Hy] = JntDistContingN(Dx,Dy,Nx,Ny)
% Computes the extent to which the values in data vector Dy are contingent
% on the values in data vector Dx by discretizing the joint and marginal
% distributions into the number of marginal bins specified in the Nx and Ny
% integers.
%
% Syntax:   [Cyx,MI,Hy] = JntDistConting(Dx,Dy,Nx,Ny)
% where Cyx is the contingency of y on x, MI is the mutual information, and
% Hy is the available information
% Dx and Dy must be vectors of the same length. Nx and Ny must be integers
% specifying the number of bins in the marginal distributions. The
% partitioning divides the x range and the y range into Nx and Ny equal
% width bins. There are Nx?Ny bins in the joint distribution.
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

Xedges = linspace(min(Dx)-.01,max(Dx)+.01,Nx+1);
Yedges = linspace(min(Dy)-.01,max(Dy)+.01,Ny+1);

LVx = nan(length(Dx),Nx);
for c = 1:Nx % filling in the columns of the logical array for the X partition
    LVx(:,c) = Dx>=Xedges(c)&Dx<Xedges(c+1);
end

LVy = nan(length(Dy),Ny); 
for c = 1:Ny  % filling in the columns of the logical array for the Y partition
    LVy(:,c) = Dy>=Yedges(c)&Dy<Yedges(c+1);
end

%
histmat=nan(Nx,Ny); % initializing the histogram array. Matlab's hist2 command
% SHOULD compute this array BUT it seems to have a bug; it undercounts the
% upper right bin by 1. Weird!
for c = 1:Ny
    for r = 1:Nx
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
Hx = nansum(pX.*log2(1./pX)); % X entropy
Hy = nansum(pY.*log2(1./pY)); % Yentropy

MI = (Hx+Hy-Hxy);

Cyx = MI/Hy;
if isnan(Cyx);keyboard;end
