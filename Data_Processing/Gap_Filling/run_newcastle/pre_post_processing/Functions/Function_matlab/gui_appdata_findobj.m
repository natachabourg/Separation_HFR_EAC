
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DEBUT DE LA FONCTION PRINCIPALE%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function gui_appdata_findobj

% Création de l'objet Figure
figure('units','pixels',...
    'position',[250 250 500 500],...
    'color',[0.925 0.913 0.687],...
    'numbertitle','off',...
    'name','[GUI] Utilisation de SETAPPDATA / GETAPPDATA',...
    'menubar','none',...
    'tag','interface');

% Création de l'objet Uicontrol Pushbutton -
uicontrol('style','pushbutton',...
    'units','normalized',...
    'position',[0.1 0.1 0.1 0.05],...
    'string','-',...    
    'callback',@retrancher,...
    'tag','bouton-');

% Création de l'objet Uicontrol Pushbutton +
uicontrol('style','pushbutton',...
    'units','normalized',...
    'position',[0.3 0.1 0.1 0.05],...
    'string','+',...    
    'callback',@ajouter,...
    'tag','bouton+');

% Création de l'objet Uicontrol Text résultat
uicontrol('style','text',...
    'units','normalized',...
    'position',[0.1 0.2 0.3 0.05],...
    'string','0',...
    'tag','resultat');

% Initialisation de la valeur représentant la valeur courante du compteur nCompteur à 0
nCompteur=0;

% Enregistrement direct de nCompteur dans les données d'application de l'objet Figure
setappdata(gcf,'valeur_de_nCompteur',nCompteur);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FIN DE LA FONCTION PRINCIPALE%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DEBUT DE LA SOUS-FONCTION RETRANCHER%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function retrancher(obj,event)

% Récupération directe de nCompteur depuis les données d'application de l'objet Figure
% contenant l'objet graphique dont l'action est exécutée (gcbf)
nCompteur=getappdata(gcbf,'valeur_de_nCompteur');

% Diminution de la valeur de nCompteur
nCompteur=nCompteur-1;

% Récupération de l'identifiant de l'objet Uicontrol Text résultat enfant de l'objet Figure
% contenant l'objet graphique dont l'action est exécutée (gcbf)
h=findobj('parent',gcbf,'style','text','tag','resultat');
% Modification de sa propriété String
set(h,'string',num2str(nCompteur));

% Enregistrement de la nouvelle valeur de nCompteur dans les données d'application de l'objet Figure
% contenant l'objet graphique dont l'action est exécutée (gcbf)
setappdata(gcbf,'valeur_de_nCompteur',nCompteur);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FIN DE LA SOUS-FONCTION RETRANCHER%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DEBUT DE LA SOUS-FONCTION AJOUTER%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ajouter(obj,event)

% Récupération directe de nCompteur depuis les données d'application de l'objet Figure
% contenant l'objet graphique dont l'action est exécutée (gcbf)
nCompteur=getappdata(gcbf,'valeur_de_nCompteur');

nCompteur=nCompteur+1;

% Récupération de l'identifiant de l'objet Uicontrol Text résultat enfant de l'objet Figure
% contenant l'objet graphique dont l'action est exécutée (gcbf)
h=findobj('parent',gcbf,'style','text','tag','resultat');
% Modification de sa propriété String
set(h,'string',num2str(nCompteur));

% Enregistrement de la nouvelle valeur de nCompteur dans les données d'application de l'objet Figure
setappdata(gcbf,'valeur_de_nCompteur',nCompteur);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FIN DE LA SOUS-FONCTION AJOUTER%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
