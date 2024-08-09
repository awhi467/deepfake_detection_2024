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
addpath('..\Speech samples\LJ_synthetic')
addpath('..\Speech samples\LJSpeech natural')

% Specify directory of .wav files
path_in = ['..\Speech samples\LJ_synthetic'];
is_synthetic = 0;       % 0 for natural, 1 for synthetic
wav_files = dir(strcat(path_in,'\*.wav'));
% Specify output directory
path_out = 'feature_data';
% Params
nlag = 25;
nsamp = 256;
overlap = 50;
nfft = 256;
wind = hamming(nfft+1);
fs= 22050;

% Define pre-emphasis filter
pe = tf([1,-0.95],1,1/fs,'Variable','z^-1');
fa = [];
fb = [];
% Loop through .wav files and compute features
for i=1:size(wav_files,1)
    % Read file and pre-emphasise
    disp(wav_files(i).name)
    [s,fs] = audioread(wav_files(i).name);
    s = lsim(pe,s);
    % Bispectrum and skewness
    [B,axis] = bispeci(s,nlag,nsamp,overlap,'unbiased',nfft,wind);
    [sk,axis] = bicoher(s,nfft,wind,nsamp,overlap);
    % Complex bicepstrum
    Blog = log(abs(sk)) + 1j*phase_unwrap(angle(B));
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
    
    %B = process(B,nfft);
    %writematrix(B,strcat(path_out,'\B_', erase(wav_files(i).name, '.wav'),'.csv'))
    %sk = process(sk,nfft);
    %writematrix(sk,strcat(path_out,'\sk_', erase(wav_files(i).name, '.wav'),'.csv'))
    % Compute the first four statistical moments of mag/phase
    B_mag = abs(BN);     %or abs(B)
    B_ph = angle(BN);
    [B_mag_m1,B_mag_m2,B_mag_m3,B_mag_m4] = compute_moments(B_mag);
    [B_ph_m1,B_ph_m2,B_ph_m3,B_ph_m4] = compute_moments(B_ph);
    % Define feature vector
    %f = [f; B_mag_m1,B_mag_m2,B_mag_m3,B_mag_m4,B_ph_m1,B_ph_m2,B_ph_m3,B_ph_m4];
    [rad,ax] = integration_measures(B);
    fa = [fa;abs(rad)];
    ax = sum(reshape(ax, 16, 16),2);
    fb = [fb;abs(ax')];
    
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
% Radial and axial integrals, computed over the principal domain
function [rad, ax] = integration_measures(B)
    [m,n] = size(B);
    i = 1:m;
    j = 1:n;
    [Bf1,Bf2] = meshgrid(i,j);
    
    % Define the principal domain
    % Assuming principal domain is a triangular region where k1 + k2 <= pi
    principal_mask = (Bf1>=0) & (Bf2>=0) & (Bf2<=Bf1);
    
    % Mask the bispectrum to keep only the principal domain
    B_principal = B .* principal_mask;
    
    % Perform axial integration over k2 for each k1
    axial_integration = trapz(i, B_principal, 2);
    
    % Convert to polar coordinates
    [Theta, R] = cart2pol(Bf1, Bf2);
    
    % Define radial bins
    num_bins = 21;  % Adjust the number of bins as necessary
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