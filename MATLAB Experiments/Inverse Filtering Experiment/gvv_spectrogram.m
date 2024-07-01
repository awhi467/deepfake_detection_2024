clear;
addpath('..\Speech samples');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Isabella (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Nick (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Isabella');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Nick');
addpath('covarep\glottalsource\')
addpath('myspectrogram\')

% Specify the filenames and start/duration of vowels
%filename1 = 'NaturalNick06.wav';
%filename2 = '06_logs-150-Nick-Base.wav';
filename1 = 'NaturalIsabella04.wav';
filename2 = '04_logs-150-Isabella-Reference-Base.wav';

% Read the audio files and isolate the vowel sounds
[s1 fs1] = audioread(filename1);
[s2 fs2] = audioread(filename2);

figure(100)
subplot(2,1,1)
plot(cumsum(s1));
subplot(2,1,2)
plot(cumsum(s2));

% Pre-emphasize the speech
pe = tf([1,-0.95],1,1/fs1,'Variable','z^-1')
s_pe1 = lsim(pe,s1);
s_pe2 = lsim(pe,s2);

% Determine LPC coefs of glottal filter, VT filter and lip radiation filter
[gvvd1, gvvdd1, av1, ag1] = iaif(s_pe1,fs1);
[gvvd2, gvvdd2, av2, ag2] = iaif(s_pe2,fs2);
gvv1 = cumsum(gvvd1);
gvv2 = cumsum(gvvd2);

vt1 = tf(1,av1,1/fs1,'Variable','z^-1');
vt2 = tf(1,av2,1/fs2,'Variable','z^-1');

data1 = fun_compute_bispectrum(gvv1,fs1,1024,50,'hann',1);
data2 = fun_compute_bispectrum(gvv2,fs2,1024,50,'hann',1);
gvv1_psd = data1.P;
gvv2_psd = data2.P;
f = data1.f;

% Take half the plot, due to symmetry
N = floor(size(gvv1_psd,1)/2);
gvv1_psd = gvv1_psd(N+1:end);
gvv2_psd = gvv2_psd(N+1:end);
f = data1.f/1000;
f = f(N+1:end);

figure(1)
subplot(2,1,1)
plot(s1)
title('Natural Speech')
xlabel('n')
ylabel('s[n]')
subplot(2,1,2)
plot(s2)
title('Synthetic Speech')
xlabel('n')
ylabel('s[n]')

figure(2)
subplot(2,1,1)
plot(gvv1)
title('Natural GVV')
xlabel('n')
ylabel('u_G[n]')
subplot(2,1,2)
plot(gvv2)
title('Synthetic GVV')
xlabel('n')
ylabel('u_G[n]')

figure(3)
subplot(2,1,1)
plot(gvvd1)
title('Natural GVV Derivative')
xlabel('n')
ylabel("u_G'[n]")
subplot(2,1,2)
plot(gvvd2)
title('Synthetic GVV Derivative')
xlabel('n')
ylabel("u_G'[n]")

plotoptions = bodeoptions;
plotoptions.FreqScale = 'linear';
plotoptions.MagScale = 'linear';
plotoptions.FreqUnits = 'Hz';
plotoptions.XLim = [0, 8000];

figure(4)
subplot(2,1,1)
bodemag(vt1, plotoptions)
title('Vocal tract frequency response (Natural)')
subplot(2,1,2)
bodemag(vt2, plotoptions)
title(title('Vocal tract frequency response (Synthetic)'))

figure(5)
myspectrogram(gvv1,fs1,[6,1],'@hamming',1024,[-45,-1],[1],'default',true,'per')
title('GVV natural')
xlabel('t (s)')
ylabel('f (Hz)')

figure(6)
myspectrogram(gvv2,fs2,[6,1],'@hamming',1024,[-45,-1],[1],'default',true,'per')
title('GVV synthetic')
xlabel('t (s)')
ylabel('f (Hz)')

figure(7)
myspectrogram(gvvd1,fs1,[6,1],'@hamming',1024,[-45,-1],[1],'default',true,'per')
title('GVVD natural')
xlabel('t (s)')
ylabel('f (Hz)')

figure(8)
myspectrogram(gvvd2,fs2,[6,1],'@hamming',1024,[-45,-1],[1],'default',true,'per')
title('GVVD synthetic')
xlabel('t (s)')
ylabel('f (Hz)')

figure(9)
subplot(2,1,1)
histogram(s_pe1)
title('Natural speech magnitude histogram')
subplot(2,1,2)
histogram(s_pe2)
title('Synthetic speech magnitude histogram')

figure(10)
plot(f,10*log10(gvv1_psd),f,10*log10(gvv2_psd))
title('GVV Power Spectral Density')
xlabel('f (kHz)')
ylabel('10*log(PSD)')