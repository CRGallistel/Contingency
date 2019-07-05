function [Cont p_trig] = RetroCont(RbcktoPints,mu_hat)
% Computes the retrospective contingency between reinforcement and pecks in
% Experiment 3, where the RndTbcktoPints are exponentially distributed, as
% are the intervals back from the reinforcements not triggered by a peck

p_trig = sum(RbcktoPints<=.011)/length(RbcktoPints);

bc = .011/2:.011:15; % bin centers

p_basal = .011*exppdf(bc,mu_hat);

p_bckfrmR = [p_trig (1-p_trig)*p_basal];

H_pb = sum(p_basal.*log(1./p_basal)); % basal entropy

H_bR = sum(p_bckfrmR.*log(1./p_bckfrmR));

Cont = (H_pb - H_bR)/H_pb;


