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
%s=2*s;

% Bispectrum calculation
[B,axis] = bispeci(s,nlag,nsamp,overlap,'unbiased',nfft,wind);

% Skewness function
sk = bicoher(s,nfft,wind,nsamp,overlap);
skn = (sk-min(sk(:)))/(max(sk(:))-min(sk(:)));
writematrix(skn, 'skn.csv')

%sk = (abs(B))^2/(P*transpose(P))

% Normalisation
[minB,maxB] = bounds(abs(B(:)));
B = (B-minB)/(minB-maxB);

% Complex bicepstrum
Blog = log(abs(B)) + 1j*phase_unwrap(angle(B));
b = ifft2(Blog);
b(1,1)=b(1,1)/3;

% Compute linear and nonlinear complex bicepstrum
bL = zeros(nfft);
bL(1,:) = b(1,:);
bL(:,1) = b(:,1);
bL(1:nfft+1:end) = diag(b);
bN = b - bL;
bH = b(1,:);

% Compute linear and nonlinear bispectrum
BL = exp(fft2(bL));
BN = exp(fft2(bN));

% System frequency response
H = exp(fft(bH));
H = H(nfft/2:end);

abs(mean(B(:)))
abs(mean(BL(:)))
abs(mean(BN(:)))

% Extract magnitudes of high freq. part
BN_hf = [];
[i, j] = meshgrid(1:nfft, 1:nfft);
cond = (i + j <= nfft/2);
BN_hf = abs(BN(cond));

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
image(flipud(abs(B)),'CDataMapping','scaled')
colormap(flipud(gray))
title('Bicoherence magnitude')
xlabel('f_1 (kHz)')
ylabel('f_2 (kHz)')
subplot(1,2,2)
image(flipud(phase_unwrap(angle(B))),'CDataMapping','scaled')
colormap(flipud(gray))
title('Bicoherence phase')
xlabel('f_1 (kHz)')
ylabel('f_2 (kHz)')
%xlim([-fs/2000,fs/2000])
%ylim([-fs/2000,fs/2000])

figure(3)
subplot(2,2,1)
image(flipud(abs(BL)),'CDataMapping','scaled')
colormap(flipud(gray))
title('Linear')
subplot(2,2,2)
image(flipud(abs(BN)),'CDataMapping','scaled')
colormap(flipud(gray))
title('Nonlinear')
subplot(2,2,3)
image(flipud(abs(B)),'CDataMapping','scaled')
colormap(flipud(gray))
title('Original')
subplot(2,2,4)
image(flipud(abs(BN.*BL)),'CDataMapping','scaled')
colormap(flipud(gray))
title('Product BN*BL')

figure(4)
plot(abs(H))

figure(5)
b = fftshift(b);
image(flipud(hz2mel(abs(b))),'CDataMapping','scaled')
colormap(flipud(gray))

figure(6)
histogram(BN_hf,100)

figure(7)
image(flipud(abs(sk)),'CDataMapping','scaled')
colormap(flipud(gray))
title('Bicoherence')