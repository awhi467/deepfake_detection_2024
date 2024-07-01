%______________________________________________________________________________________________________________________
% myspectrogram test framework by Kamil Wojcicki, 2010 (test_myspectrogram.m)
clear all; close all; % clc;

    titlecase = @(str) ( sprintf('%s%s',upper(str(1)),str(2:end))); % make a word title case

    file.clean = 'sp10.wav';
    file.noisy = 'sp10_white_sn5.wav';

    [speech.clean, fs, nbits] = wavread(file.clean);    
    [speech.noisy, fs, nbits] = wavread(file.noisy);

    % speech.enhanced = some_enhancement_method(speech.noisy, "other method parameters go here..."); 

    methods = fieldnames(speech); % method names
    M = length(methods); % number of methods


    % PLOT SPECTROGRAMS (PERIODOGRAM SPECTRUM)
    figure('Position', [20 20 800 250*M], 'PaperPositionMode', 'auto', 'Visible', 'on');
    for m = 1:M % loop through treatment types and plot spectrograms
        method = methods{m};
        subplot(M,1,m); 
        %myspectrogram(speech.(method), fs); % use the default options
        myspectrogram(speech.(method), fs, [22 1], @hamming, 2048, [-59 -1], false, 'default', false, 'per'); % or be quite specific about what you want
        title(titlecase(method));
        xlabel('Time (s)');
        ylabel('Frequency (Hz)');
    end
    print('-depsc2', '-r250', sprintf('%s.eps', mfilename));
    print('-dpng', sprintf('%s.png', mfilename));


    % PLOT SPECTROGRAMS (AUTOREGRESSIVE SPECTRUM WITH PREEMPHASIS)
    figure('Position', [20 20 800 250*M], 'PaperPositionMode', 'auto', 'Visible', 'on');
    for m = 1:M % loop through treatment types and plot spectrograms
        method = methods{m};
        subplot(M,1,m); 
        myspectrogram(speech.(method), fs, [32 1], @hamming, 2048, [-59 -1], [1 -0.97], 'default', false, 'lp'); 
        title(titlecase(method));
        xlabel('Time (s)');
        ylabel('Frequency (Hz)');
    end 
    print('-depsc2', '-r250', sprintf('%s_lp.eps', mfilename));
    print('-dpng', sprintf('%s_lp.png', mfilename));


    % WRITE TO AUDIO FILES
    for m = 1:M % loop through treatment types and write to wavs
        method = methods{m};
        audio.(method) = 0.999*speech.(method)./max(abs(speech.(method)));
        wavwrite(audio.(method), fs, nbits, sprintf('%s.wav',method));
    end

    fprintf('Enjoy! :)\n');

%______________________________________________________________________________________________________________________
% EOF
