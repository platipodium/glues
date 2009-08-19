function p=plot_powerspectrum(t,v)

cl_register_function();

%Assume T is in kyr, convert to year
t=t*1000;
n=length(t);
tdiff=max(t)-min(t);
fs=n/tdiff;
               % Sampling frequency

NFFT = 2^nextpow2(n); % Next power of 2 from length of y
vfft = fft(v,NFFT)/n;
f = fs/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.
vpow=2*abs(vfft(1:NFFT/2+1));
p=plot(f,db(vpow));
title('Single-Sided Amplitude Spectrum');
ylabel('Spectral power (dB)');

set(gca,'XLim',[1/4000,min([max(f),1/190])]);
xt=round(1./get(gca,'XTick'));
xtl=num2str(xt');
set(gca,'XTickLabel',xtl);
xlabel('Cyclicity (a)');

return
end
