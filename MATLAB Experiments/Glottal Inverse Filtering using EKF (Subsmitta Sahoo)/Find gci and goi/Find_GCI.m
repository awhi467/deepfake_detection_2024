% MATLAB function Find_GCI_Peaks.m finds the GCI locations by picking
% the peaks in the Linear prediction residual. It uses the method used in
% [1].
%
% Note: The pitch_srh.m function used in this file has been taken from
% the online repository https://github.com/covarep/covarep. (Version 1.3.2)
%
% Inputs
%  Sn           : [N x 1] The speech signal.
%  Fs           : The sampling frequency.
%
% Outputs
%  Peak_loc     : Estimated value of the vowel speech sample.
%  res          : The LP residuals.
%
% References
%  [1] Plumpe, M.D., Quatieri, T.F. and Reynolds, D.A., 1999. Modeling of
%  the  glottal flow derivative waveform with application to speaker
%  identification.  IEEE Transactions on Speech and Audio Processing, 7(5),
%  pp.569-586.
%



function [res, Peak_loc]=Find_GCI(Sn,Fs)
[FramedSignal,Fs] = Speech_To_Frames(Sn,Fs);
[F0s] = FindPitch(FramedSignal,Fs,250,100);

avg_pitch=mean(F0s);

Frame_shift=round(Fs/avg_pitch);
Frame_duration=2*Frame_shift;

res=zeros(1,length(Sn-14));
start=15;
stop=start+Frame_duration;
order=14;

n=1;
while stop<length(Sn)
    
    segment=Sn(start-14:stop);
    
    A=covar_LPC(segment,order);
    
    temp=filter([1 -A],1,segment);
    inv=temp(15:end);
    
    inv=inv*sqrt(sum(segment.^2)/sum(inv.^2));
    
    res(start:stop)=res(start:stop)+inv'; % Overlap and add
    
    % Increment
    start=start+Frame_shift;
    stop=stop+Frame_shift;
    n=n+1;
end

res=res/max(abs(res));
% figure;plot(res)

[~, Xp]=max(res);
Peak_loc(1)=Xp;

%% move right to the maximum negative peak
cnt=1;
I=floor(Xp/(.01*Fs));    %10 ms is the window shift length

start=round(Peak_loc(cnt)+0.85*Fs/F0s(I));
stop=round(Peak_loc(cnt)+1.15*Fs/F0s(I));
while stop<length(res)-.02*Fs
    [~,Xp]=max(res(start:stop));
    Peak_loc(cnt+1)=Xp+start-1;cnt=cnt+1;
    
    I=floor(Peak_loc(cnt)/(.01*Fs));
    
    start=round(Peak_loc(cnt)+0.85*Fs/F0s(I));
    stop=round(Peak_loc(cnt)+1.15*Fs/F0s(I));
end

%% move left to the maximum negative peak
I=floor(Peak_loc(1)/(.01*Fs));

start=round(Peak_loc(1)-1.15*Fs/F0s(I));
stop=round(Peak_loc(1)-0.85*Fs/F0s(I));
while start>0
    [~,Xp]=max(res(start:stop));
    Peak_loc(cnt+1)=Xp+start-1;cnt=cnt+1;
    
    I=ceil(Peak_loc(cnt)/(.01*Fs));
    
    start=round(Peak_loc(cnt)-1.15*Fs/F0s(I));
    stop=round(Peak_loc(cnt)-0.85*Fs/F0s(I));
end
Peak_loc=sort(Peak_loc,'ascend');

% figure;plot(res);hold on;plot(Peak_loc,res(Peak_loc),'k^','markerfacecolor',[1 0 0]);
% figure;plot(Sn);hold on;plot(Peak_loc,Sn(Peak_loc),'k^','markerfacecolor',[1 0 0]);


