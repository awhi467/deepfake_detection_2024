 clear;

% Audio file to be analysed
filename = 'vowel.wav';

% Linear prediction order fs/1000+2
P = 18;

% Read file
[s,Fs] = audioread(filename);
n = 0:size(s)-1;

pe = tf([1,-0.95],1,1/Fs,'Variable','z^-1');
s = lsim(pe,s);

% Perform LPC analysis, determine estimated signal and error
a = lpc(s,P);
s_est = filter([0,-a(2:end)],1,s);
e = s-s_est;

% Zoom in on the signal and error
n1 = 501:800;
s1 = s(n1);
e1 = e(n1);

% Long term prediction order
Q = 1;

% Pitch estimation
f0 = pitch(e, Fs, Method='LHS');
N0=Fs./f0;
N0_avg = round(mean(N0));

% Shift error to the right by N0, e(1)=e_shift(N0+1)
e_shift = zeros(size(e,1)+N0_avg,1);
e_shift(N0_avg+1:end) = e(1:end);
n2 = 0:size(e_shift)-1;

% Perform a long term LPC prediction. LPC on e is predicting e_shift. what
% about b0 coefficeint?
b = lpc(e, Q);
e_shift_est = filter([0,-b(2:end)],1,e_shift);
q = e_shift-e_shift_est;

% Shift signal to the right by N0, e(1)=e_shift(N0+1)
s_shift = zeros(size(e,1)+N0_avg,1);
s_shift(N0_avg+1:end) = s(1:end);

s_shift_est = filter([0,-a(2:end)],1,s_shift) + filter([0,-b(2:end)],1,[s;zeros(N0_avg,1)]);
e2 = s_shift-s_shift_est;

% Plot of signals
figure(1);
plot(n,s,n,s_est);
legend('orginal','estimated');
xlabel('n')
ylabel('s[n]')
title('Original signal and Estimated signal');

% Plot of error signal
figure(2);
plot(n,e);
xlabel('n')
ylabel('e[n]')
title('Error');

% Plot of zoomed in signal
figure(3);
subplot(2,1,1)
stem(n1,s1);
xlabel('n')
ylabel('s[n]')
title('Original Signal')
subplot(2,1,2)
stem(n1, e1.^2);
xlabel('n')
ylabel('e[n]^2')
title('Error squared')

% Plot error long term prediction
figure(4)
plot(n2,e_shift, n2,e_shift_est)
legend('orginal','estimated');
xlabel('n')
ylabel('e[n]')
title('Long term Error Prediction');

% Plot of wideband noise component
figure(5);
plot(n2,q);
xlabel('n')
ylabel('q[n]')
title('Wideband noise');

figure(6)
plot(n2,s_shift, n2, s_shift_est)

figure(7)
plot(n2, e2)