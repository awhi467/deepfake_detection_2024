% MATLAB function Track_Formants.m tracks the formants between the adjacent
% GCIs.
%
%
%
% Inputs
%  Sn          : [N x 1] The speech signal.
%  Fs          : The sampling frequency.
%  Start_loc   : Starting GCI location.
%  Stop_loc    : Ending GCI location.
%  Nw          : Number of samples in the sliding window used to track the formants.
%  p           : Order of the linear prediction.
%
% Outputs
%  Formants    : The computed formants.
%
%
%
%
function Formants=Track_Formants(Sn,Fs,Start_loc,Stop_loc,Nw,p)

N=Stop_loc-Start_loc+1;
for j=0:N-Nw-1
    y=Sn(Start_loc+j-p:Start_loc+j+Nw);
    LP_coeff=covar_LPC(y,p);
    
    rts = roots([1 -LP_coeff]);
    rts = rts(imag(rts)>=0);
    angz = atan2(imag(rts),real(rts));
    [frqs,indices] = sort(angz.*(Fs/(2*pi)));
    bw = -1/2*(Fs/(2*pi))*log(abs(rts(indices)));
    nn = 1;
    for kk = 1:length(frqs)
        if (frqs(kk) > 90 && bw(kk) <400)
            Formants(j+1,nn) = frqs(kk);
            nn = nn+1;
        end
    end
    
end
