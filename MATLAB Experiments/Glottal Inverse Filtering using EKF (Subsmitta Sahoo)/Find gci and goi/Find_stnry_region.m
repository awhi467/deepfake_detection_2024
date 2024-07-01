% MATLAB function Find_stnry_region.m finds the closed phase region beteen
% two  GCIs where the formants are almost stationary and start to change at
% the  onset of GOI. 
%
% Description:
% It checks the statistical variation in formants happening after the
% closed phase due to the interaction between glottis and the vocal tract.
% This  method has been given in [1].
%
%
%
% Inputs
%  F           : Formants calculated by sliding a window in the region between two GCIs.
%  N           : Number of samples between two adjacent GCIs over which the
%                Formants have been computed.
%  Nw          : Number of samples in the sliding window used to track the formants.
%
% Outputs
%  Strt_idx_stnry_formant    : Starting index of the stationary region.
%  End_idx_stnry_formant     : Ending index of the stationary region.
%
% References
%  [1] Plumpe, M.D., Quatieri, T.F. and Reynolds, D.A., 1999. Modeling of
%  the  glottal flow derivative waveform with application to speaker
%  identification.  IEEE Transactions on Speech and Audio Processing, 7(5),
%  pp.569-586.
%



function [Strt_idx_stnry_formant,End_idx_stnry_formant]= Find_stnry_region(F,N,Nw) 

% Find initial stationary region
for n0=2:N-Nw-4
    D(n0-1)=abs(F(n0)-F(n0-1))+abs(F(n0+1)-F(n0+1-1))+abs(F(n0+2)-F(n0+1))+abs(F(n0+3)-F(n0+2))+abs(F(n0+4)-F(n0+3));
end
[~, I]=min(D);
Strt_idx_stnry_formant=I;
End_idx_stnry_formant=I+4;

Mean_formant=mean(F(Strt_idx_stnry_formant:End_idx_stnry_formant));
StdDev_formant=std(F(Strt_idx_stnry_formant:End_idx_stnry_formant));

%% Grow the stationary region to right
for r=End_idx_stnry_formant+1:1:length(F)
    if abs(F(r)-Mean_formant)<2*StdDev_formant
        End_idx_stnry_formant=End_idx_stnry_formant+1;
        Mean_formant=mean(F(Strt_idx_stnry_formant:End_idx_stnry_formant));
        StdDev_formant=std(F(Strt_idx_stnry_formant:End_idx_stnry_formant));
    else
        break;
    end
end

%% Grow the stationary region to left
for l=Strt_idx_stnry_formant-1:-1:1
    if abs(F(l)-Mean_formant)<2*StdDev_formant
        Strt_idx_stnry_formant=Strt_idx_stnry_formant-1;
    else
        break;
    end
end
    