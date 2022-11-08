function [DATE]=julday2date(DATEj,time_origin)
%%% MARMAIN
%%% 2012/06/14
%%% JM_TOOLS
%%% from the julian date DATEj = DATEjulian (JJJ) since time_origin, computes 
%%% DATE.julian the julian day since the time_origin, and DATE.calendar 
%%% with format YYYY-MM-DD hh:mm:ss and DATE.radar (YYYYJJJhhmm) the date
%%% at radar format

if length(time_origin) == 19
    
YYYYo=s2n(time_origin(1:4)); MMo=s2n(time_origin(6:7)); DDo=s2n(time_origin(9:10));
hho=s2n(time_origin(12:13)); mmo=s2n(time_origin(15:16)); sso=s2n(time_origin(18:19));

else
   YYYYo=s2n(time_origin(1:4)); MMo=s2n(time_origin(5:6)); DDo=s2n(time_origin(7:8));
    hho=s2n(time_origin(9:10)); mmo=s2n(time_origin(11:12)); sso=s2n(time_origin(13:14)); 
end

DATE.julian=DATEj;

DATE.calendar=datestr(DATE.julian + datenum(YYYYo,MMo,DDo,hho,mmo,sso),31);

DATE.time_origin=datestr(datenum(YYYYo,MMo,DDo,hho,mmo,sso),31);


for t=1:length(DATEj)
    
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
