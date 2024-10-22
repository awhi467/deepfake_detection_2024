clear;
addpath('..\Speech samples');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Isabella (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Nick (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Isabella');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Nick');
addpath('covarep\glottalsource\')
addpath('myspectrogram\')
addpath('covarep\glottalsource\')
addpath('phase_unwrap\')
addpath('speech')

% Specify the filenames and start/duration of vowels
filename = 'NaturalNick07.wav';
%filename = '07_logs-150-Nick-Base.wav';
%filename = "..\Speech samples\odss\fastpitch-hifigan\hifi-tts\92\auntcretesemancipation_01_hill_0284.wav"
%filename = "..\Speech samples\odss\natural\hifi-tts\92\auntcretesemancipation_01_hill_0284.wav"

% Read the audio files and isolate the vowel sounds
[s fs] = audioread(filename);
%s = s(100000:300000);

% Downsample to 8k
%s = downsample(s,2);
%fs = 8000;

% Pre-emphasize the speech
%pe = tf([1,-0.95],1,1/fs,'Variable','z^-1');
%s = lsim(pe,s);

% Compute the GVV
%iaif_ola(x,fs,winLen,winShift,p_vt,p_gl,d,hpfilt)
gvv = iaif_ola(s,fs,200,10,18,16,0.99,1);
s = s(1:length(gvv));

map1 = colormap(slanCM('ice'));
map2 = colormap(slanCM('amp'));
cmap = [flipud(map1);flipud(map2)];

% Compute and display phase spectrograms
figure(1)
S_gvv = myphasespectrogram(gvv,fs,[25,5],'@blackman',2048,1,'gray',true,'per');
title('GVV')
xlabel('t (s)')
ylabel('f (Hz)')

figure(2)
S_s = myphasespectrogram(s,fs,[25,5],'@blackman',2048,1,'gray',true,'per');
title('Speech')
xlabel('t (s)')
ylabel('f (Hz)')

% Spectrogram of the vocal tract phase response
spectrogram_size = size(S_gvv);
S_s = S_s(1:spectrogram_size(1),1:spectrogram_size(2));
S_vt = mod(S_s - S_gvv + 2*pi,2*pi);
S_vt = S_vt(1:1024,:)-pi;

figure(3)
subplot(2,1,2)
myspectrogram(s,fs,[6,1],'@hamming',2048,[-45,-1],1,'default',true,'per');
title("Power spectrogram")
subplot(2,1,1)
imagesc(flipud(S_vt))
xlabel('t')
ylabel('f')
title("Phase spectrogram")
colormap(gca,cmap)
colorbar
xticks(linspace(0,12000,7))
xticklabels({'0','2','4','6','8','10','12'})
yticks(linspace(1,1024,5));
yticklabels({'8000','6000','4000','2000','0'})

figure(4)
myspectrogram(s,fs,[6,1],'@hamming',2048,[-45,-1],1,'default',true,'per');
xlabel('t (s)')
ylabel('f (Hz)')
a = colorbar;
a.Label.String = 'Power (dB)';

% Time domain waveform
n = 1:length(gvv);
figure(6)
plot(n,s,n,gvv)

