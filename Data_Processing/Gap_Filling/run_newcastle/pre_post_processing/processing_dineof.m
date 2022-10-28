%
% Performs the pre/post-processing and data interpolation using dineof3.0 algorithm
% Based on cartography.m
%
% ****** RADIAL and VECTOR VELOCITIES CASE ***************
%
%   Marmain - 2014/04/03
%
% On utilise soit des fichiers correspondant a une periode donnees soit des
% fichiers mensuels crees prealablement avec cartography.m
% Les dates sont celles indiquees dans CONFIGURATION.m
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% N.B.: You must be in the main directory of the %
%       package to be able to run it             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
set(0,'DefaultTextFontName','Arial')
set(0,'DefaultAxesFontName','Arial')

clear all;
clc;
% close all;
addpath('/home/natachab/RADAR_NATACHA/Function_matlab/');

%% Check that we are in the right directory
tmp = dir(pwd);
ok = 0;
for i_file = 1 : length(tmp)
    if strcmp(tmp(i_file).name,'processing_dineof.m')
        ok = 1;
        break;
    end
end
if ok == 0
    error('You are not in the right directory!');
end
clear ok i_file


%% Temporarily add the package paths to Matlab's pathlist
addpath([path filesep 'Function_carto'],[path filesep 'Function_import'], [path filesep 'Function_installation'],[pwd filesep 'Function_dineof'], [path filesep 'Function_matlab/JM_TOOLS'], [path filesep 'utilitaire_MARMAIN']);


%% Load all the configuration parameters
CONFIGURATION;
CONFIGURATION_dineof;


%% Choose the operation to be performed

t1 = ['1. Créer un masque d''interpolation pour >>> ' dineof_params.case  ' <<<'];

t2 = '2. Classique vers dineof >> Pre-processing des donnees "CARTO" pour utilisation dans dineof';

t3 = '3. IDEM 2 +  Make files for validation studies';

t4 = '4. Interpolation DINEOF';

t5 = '5. dineof vers classique >> Post-processing du resultat dineof vers format "CARTO" ';

t6 = '6. DINEOF in one step: *2* >> 4 >> 5';

t7 = '7. DINEOF in one step: *3* >> 4 >> 5';


action = menu(['>>> ' dineof_params.case  ' case <<< Que voulez-vous faire?'],...
    t1,t2,t3,t4,t5,t6,t7);
clear t1 t2 t3 t4 t5 t6 t7
pause(0.1);

switch action
    
    case 1
         %% make dineof mask
         eval(['script_edit_' dineof_params.case '_mask_dineof']) 
         
    case 2
        %% Import classic data and convert in dineof format
        eval(['script_conversion_' dineof_params.case '_classic2dineof'])
    
    case 3
        %% Import classic data and convert in dineof format + Extract validation point 
        eval(['script_extraction_PointValidation_' dineof_params.case])  
        
    case 4
       %% interpolation with fortran DINEOF 3.0
         script_interpolation_dineof
        
    case 5
        %% convert dineof result to classic format
        eval(['script_conversion_' dineof_params.case '_dineof2classic'])
   
    case 6
        %% Import classic data and convert in dineof format
        eval(['script_conversion_' dineof_params.case '_classic2dineof'])
        
        %% interpolation with fortran DINEOF 3.0
        script_interpolation_dineof     
        
        %% convert dineof result to classic format
        eval(['script_conversion_' dineof_params.case '_dineof2classic'])
        
     case 7
        %% Import classic data and convert in dineof format + Extract validation point 
        eval(['script_extraction_PointValidation_' dineof_params.case])  
        
        %% interpolation with fortran DINEOF 3.0
        script_interpolation_dineof     
        
        %% convert dineof result to classic format
        eval(['script_conversion_' dineof_params.case '_dineof2classic'])   
        
    
end
 

%% Remove the package paths from Matlab's pathlist
% rmpath([pwd filesep 'Function_carto'],[pwd filesep 'Function_import'],...
%     [pwd filesep 'Function_installation']);%,[pwd filesep 'm_map']);

