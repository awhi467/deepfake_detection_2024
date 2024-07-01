clear;
addpath('..\Speech samples');
addpath('Troparion-master\IRAPT\IRAPT_web');
addpath('Troparion-master\Perturbation_analysis');

filename = 'vowel.wav';
[s,Fs]=audioread(filename);

[Fo, ~, time_marks] = irapt(s, Fs, 'irapt1','sustain phonation');  
    
% Segmentation of signal onto fundamental periods
[periods] = WM_phase_const(s,Fo,time_marks,Fs);
[amplitudes]= amp_extract(periods,s);
    
% Perturbation parameters calculation
J_loc  = shim_local(periods);
J_rap  = shim_apq3(periods);
J_ppq5 = shim_apq5(periods);
J_apq11 = shim_apq11(periods);
J_apq17 = shimmer_apq(periods,17);
S_loc   = shim_local(amplitudes);
S_apq3  = shim_apq3(amplitudes);
S_apq5  = shim_apq5(amplitudes);
S_apq11 = shim_apq11(amplitudes);
S_apq17  = shimmer_apq(amplitudes,17);

% Plot the speech signal
n = 0:size(s,1)-1;
plot(n,s)