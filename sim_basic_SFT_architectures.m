clear all
%% simulating SFT predictions, 
% given a double factorial experiment, and assumptions regarding
% parallel or serial nature of underlying architecture
% written by K. Garner getkellygarner@gmail.com
% based on code from Ami Eidels
% using the assumptions set out in the book:
% Little, D. et al (2017). Systems Factorial Technology: A Theory
%                              Driven Methodology for the Identification of
%                              Perceptual and Cognitive Mechanisms
% particularly chapter 1:
% Alteri et al (2017). Historical Foundations and a Tutorial Introduction
% to SFT
% and
% Harding et al (2016). Systems Factorial Technology Explained to Humans.
% The Quantitative Methods for Psychology

%% first step, generate data using LBA model
% first, set LBA parameters and produce RTs for each condition
% we assume two manipulated processes (T1 | T2) and two difficulty levels
% (hi vs lo). This forms the basis of the double factorial experiment (see
% pp. 9 of Alteri et al, 2017).

t0 = 0.1; % non-decision time
b = 2.0; % criterion
a = 0.5; % upper end of start point distribution
s = 1.0; % standard deviation of drift rates
% now set drift rates for each channel (h or l = high or
% low, v = drift)
h_v = 6;
l_v = 4; 

ntrials = 1000; % how many trials to simulate?
ncond = 4; % how many conditions?

T1_hi = simulate_RTs(t0, b, a, s, h_v, ntrials);
T1_lo = simulate_RTs(t0, b, a, s, l_v, ntrials);
T2_hi = simulate_RTs(t0, b, a, s, h_v, ntrials);
T2_lo = simulate_RTs(t0, b, a, s, l_v, ntrials);

% now that we have the simulated RTs, we can combine the RTs to reflect
% the hypothesised underlying information processing system
% Note: naming convention for simulating outcomes of double factorial
% experiments:
% modelabbreviation_condAcondB
% e.g.
% se[serial exhaustive]_h[T1_hi]h[T2_hi]

%% serial exhaustive model
% serial = one process must be complete before the next is initiated
% exhaustive = the system can only emit a response once both channels are
% complete pp. 8

se_hh = T1_hi + T2_hi;
se_lh = T1_lo + T2_hi;
se_hl = T1_hi + T2_lo;
se_ll = T1_lo + T2_lo;

se = [se_ll, se_lh, se_hl, se_hh];

%% serial self terminating
% definition taken from Harding et al (2016). Systems Factorial Technology
% Explained to Humans. The Quantitative Methods for Psychology pp. 40
% sub-processes are queued sequentially, but only one needs to be
% completed for the process to fire. The order of sub-processes is unknown
% and wholly random

for i = 1:ntrials

    sst_hh(i) = randsample([T1_hi(i); T2_hi(i)],1);
    sst_lh(i) = randsample([T1_lo(i); T2_hi(i)],1);
    sst_hl(i) = randsample([T1_hi(i); T2_lo(i)],1);
    sst_ll(i) = randsample([T1_lo(i); T2_lo(i)],1);
end
sst_hh = sst_hh';
sst_lh = sst_lh';
sst_hl = sst_hl';
sst_ll = sst_ll';

sst = [sst_ll, sst_lh, sst_hl, sst_hh];

%% parallel self terminating
% Harding et al (2016) pp 40: both sub-processes work simultaneously
% and the process fires as soon as one sub-process finishes

pst_hh = min([T1_hi'; T2_hi'])';
pst_lh = min([T1_lo'; T2_hi'])';
pst_hl = min([T1_hi'; T2_lo'])';
pst_ll = min([T1_lo'; T2_lo'])';

pst = [pst_ll, pst_lh, pst_hl, pst_hh];

%% parallel exhaustive
% Harding et al (2016) pp. 40: both sub-processes work simultaneously and
% the process fires only after both sub-processes have finished

pe_hh = max([T1_hi'; T2_hi'])';
pe_lh = max([T1_lo'; T2_hi'])';
pe_hl = max([T1_hi'; T2_lo'])';
pe_ll = max([T1_lo'; T2_lo'])';

pe = [pe_ll, pe_lh, pe_hl, pe_hh];

%% compute survivor functions
% now that we have simulated what the outcomes of the double factorial
% experiment should look like,we can first compute and plot the survivor
% functions
x = 0:0.001:3; % x along which to evaluate

se_sf = zeros(length(x), ncond); %se[serial exhaustive]_sf[survivor functions]
sst_sf = se_sf;
pst_sf = se_sf;
pe_sf = se_sf;

for i = 1:ncond
    
    se_sf(:,i) = get_surv(se(:,i), x);
    sst_sf(:,i) = get_surv(sst(:,i), x);
    pst_sf(:,i) = get_surv(pst(:,i), x);
    pe_sf(:,i) = get_surv(pe(:,i), x);
end

% now plot the survivor functions for each experiment
subplot(2,2,1)
plot(x, se_sf(:,1), x, se_sf(:,2), x, se_sf(:,3), x, se_sf(:,4))
ylabel('surv func')
xlabel('t')
legend('ll', 'lh', 'hl', 'hh', 'Location', 'northeast')
legend('boxoff')
title('se')

subplot(2,2,2)
plot(x, sst_sf(:,1), x, sst_sf(:,2), x, sst_sf(:,3), x, sst_sf(:,4))
title('sst')

subplot(2,2,3)
plot(x, pst_sf(:,1), x, pst_sf(:,2), x, pst_sf(:,3), x, pst_sf(:,4))
title('pst')

subplot(2,2,4)
plot(x, pe_sf(:,1), x, pe_sf(:,2), x, pe_sf(:,3), x, pe_sf(:,4))
title('pe')

%% now compute and plot SICs
% caution: hard coded
% SIC(t) = [S_ll(t) - S_lh(t)] - [S_hl(t) - S_hh(t)] equation 1.1, page 12
% from Alteri et al (2017)
se_SIC = (se_sf(:,1) - se_sf(:,2)) - (se_sf(:,3) - se_sf(:,4));
sst_SIC = (sst_sf(:,1) - sst_sf(:,2)) - (sst_sf(:,3) - sst_sf(:,4));
pst_SIC = (pst_sf(:,1) - pst_sf(:,2)) - (pst_sf(:,3) - pst_sf(:,4));
pe_SIC = (pe_sf(:,1) - pe_sf(:,2)) - (pe_sf(:,3) - pe_sf(:,4));

figure;
subplot(2,2,1)
plot(x, se_SIC, 'b')
ylim([-0.4, 0.4])
ylabel('SIC')
xlabel('t')
yline(0, '--')
title('serial exhaustive')

subplot(2,2,2)
plot(x, sst_SIC, 'b')
ylim([-0.4, 0.4])
yline(0, '--')
title('serial self terminating')

subplot(2,2,3)
plot(x, pst_SIC, 'b')
ylim([-0.4, 0.4])
yline(0, '--')
title('parallel self terminating')

subplot(2,2,4)
plot(x, pe_SIC, 'b')
ylim([-0.4, 0.4])
yline(0, '--')
title('parallel exhaustive')
