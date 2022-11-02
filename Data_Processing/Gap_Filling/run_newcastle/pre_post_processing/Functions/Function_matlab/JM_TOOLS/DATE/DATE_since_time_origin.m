function [ DATE2 ] = DATE_since_time_origin(DATE1,time_origin1,time_origin2);
% MARMAIN 
% 2012/07/31
%
% To change the time origin of the DATE vector and the DATE vector accordingly
%
%   INPUT:  DATE1: julian day since time_origin1
%           time_origin1: old
%           time_origin2: new 
%
%   OUTPUT: DATE2: julian day since time_origin2
%
%%%########################################################################

DATE2.julian=DATE1  + datenum(time_origin1,'yyyy-mm-dd HH:MM:SS')...
    - datenum(time_origin2,'yyyy-mm-dd HH:MM:SS') ;%-1;

DATE2.calendar=...
    datestr(DATE2.julian  + datenum(time_origin2,'yyyy-mm-dd HH:MM:SS') ,31);

DATE2.time_origin=time_origin2;


for t=1:length(DATE2.julian)
    
    YYYY=s2n(DATE2.calendar(t,1:4)); MM=s2n(DATE2.calendar(t,6:7));
    JJ=s2n(DATE2.calendar(t,9:10));
    hh=s2n(DATE2.calendar(t,12:13)); mm=s2n(DATE2.calendar(t,15:16));
    ss=s2n(DATE2.calendar(t,18:19));
    
%     JJJ=n2s(floor(DATE2.julian(t) + 1 - (datenum(YYYY,01,01,0,0,0) - ...
%         datenum(time_origin2,'yyyy-mm-dd HH:MM:SS')) ));
    JJJ=n2s(floor(DATE2.julian(t)  - (datenum(YYYY,01,01,0,0,0) - ...
        datenum(time_origin2,'yyyy-mm-dd HH:MM:SS')) ));
    
    if length(JJJ)==1; JJJ=['00' JJJ]; end
    if length(JJJ)==2; JJJ=['0' JJJ]; end
    
    DATE2.radar(t,:)=...
        [DATE2.calendar(t,1:4) n2s(JJJ) DATE2.calendar(t,12:13) DATE2.calendar(t,15:16)];
    
end

end

