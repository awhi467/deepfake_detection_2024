clear;
addpath('functions');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Isabella (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Nick (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Isabella');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Nick');
addpath('..\Speech samples\fs2')
addpath('..\Speech samples\aotearoa_voices')

% Read audio files
number = ['00'];
filename = ['NaturalNick', number, '.wav'];
filename = [number, '_logs-150-Nick-Base.wav'];
%filename = ['NaturalIsabella', number, '.wav'];
%filename = [number, '_logs-150-Isabella-Reference-Base.wav'];
%filename = 'fs2_test.wav';
%filename = 'fest_en_f1_1.wav'
[s, fs] = audioread(filename);

% Pre-emphasise
pe = tf([1,-0.95],1,1/fs,'Variable','z^-1');
s = lsim(pe,s);

[B,Bpsd,psd,B_mean,B_var,B_skew,B_kurt] = compute_bispectrogram(s, 128, 64);

t = (1:size(s,1))/fs;
t_small = (1:size(B_mean,1))/size(B_mean,1)*size(s,1)/fs;

% Time domain waveform
figure(1)
plot(t,s)

% Plot the first four statistical moments
figure(2)
subplot(2,2,1)
plot(t_small,abs(B_mean))
title('Bispectrum mean')
xlabel('n/f_s (s)')
ylabel('\mu_B')
subplot(2,2,2)
plot(t_small,abs(B_var))
title('Bispectrum variance')
xlabel('n/f_s (s)')
ylabel('\sigma_B^2')
subplot(2,2,3)
plot(t_small,abs(B_skew))
title('Bispectrum skewness')
xlabel('n/f_s (s)')
ylabel('\gamma_B')
subplot(2,2,4)
plot(t_small,abs(B_kurt))
title('Bispectrum kurtosis')
xlabel('n/f_s (s)')
ylabel('\kappa_B')
ylim([0,1e6])