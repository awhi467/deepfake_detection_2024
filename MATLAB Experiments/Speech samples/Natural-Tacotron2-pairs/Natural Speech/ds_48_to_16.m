% Downsamples audio from 48kHz to 16kHz

clear;
addpath('Isabella (48kHz)');
addpath('Nick (48kHz)');

original = dir('Isabella (48kHz)');

for i = 1:size(original,1)
    if ~original(i).isdir
        [s,fs] = audioread(original(i).name);
        sn = downsample(s, 3);
        audiowrite(original(i).name, sn, fs/3)
    end
end