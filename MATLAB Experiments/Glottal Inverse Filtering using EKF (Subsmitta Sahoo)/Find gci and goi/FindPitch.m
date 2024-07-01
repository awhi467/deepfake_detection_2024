% Function FindPitch finds the pitch of the sound wave using
% autocorrelation method.
%
%
%
% Inputs
%  FramedSignal   : [Frame size x Number of Frames] Matrix formed by taking
%                   overlapped frames of the speech samples.
%  Fs             : (Hz) The sampling frequency.
%  F_max          : (Hz) Upper limit of the Pitch range.
%  F_min          : (Hz) Lower limit of the Pitch range.
%
% Outputs
%  Pitch          : [1 x Number of Frames]Vector containing Pitch of the
%                   frames.
%
%
%

function [Pitch] = FindPitch(FramedSignal,Fs,F_max,F_min)
NumOfFrames=size(FramedSignal,2);
Pitch = zeros(NumOfFrames,1);

minms = floor(Fs/F_max);
maxms = floor(Fs/F_min);

for i = 1:NumOfFrames
    
    r = xcorr(FramedSignal(:,i)); % Auto Correlation
    % half is just mirror for real signal,so eliminating the half part
    r = r(ceil(length(r)/2):end);
    
    % search for peaks in autocorrelation function so that Pitch will lie
    % between F_min to F_max
    [~,idx]=max(r(minms:maxms));
    Pitch(i) = floor(Fs/(minms+idx-1));
    
end
Pitch = medfilt1(Pitch,8);

