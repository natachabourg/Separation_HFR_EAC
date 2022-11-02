function [ JJJ ] = julianday( AAAA,MM,DD )
% JM
%Donne le nombre de jour écoulé depuis le début de l'année


if AAAA==(1996||2000||2004||2008||2012||2016)
    days_in_prev_months = [0 31 60 91 121 152 182 213 244 274 305 335];
else
    days_in_prev_months = [0 31 59 90 120 151 181 212 243 273 304 334];
end

for t=1:length(DD)
   JJJ(t,1)= days_in_prev_months(MM(t)) ...             % days in prev. months      
      + DD(t) ;                                    % day in month
       %%% + ( second + 60*minute + 3600*hour )/86400;  % part of day
       
end

end

