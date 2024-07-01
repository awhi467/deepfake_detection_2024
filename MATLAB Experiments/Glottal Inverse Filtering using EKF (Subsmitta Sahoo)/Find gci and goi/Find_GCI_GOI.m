% MATLAB function Find_GCI_GOI.m finds the GCI and GOI locations. 
%
% Description:
% It first finds the GCI locations by peak picking in the Linear Prediction
% residual. After that, closed phase regions are obtained by seeing at the
% variation in formants and the end of the closed phase regions was taken
% as the GOI locations. This method has been given in [1].
%
%
%
% Inputs
%  Sn           : [N x 1] The speech signal.
%  Fs           : The sampling frequency.
%
% Outputs
%  Peak_loc     : Estimated value of the vowel speech sample.
%  idx          : The starting and ending points of closed phase.
%
% References
%  [1] Plumpe, M.D., Quatieri, T.F. and Reynolds, D.A., 1999. Modeling of
%  the  glottal flow derivative waveform with application to speaker
%  identification.  IEEE Transactions on Speech and Audio Processing, 7(5),
%  pp.569-586.
%
% 

function [Peak_loc, idx]=Find_GCI_GOI(Sn,Fs)

% Find Initial glottal pulse positions by peak picking method
[~, Peak_loc]=Find_GCI(Sn,Fs);
p=14;
Glot_dvtv=[];
idx=[];
for i=1:length(Peak_loc)-1
    % Take the region between two consecutive glottal pulse positions
    N=Peak_loc(i+1)-Peak_loc(i)+1;
    
    % Track the Formants by sliding covariance analysis
    if (N/4)>=2*p
        Nw=2*p;
    elseif (N/4)<=p+3
        Nw=p+3;
    else
        Nw=round(N/4);
    end
    F=Track_Formants(Sn,Fs,Peak_loc(i),Peak_loc(i+1),Nw,p);
    
    % Find the Stationary region(closed phase) by seeing Formant modulation
    [Strt_idx_stnry_formant,End_idx_stnry_formant]= Find_stnry_region(F(:,1),N,Nw);
    
    Strt_idx_stnry=Peak_loc(i)+Strt_idx_stnry_formant-1;
    End_idx_stnry=Peak_loc(i)+End_idx_stnry_formant-1+Nw;
    idx=[idx Strt_idx_stnry End_idx_stnry];
    clearvars -except Sn Fs Peak_loc Glot_dvtv p i idx res;
end
% save('GciGoi','Sn','res','Peak_loc');
% figure;plot(Sn);hold on;plot(idx,Sn(idx), 'k^','markerfacecolor',[1 0 0]);plot(Peak_loc,Sn(Peak_loc),'k^','markerfacecolor',[0 1 0]);
% figure;plot(res);hold on;plot(idx,Sn(idx), 'k^','markerfacecolor',[1 0 0]);plot(Peak_loc,Sn(Peak_loc),'k^','markerfacecolor',[0 1 0]);