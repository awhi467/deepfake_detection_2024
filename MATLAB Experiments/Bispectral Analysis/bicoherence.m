clear;
addpath('..\Speech samples');

% Specify constants
N = 1024;                          % No. samples
M = N/2;
n = -M:M-1;
f = n/N;
B_bins = 128;                      % No. bins for bispectrum plot
B_bin_size = N/B_bins;

% Quadratically nonlinear system
f1 = 0.1;
f2 = 0.15;
x = exp(2j*pi*f1*n)+exp(2j*pi*f2*n);
y = x.^2 + x;

% Audio read
x = zeros(1,N);
[y,Fs] = audioread('synthetic_vowel.wav');
%y = downsample(y,4);
%[y,Fs] = audioread('nick_synthetic.wav');
y = y(1:N);
figure(10)
plot(y)

% FFTs
X = 1/sqrt(N)*fft(x);
Y = 1/sqrt(N)*fft(y);

psd = pwelch(Y, hamming(size(Y,1)));

% Bispectrum calculation
for k=1:N
    for m=1:N
        if k+m<=N
            B(k,m) = Y(k)*Y(m)*conj(Y(k+m));
            B_psd(k,m) = psd(k)*psd(m)*conj(psd(k+m));
        else
            B(k,m) = Y(k)*Y(m)*conj(Y(k+m-N));
            B_psd(k,m) = psd(k)*psd(m)*conj(psd(k+m-N));
        end
    end
end

% Make spectrum symmetrical around zero
X = fftshift(X);
Y = fftshift(Y);
B = fftshift(B);
B_psd = fftshift(B_psd);

% Bin the bispectrum, so that it is easier to see
B_small = bin(B, B_bins, B_bin_size);
B_psd_small = bin(B_psd, B_bins, B_bin_size);
ticks = linspace(1.5, B_bins-0.5, 11);
ticklabels = {'-0.5' '-0.4' '-0.3' '-0.2' '-0.1' '0' '0.1' '0.2' '0.3' '0.4' '0.5'};

% Plot input and output spectrum
figure(1)
subplot(2,1,1)
plot(f,abs(X))
title('Input magnitude response')
xlabel('f (normalised)')
ylabel('X[f]')
subplot(2,1,2)
plot(f,abs(Y))
title('Output magnitude response')
xlabel('f (normalised)')
ylabel('Y[f]')

% Surf plot of bispectrum magnitude
figure(2)
surf(abs(B_small))
title('Bispectrum magnitude')
xlabel('f1 (normalised)')
ylabel('f2 (normalised)')
zlabel('|B[f1,f2]|')
xticks(ticks)
xticklabels(ticklabels)
yticks(ticks)
yticklabels(ticklabels)

% Contour plot of bispectrum
figure(3)
contour(abs(B_small))
title('Bispectrum magnitude')
xlabel('f1 (normalised)')
ylabel('f2 (normalised)')
zlabel('|B[f1,f2]|')
xticks(ticks)
xticklabels(ticklabels)
yticks(ticks)
yticklabels(ticklabels)

% Surf plot of bispectrum phase
figure(4)
contour(angle(B_small))
title('Bispectrum phase')
xlabel('f1 (normalised)')
ylabel('f2 (normalised)')
zlabel('|B[f1,f2]|')
xticks(ticks)
xticklabels(ticklabels)
yticks(ticks)
yticklabels(ticklabels)

% Surf plot of bispectrum magnitude
figure(5)
plot(psd)
title('Power Spectral Density')
xlabel('f')
ylabel('psd')

% Surf plot of bispectrum magnitude
figure(6)
surf(B_psd_small)
title('PSD Bispectrum')
xlabel('f1 (normalised)')
ylabel('f2 (normalised)')
zlabel('B (PSD)')
xticks(ticks)
xticklabels(ticklabels)
yticks(ticks)
yticklabels(ticklabels)