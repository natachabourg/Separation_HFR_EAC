function [DATE]=radar2date(DATEr,time_origin)
%%% MARMAIN
%%% 2012/05/25
%%% JM_TOOLS
%%% from the radar date DATEr = DATE.radar (YYYYJJJhhmm), computes 
%%% DATE.julian the julian day since the time_origin, and DATE.calendar 
%%% with format YYYY-MM-DD hh:mm:ss


YYYYo=s2n(time_origin(1:4)); MMo=s2n(time_origin(5:6)); DDo=s2n(time_origin(7:8));
hho=s2n(time_origin(9:10)); mmo=s2n(time_origin(11:12)); sso=s2n(time_origin(13:14));

DATE.time_origin=datestr(datenum(YYYYo,MMo,DDo,hho,mmo,sso),31);
DATE.radar=DATEr;

for t=1:length(DATE.radar)
    
    YYYY=s2n(DATE.radar(t,1:4)); JJJ=s2n(DATE.radar(t,5:7));
    hh=s2n(DATE.radar(t,8:9)); mm=s2n(DATE.radar(t,10:11));

    DATE.julian(t,:)=JJJ + hh/24 + mm/1440 +  datenum(YYYY,01,01,0,0,0) - ...
        datenum(YYYYo,MMo,DDo,hho,mmo,sso) -1;
    
    %%% ATTENTION !!! -1 pour obtenir la bonne date calendaire!!!
    DATE.calendar(t,:)=datestr(DATE.julian(t,:) + datenum(YYYYo,MMo,DDo,hho,mmo,sso),31);
       
end

end


