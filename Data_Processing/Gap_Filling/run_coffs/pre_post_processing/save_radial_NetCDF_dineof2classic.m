%@ Julien Marmain
% 
% Script to post process the .nc file output from dineof
% % Variables to change :
% %
% - PATH_NC_ini : path where the output file of dineof is located
% - PATH_NC_out : path where the postprocessed file will be 
% - ncname_ini : name of the output file of dineof
% - ncname_out : name of the postprocessed file
% %
% % NB : ici pour le dineof horaire sur les données 2020 y'a jamais de
% steps créés alors on fait pas le post processing oka 

function save_radial_NetCDF_dineof2classic()

%%% NetCDF path
PATH_NC_ini = '/data/MIO/natachab/dineof_hourly_2020_2021/my_result_folder/';      %% chemin fichier original
PATH_NC_out = '/data/MIO/natachab/dineof_hourly_2020_2021/my_result_folder/post/'; %% chemin fichier final

ncname_ini = 'POB_din_Y2020M11_11.nc';
ncname_out = 'POB_din_post_Y2020M11_11.nc';

ncfile_ini = fullfile(PATH_NC_ini,ncname_ini);
ncfile_out = fullfile(PATH_NC_out,ncname_out);

if ~exist(PATH_NC_out,'dir')
    mkdir(PATH_NC_out);
end
if exist(ncfile_out,'file')
    delete(ncfile_out);
end

eval(['!cp ' ncfile_ini ' ' ncfile_out]) 


disp('Writing NetCDF file ...');

if exist(ncfile_ini,'file')
    
    %% NetCDF file
    % Read from NetCDF
    % - Data
    
    vr      = double(ncread(ncfile_ini,'v'));
   
    missval = double(ncreadatt(ncfile_ini,'v','missing_value')); % READ dineof file to get vr and missing_value

    %% get other information on the rebuild field
    valc        =gread([PATH_NC_ini 'valc.dat']);
    valosclast  =gread([PATH_NC_ini 'valosclast.dat']);

    neofretained=load([PATH_NC_ini 'neofretained.val']);

      
else
    error(['The NetCDF file to be read does not exist!  ' ncfile]);
end

%% data

%%% Fill value for NetCDF file
fillval = NaN;

% replace missing_value by NaN in vr
vr(vr==missval)=fillval;
    
%% write in new nc file
ncwriteatt(ncfile_out,'/','title',char('Analyse Dineof'));
ncwriteatt(ncfile_out,'/','creation date',char(datestr(now)));
ncwriteatt(ncfile_out,'/','neofretained',neofretained);

ncwrite(ncfile_out,'v',vr);


%%% Creation
nccreate(ncfile_out,'valc',...
    'Dimensions',{'nev',size(valc,1)},'Format','classic');

%%% Attributs
ncwriteatt(ncfile_out,'valc','long_name',char('CrossValidation Error'));
ncwriteatt(ncfile_out,'valc','units',char('normalized'));

ncwrite(ncfile_out,'valc',valc); 

disp('Done');
disp(blanks(1)');



end