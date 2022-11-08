function [ VAR_EXT, DATE_EXT , TIME_NONAN ] = ...
    FILL_miss_time_NAN( VAR , datejulian ,accur, time_origin )

% MARMAIN - 2012/06/14
% modif - 2012/11/15: cas 1D et 3D
%   Fill missing time in data by NaN in order to create a continuous
%   time vector.
%   It is able to fill (1D, 2D, 3D + time) VARiables
%
%   INPUT:  - VAR(time,x[,y,z]): the VARiable to fill
%             !!!! time must be the first dimension
%           - datejulian(time): the original time vector in julian day (ascend order)
%           - accur: time step accuracy to compute the final time vector.
%           If difference between two consecutives times is smaller than
%           accur, then the time is not missing
%           - time_origin: used to compute the final DATE vector.
%          
%   OUPUT:  - VAR_EXT(time_ext,x,y): The filled radial velocity
%           - DATE_EXT(time_ext): The filled time vector. Structure with 
%           radar time (DATE.radar), julian day since time_origin (DATE.julian) 
%           and DATE.calendar with a more classical format YYYY-MM-DD hh:mm:ss
%           and DATE_EXT.time_step give the time step
%           - TIME_NONAN(time_ext) : vector where 1 represent original
%           time and 0 represent filled times with NaN;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Fill time using "DINEOF_fill_miss_time.m"')

%%% define time origin
if nargin==2  %%% default case
    time_origin='20100101000000';  %%% YYYYMMDDhhmmss
    accur=5/60/24;     % precision entre les temps = 5 minutes
end

%%% Creation des temps non existants
dif=diff(datejulian);
dif_sorted=sort(dif,'ascend');
time_step=dif_sorted(1);    %%% pas de temps entre les fichiers
% Nombre de temps dans la periode datejulian(1:end)
NB_TIME=round(abs(datejulian(end,1)-datejulian(1)) / time_step +1);
disp(['nombre de temps a combler: ' n2s(NB_TIME)]);

% initialisation
k=2;
datejulian_EXT(1)=datejulian(1);

%%% Cas 1D + t
if ndims(VAR) == 2
    VAR_EXT=nan(NB_TIME,size(VAR,2));
    VAR_EXT(1,:)=squeeze(VAR(1,:));
    TIME_NONAN=zeros(NB_TIME,1);
    TIME_NONAN(1)=1;
    for i=2:NB_TIME
        datejulian_EXT(i)=datejulian_EXT(i-1) + time_step;
        if abs(datejulian_EXT(i)-datejulian(k))  < accur
            datejulian_EXT(i)=datejulian(k);
            VAR_EXT(i,:)=squeeze(VAR(k,:));
            TIME_NONAN(i)=1;
            k=k+1;
        end
    end
end

%%% Cas 2D + t
if ndims(VAR) == 3
    VAR_EXT=nan(NB_TIME,size(VAR,2),size(VAR,3));
    VAR_EXT(1,:,:)=squeeze(VAR(1,:,:));
    TIME_NONAN=zeros(NB_TIME,1);
    TIME_NONAN(1)=1;
    for i=2:NB_TIME
        datejulian_EXT(i)=datejulian_EXT(i-1) + time_step;
        if abs(datejulian_EXT(i)-datejulian(k))  < accur
            datejulian_EXT(i)=datejulian(k);
            VAR_EXT(i,:,:)=squeeze(VAR(k,:,:));
            TIME_NONAN(i)=1;
            k=k+1;
        end
    end
end

%%% Cas 3D + t
if ndims(VAR) == 4
    VAR_EXT=nan(NB_TIME,size(VAR,2),size(VAR,3),size(VAR,4));
    VAR_EXT(1,:,:,:)=squeeze(VAR(1,:,:,:));
    TIME_NONAN=zeros(NB_TIME,1);
    TIME_NONAN(1)=1;
    for i=2:NB_TIME
        datejulian_EXT(i)=datejulian_EXT(i-1) + time_step;
        if abs(datejulian_EXT(i)-datejulian(k))  < accur
            datejulian_EXT(i)=datejulian(k);
            VAR_EXT(i,:,:,:)=squeeze(VAR(k,:,:,:));
            TIME_NONAN(i)=1;
            k=k+1;
        end
    end
end


DATE_EXT=julday2date(datejulian_EXT,time_origin) ;
DATE_EXT.time_step=time_step;
end
