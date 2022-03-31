function s = get_surv(rts, x)
% GET_SURV local function that evaluates survival function of RTs against x
% Args:
% -- rts [ntrials x 1]: simulated RTs for that condition
% -- x [1:length(x)]: the values along which the ecdf should be
% evaluated
% Returns:
% -- s: survivor function of RTs

for i = 1:length(x)
    
    e(i) = sum(rts < x(i))/length(rts);
end
s = 1-e;
end