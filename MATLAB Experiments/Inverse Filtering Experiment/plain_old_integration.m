clear;
addpath('..\Speech samples');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Isabella (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Nick (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Isabella');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Nick');
addpath('..\Speech samples\aotearoa_voices\');
addpath('..\Speech samples\fs2\ljspeech');
addpath('covarep\glottalsource\')
addpath('myspectrogram\')

%filename = 'mtts_en_m1_1.wav';
%filename = 'fest_en_f1_1.wav';
%filename = 'fs2_test.wav';
%filename = 'NaturalNick12.wav';
%filename = '12_logs-150-Nick-Base.wav';
%filename = 'NaturalIsabella04.wav';
%filename = '04_logs-150-Isabella-Reference-Base.wav';
filename = 'lj1.wav';

% Read the audio files and isolate the vowel sounds
[s fs] = audioread(filename);

%pe = tf([1,-1],1,1/fs,'Variable','z^-1')
%s = lsim(pe, s);

uL = cumsum(s);
uLi = cumsum(uL);
figure(4)
plot(uLi)

figure(1)
subplot(2,1,1)
plot(s)
title('Speech signal')
xlabel('n')
ylabel('s[n]')
subplot(2,1,2)
plot(uL)
title('Lip volume velocity')
xlabel('n')
ylabel('u_L[n]')

figure(2)
sp1 = myspectrogram(s,fs,[6,1],'@hamming',1024,[-45,-1],[1],'default',false,'per')
title('Speech signal')
xlabel('t (s)')
ylabel('f (Hz)')
figure(3)
sp2 = myspectrogram(uL,fs,[6,1],'@hamming',1024,[-45,-1],[1],'default',false,'per')
title('Lip volume velocity')
xlabel('t (s)')
ylabel('f (Hz)')