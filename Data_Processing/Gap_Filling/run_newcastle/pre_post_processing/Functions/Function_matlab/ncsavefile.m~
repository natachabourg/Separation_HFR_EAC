function ncsavefile(file, varargin)

% ncsavefile -- save variables in a netCDF file.
%
%   ncsavefile('filename', 'var1', 'var2', ... {'dim1', 'dim2'...})
%
%   Les dimensions a utiliser peuvent etre precisees
%   comme une liste de cells, mais ce n'est pas obligatoire.
%   Si les variables suivantes font partie des parametres, 
%   elles sont automatiquement choisies comme dimensions :
%       time, level, altitude, alt, lat, latitude, lon, longitude
%   Des dimensions supplementaires seront creees au besoin.
%
%   Si des variables sont des structures, l'element "var" de la structure
%   doit contenir les donnees, et les autres elements de la structure sont
%   sauvegardes comme attributs de la variable.
%
%   Si une variable est une structure nommee "glob",
%   ses elements seront sauvegardes comme attributs globaux du fichier.
%
%   voir http://www.lmd.polytechnique.fr/~intro/wiki/doku.php?id=matlab:sauvegarde_netcdf
%   pour des exemples d'utilisation
%
% Vincent Noel, Yohann Morille 2008 

if nargin < 1, help(mfilename), return, end

nc = netcdf(file, 'clobber');
[s,r] = system('whoami'); % might not work on windows
nc.author = sprintf('Created by %s, LMD using Matlab', r(1:end-1));
nc.creationdate = date;

% Are there global attributes ?

for j=1:length(varargin)
	varname = varargin{j};
	if strcmp(varname, 'glob')
		x = evalin('caller', varargin{j});
		if ~isstruct(x), continue, end;
		attrnames = fieldnames(x);
		for i=1:length(attrnames)
			setfield(nc, attrnames{i}, getfield(x, attrnames{i}));
		end
		% remove glob element, see http://romanski.livejournal.com/1980.html for the weird cell syntax		
		varargin(j) = []; 
	end
end


% Are dimensions given ?

dimnames = [];
ndims = 0;

for j=1:length(varargin)
	if iscell(varargin{j})
		dimnames = varargin{j};
		for i=1:length(dimnames)
			try
				x = evalin('caller', dimnames{i});
				if isstruct(x)
					struct_assert_var (x);
					x = x.var;
				end
			catch
				fprintf('Dimension %s does not exist. Aborting.\n', dimnames{i});
				return
			end
			if size(x,1)==1, x=x'; end;
			if size(x,2)>1
				fprintf('Dimension %s has more than 1 dimension. Aborting.\n', dimnames{i});
				return
			end 
			nc(dimnames{i}) = length(x);
		end
	end
end

if isempty(dimnames)
	% Can we detect dimensions ?
	fprintf('No dimension specified\n');

	for i=1:length(varargin)
		varname = varargin{i};
		switch varname
			case {'time', 'level', 'altitude', 'alt', 'lat', 'latitude', 'lon', 'longitude'}
				x = evalin('caller', varname);
				
				if isstruct(x)
					struct_assert_var (x);
					x = x.var;
				end
				
				if size(x,1)==1, x=x'; end;
				if size(x,2) == 1
					fprintf('Using %s as a dimension (%d)\n', varname, length(x));
					nc(varname) = length(x);
					ndims = ndims + 1;
					dimnames{ndims} = varname;
				end
				
		end
	end	
end

% Sauver les variables
nextradims = 0;

for i=1:length(varargin)
	varname = varargin{i};
	if iscell(varname), continue, end;

	try
		x = evalin('caller', varname);
	catch
		fprintf('Variable %s does not exist, skipping.\n', varname);
		continue;
	end

	% If we have attributes, remember them
	attrnames = [];
	
	if isstruct(x)
		struct_assert_var (x);
		attrnames = fieldnames(x);
		xstruct = x;
		x = x.var;		
	end
	
	if size(x,1)==1, x=x'; end;
	
	dims = size(x);
	dims(find(dims==1)) = []; % get rid of singletons
	
	% Find dimensions
	clear dimnames_var
	for j=1:length(dims)
		dimnames_var{j} = [];
		if ~isempty(dimnames)
			for k=1:length(dimnames)
				y = evalin('caller', dimnames{k});
				if isstruct(y)
					struct_assert_var(y)
					y = y.var;
				end
				
				if size(y,1)==1, y=y'; end;
				if dims(j) == size(y,1)
					dimnames_var{j} = dimnames{k};
				end
			end
		end
	end

	% Create dimensions if needed
	for j=1:length(dims)
		if isempty(dimnames_var{j})
			nextradims = nextradims + 1;
			eval(sprintf('extradim%02d = 1:dims(j);', nextradims));
			dimnames_var{j} = sprintf('extradim%02d', nextradims);
			nc(dimnames_var{j}) = dims(j);
		end
	end
	
	fprintf('Saving %s, dimensions : ', varname);
	for j=1:length(dims), fprintf('%s ', dimnames_var{j}), end;
	fprintf('\n'); 

	% Initialize variable size
	nc{varname} = dimnames_var;
	
	% If attributes, set them
	if ~isempty(attrnames)
		for j=1:length(attrnames)
			if strcmp(attrnames{j}, 'var'), continue, end;
			setfield(nc{varname}, attrnames{j}, getfield(xstruct, attrnames{j}));
		end
	end		
	
	nc{varname}(:) = squeeze(x);
	
end

nc = close(nc);
return




% Helper functions

function struct_assert_var (s)
	if ~isfield(s, 'var')
		error ('Structures need to have a "var" field. Aborting.\n');
	end
	
end


end

