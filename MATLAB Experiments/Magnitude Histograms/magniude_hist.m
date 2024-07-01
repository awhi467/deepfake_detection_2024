clear;
%addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Isabella (silence removed)');
%addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Nick (silence removed)');
%addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Isabella (silence removed)');
%addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Nick (silence removed)');

addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Isabella (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Nick (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Isabella');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Nick');

filename1 = 'NaturalIsabella04.wav';
filename2 = '04_logs-150-Isabella-Reference-Base.wav';
%filename1 = 'NaturalNick04.wav';
%filename2 = '04_logs-150-Nick-Base.wav';
[s1, Fs1] = audioread(filename1);
[s2, Fs2] = audioread(filename2);

figure(1)
histogram(abs(s1),100);

figure(2)
histogram(abs(s2),100);