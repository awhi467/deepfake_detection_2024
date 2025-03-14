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
addpath('..\Speech samples\LJSpeech synthetic')

% Specify directory of .wav files
path_in = ['..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Nick'];
is_synthetic = 0;       % 0 for natural, 1 for synthetic
wav_files = dir(strcat(path_in,'\*.wav'));

% Specify output directory
path_out = 'feature_data';

% Params for bispectrum calculation
nlag = 25;
nsamp = 256;
overlap = 75;
nfft = 256;
fs= 16000;

% Define pre-emphasis filter
pe = tf([1,-0.95],1,1/fs,'Variable','z^-1');

f = [];

% Loop through .wav files and compute features
for i=1:size(wav_files,1)

    % Read file and pre-emphasise
    [s,fs] = audioread(wav_files(i).name);
    s = lsim(pe,s);

    % Extract vowels
    vowels = extract_vowels(s,fs);
    
    f1=[];
    
    B = zeros(nfft);

    for j=1:length(vowels)
        vowel = cell2mat(vowels(j));
        wind = hamming(size(vowels(j),1));
        disp(wind)

        % Bispectrum and skewness
        [B1,axis] = bispeci(vowel,nlag,nsamp,overlap,'unbiased',nfft,wind);
        [sk,axis] = bicoher(vowel,nfft,wind,nsamp,overlap);
        
        Bc = sk.*exp(1j*angle(B1));
    
        % Complex bicepstrum
        Blog = log(abs(Bc)) + 1j*phase_unwrap(angle(Bc));
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
        
        B = B + BN/length(vowels);
        
    end
    
    % Compute the first four statistical moments of mag/phase
    %B_mag = abs(BN);     %or abs(B)
    %B_ph = angle(BN);
    %[B_mag_m1,B_mag_m2,B_mag_m3,B_mag_m4] = compute_moments(B_mag);
    %[B_ph_m1,B_ph_m2,B_ph_m3,B_ph_m4] = compute_moments(B_ph);

    % Define feature vector
    %f1 = [f1;B_mag_m1,B_mag_m2,B_mag_m3,B_mag_m4,B_ph_m1,B_ph_m2,B_ph_m3,B_ph_m4];
    %f=[f;f1];
    evals = eig(abs(BN));
    [ax,rad] = compute_integrals(B,nfft);
    f = [f;ax];
    
end

% Reduce the size to the first quadrant, normalise magnitudes
function y = process(x,nfft)
    y = x(nfft/2:end, nfft/2:end);
    [min,max] = bounds(abs(y(:)));
    y = (y-min)/(max-min);
end

% Compute the first four statistical moments
function [m1,m2,m3,m4] = compute_moments(B)
    m1 = mean(B(:));
    m2 = var(B(:));
    m3 = skewness(B(:));
    m4 = kurtosis(B(:));
end

function [ax,rad] = compute_integrals(B,nfft)
    % Define the principal domain
    % Assuming principal domain is a triangular region where k1 + k2 <= pi
    k1 = linspace(-pi, pi, nfft);
    k2 = linspace(-pi, pi, nfft);
    [B_k1, B_k2] = meshgrid(k1, k2);
    principal_mask = (B_k1 + B_k2 <= pi) & (B_k1>=0) & (B_k2>=0);

    % Mask the bispectrum to keep only the principal domain
    B_principal = B .* principal_mask;

    % Perform axial integration over k2 for each k1
    axial_integration = trapz(k2, B_principal, 2);

    % Convert to polar coordinates
    [Theta, R] = cart2pol(B_k1, B_k2);

    % Define radial bins
    num_bins = 17;  % Adjust the number of bins as necessary
    r_max = max(R(:));
    radial_bins = linspace(0, r_max, num_bins);
    radial_values = zeros(1, num_bins-1);

    % Perform radial integration
    for i = 1:num_bins-1
        radial_mask = (R >= radial_bins(i) & R < radial_bins(i+1));
        B_radial = B_principal .* radial_mask;
        radial_values(i) = sum(B_radial(:));
    end
    rad = radial_values;
    ax = axial_integration';
end
