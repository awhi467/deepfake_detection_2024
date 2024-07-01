clear;
addpath('functions');
addpath('phase_unwrap')
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Isabella (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Nick (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Isabella');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Nick');
addpath('..\Speech samples\fs2')
addpath('..\Speech samples\')

% Read audio files
number = '04';
filename = ['NaturalNick', number, '.wav'];
filename = [number, '_logs-150-Nick-Base.wav'];
filename = ['NaturalIsabella', number, '.wav'];
filename = [number, '_logs-150-Isabella-Reference-Base.wav'];
%filename = 'fs2_test.wav';
%filename = 'peter_test1.wav';
[s, fs] = audioread(filename);

% Pre-emphasise
pe = tf([1,-0.95],1,1/fs,'Variable','z^-1');
s = lsim(pe,s);

% Params
nfft = 1024;
hop = 128;
nbins = 512;

[B,psd,BL,BN,bL,bN] = compute_bispectrum(s, nfft, hop, nbins);

% Calculate stsistical measures (mean, standard deviation, skewness and kurtosis)
%B_psd_mean = mean(B_psd(:));
%B_psd_variance = var(B_psd(:));
%B_psd_skewness = skewness(B_psd(:));
%B_psd_kurtosis = kurtosis(B_psd(:));

% Ratio proposed by Hinich and Patterson
psd_size = size(psd,1);
indices = mod((0:psd_size-1)+(0:psd_size-1)',psd_size) + 1;
den = psd * transpose(psd) .* conj(psd(indices));
ratio = (abs(B))^2./(den);
ratio = hz2bark(ratio);
[minr, maxr] = bounds(ratio(:));
disp(minr)
disp(maxr)

% Take half of the PSD due to symmetry
psd = psd(1:floor(end/2));

[minB,maxB] = bounds(abs(B(:)));

%--------------------------------Plots--------------------------------

% Time domain waveform
figure(1)
plot(s)
title('Time domain waveform')
xlabel('n')
ylabel('s[n]')

% Bicoherence
figure(2)
subplot(1,2,1)
image(flipud(abs(B)),'CDataMapping','scaled')
colormap(flipud(gray))
title('Bicoherence magnitude')
xlabel('f_1 (kHz)')
ylabel('f_2 (kHz)')
subplot(1,2,2)
image(flipud(phase_unwrap(angle(B))),'CDataMapping','scaled')
colormap(flipud(gray))
title('Bicoherence phase')
xlabel('f_1 (kHz)')
ylabel('f_2 (kHz)')
%xlim([-fs/2000,fs/2000])
%ylim([-fs/2000,fs/2000])

% Power Spectral Density
figure(3)
subplot(1,2,1)
plot(psd)
title('Power Spectral Density (linear)')
xlabel('f (kHz)')
ylabel('PSD')
subplot(1,2,2)
plot(10*log10(psd))
title('Power Spectral Density (dB)')
xlabel('f (kHz)')
ylabel('10*log(PSD)')

% Ratio proposed by Hinich and Patterson
figure(4)
image(flipud(ratio),'CDataMapping','scaled')
colormap(flipud(gray))

% Bicepstrum
b = bL + bN;
figure(5)
image(flipud(abs(bL+bN)),'CDataMapping','scaled')
colormap(flipud(gray))

% Linear and nonlinear bispectrum
figure(6)
subplot(2,2,1)
image(flipud(abs(BL)),'CDataMapping','scaled')
colormap(flipud(gray))
clim([minB,maxB])
title('Linear Bispectrum')
xlabel('f_1 (kHz)')
ylabel('f_2 (kHz)')
subplot(2,2,2)
image(flipud(abs(BN)),'CDataMapping','scaled')
colormap(flipud(gray))
clim([minB,maxB])
title('Nonlinear Bispectrum')
xlabel('f_1 (kHz)')
ylabel('f_2 (kHz)')
subplot(2,2,3)
image(flipud(abs(B)),'CDataMapping','scaled')
colormap(flipud(gray))
%clim([minB,maxB])
title('Original')
xlabel('f_1 (kHz)')
ylabel('f_2 (kHz)')
subplot(2,2,4)
image(flipud(abs(BL.*BN)),'CDataMapping','scaled')
colormap(flipud(gray))
%clim([minB,maxB])
title('Product BL*BN')
xlabel('f_1 (kHz)')
ylabel('f_2 (kHz)')
