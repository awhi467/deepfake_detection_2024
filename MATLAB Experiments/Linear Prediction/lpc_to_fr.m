function vt = lpc_to_fr(a,fs)
    den = 0;
    f = 0:fs/2-1;
    for i=1:size(a,2)
        den = den + a(i)*exp(1i*2*pi*f*(i-1)/fs);
    end
    vt = 10*log10(abs(1./den));
end