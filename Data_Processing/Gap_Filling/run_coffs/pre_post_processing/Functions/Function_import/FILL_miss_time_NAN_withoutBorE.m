function [ VAR_EXT, DATE_EXT , TIME_NONAN ] = ...
    FILL_miss_time_NAN_withoutBorE( VAR , datejulian, DATESjulian ,accur, time_origin )

% MARMAIN - 2012/06/14
% modif - 2012/11/15: cas 1D et 3D
%   Fill missing time in data by NaN in order to create a continuous
%   time vector.
%   It is able to fill (1D, 2D, 3D + time) VARiables
%
% MARMAIN - 2013/03/19 - Modif
% Tiens compte des temps absent au debut ou a la fin
% idee: on rempli du premier temps disponible jusqu'au dernier temps
% disponible, puis on complete pour parvenir a DATES(1,:) et DATES(2,:)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   INPUT:  - VAR(time,x[,y,z]): the VARiable to fill
%             !!!! time must be the first dimension
%           - datejulian(time): the original time vector in julian day (ascend order)
%           - DATES: first and last dates
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
disp('Fill time using "FILL_miss_time_NAN_withoutBorE.m"')

%%% define time origin
if nargin <= 3  %%% default case
    time_origin='20100101000000';  %%% YYYYMMDDhhmmss
    accur=55/60/24;     % precision entre les temps = 5 minutes
end

%%% Creation des temps non existants
dif=diff(datejulian);
dif_sorted=sort(dif,'ascend');
%time_step=dif_sorted(1)    %%% pas de temps entre les fichiers
time_step=1/24; % 1H AJM
% Nombre de temps dans la periode datejulian(1:end)
NB_TIME=round(abs(datejulian(end)-datejulian(1)) / time_step +1);
disp(['nombre de temps total: ' n2s(NB_TIME)]);
disp(['nombre de temps disponible: ' n2s(length(datejulian))]);
disp(['nombre de temps a combler: ' n2s(NB_TIME-length(datejulian))]);

% initialisation
k=2;
datejulian_EXT(1)=datejulian(1)%;AJM datejulian

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
            ano=i ;%debug AJM
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


if nargin >= 3
%%% Check if the filling is done from DATES(1,:)
if abs(datejulian_EXT(1)-DATESjulian(1))  < accur
    disp('OK >>> No need to fill the beginning')
else
    NB_TIME_begin=round(abs(datejulian_EXT(1)-DATESjulian(1)) / time_step );
    disp(['nombre de temps a combler au debut: ' n2s(NB_TIME_begin)]);
    
    %%% cree une matrice de dimension (NB_TIME_begin,:...) remplie de NaN
    if ndims(VAR) == 2
        VAR_EXT_begin=nan(NB_TIME_begin,size(VAR,2));
    elseif ndims(VAR) == 3
        VAR_EXT_begin=nan(NB_TIME_begin,size(VAR,2),size(VAR,3));
    elseif ndims(VAR) == 4
        VAR_EXT_begin=nan(NB_TIME_begin,size(VAR,2),size(VAR,3),size(VAR,4));
    end
    
    datejulian_EXT_begin(1)=datejulian_EXT(1)-time_step;
    TIME_NONAN_begin(1,1)=0;
    for i=2:NB_TIME_begin
        TIME_NONAN_begin(i,1)=0;
        datejulian_EXT_begin(i)=datejulian_EXT_begin(i-1)-time_step;
    end
    TIME_NONAN_begin=flipud(TIME_NONAN_begin);
    datejulian_EXT_begin=fliplr(datejulian_EXT_begin);
    
    %%% concatene les matrices
    VAR_EXT=cat(1,VAR_EXT_begin,VAR_EXT);
    TIME_NONAN=[TIME_NONAN_begin ; TIME_NONAN];
    datejulian_EXT=[datejulian_EXT_begin datejulian_EXT];
    
end

%%% Check if the filling is done to DATES(2,:)
%%% < time_step pour ne pas creer de temps supplementaire
if abs(datejulian_EXT(end)-DATESjulian(2))  < time_step %accur
    disp('OK >>> No need to fill the end')
else
    NB_TIME_end=round(abs(datejulian_EXT(end)-DATESjulian(2)) / time_step );
    disp(['nombre de temps a combler a la fin: ' n2s(NB_TIME_end)]);
    
    %%% cree une matrice de dimension (NB_TIME_end,:...) remplie de NaN
    if ndims(VAR) == 2
        VAR_EXT_end=nan(NB_TIME_end,size(VAR,2));
    elseif ndims(VAR) == 3
        VAR_EXT_end=nan(NB_TIME_end,size(VAR,2),size(VAR,3));
    elseif ndims(VAR) == 4
        VAR_EXT_end=nan(NB_TIME_end,size(VAR,2),size(VAR,3),size(VAR,4));
    end 
    
    datejulian_EXT_end(1)=datejulian_EXT(end)+time_step;
    TIME_NONAN_end(1,1)=0;
    for i=2:NB_TIME_end
        TIME_NONAN_end(i,1)=0;
        datejulian_EXT_end(i)=datejulian_EXT_end(i-1)+time_step;  
    end
    
    %%% concatene les matrices
    VAR_EXT=cat(1,VAR_EXT,VAR_EXT_end);
    TIME_NONAN=[TIME_NONAN ; TIME_NONAN_end];
    datejulian_EXT=[datejulian_EXT datejulian_EXT_end];
    
end

end

DATE_EXT=julday2date(datejulian_EXT,time_origin) ;
DATE_EXT.time_step=time_step;
end
