% Script for generating input data for classifying between natural and
% synthetic speech. Features are based on the axial and radial integrated
% bicoherence/skewness function. 

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
addpath('..\Speech samples\LJ_natural')

% Specify directory of .wav files
natural_path = '..\Speech samples\LJ_natural';
natural_wavs = dir(strcat(natural_path,'\*.wav'));
synthetic_path = '..\Speech samples\LJ_synthetic';
synthetic_wavs = dir(strcat(synthetic_path,'\*.wav'));

% Params 
nlag = 25;
nsamp = 32 ;
overlap = 50;
nfft = 32;
wind = hamming(nfft);
fs= 22050;

% Define pre-emphasis filter
pe = tf([1,-0.95],1,1/fs,'Variable','z^-1');

% Initialise data matrices
f_bic_ax = [];
f_sk_ax = [];
f_bic_rad = [];
f_sk_rad = [];
%f_moments = [];

for is_synthetic=0:1
    
    % First loop through natural wavs, then synthetic wavs
    if is_synthetic
        wav_files = synthetic_wavs;
    else
        wav_files = natural_wavs;
    end
    
    % Loop through .wav files and compute features
    for i=1:size(wav_files,1)

        % Print filename
        disp(wav_files(i).name)

        % Read file
        [s,fs] = audioread(wav_files(i).name);
        
        % Pre-emphasise
        s = lsim(pe,s);

        % Bicoherence and skewness
        [sk,bic,axis] = bicoherence_modified(s,nfft,wind,nsamp,overlap);

        % Principal domain
        bicp = bic(nfft/2+1:end, nfft/2+1:end).*triu(ones(nfft/2)).*fliplr(triu(ones(nfft/2)));
        skp = sk(nfft/2+1:end, nfft/2+1:end).*triu(ones(nfft/2)).*fliplr(triu(ones(nfft/2)));

        % Axial integral 
        bic_ax = trapz(bicp,1);
        sk_ax = trapz(skp,1);

        % Radial integral
        bic_rad = compute_radial_integral(bicp,nfft,nfft/2);
        sk_rad = compute_radial_integral(skp,nfft,nfft/2);

        % Compute the first four statistical moments of mag/phase
        %B_mag = abs(bic);     %or abs(B)
        %B_ph = angle(bic);
        %[B_mag_m1,B_mag_m2,B_mag_m3,B_mag_m4] = compute_moments(B_mag);
        %[B_ph_m1,B_ph_m2,B_ph_m3,B_ph_m4] = compute_moments(B_ph);

        % Add feature vectors to data matrices
        %f_moments = [f_moments; B_mag_m1,B_mag_m2,B_mag_m3,B_mag_m4,B_ph_m1,B_ph_m2,B_ph_m3,B_ph_m4];
        f_bic_ax = [f_bic_ax;is_synthetic,abs(bic_ax)];
        f_sk_ax = [f_sk_ax;is_synthetic,abs(sk_ax)];
        f_bic_rad = [f_bic_rad;is_synthetic,abs(bic_rad)];
        f_sk_rad = [f_sk_rad;is_synthetic,abs(sk_rad)];

    end
end

% Compute the first four statistical moments
function [m1,m2,m3,m4] = compute_moments(B)
    m1 = mean(B(:));
    m2 = var(B(:));
    m3 = skewness(B(:));
    m4 = kurtosis(B(:));
end

% Compute the radial integral
function rad = compute_radial_integral(B,nfft,rad_points)
    alpha = linspace(0,1,rad_points);
    for j=1:rad_points
        Bnew = interpolate(B,alpha(j));
        rad(j) = 0;
        for k=1:nfft/2
            rad(j) = rad(j)+Bnew(k);
        end
    end
end

% Interpolation for the radial integral
% B(k,ak) = pB(k,ceil(ak))+(1-p)B(k,floor(ak))
function Brad = interpolate(B,alpha)
    [K1,K2] = size(B);
    k1 = 1:K1;
    k2 = 1:K2;
    p = alpha*k1-floor(alpha*k1);
    index1 = ceil(alpha*k1);
    index2 = floor(alpha*k1);
    index1(index1==0)=1;
    index2(index2==0)=1;
    Brad = p*B(k1,index1)+(1-p)*B(k1,index2);
end

% Bisepctrum energy normalisation - not needed if using bicoherence/skewness
function Bn = energy_normalise(B)
    absB = abs(B);
    vol = sum(absB(:));
    Bn = B/vol;
end

function [BL,BN] = cepstum_factorise(B)
    % Complex bicepstrum
    Blog = log(abs(sk)) + 1j*phase_unwrap(angle(B));
    b = ifft2(Blog);

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

end
    

%OLD RADIAL INTEGRAL _ WORKED WELL
    % Convert to polar coordinates
    %[Theta, R] = cart2pol(Bf1, Bf2);
    
    % Define radial bins
    %num_bins = 41;  % Adjust the number of bins as necessary
    %r_max = max(R(:));
    %radial_bins = linspace(0, r_max, num_bins);
    %radial_values = zeros(1, num_bins-1);
    
    % Perform radial integration
    %for i = 1:num_bins-1
    %    radial_mask = (R >= radial_bins(i) & R < radial_bins(i+1));
    %    B_radial = Bp .* radial_mask;
    %    radial_values(i) = sum(B_radial(:));
    %end
    %rad = radial_values;
    %rad = Ir;
    %ax = Ia;
%end