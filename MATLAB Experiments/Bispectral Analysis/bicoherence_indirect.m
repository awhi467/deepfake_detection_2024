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
addpath('..\Speech samples\LJ_natural')
addpath('..\Speech samples\LJ_synthetic')
addpath('..\Speech samples\cw_natural')
addpath('..\Speech samples\cw_synthetic')

% Read audio files
number = '319';
%filename = ['NaturalNick', number, '.wav'];
%filename = [number, '_logs-150-Nick-Base.wav'];
%filename = ['NaturalIsabella', number, '.wav'];
%filename = [number, '_logs-150-Isabella-Reference-Base.wav'];
%filename = 'fs2_test.wav';
%filename = 'peter_test1.wav';
filename = [number,'.wav'];
filename = "cw_synthetic\17.wav"
[s, fs] = audioread(filename);

% Pre-emphasise
pe = tf([1,-1],1,1/fs,'Variable','z^-1');
s = lsim(pe,s);

% Params
nlag = 25;
nsamp = 256;
overlap = 50;
nfft = 256;
wind = hamming(nfft+1);
%s=2*s;

% Bispectrum calculation
[B,axis] = bispeci(s,nlag,nsamp,overlap,'unbiased',nfft,wind);

% Skewness function
[sk,bic,axis] = bicoherence_modified(s,nfft,wind,nsamp,overlap);

% Complex bicepstrum
Blog = log(abs(bic)) + 1j*phase_unwrap(angle(B));
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

% System frequency response
H = exp(fft(bH));
H = H(nfft/2:end);

% Principal domain
bicp = bic(nfft/2+1:end, nfft/2+1:end).*triu(ones(nfft/2)).*fliplr(triu(ones(nfft/2)));
skp = sk(nfft/2+1:end, nfft/2+1:end).*triu(ones(nfft/2)).*fliplr(triu(ones(nfft/2)));

%Integrated bicoherence
ax = trapz(bicp,1);
rad = compute_radial_integral(bicp,nfft,nfft/2);

%--------------------------------Plots--------------------------------

% Time domain waveform
figure(1)
plot(s)
title('Time domain waveform')
xlabel('n')
ylabel('s[n]')

% Bicoherence
figure(2)
subplot(1,2,1)
image(flipud(abs(B)),'CDataMapping','scaled')
colormap(flipud(gray))
title('Bispectrum magnitude')
xlabel('f_1 (kHz)')
ylabel('f_2 (kHz)')
subplot(1,2,2)
image(flipud(phase_unwrap(angle(B))),'CDataMapping','scaled')
colormap(flipud(gray))
title('Bispectrum phase')
xlabel('f_1 (kHz)')
ylabel('f_2 (kHz)')

figure(3)
subplot(2,2,1)
image(flipud(abs(BL)),'CDataMapping','scaled')
colormap(flipud(gray))
title('Linear')
subplot(2,2,2)
image(flipud(abs(BN)),'CDataMapping','scaled')
colormap(flipud(gray))
title('Nonlinear')
subplot(2,2,3)
image(flipud(abs(B)),'CDataMapping','scaled')
colormap(flipud(gray))
title('Original')
subplot(2,2,4)
image(flipud(abs(BN.*BL)),'CDataMapping','scaled')
colormap(flipud(gray))
title('Product BN*BL')

figure(4)
plot(abs(H))

figure(5)
b = fftshift(b);
image(flipud(hz2mel(abs(b))),'CDataMapping','scaled')
colormap(flipud(gray))

ticks = [1,64,128,192,256];
xlabels = {'-0.5','-0.25','0','0.25','0.5'};
ylabels = {'0.5','0.25','0','-0.25','-0.5'};

ticks1 = [1,32,64,96,128];
xlabels1 = {'0','0.125','0.25','0.375','0.5'};
xlabels2 = {'0','0.25','0.5','0.75','1'};

figure(7)
image(flipud(abs(bicp)),'CDataMapping','scaled')
colormap(flipud(gray))
xticks(ticks)
xticklabels(xlabels)
yticks(ticks)
yticklabels(ylabels)
xlabel('f_1')
ylabel('f_2')
title("Bicoherence")

figure(8)
image(flipud(abs(skp)),'CDataMapping','scaled')
colormap(flipud(gray))
xticks(ticks)
xticklabels(xlabels)
yticks(ticks)
yticklabels(ylabels)
xlabel('f_1')
ylabel('f_2')
title("Skewness")

figure(9)
plot(abs(ax),'k')
%title('Axial integral - bicoherence')
xlabel('f_1')
ylabel('I_A(f_1)')
xticks(ticks1)
xticklabels(xlabels1)

figure(100)
plot(angle(ax),'k')
%title('Axial integral - bicoherence')
xlabel('f_1')
ylabel('I_A(f_1)')
xticks(ticks1)
xticklabels(xlabels1)

figure(10)
plot(rad,'k')
%title('Radial integral - bicoherence')
xlabel('\alpha')
ylabel('I_R(\alpha)')
xticks(ticks1)
xticklabels(xlabels2)


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