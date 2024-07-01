function [B,Bpsd,psd,B_mean,B_var,B_skew,B_kurt] = compute_bispectrogram(s,nfft,hop)

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
        s_frame = s_frame .* hamming(nfft+1);

        % Compute FFT
        sfft_frame = fft(s_frame,nfft);

        % Compute PSD
        psd_frame = sfft_frame .* conj(sfft_frame);

        %B_frame = sfft_frame * transpose(sfft_frame);
        %Bpsd_frame = psd_frame * transpose(psd_frame);
        %for i = 1:nfft
        %    for j = 1:nfft
        %        B_frame(i,j) = B_frame(i,j) * conj(sfft_frame(mod(i+j-1,nfft)+1));
        %        Bpsd_frame(i,j) = Bpsd_frame(i,j) * psd_frame(mod(i+j-1,nfft)+1);
        %    end
        %end

        indices = mod((0:nfft-1)+(0:nfft-1)',nfft) + 1;
        B_frame = sfft_frame * transpose(sfft_frame) .* conj(sfft_frame(indices));
        Bpsd_frame = psd_frame * transpose(psd_frame) .* psd_frame(indices);

        % Compute the first four statistical moments
        mean_frame = mean(B_frame(:));
        var_frame = var(B_frame(:));
        skew_frame = skewness(B_frame(:));
        kurt_frame = kurtosis(B_frame(:));

        % Prepare for next frame
        B = cat(3,B,B_frame);
        Bpsd = cat(3,Bpsd,Bpsd_frame);
        psd = cat (2,psd,psd_frame);
        sfft = cat(2,sfft,sfft_frame);
        B_mean = cat(1,B_mean,mean_frame);
        B_var = cat(1,B_var,var_frame);
        B_skew = cat(1,B_skew,skew_frame);
        B_kurt = cat(1,B_kurt,kurt_frame);
        n_start = n_start + hop;
        n_end = n_end + hop;
    end

    % Compute the long term averages
    psd = mean(psd,2);
    sfft = mean(sfft,2);
    B = mean(B,3);
    Bpsd = mean(Bpsd,3);
    B = fftshift(B);
    Bpsd = fftshift(Bpsd);

    % Take half of the PSD due to symmetry
    psd = psd(1:floor(end/2));
 
end