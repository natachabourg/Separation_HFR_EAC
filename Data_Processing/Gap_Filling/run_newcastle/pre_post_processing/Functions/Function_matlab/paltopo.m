%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                         %
%        CREATION D'UNE PALETTE POUR LA TOPOGRAPHIE       %
%                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function map=paltopo

%%%%%%%%%%%%%% Cr�ation des matrices RGB %%%%%%%%%%%%%%%%%%

r=zeros(256,1);
g=zeros(256,1);
b=zeros(256,1);

%%%%%%%%%%%%%%%%%% Cr�ation de la palette %%%%%%%%%%%%%%%%%

b(1)=0.94;         % mise du premier niveau au bleu
g(1)=0.77;
r(1)=0.46;

b(2:256)=((0:254)/254).^3*0.7+0.3;
r(2:256)=((0:254)/254).^0.3;
g(2:256)=((-127:127)/127).^2/2+0.5;

map=[r,g,b];    % �criture de la palette

colormap(map)

%%%%%%%% Cr�ation d'une palette en niveaux de gris %%%%%%%%

mapgris=gray(256);        % cr�ation de la matrice gris
mapgris=flipud(mapgris);  % inversion haut-bas
mapgris(1,:)=[1 1 1];     % mise du 1er niveau au blanc
mapgris=mapgris.^0.5;       % accentuation (3 pour forte accentuation)

% colormap(mapgris);      % � d�commenter pour utilisation