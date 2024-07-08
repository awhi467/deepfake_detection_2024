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

% Specify directory of .wav files
path_in = '..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Isabella (16kHz)';
wav_files = dir(strcat(path_in,'\*.wav'));

% Specify output directory
path_out = 'feature_data';

% Params
nlag = 25;
nsamp = 256;
overlap = 50;
nfft = 256;
wind = hamming(nfft+1);
fs= 16000;

% Define pre-emphasis filter
pe = tf([1,-0.95],1,1/fs,'Variable','z^-1');

% Loop through .wav files and compute features
for i=1:size(wav_files,1)

    % Read file and pre-emphasise
    [s,fs] = audioread(wav_files(i).name);
    s = lsim(pe,s);

    % Bispectrum
    [B,axis] = bispeci(s,nlag,nsamp,overlap,'unbiased',nfft,wind);
    B = process(B,nfft);
    writematrix(B,strcat(path_out,'\B_', erase(wav_files(i).name, '.wav'),'.csv'))

    % Skewness
    [sk,axis] = bicoher(s,nfft,wind,nsamp,overlap);
    sk = process(sk,nfft);
    writematrix(sk,strcat(path_out,'\sk_', erase(wav_files(i).name, '.wav'),'.csv'))

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
    BL = process(BL,nfft);
    BN = process(BN,nfft);
    
end

% Reduce the size to the first quadrant, normalise magnitudes
function y = process(x,nfft)
    y = x(nfft/2:end, nfft/2:end);
    [min,max] = bounds(abs(y(:)));
    y = (y-min)/(max-min);
end