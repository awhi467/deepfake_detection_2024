clear;
addpath('..\Speech samples');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Isabella (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Nick (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Isabella');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Nick');

% Specify the filenames and start/duration of vowels
filename1 = 'NaturalNick03.wav';
filename2 = '03_logs-150-Nick-Base.wav';
%filename1 = 'NaturalIsabella00.wav';
%filename2 = '00_logs-150-Isabella-Reference-Base.wav';
start1 = 25440;
duration1 = 1599;
start2 = 16640;
duration2 = 1279;

% Read the audio files and isolate the vowel sounds
[s1 fs1] = audioread(filename1);
s1 = s1(start1:start1+duration1);
[s2 fs2] = audioread(filename2);
s2 = s2(start2:start2+duration2);

figure(2)
plot(s1)
figure(3)
plot(s2)

% Pre-emphasize the speech
pe = tf([1,-0.95],1,1/fs1,'Variable','z^-1')
s_pe1 = lsim(pe,s1);
s_pe2 = lsim(pe,s2);

% Determine LPC coefs of glottal filter, VT filter and lip radiation filter
[av1 ag1 al1] = gfmiaif(s_pe1,50,2);
[av2 ag2 al2] = gfmiaif(s_pe2,50,2);

% Excite the glottal filter with an impulse train to obtain the GVV
sys1 = tf(1,ag1,1/fs1,'Variable','z^-1');
sys2 = tf(1,ag2,1/fs2,'Variable','z^-1');
x = zeros(1000,1);
x(100:200:end) = 1;
gvv1 = lsim(sys1,x);
gvv2 = lsim(sys2,x);

figure(1)
subplot(2,1,1)
plot(gvv1)
title('Natural')
subplot(2,1,2)
plot(gvv2)
title('Synthetic')

gvv1 = gvv1.*hamming(size(gvv1,1));
gvv2 = gvv2.*hamming(size(gvv2,1));
fft1 = abs(fft(gvv1));
fft2 = abs(fft(gvv2));

%figure(2)
%subplot(2,1,1)
%plot(fft1)
%title('Natural')
%subplot(2,1,2)
%plot(fft2)
%title('Synthetic')