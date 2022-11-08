%% MRN - 2014/12/17 - PATCH
 % - Patch to remove unused range existing in xyv/cll file but not in the
 % whole period
 % - Comparison with radial mask grid_*.mat in CARTO_RADAR directory
 % - if the spatial size of Vr, Xr and Yr is different of rad_grid.xr,
 % defined by hand the limit of the use part of Vr, Xr and Yr
 % - if the mask does not exist >> ignore this step >> be careful
 STA = cxname(1,end-6:end-4); % station name
 
 %%% Load the generic mask (built for a given grid size)
 if exist(['grid_' STA '.mat'],'file')~=0
     pwd 
     load(['grid_' STA '.mat'],'rad_grid');
     size(rad_grid.xr)
     size(Xr)
    
     if size(rad_grid.xr,1) ~= size(Xr,1)
         warning(['For **' STA '**, the spatial grid of radial velocity (' ...
             num2str(size(Xr)) ') is different of the '...
             'mask' ' grid_' STA '.mat (' num2str(size(rad_grid.xr)) ')']);
         warning(['In cll_xyv_reader.m, I choose to remove manually the range 1 and 32:38 because' ...
             ' they do not contain useful information']);
         
         vr_tmp=Vr(:,2:31,:);  %%% limit are defined by hand 
         xr_tmp=Xr(2:31,:);
         yr_tmp=Yr(2:31,:);
         
         Vr=vr_tmp;
         Xr=xr_tmp;
         Yr=yr_tmp;
  
     elseif size(rad_grid.xr,2) ~= size(Xr,2)
         a=1%anne
         size(rad_grid.xr,2)
         size(Xr,2)
         error(['size(rad_grid.xr,2) ~= size(Xr,2)' ...
             '>>>> I dont know what to do!!!'])
         
     else
          disp(['>>> The grid seems OK compared to the mask grid_' STA '.mat'])
     end  
      
 else
     warning(['Are you sure that the spatial grid have the same size '...
         'as the mask grid_' STA '.mat ????'])   
 end
 %%% END MRN