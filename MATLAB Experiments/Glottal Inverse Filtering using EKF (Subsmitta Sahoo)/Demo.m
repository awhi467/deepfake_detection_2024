% This is a demo file showing the glottal inverse filtering and estimation of air
% pressure distribution at different sections of the vocal tract. To
% inverse filter a particular vowel, the corresponding approximate vocal
% tract area should be passed to the Find_pr_dist() funtion for
% initialization of the reflection coefficients.
% This demo is for vowel /e/ so the corresponding vocal tract area from [1]
% has been taken.
%
% References
%  [1] Story, B.H., Titze, I.R. and Hoffman, E.A., 1996. Vocal tract area
%      functions  from magnetic resonance imaging. The Journal of the Acoustical
%      Society of America, 100(1), pp.537-554
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear all
close all


A=[0.210000000000000,0.130000000000000,0.160000000000000,0.140000000000000,0.0600000000000000,0.780000000000000,1.25000000000000,1.24000000000000, ...
0.990000000000000,0.720000000000000,0.730000000000000,1.06000000000000,1.77000000000000,1.97000000000000,2.46000000000000,2.70000000000000,2.92000000000000, ...
3.03000000000000,2.84000000000000,2.84000000000000,2.83000000000000,2.36000000000000,2.14000000000000,2,1.78000000000000,1.81000000000000,1.79000000000000, ...
1.50000000000000,1.37000000000000,1.36000000000000,1.43000000000000,1.83000000000000,2.08000000000000,2.59000000000000,2.54000000000000,2.11000000000000, ...
2.34000000000000,2.74000000000000,2.19000000000000,1.60000000000000]; % Vocal tract areas for the vowel /e/ taken from [1].
[VowelSpeech, Fs]=audioread('Eh.wav');

% The speech is resampled to appropriate sampling frequency to satisfy the
% satability condition c*dT<=dx
VowelSpeech=resample(VowelSpeech,88200,Fs);VowelSpeech=VowelSpeech*.01;
Fs=88200;
[GlotFlowDerivative, Est_Speech, Flow_values, Peak_loc]=Find_pr_dist(VowelSpeech(:,1),Fs,A);

figure;plot(GlotFlowDerivative);
figure;plot(VowelSpeech(Peak_loc(1):Peak_loc(end)-1,1)), hold on;plot(Est_Speech,'r');
