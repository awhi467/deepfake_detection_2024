clear;
addpath('functions')


%files = dir('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Isabella');
%files = dir('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Nick');
%files = dir('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Nick (16kHz)');
files = dir('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Isabella (16kHz)');

m = [];
sk = [];
v = [];
k = [];

for i=1:size(files,1)
    if ~files(i).isdir
        [s,fs] = audioread(files(i).name);
        data = fun_compute_bispectrum(s,fs,1024,50,'hann',8);
        B = abs(data.B);
        m = [m; mean(B(:))];
        sk = [sk; skewness(B(:))];
        v = [v; var(B(:))];
        k = [k; kurtosis(B(:))];
    end
end

n = 1:11;

figure(1)
plot(n,m)
title('Mean')
figure(2)
plot(n,sk)
title('Skewness')
figure(3)
plot(n,v)
title('Variance')
figure(4)
plot(n,k)
title('Kurtosis')