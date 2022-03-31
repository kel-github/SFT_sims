function [RTs] = simulate_RTs(t0, b, a, s, v, n)
%SIMULATE_RTs - simulate RTs using the LBA model
% this function will provide a distribution of RTs
% given the input parmaters 
% Input Args:
% LBA parameters
% ~~~~~~~~~~~~~~
%   t0: non-decision/basetime, e.g. 0.1
%    b: criterion, e.g. 2
%    a: upper end of startpoint distribution - e.g. .5
%    s: std dev of rates, e.g. 1
%    v: value of drift, e.g. 6 for fast, 4 for low
% Other
% ~~~~~~~~~~~~~~
%    n: number of trials

%% generate data

drifts = normrnd(v, s, n, 1); % sample random values for drift rates across trials
A = unifrnd(0, a, n, 1); % simulate start points for each trial
RTs = ((b-A)./drifts) + t0; % RTs are distance over speed, plus non-decision time

end

