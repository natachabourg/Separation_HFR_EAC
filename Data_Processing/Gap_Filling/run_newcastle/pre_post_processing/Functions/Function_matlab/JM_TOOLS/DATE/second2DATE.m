function DATE=second2DATE(time_counter,time_origin)
% MARMAIN 
% 2012/07/12
% JM_TOOLS
% conversion of Glazur64 time_counter in classical date: 
% DATE.radar (YYYYJJJhhmm), DATE.julian the julian day since the time_origin, 
% and DATE.calendar with format YYYY-MM-DD hh:mm:ss

%%%########################################################################

DATE.julian=time_counter/(24*3600); %%% conversion second to day since time_origin

DATE.calendar=datestr(DATE.julian + datenum(time_origin, 'yyyy-mmm-dd HH:MM:SS'),31);
%%DATE.calendar=datestr(DATE.julian);

DATE.time_origin=datestr(datenum(time_origin, 'yyyy-mmm-dd HH:MM:SS'),31);%time_origin;


YYYYo=s2n(DATE.time_origin(1:4)); MMo=s2n(DATE.time_origin(6:7)); 
DDo=s2n(DATE.time_origin(9:10)); hho=s2n(DATE.time_origin(12:13)); 
mmo=s2n(DATE.time_origin(15:16)); sso=s2n(DATE.time_origin(18:19));


for t=1:length(DATE.julian)
    
    YYYY=s2n(DATE.calendar(t,1:4)); MM=s2n(DATE.calendar(t,6:7));
    JJ=s2n(DATE.calendar(t,9:10));
    hh=s2n(DATE.calendar(t,12:13)); mm=s2n(DATE.calendar(t,15:16));
    ss=s2n(DATE.calendar(t,18:19));
    
    JJJ=n2s(floor(DATE.julian(t) + 1 - (datenum(YYYY,01,01,0,0,0) - ...
        datenum(YYYYo,MMo,DDo,hho,mmo,sso)) ));
    
    if length(JJJ)==1; JJJ=['00' JJJ]; end
    if length(JJJ)==2; JJJ=['0' JJJ]; end
    
    DATE.radar(t,:)=...
        [DATE.calendar(t,1:4) n2s(JJJ) DATE.calendar(t,12:13) DATE.calendar(t,15:16)];
    
end


end

