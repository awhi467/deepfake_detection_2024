clear, clc, close all

% load a sound file
[x, fs] = audioread('sample2.wav'); % load an audio file
x = x(:, 1);                        % get the first channel
x = x/max(abs(x));                  % normalize the signal
N = length(x);                      % signal length
t1 = (0:N-1)/fs;                    % time vector

% define the analysis parameters
wlen = 1024;                        % window length (recomended to be power of 2)
hop = 256;                          % hop size (recomended to be power of 2)

% calculate the cepstrogram
win = hamming(wlen, 'periodic');
[C, q, t2] = cepstrogram(x, win, hop, fs);

% some conditioning
C = C(q > 0.5e-3, :);               % ignore all cepstrum coefficients for 
                                    % quefrencies bellow 0.5 ms  
q = q(q > 0.5e-3);                  % ignore all quefrencies bellow 0.5 ms
q = q*1000;                         % convert the quefrency to ms

% plot the signal cepstrogram
figure(1)
subplot(3, 1, 1) 
plot(t1, x)
grid on
xlim([0 max(t1)])
ylim([-1.1*max(abs(x)) 1.1*max(abs(x))])
set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
xlabel('Time, s')
ylabel('Normalised amplitude')
title('The signal in the time domain')

subplot(5, 3, 7:15) 
[T, Q] = meshgrid(t2, q);
surf(T, Q, C)
shading interp
box on
axis([0 max(t1) 0 max(q)])
set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
xlabel('Time, s')
ylabel('Quefrency, ms')
title('Cepstrogram of the signal')
view(0, 90)

% set the colormap properties 
colormap(flipud(bone(16)))
[cmin, cmax] = caxis;
caxis([0 cmax])