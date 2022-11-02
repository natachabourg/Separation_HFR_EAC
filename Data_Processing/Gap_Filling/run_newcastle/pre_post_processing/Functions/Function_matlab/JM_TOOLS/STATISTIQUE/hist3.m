function ret_val = hist3(X, bins)
%hist3(X, bins)
%Creates a 2-variable histogram of the data in the input matrix X, which 
%should be of the format [x,y] on each row. Returns matrix (as passed to 
%imagesc) in Y. If bins is a number argument, hist3 sets the number of
%bins per variable to be the integer stored in bins, and total number 
%will be bins^2. If bins is a two element array, where both elements 
%are numbers, these are the number of bins in each dimension. If bins  
%is a two element array, each element of which is a vectors, these give 
%the edges of the bins in each dimension.

if nargin ~= 2
  usage ("hist3 (matrix, number of bins)\nhist3 (matrix, {number of x bins, number of y bins})\nhist3 (matrix, {[edges of x bins], [edges of y bins]})");
endif

if (isscalar (bins))
  %Find max x,y values and then divide by number of bins to get bin width
  num_x_bins = num_y_bins = bins;
  x_max = max (X(:,1));
  x_min = min (X(:,1));
  y_max = max (X(:,2));
  y_min = min (X(:,2));
  x_bin_width = (x_max - x_min)/(num_x_bins-1);
  y_bin_width = (y_max - y_min)/(num_y_bins-1);
  %Correct max and min values, to avoid boundary cases
  x_min -= x_bin_width/2;
  y_min -= y_bin_width/2;
  x_max += x_bin_width/2;
  y_max += y_bin_width/2;
  %Build bin lists
  x_bins = [x_min:x_bin_width:x_max];
  y_bins = [y_min:y_bin_width:y_max];
elseif (isvector (bins))
  if (isscalar (bins{1}))
    num_x_bins = bins{1};
    num_y_bins = bins{2};
    x_max = max (X(:,1));
    x_min = min (X(:,1));
    y_max = max (X(:,2));
    y_min = min (X(:,2));
    x_bin_width = (x_max - x_min)/(num_x_bins-1);
    y_bin_width = (y_max - y_min)/(num_y_bins-1);
    %Correct max and min values, to avoid boundary cases
    x_min -= x_bin_width/2;
    y_min -= y_bin_width/2;
    x_max += x_bin_width/2;
    y_max += y_bin_width/2;
    %Build bin lists
    x_bins = [x_min:x_bin_width:x_max];
    y_bins = [y_min:y_bin_width:y_max];
  else
    num_x_bins = length (bins{1});
    num_y_bins = length (bins{2});
    x_bins = bins{1};
    y_bins = bins{2};
    x_min = x_bins(1);
    x_max = x_bins(length(x_bins));
    y_min = y_bins(1);
    y_max = y_bins(length(y_bins));
  endif
endif

%Set fltk as backend, because it can render square patches
backend("fltk");

%Create 2d array to hold counts
A = zeros (num_x_bins, num_y_bins);


for i = 1:length (X) %For each data point
  x_loc = find(x_bins > X(i,1))(1) - 1;
  y_loc = find(y_bins > X(i,2))(1) - 1;
  A(x_loc, y_loc) += 1;
endfor

freq_max = max ( max (A));

newplot ();
axis ([x_min, x_max, y_min, y_max, 0, freq_max]);
box ("off");
view(-45,45);
xlabel ("x-data");
ylabel ("y-data");
zlabel ("frequency");
%render boxes
for i = 1:(num_x_bins-1)
  for j = 1:(num_y_bins-1)
    freq = A(i,j);
    if (freq != 0)
      %Make box
      %Starting points:
      x0 = x_bins(i);
      x1 = x_bins(i+1);
      y0 = y_bins(j);
      y1 = y_bins(j+1);

      colour = [freq/freq_max, 0, (freq_max-freq)/freq_max];

      %Sides
      patch ([x0, x0, x0, x0], [y0, y0, y1, y1], [0, freq, freq, 0], "facecolor", colour); %x-
      patch ([x1, x1, x1, x1], [y0, y0, y1, y1], [0, freq, freq, 0], "facecolor", colour); %x+
      patch ([x0,x0,x1,x1], [y0, y0, y0, y0], [0, freq, freq, 0], "facecolor", colour); %y-
      patch ([x0,x0, x1, x1], [y1, y1, y1,y1], [0, freq, freq, 0], "facecolor", colour); %y+
      %Top
      patch([x0, x0, x1, x1],[y0, y1, y1, y0], [freq, freq, freq, freq], "facecolor", colour);
    endif
  endfor
endfor
drawnow ();

if (nargout > 0)
  ret_val = A;
endif

endfunction
