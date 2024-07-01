clear;
addpath('..\Speech samples');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Isabella (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Nick (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Isabella');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Nick');
addpath('covarep\glottalsource\')
addpath('..\Bispectral Analysis\functions\')

% Specify the filenames and start/duration of vowels
filename1 = 'NaturalNick02.wav';
filename2 = '02_logs-150-Nick-Base.wav';
%filename1 = 'NaturalIsabella00.wav';
%filename2 = '00_logs-150-Isabella-Reference-Base.wav';
start1 = 9920;
duration1 = 1919;
start2 = 1920;
duration2 = 1439;

% Read the audio files and isolate the vowel sounds
[s1 fs1] = audioread(filename1);
s1 = s1(start1:start1+duration1);
[s2 fs2] = audioread(filename2);
s2 = s2(start2:start2+duration2);

% Pre-emphasize the speech
pe = tf([1,-0.95],1,1/fs1,'Variable','z^-1');
s_pe1 = lsim(pe,s1);
s_pe2 = lsim(pe,s2);

% Determine LPC coefs of glottal filter, VT filter and lip radiation filter
[gvvd1, gvvdd1, av1, ag1] = iaif(s_pe1,fs1);
[gvvd2, gvvdd2, av2, ag2] = iaif(s_pe2,fs2);
gvv1 = cumsum(gvvd1);
gvv2 = cumsum(gvvd2);

% Determine the frequency response of the vocal tract
vt1 = lpc_to_fr(av1,fs1);
vt2 = lpc_to_fr(av2,fs2);

% Normalised VT spectrum
[min_vt1,max_vt1] = bounds(vt1);
vt1n = (vt1-min_vt1)/(max_vt1-min_vt1);
[min_vt2,max_vt2] = bounds(vt2);
vt2n = (vt2-min_vt2)/(max_vt2-min_vt2);
figure(10)
plot(vt1n)

figure(5)
plot(cumsum(vt1n))

figure(6)
plot(cumsum(vt2n))

% Ratio of half spectrum
vt1_a1 = sum(vt1n(1:4000));
vt1_a2 = sum(vt1n(4001:8000));
ratio1 = vt1_a2/vt1_a1;
vt2_a1 = sum(vt2n(1:4000));
vt2_a2 = sum(vt2n(4001:8000));
ratio2 = vt2_a2/vt2_a1;

figure(1)
subplot(2,1,1)
plot(s1)
title('Natural Speech')
subplot(2,1,2)
plot(s2)
title('Synthetic Speech')

figure(2)
subplot(2,1,1)
plot(gvv1)
title('Natural GVV')
subplot(2,1,2)
plot(gvv2)
title('Synthetic GVV')

figure(3)
subplot(2,1,1)
plot(gvvd1)
title('Natural GVV Derivative')
subplot(2,1,2)
plot(gvvd2)
title('Synthetic GVV Derivative')

figure(4)
subplot(2,1,1)
plot(vt1)
title('Natural')
xlabel('f (kHz)')
ylabel('|V(e^{j2\pif})| (dB)')
subplot(2,1,2)
plot(vt2)
title('Synthetic')
xlabel('f (kHz)')
ylabel('|V(e^{j2\pif})| (dB)')
