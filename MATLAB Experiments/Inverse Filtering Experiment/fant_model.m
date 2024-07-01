clear;

T0 = 1/200;  % fundamental period
tp = T0/3;   % instant of max glottal flow
tc = 2*T0/3; % instant of termination
K = 0.5;     % symmetry factor
wg=pi/tp;

for n = 1:1000
    t = n*T0/1000;
    if (t <= tp)
        g(n) = 0.5*(1-cos(wg*t));
    elseif (t <= tc)
        g(n) = K*cos(wg*(t-tp))-K+1;
    else
        g(n) = 0;
    end
end

plot(g)