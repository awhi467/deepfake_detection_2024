clear;
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Isabella (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Natural Speech\Nick (16kHz)');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Isabella');
addpath('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Nick');
addpath('Troparion-master\IRAPT\IRAPT_web');
addpath('Troparion-master\Perturbation_analysis');

files = dir('..\Speech samples\Natural-Tacotron2-pairs\Tacotron 2\Isabella');
J_loc = [];
J_rap = [];
J_ppq5 = [];
J_ppq11 = [];
S_loc = [];
S_apq3 = [];
S_apq5 = [];
S_apq11 = [];
for i=1:size(files,1)
    if ~files(i).isdir
        [s,fs] = audioread(files(i).name);
        [Fo, ~, time_marks] = irapt(s, fs, 'irapt1','speech');  
    
        % Segmentation of signal onto fundamental periods
        [periods] = WM_phase_const(s,Fo,time_marks,fs);
        [amplitudes]= amp_extract(periods,s);
    
        % Perturbation parameters calculation
        J_loc  = [J_loc, shim_local(periods)];
        J_rap  = [J_rap, shim_apq3(periods)];
        J_ppq5 = [J_ppq5, shim_apq5(periods)];
        J_ppq11 = [J_ppq11, shim_apq11(periods)];
        S_loc   = [S_loc, shim_local(amplitudes)];
        S_apq3  = [S_apq3, shim_apq3(amplitudes)];
        S_apq5  = [S_apq5, shim_apq5(amplitudes)];
        S_apq11 = [S_apq11, shim_apq11(amplitudes)];
    end
end

n = 1:size(J_loc,2);

figure(1)
plot(n,J_loc,n,J_rap,n,J_ppq5,n,J_ppq11)
legend('Jloc','Jrap','Jppq5','Jppq11')
xlabel('Sample')
ylabel('Jitter')

figure(2)
plot(n,S_loc,n,S_apq3,n,S_apq5,n,S_apq11)
legend('Sloc','Srap','Sppq5','Sppq11')
xlabel('Sample')
ylabel('Shimmer')
