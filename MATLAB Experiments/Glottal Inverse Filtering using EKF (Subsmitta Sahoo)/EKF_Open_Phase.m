% MATLAB function EKF_Open_Phase.m is the EKF estimation algorithm
% in the open phase.
%
% Description:
% The EKF estimation algorithm and the state space equations of the model
% have  been given in [1].
%
%
%
% Inputs
%  V            : One sample of the vowel speech.
%  X0           : State values estimated at the previous step.
%  Theta0       : Parameter values estimated at the previous step.
%  P00          : Error covariance of the previous step.
%  S0, Q0, R0   : Noise variances associated with State, Parameters, 
%                 and measured output.
%  L            : Length of the vocal tract tube sections.
%  Fs           : The sampling frequency.
%
% Outputs
%  est_V        : Estimated value of the vowel speech sample.
%  X1           : Estimated State values.
%  Theta1       : Estimated Parameter values.
%  P11          : Updated Error covariance.
%  ug           : The estimated glottal flow derivative sample.
%  states       : The Estimated State values (Same as X1).
%
% References
%  [1] Sahoo S, Routray A. A Novel Method of Glottal Inverse Filtering. 
%      IEEE/ACM Transactions on Audio, Speech, and Language Processing. 
%      2016 Jul;24(7):1230-41.
%  [2] Chui CK, Chen G. Kalman filtering: with real-time applications. 
%      Springer Science & Business Media; 2008 Nov 23.
%
% Author: Subhasmita Sahoo, Aurobinda Routray, IIT Kharagpur, India; 13-Sep-2016.


function [est_V,X1,Theta1,P11,ug,states]=EKF_Open_Phase(V,X0,Theta0,P00,S0,Q0,R0,L,Fs)
N=2*L+2+L+3;

Tau=1/Fs;
Theta10=Theta0;
[P10, X10]=Find_P(X0,Theta0,P00,Tau,S0,Q0,L);
C_Theta=[zeros(1,L-1) 1+Theta0(L+1) zeros(1,L+2)];
G1=P10(:,L)*(1+Theta0(L+1))/(P10(L,L)*(1+Theta0(L+1))^2+R0);
P11=(eye(N)-G1*[C_Theta zeros(1,L+3)])*P10;

New_X_Theta=[X10; Theta10]+G1*(V(1)-C_Theta*X10);
est_V(1)=C_Theta*X10;
X1=New_X_Theta(1:2*L+2);
Theta1=New_X_Theta(2*L+2+1:end);
ug(1)=X1(2*L+2-1);
states=X1;
end

function [P10, X10]=Find_P(X0,Theta0,P00,Tau,S0,Q0,L)

[A_Theta, A_Theta_X]=Find_A_Theta_X(X0,Theta0,Tau,L);
del_A_Theta=Find_partialderivtv(X0,Theta0, Tau,L);

tmp=[A_Theta del_A_Theta; zeros(L+3,2*L+2) eye(L+3)];
P10=tmp*P00*tmp'+[Q0,zeros(2*L+2,L+3);zeros(L+3,2*L+2),S0];
X10=A_Theta_X;
end

function [A_Theta, A_Theta_X]=Find_A_Theta_X(X,Theta,Tau,L)

A_Theta_X=zeros(2*L+2,1);
A_Theta_X(1)=Theta(1)*X(L+1)+0.5*(1+Theta(1))*X(2*L+1);
for i=2:L
    A_Theta_X(i)=(1+Theta(i))*X(i-1)+Theta(i)*X(i+L);
    A_Theta_X(i+L-1)=-Theta(i)*X(i-1)+(1-Theta(i))*X(i+L);
end
A_Theta_X(2*L)=-Theta(L+1)*X(L);
A_Theta_X(2*L+1)=Tau*X(2*L+2)+X(2*L+1);
A_Theta_X(2*L+2)=(1+2*Theta(L+3)*Tau)*X(2*L+2)-(Theta(L+3)^(2)+Theta(L+2)^(2))*Tau*X(2*L+1);

A_Theta(1,:)=[zeros(1,L) Theta(1) zeros(1, 2*L-L-1) 0.5*(1+Theta(1)) 0];
for i=1:L-1
    A_Theta(i+1,:)=[zeros(1,i-1) 1+Theta(i+1) zeros(1,L) Theta(i+1) zeros(1,2*L+2-i-1-L)];
    A_Theta(i+L,:)=[zeros(1,i-1) -Theta(i+1) zeros(1,L) 1-Theta(i+1) zeros(1,2*L+2-i-1-L)];
end
A_Theta(2*L,:)=[zeros(1,L-1) -Theta(L+1) zeros(1,2*L+2-L)];
A_Theta(2*L+1,:)=[zeros(1,2*L-1) 0 1 Tau];
A_Theta(2*L+2,:)=[zeros(1,2*L) -(Theta(L+2)^(2)+Theta(L+3)^(2))*Tau  1+2*Tau*Theta(L+3)];
end

function del_A_Theta=Find_partialderivtv(X,Theta, Tau,L)
del_A_Theta=zeros(2*L+2,L+2);
del_A_Theta(1,1)=X(L+1)+0.5*X(2*L+1);
for  i=2:L
    tmp=X(i-1)+X(i+L);
    del_A_Theta(i,i)=tmp;
    del_A_Theta(i+L-1,i)=-tmp;
end
del_A_Theta(2*L,L+1)=-X(L);
del_A_Theta(2*L+2,L+2)=-2*Theta(L+2)*Tau*X(2*L+1);
del_A_Theta(2*L+2,L+3)=2*Tau*X(2*L+2)-2*Theta(L+3)*Tau*X(2*L+1);
end