% Conversion en dB (0 ou en 10**(y/10) (1)
function [y]=db(y,iopt)
if iopt==0 y=10*log10(y);
else y=10.^(0.1*y); end