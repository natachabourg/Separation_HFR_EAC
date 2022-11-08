
%
%
%

function save_current_ASCII(currents,grid,path)

N_times = length(currents);

%% First of all, save the currents in Philippe's format
% Check that the folder exists
dir_save = [path filesep 'Philippe'];
if ~exist(dir_save,'dir')
    mkdir(dir_save);
end

% Write one file per time
disp('Writing ASCII files - Philippe ...');
% h = waitbar(0,'Writing ASCII files - Philippe...');
for i_time = 1 : N_times
    % Generate the date in format yyyymmddHHMM
    date =  julday2date(currents(i_time).time,currents(i_time).time0);
    date = date.calendar;
    date = [date(1:4) date(6:7) date(9:10) date(12:13) date(15:16)];
    
    % Open the file to be written
    file_name = [dir_save filesep 'xyuv' date];
    fid = fopen(file_name,'w');
    
    % Write the data
    % - size of the grid
    fwrite(fid,size(grid.x),'real*4');
    % - step of the grid
    fwrite(fid,grid.step,'real*4');
    % - x cooridnate
    fwrite(fid,grid.x,'real*4');
    % - y coordinate
    fwrite(fid,grid.y,'real*4');
    % - longitude
    fwrite(fid,grid.lon,'real*4');
    % - latitude
    fwrite(fid,grid.lat,'real*4');
    % - u
    fwrite(fid,currents(i_time).u,'real*4');
    % - v
    fwrite(fid,currents(i_time).v,'real*4');
    
    % Close the file
    fclose(fid);
    
%     waitbar(i_time/N_times);
end
% close(h);


%% Then save the currents in Anne's format (Fortran readable)
% Check that the folder exists
dir_save = [path filesep 'Anne'];
if ~exist(dir_save,'dir')
    mkdir(dir_save);
end

% Fill the NaN values of the grid points with -999
grid.x(isnan(grid.x)) = -999;
grid.y(isnan(grid.y)) = -999;

% Write one file per time
disp('Writing ASCII files - Anne ...');
% h = waitbar(0,'Writing ASCII files - Anne...');
for i_time = 1 : N_times
    % Fill the NaN values of the current with -999
    currents(i_time).u(isnan(currents(i_time).u)) = -999;
    currents(i_time).v(isnan(currents(i_time).v)) = -999;
    
    % Generate the date in format yyyymmddHHMM
    date =  julday2date(currents(i_time).time,currents(i_time).time0);
    date = date.calendar;
    date = [date(1:4) date(6:7) date(9:10) date(12:13) date(15:16)];
    
    % Open the file to be written
    file_name = [dir_save filesep 'xyuv' date];
    fid = fopen(file_name,'w');
    
    % Write the data
    % - Size of the grid
    grid_size = size(grid.x);
    fprintf(fid,'%i \n',grid_size); fprintf(fid,'\n');
    % - x cooridnate
    for ind = grid_size(1) : -1 : 1
        fprintf(fid,'%8.2f',grid.x(ind,:)); fprintf(fid,'\n');
    end
    fprintf(fid,'\n');
    % - y coordinate
    for ind = grid_size(1) : -1 : 1
        fprintf(fid,'%8.2f',grid.y(ind,:)); fprintf(fid,'\n');
    end
    fprintf(fid,'\n');
    % - u
    for ind = grid_size(1) : -1 : 1
        fprintf(fid,'%8.2f',currents(i_time).u(ind,:)); fprintf(fid,'\n');
    end
    fprintf(fid,'\n');
    % - v
    for ind = grid_size(1) : -1 : 1
        fprintf(fid,'%8.2f',currents(i_time).v(ind,:)); fprintf(fid,'\n');
    end
    fprintf(fid,'\n');
    % - current speed
    speed = sqrt(currents(i_time).u.^2 + currents(i_time).v.^2);
    speed( (currents(i_time).u == -999) | (currents(i_time).v == -999)) = -999;
    for ind = grid_size(1) : -1 : 1
        fprintf(fid,'%8.2f',speed(ind,:)); fprintf(fid,'\n');
    end
    fprintf(fid,'\n');
    % - current direction
    direction = atan2(currents(i_time).v,currents(i_time).u)*180/pi;
    direction( (currents(i_time).u == -999) | (currents(i_time).v == -999)) = -999;
    for ind = grid_size(1) : -1 : 1
        fprintf(fid,'%8.2f',direction(ind,:)); fprintf(fid,'\n');
    end
    
    % Close the file
    fclose(fid);
    
%     waitbar(i_time/N_times);
end
% close(h);
