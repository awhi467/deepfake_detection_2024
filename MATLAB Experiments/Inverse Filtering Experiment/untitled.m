% Frequency response plot example in MATLAB

% Frequency range (log scale)
freq = logspace(log10(20), log10(20000), 1000);

% Response curve in dB (approximation of the curve in the image)
response = -10 + 10 * log10(freq / 100) ./ (1 + (freq/1000).^2);

% Plotting the graph
figure;
semilogx(0,0, 'r', 'LineWidth', 2); % Red line with width 2
grid on; % Add grid
hold on;

% Axis labels and limits
xlabel('f (Hz)');
ylabel('dB re 1 V/Pa');

% Set axis limits similar to the image
xlim([20 20000]);
ylim([-30 20]);

% Set grid and ticks to match the image
set(gca, 'XTick', [20 100 1000 10000 20000]);
set(gca, 'YTick', [-30 -20 -10 0 10 20]);

% Make the grid lines similar to the image
set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on', 'XScale', 'log');
grid minor;
