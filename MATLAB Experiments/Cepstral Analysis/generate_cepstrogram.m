clear;
addpath('..\Speech samples');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Isabella (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Nick (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Isabella');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Nick');
addpath('cepstrogram\')

% Specify the filenames and start/duration of vowels
%filename1 = 'NaturalNick00.wav';
%filename2 = '00_logs-150-Nick-Base.wav';
filename1 = 'NaturalIsabella02.wav';
filename2 = '02_logs-150-Isabella-Reference-Base.wav';
[s1,fs1] = audioread(filename1);
[s2,fs2] = audioread(filename2);

[C1,q1,t1] = cepstrogram(s1, hamming(1024), 8, fs1);
[C2,q2,t2] = cepstrogram(s2, hamming(1024), 8, fs2);

[min1,max1] = bounds(C1);
C1 = (C1-min1)./(max1-min1);
[min2,max2] = bounds(C2);
C2 = (C2-min2)./(max2-min2);

figure(1)
image(flipud(C1), "CDataMapping","scaled")
title('Natural')
colormap(gray)

figure(2)
image(flipud(C2), "CDataMapping","scaled")
title('Synthetic')
colormap(gray)