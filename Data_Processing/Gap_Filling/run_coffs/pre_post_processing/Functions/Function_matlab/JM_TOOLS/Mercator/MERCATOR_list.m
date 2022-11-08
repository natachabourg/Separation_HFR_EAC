function [ GLname ] = MERCATOR_list( PATH_MER , CONF , PARAM  )
% MARMAIN 
% 2012/07/14
% To create a list of Mercator files
%
%   INPUT:  PATH_MER: where the files are stored
%           PARAM: the parameter to list
%           CONF: configuration name: PSY2V4R2...

%   OUTPUT: GLname: structure variable with
%               GLname.ANALYSE: Analysed states (7 first days)
%               GLname.FORECAST:Forecast states (7 last days)
%
%               GLname.ANALYSE.short: the list of short name (without path)
%               GLname.ANALYSE.long: the list of long name (with path)
%               GLname.FORECAST.short: the list of short name (without path)
%               GLname.FORECAST.long: the list of long name (with path)


%%% Creation de la liste
disp(['list ' PARAM ' files'])
flist=dir([PATH_MER '/ext-' CONF '_*_grid' PARAM '*.nc']);

PATH_MER
if isempty(flist)==1 %%% -> files are sorted in directories

    rlist=dir([PATH_MER '/2*']);%%% 2 because all file are measured in 201*

    k=0;
    f=0;
    g=0;
    
    for i=1:size(rlist,1);

        rname(i,:)=fullfile(PATH_MER,rlist(i,1).name);

        flist1=dir([rname(i,:) '/ext-' CONF '_*_grid' PARAM '*.nc*']);
        

        if isempty(flist1)==0 %%% il y a des fichiers qu'on recherche
            count = 0; %%% pour forecast; prend les 7 premiers
            
            for j=1:size(flist1,1);

                %%% List of Analysed states
                if str2double(flist1(j,1).name(1,19:26)) < str2double(flist1(j,1).name(1,44:51)) 
                    
                    k=k+1;
                    
                    GLname.ANALYSE(k,:).long=fullfile(rname(i,:),flist1(j,1).name);
                    
                    GLname.ANALYSE(k,:).short=flist1(j,1).name;
                end    
              
                %%% List of Forecast states if exist
                if str2double(flist1(j,1).name(1,19:26)) >= str2double(flist1(j,1).name(1,44:51))
                    
                    %%% cas non operationnel: cahrge les 7 premiers
                    %%% forecast
                    if count < 7
                        f=f+1;
                        count = count +1;
                        
                        GLname.FORECAST(f,:).long=fullfile(rname(i,:),flist1(j,1).name);
                        
                        GLname.FORECAST(f,:).short=flist1(j,1).name;
                    end
                    
                    %%% Cas operationnel: Charge les 8 forecasts
                    %%% disponibles
                    g=g+1;
                    GLname.FORECAST_OPS(g,:).long=fullfile(rname(i,:),flist1(j,1).name);
                        
                    GLname.FORECAST_OPS(g,:).short=flist1(j,1).name;
                    
                end
           
            end
           
        else
            error(['No file in format ext-' CONF '_*_grid' PARAM '*.nc*'])
        end
      
    end

end


end

