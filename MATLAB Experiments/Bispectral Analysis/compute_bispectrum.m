function [B,psd,BL,BN, bL, bN] = compute_bispectrum(s,nfft,hop, nbins)
addpath('phase_unwrap')

% Inputs:   s = Speech signal
%           nfft = FFT/frame size in samples
%           hop = Frame shift in samples
%           nbins = Desired number of points in the outputs
% Outputs:  B = Bispectrum
%           Bpsd = Power bispectrum
%           psd = Power spectral density
%
% Note that nfft, hop and nbins should all be powers of two.

    % Initialisation
    n_start = 1;
    n_end = n_start + nfft;
    psd = [];
    sfft = [];
    B = [];
    Bpsd = [];
    B_mean = [];
    B_var = [];
    B_skew = [];
    B_kurt = [];

    % Cycle through overlapping frames of the speech signal
    while (n_end <= size(s,1))

        % Get data frame and apply a Hamming window
        s_frame = s(n_start:n_end) ;
        %s_frame = s_frame .* hamming(nfft+1);

        % Compute FFT
        sfft_frame = fft(s_frame,nfft);

        % Compute PSD
        psd_frame = sfft_frame .* conj(sfft_frame);

        sfft_frame = bin1(sfft_frame, nbins);
        psd_frame = bin1(psd_frame, nbins);

        % Compute the bispectrum and power bispectrum
        indices = mod((0:nbins-1)+(0:nbins-1)',nbins) + 1;
        B_frame = sfft_frame * transpose(sfft_frame) .* conj(sfft_frame(indices));

        % Compute the first four statistical moments
        mean_frame = mean(B_frame(:));
        var_frame = var(B_frame(:));
        skew_frame = skewness(B_frame(:));
        kurt_frame = kurtosis(B_frame(:));

        % Prepare for next frame
        B = cat(3,B,B_frame);
        psd = cat (2,psd,psd_frame);
        sfft = cat(2,sfft,sfft_frame);
        B_mean = cat(1,mean_frame);
        B_var = cat(1,var_frame);
        B_skew = cat(1,skew_frame);
        B_kurt = cat(1,kurt_frame);
        n_start = n_start + hop;
        n_end = n_end + hop;
    end

    % Compute the long term averages
    psd = mean(psd,2);
    sfft = mean(sfft_frame,2);
    B = mean(B,3);

    % Compute the complex bicepstrum
    Blog = log(abs(B)) + 1j*phase_unwrap(angle(B));
    b = ifft2(Blog);

    % Compute linear and nonlinear complex bicepstrum
    bL = zeros(nbins);
    for i=1:nbins
        for j=1:nbins
            if (i==1) || (j==1) || (i==j)
                bL(i,j)=b(i,j);
            end
        end
    end
    bN = b - bL;

    % Compute linear and nonlinear bispectrum
    BL = exp(fft2(bL));
    BN = exp(fft2(bN));

    %{ 
    % Binning
    psd = bin1(psd, nbins);
    B = bin2(B, nbins);
    BL = bin2(BL, nbins);
    BN = bin2(BN, nbins);
    %}

    % FFT shifts
    B = fftshift(B);
    BL = fftshift(BL);
    BN = fftshift(BN);
    bL = fftshift(bL);
    bN = fftshift(bN);

end

% Used for binning the 1D outputs to get desired size
function y = bin1(x,nbins)
    bin_size = size(x,1)/nbins;
    y = zeros(nbins,1);
    for i=1:nbins
        y(i) = mean(x((bin_size*(i-1)+1):(bin_size*i)));
    end
end

% Used for binning the 2D outputs to get desired size
function y = bin2(x, nbins)
    % Initialize the new matrix
    y = zeros(nbins, nbins);

    bin_size = size(x,1)/nbins;
    
    % Loop through each block and calculate the average
    for i = 1:nbins
        for j = 1:nbins
            block = x(bin_size*(i-1)+1:bin_size*i, bin_size*(j-1)+1:bin_size*j);
            y(i,j) = mean(block(:));
        end
    end
end