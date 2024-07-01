% Removes silent parts of the audio

clear;
addpath('Natural Speech\Isabella (16kHz)');
addpath('Natural Speech\Nick (16kHz)');
addpath('Tacotron 2\Isabella');
addpath('Tacotron 2\Nick');

original = dir('Tacotron 2\Nick');

for i = 1:size(original,1)
    if ~original(i).isdir
        s = audioread(original(i).name);
        smax = movmax(s,100);
        snew = s(smax>0.001);
        audiowrite(original(i).name, snew, 16000);
    end
end