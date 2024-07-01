function LP_coeff=covar_LPC(y,p)


for j=0:p
    for k=1:p
        sum=0;
        for n=1:length(y)-p
            sum=sum+y(n-j+p)*y(n-k+p);
        end
        if j==0
            psi(k)=sum;
        else
            phi(j,k)=sum;
        end
    end
end

LP_coeff=psi/phi;