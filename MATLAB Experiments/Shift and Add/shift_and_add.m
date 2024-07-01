clear;
addpath('..\Speech samples');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Isabella (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Nick (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Isabella');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Nick');
addpath('..\Speech samples\fs2\ljspeech');

%filename = 'lj1.wav';
filename = 'NaturalNick04.wav';
%filename = '00_logs-150-Isabella-Reference-Base.wav';
[s,fs]=audioread(filename);
%start = 1661;
%duration = 2086;
%s = s(start:start+duration);

% Pre-emphasise
pe = tf([1,-0.95],1,1/fs,'Variable','z^-1');
s = lsim(pe,s);

% Initialisation
nf = 1;  % frame index
L = 100;  % length of each frame
ns = 50;  % frame shift
sthres = max(abs(s))*0.1; % threshold
saa = zeros(3*L+1,1);

while nf+L<size(s,1)
    % Current frame
    sv = s(nf:nf+L);

    % Shift
    [smax,kmax] = max(sv);

	% Add
    if abs(smax)>sthres
        sv1 = [zeros(1.5*L-kmax,1);sv/smax;zeros(0.5*L+kmax,1)];
        saa = saa + sv1;
    end
    
    % Next frame
    nf = nf+ns;
end

saa = saa(saa~=0);
ft = fft(saa);

figure(1)
plot(saa)
title('Shift and Add')
xlabel('n')
ylabel('s_{saa}[n]')

figure(2)
plot(1:201,abs(ft))
xlabel('k')
ylabel('S_{saa}[k]')