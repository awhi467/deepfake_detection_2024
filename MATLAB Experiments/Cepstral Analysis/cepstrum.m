clear;
addpath('..\Speech samples');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Isabella (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Nick (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Isabella');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Nick');

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
[s1,fs1] = audioread(filename1);
s1 = s1(start1:start1+duration1);
[s2,fs2] = audioread(filename2);
s2 = s2(start2:start2+duration2);
size1 = size(s1,1);
size2 = size(s2,1);
t1 = (0:(size1-1))/fs1;
t2 = (0:(size2-1))/fs2;
q1 = (-size1/2:size1/2-1)/fs1;
q2 = (-size2/2:size2/2-1)/fs2;

s1 = s1.*hamming(duration1+1);
s2 = s2.*hamming(duration2+1);
c1 = cceps(s1);
c2 = cceps(s2);

% Set high quefrency components to zero
c11 = c1;
c11(161:end-161) = 0;
s11 = icceps(c11);
v1 = 10*log10(abs(fft(s11)));

figure(1)
subplot(2,2,1)
plot(t1,s1)
title('Natural speech signal')
xlabel('time (s)')
ylabel('s[t]')
subplot(2,2,2)
plot(t2,s2)
title('Synthetic speech signal')
xlabel('time (s)')
ylabel('s[t]')
subplot(2,2,3)
plot(q1,fftshift(c1))
title('Natural speech cepstrum')
xlabel('Quefrency n/fs')
ylabel('Amplitude')
subplot(2,2,4)
plot(q2,fftshift(c2))
title('Synthetic speech cepstrum')
xlabel('Quefrency n/fs')
ylabel('Amplitude')

figure(2)
plot(v1)