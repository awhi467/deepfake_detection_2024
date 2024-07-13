function vowel_segments = extract_vowels(s,fs)

    % Normalize the signal
    s = s / max(abs(s));
    
    % Define parameters for segmentation
    window_length = 0.025;  % 25 ms window
    hop_length = 0.01;  % 10 ms hop
    window_samples = round(window_length * fs);
    hop_samples = round(hop_length * fs);
    threshold = 0.1;  % Energy threshold for detecting vowels
    
    % Segment the signal into overlapping windows
    num_windows = floor((length(s) - window_samples) / hop_samples) + 1;
    energy = zeros(num_windows, 1);
    for i = 1:num_windows
        start_idx = (i-1) * hop_samples + 1;
        end_idx = start_idx + window_samples - 1;
        window = s(start_idx:end_idx);
        energy(i) = sum(window.^2);
    end
    
    % Normalize energy
    energy = energy / max(energy);
    
    % Detect segments above the threshold
    vowel_indices = find(energy > threshold);
    vowel_segments = {};
    current_segment = [];
    for i = 1:length(vowel_indices)
        idx = vowel_indices(i);
        start_idx = (idx-1) * hop_samples + 1;
        end_idx = start_idx + window_samples - 1;
        current_segment = [current_segment; s(start_idx:end_idx)];
        
        % Check if the next index is not consecutive
        if i == length(vowel_indices) || vowel_indices(i+1) > vowel_indices(i) + 1
            vowel_segments{end+1} = current_segment;  %#ok<SAGROW>
            current_segment = [];
        end
    end
end