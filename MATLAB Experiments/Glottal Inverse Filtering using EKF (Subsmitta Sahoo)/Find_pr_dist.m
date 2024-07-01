% MATLAB function Find_pr_dist.m finds Pressure distribution at different
% sections of vocal tract and the glottal flow derivative signal.
%
%
%
% Inputs
%  VowelSpeech            : [samples] [Nx1] input signal (speech signal)
%  Fs                     : [Hz]      [1x1] sampling frequency
%  VocalTractArea         : [cm^2]    [1xL] vocal tract xsectional areas
%
% Outputs
%  GlotFlowDerivative   : Vector containing the estimated Glottal flow
%                         derivative signal.
%  Est_Speech           : Vector containing the estimated Glottal flow
%                         Speech signal
%  Flow_values          : Marix containing the air flow at different
%                         sections of vocal tract.
%  Peak_loc             : The GCI locations
%
% References
%  [1] Sahoo S, Routray A. A Novel Method of Glottal Inverse Filtering. 
%      IEEE/ACM Transactions on Audio, Speech, and Language Processing. 
%      2016 Jul;24(7):1230-41.
%  [2] Chui CK, Chen G. Kalman filtering: with real-time applications. 
%      Springer Science & Business Media; 2008 Nov 23.
%
% Author: Subhasmita Sahoo, Aurobinda Routray, IIT Kharagpur, India; 13-Sep-2016.



function [GlotFlowDerivative, Est_Speech, Flow_values, Peak_loc]=Find_pr_dist(VowelSpeech,Fs,VocalTractArea)

L=length(VocalTractArea);

%% Downweight the speech signal to make the algorithm converge
Weight=.01;
VowelSpeech=VowelSpeech*Weight;

%% Find the GCI and GOI locations
addpath(strcat(pwd,'\Find gci and goi'));
[Peak_loc, idx]=Find_GCI_GOI(decimate(VowelSpeech,2),Fs/2);Peak_loc=Peak_loc*2;idx=idx*2;

%% Initialization of the States, System parameters and Covariance matrices
% Initialize the states
X0=zeros(2*L+2,1); 
% Initialize the System Parameters calculated from vocal tract areas
Theta0=zeros(L+3,1);                                    
Theta0(1)=0.8;Theta0(L+1)=0.99;                        
for i=1:L-1
Theta0(i+1)=(VocalTractArea(i+1)-VocalTractArea(i))/(VocalTractArea(i)+VocalTractArea(i+1));               
end
Theta0(L+2)=0.4;                                       
Theta0(L+3)=1; 
% Initialize the covariance matrices (values chosen heuristically, should
% be adjusted when require)
Q0=diag(ones(2*L+2,1))*.001;S0=diag(ones(L+3,1))*.01;      
P00=eye(2*L+2+L+3);                                     
R0=.01;

%% The EKF estimation process using the algorithm given in [2] page no 115.
Est_Speech=[];GlotFlowDerivative=[];Flow_values=[];

X1=X0;Theta1=Theta0;P11=P00;

Theta1_tmp1=Theta1(end);
[~, N]=size(P00);P11_tmp2=P11(1:N-2,N-1);P11_tmp3=P11(N-1,1:N-1);
for i=1:length(Peak_loc)-1
    %% For return phase and closed phase 
    
    % Save the error covariance and values of the state variables of the
    % open  Phase
    Theta1_tmp=Theta1(end-1:end);
    P11_tmp=P11(1:N-2,N-1:N);P11_tmp1=P11(N-1:N,:);
    
    % Append the previously saved values of error covariance and state
    % variables  of return phase and closed phase
    Theta1=[Theta1(1:end-2); Theta1_tmp1];
    P11=[P11(1:N-2,1:N-2) P11_tmp2;P11_tmp3];
    
    % Do the EKF iterations till the next GOI reaches
    for j=Peak_loc(i):idx(2*i)
        [Est_SpeechSample,X1,Theta1,P11,GlotFlowSample,states]=EKF_Return_n_Closed_Phase(VowelSpeech(j),X1,Theta1,P11,S0(1:size(S0,2)-1,1:size(S0,2)-1),Q0,R0,L,Fs);
        P11=(P11+P11')/2;
        Est_Speech=[Est_Speech Est_SpeechSample];GlotFlowDerivative=[GlotFlowDerivative GlotFlowSample];Flow_values=[Flow_values states];
    end
    
    %% For open phase
    
    % Save the error covariance and values of the state variables of return
    % phase and closed phase
    Theta1_tmp1=Theta1(end);
    P11_tmp2=P11(1:N-2,N-1);P11_tmp3=P11(N-1,:);
    
    % Append the previously saved values of error covariance and state
    % variables of open Phase
    Theta1=[Theta1(1:end-1); Theta1_tmp];
    P11=[P11(1:N-2,1:N-2) P11_tmp;P11_tmp1];
    
    % Do the EKF iterations till the next GCI reaches
    for k=j+1:Peak_loc(i+1)-1
        [Est_SpeechSample,X1,Theta1,P11,GlotFlowSample,states]=EKF_Open_Phase(VowelSpeech(k),X1,Theta1,P11,S0,Q0,R0,L,Fs);
        P11=(P11+P11')/2;
        Est_Speech=[Est_Speech,Est_SpeechSample];GlotFlowDerivative=[GlotFlowDerivative GlotFlowSample];Flow_values=[Flow_values states];
    end
end

Flow_values=Flow_values(1:L,1:end-1)-Flow_values(L+1:2*L,2:end);

%% Compensate for the weight multiplied to the speech signal

GlotFlowDerivative=GlotFlowDerivative/Weight;
Est_Speech=Est_Speech/Weight;
Flow_values=Flow_values/Weight;

