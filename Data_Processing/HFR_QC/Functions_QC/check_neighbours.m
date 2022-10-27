function [neigh_diff] = check_neighbours(vr, i, j, t, min_i, min_j, max_i, max_j)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


    if i == max_i
        if j == max_j

            
            neigh_diff = [get_diff(vr,i, j-1, t, min_i, min_j, max_i, max_j),...
            
                get_diff(vr,i-1, j-1, t, min_i, min_j, max_i, max_j),...
            
                get_diff(vr,i-1, j, t, min_i, min_j, max_i, max_j)];


        elseif j == min_j
                            
            
            neigh_diff = [get_diff(vr, i, j+1, t, min_i, min_j, max_i, max_j),...
            
                get_diff(vr,i-1, j, t, min_i, min_j, max_i, max_j),...
            
                get_diff(vr,i-1, j+1, t, min_i, min_j, max_i, max_j)];

        else
            
            neigh_diff = [get_diff(vr, i, j+1, t, min_i, min_j, max_i, max_j),...
            
                get_diff(vr,i, j-1, t, min_i, min_j, max_i, max_j),...
            
                get_diff(vr,i-1, j-1, t, min_i, min_j, max_i, max_j),...
            
                get_diff(vr,i-1, j, t, min_i, min_j, max_i, max_j),...
            
                get_diff(vr,i-1, j+1, t, min_i, min_j, max_i, max_j)];

        end

    elseif i == min_i
        if j == min_j

            
            neigh_diff = [get_diff(vr, i, j+1, t, min_i, min_j, max_i, max_j),...
           
                get_diff(vr,i+1, j, t, min_i, min_j, max_i, max_j),...
            
                get_diff(vr,i+1, j+1, t, min_i, min_j, max_i, max_j)];

        elseif j==max_j
    
            neigh_diff = [get_diff(vr,i, j-1, t, min_i, min_j, max_i, max_j),...
            
                get_diff(vr,i+1, j-1, t, min_i, min_j, max_i, max_j),...
            
                get_diff(vr,i+1, j, t, min_i, min_j, max_i, max_j)];

        else
            neigh_diff = [get_diff(vr, i, j+1, t, min_i, min_j, max_i, max_j),...
            
                get_diff(vr,i, j-1, t, min_i, min_j, max_i, max_j),...
            
                get_diff(vr,i+1, j-1, t, min_i, min_j, max_i-1, max_j),...
            
                get_diff(vr,i+1, j, t, min_i, min_j, max_i, max_j),...
            
                get_diff(vr,i+1, j+1, t, min_i, min_j, max_i, max_j)];

        end
    
    elseif j== max_j

        neigh_diff = [get_diff(vr,i, j-1, t, min_i, min_j, max_i, max_j),...
        
            get_diff(vr,i-1, j-1, t, min_i, min_j, max_i, max_j),...
        
            get_diff(vr,i-1, j, t, min_i, min_j, max_i, max_j),...
        
            get_diff(vr,i+1, j-1, t, min_i, min_j, max_i, max_j),...
        
            get_diff(vr,i+1, j, t, min_i, min_j, max_i, max_j)];

    elseif j == min_j
        
        neigh_diff = [get_diff(vr, i, j, t, min_i, min_j, max_i, max_j),...
        
            get_diff(vr,i-1, j, t, min_i, min_j, max_i, max_j),...
        
            get_diff(vr,i-1, j+1, t, min_i, min_j, max_i, max_j),...
        
            get_diff(vr,i+1, j, t, min_i, min_j, max_i, max_j),...
        
            get_diff(vr,i+1, j+1, t, min_i, min_j, max_i, max_j)];
        
            
    else

        neigh_diff = [get_diff(vr, i, j+1, t, min_i, min_j, max_i, max_j),...
        
            get_diff(vr,i, j-1, t, min_i, min_j, max_i, max_j),...
        
            get_diff(vr,i-1, j-1, t, min_i, min_j, max_i, max_j),...
        
            get_diff(vr,i-1, j, t, min_i, min_j, max_i, max_j),...
        
            get_diff(vr,i-1, j+1, t, min_i, min_j, max_i, max_j),...
        
            get_diff(vr,i+1, j-1, t, min_i, min_j, max_i, max_j),...
        
            get_diff(vr,i+1, j, t, min_i, min_j, max_i, max_j),...
        
            get_diff(vr,i+1, j+1, t, min_i, min_j, max_i, max_j)];

    end




end