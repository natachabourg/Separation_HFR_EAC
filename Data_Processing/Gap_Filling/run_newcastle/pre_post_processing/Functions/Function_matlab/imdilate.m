%Copyright (C) 2005  Grucker-Hardy

%This program is free software; you can redistribute it and/or
%modify it under the terms of the GNU General Public License
%as published by the Free Software Foundation; either version 2
%of the License, or (at your option) any later version.

%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.

%#    IMDILATE Dilates image.
%#    IM2 = #IMDILATE(IM,SE) dilates the grayscale, binary, or packed binary 
%#    image IM, returning the dilated image, IM2.  SE is an array of 0s
%#    and 1s that specifies the structuring element.
 
%#    If IM is logical and the structuring element is flat, IMDILATE
%#    performs binary dilation; otherwise it performs grayscale dilation.

function [IMG_R,IMG_G,IMG_B] = imdilate(varargin)

if(nargin ~= 2 && nargin ~= 4)
	usage("IMG = imdilate(im, mask) OU [R,G,B] = imdilate(r,g,b, mask)");
	
elseif(nargin == 2)
    	im = varargin{1};
    	if ~isnumeric(im) | ~isreal(im)
        	error('im doit etre une matrice de reels.');
    	end
    	mask = varargin{2};
    	if ~isnumeric(mask) | ~isreal(mask)
        	error('mask doit etre une matrice de reels.');
    	end
	
	[h,l]= size(mask);
	[n,m]= size(im);

	IMG = [];

	for i=1:n	
    		for j=1:m
			if (((i-floor(h/2))>0) && ((i+floor(h/2))<(n+1)) && ((j-floor(l/2))>0) && ((j+floor(l/2))<(m+1)))
				IMG(i,j) = max(max( ( mask .* im( (max((i-floor(h/2)),1)):(min((i+floor(h/2)),n)), (max((j-floor(l/2)),1)):(min((j+floor(l/2)),m)) ))));
			else 
				IMG(i,j) = im(i,j);
			end
    		end
	end

	IMG_R = IMG;
	IMG_G = IMG;
	IMG_B = IMG;
	
else
    	imr = varargin{1};
    	if ~isnumeric(imr) | ~isreal(imr)
        	error('imr doit etre une matrice de reels.');
    	end
    	img = varargin{2};
    	if ~isnumeric(img) | ~isreal(img)
        	error('img doit etre une matrice de reels.');
    	end
    	imb = varargin{3};
    	if ~isnumeric(imb) | ~isreal(imb)
        	error('imb doit etre une matrice de reels.');
    	end
    	mask = varargin{4};
    	if ~isnumeric(mask) | ~isreal(mask)
        	error('mask doit etre une matrice de reels.');
    	end
	
	IMG_R = [];
	IMG_G = [];
	IMG_B = [];
	
	[h,l]= size(mask);

	[n,m]= size(imr);

	for i=1:n	
    	for j=1:m
		if (((i-floor(h/2))>0) && ((i+floor(h/2))<(n+1)) && ((j-floor(l/2))>0) && ((j+floor(l/2))<(m+1)))
			IMG_R(i,j) = max(max( ( mask .* imr( (max((i-floor(h/2)),1)):(min((i+floor(h/2)),n)), (max((j-floor(l/2)),1)):(min((j+floor(l/2)),m)) ))));
			IMG_G(i,j) = max(max( ( mask .* img( (max((i-floor(h/2)),1)):(min((i+floor(h/2)),n)), (max((j-floor(l/2)),1)):(min((j+floor(l/2)),m)) ))));
			IMG_B(i,j) = max(max( ( mask .* imb( (max((i-floor(h/2)),1)):(min((i+floor(h/2)),n)), (max((j-floor(l/2)),1)):(min((j+floor(l/2)),m)) ))));
		else 
			IMG_R(i,j) = imr(i,j);
			IMG_G(i,j) = img(i,j);
			IMG_B(i,j) = imb(i,j);
		end
    	end
	end

end

 

endfunction