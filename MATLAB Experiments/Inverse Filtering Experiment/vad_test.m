clear;
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Isabella (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Nick (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Isabella');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Nick');

filename = 'NaturalIsabella00.wav';
[s,fs] = audioread(filename);
vad = voiceActivityDetector('FFTLength',1024,'SilenceToSpeechProbability',0.3,'SpeechToSilenceProbability',0.3);
[P,N] = step(vad,s');

n = 0:size(s,1)-1;
figure(1)
plot(n,s,n,P)