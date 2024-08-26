clear;
addpath('functions');
addpath('phase_unwrap')
addpath('hosa_toolbox')
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Isabella (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Nick (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Isabella');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Nick');
addpath('..\Speech samples\fs2')
addpath('..\Speech samples\')

% Read audio files
number = '03';
filename = ['NaturalNick', number, '.wav'];
%filename = [number, '_logs-150-Nick-Base.wav'];
%filename = ['NaturalIsabella', number, '.wav'];
%filename = [number, '_logs-150-Isabella-Reference-Base.wav'];
%filename = 'fs2_test.wav';
%filename = 'peter_test1.wav';
[s, fs] = audioread(filename);

% Pre-emphasise
pe = tf([1,-1],1,1/fs,'Variable','z^-1');
s = lsim(pe,s);

% Params
nlag = 25;
nsamp = 256;
overlap = 50;
nfft = 256;
wind = hamming(nfft+1);

% Bispectrum calculation
[B,axis] = bispeci(s,nlag,nsamp,overlap,'unbiased',nfft,wind);

% Skewness function
sk = bicoher(s,nfft,wind,nsamp,overlap);
skn = (sk-min(sk(:)))/(max(sk(:))-min(sk(:)));

[m,n] = size(B);
i = 1:m;
j = 1:n;
[Bf1,Bf2] = meshgrid(i,j);

% Define bispectrum in the principal domain
Bp = B(nfft/2+1:end, nfft/2+1:end).*triu(ones(nfft/2)).*fliplr(triu(ones(nfft/2)));

% Axial integral
Ia = trapz(abs(Bp),1);

radial_points = 100;
% Radial integral
alpha = linspace(0,pi/4,radial_points);
for i=1:radial_points
    Bnew = interpolate(B,alpha(i));
    K = floor((nfft/2-1)/(1+alpha(i)));
    Ir(i) = 0;
    for j=1:K
        Ir(i) = Ir(i)+Bnew(j);
    end
end
%--------------------------------Plots--------------------------------

% Time domain waveform
figure(1)
plot(s)
title('Time domain waveform')
xlabel('n')
ylabel('s[n]')

% Bicoherence
figure(2)
subplot(1,2,1)
image(flipud(abs(Bp)),'CDataMapping','scaled')
colormap(flipud(gray))
title('Bicoherence magnitude')
xlabel('f_1 (kHz)')
ylabel('f_2 (kHz)')
subplot(1,2,2)
image(flipud(phase_unwrap(angle(Bp))),'CDataMapping','scaled')
colormap(flipud(gray))
title('Bicoherence phase')
xlabel('f_1 (kHz)')
ylabel('f_2 (kHz)')
%xlim([-fs/2000,fs/2000])
%ylim([-fs/2000,fs/2000])

figure(7)
image(flipud(abs(sk)),'CDataMapping','scaled')
colormap(flipud(gray))
title('Bicoherence')

function Bnew = interpolate(B,alpha)
% alpha just a number
    [K1,K2] = size(B);
    k1 = 1:K1;
    k2 = 1:K2;
    p = alpha*k1-floor(alpha*k1);
    index1 = ceil(alpha*k1);
    index2 = floor(alpha*k1);
    index1(index1==0)=1;
    index2(index2==0)=1;
    disp(index1)
    disp(index2)
    Bnew = p*B(k1,index1)+(1-p)*B(k1,index2);

end