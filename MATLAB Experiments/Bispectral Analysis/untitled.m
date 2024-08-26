% Define the range for x
x = linspace(0, 1, 100);

% Define the lines
y1 = x;
y2 = 1 - x;
y3 = zeros(size(x));

% Plot the lines in grayscale
figure;
plot(x, y1, 'k', 'DisplayName', 'y = x'); hold on; % 'k' is black
plot(x, y2, 'k', 'DisplayName', 'y = 1-x');
plot(x, y3, 'k', 'DisplayName', 'y = 0');
% Add the vertical dashed line at x = 0.25
y_vline = linspace(0, 1, 100); % y values from 0 to 1
x_vline = 0.35 * ones(size(y_vline)); % x value is 0.25
plot(x_vline, y_vline, 'k--', 'DisplayName', 'x = 0.25');

% Fill the area between the lines to form the triangle in grayscale
fill([x fliplr(x)], [y1 fliplr(y3)], [0.5 0.5 0.5], 'FaceAlpha', 0.5); % [0.5 0.5 0.5] is gray

% Set limits and labels
xlim([-0.2 1.2]);
ylim([-0.2 0.7]);
xlabel('f_1');
ylabel('f_2');
xticks([0,1])
yticks([0,1])
%title('Triangle Bounded by y=x, y=1-x, y=0 (Grayscale)');

% Display grid
grid off;
axis equal;