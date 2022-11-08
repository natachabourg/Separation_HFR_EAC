
%
%
%

function [currents, grid] = read_current_ASCII(path)


tmp = dir([path filesep 'Philippe' filesep 'xyuv*']);

for i_file = 1 : length(tmp)
    % Read the binary data
    fid = fopen([path filesep 'Philippe' filesep tmp(i_file).name],'r');
    data = fread(fid,'real*4');
    fclose(fid);
    
    % Build the data
    currents(i_file).time  = datenum(tmp(i_file).name(5:end),'yyyymmddHHMM');
    currents(i_file).time0 = '00000101000000';
    
    % Read the grid size and step
    N_y = data(1);
    N_x = data(2);
    grid.step = data(3);
    data(1:3) = [];
    
    % Read the grid coordinates (x/y, lon/lat)
    if i_file == 1
        grid.x = data(1:N_x*N_y);
        grid.y = data(N_x*N_y+1:2*N_x*N_y);
    end
    data(1:2*N_y*N_x) = [];
    if i_file == 1
        grid.lon = data(1:N_x*N_y);
        grid.lat = data(N_x*N_y+1:2*N_x*N_y);
    end
    data(1:2*N_y*N_x) = [];
    
    % Read the current velocities
    currents(i_file).u = data(1:N_x*N_y);
    currents(i_file).v = data(N_x*N_y+1:2*N_x*N_y);    
end
