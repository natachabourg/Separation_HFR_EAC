% setpos
% Fait apparaitre explicitement la commande:
% set(gcf,'position',[ x y z t])
% pour insérer dans un programme.
% On run le progr. On déplace la figure là où on veut la faire apparaitre.
% On copie dans le progr. le résulatt de setpos

function setpos
comma='''';
a=[comma 'position' comma];
pos=get(gcf,'position');
disp=['set(gcf,' a ',[' num2str(pos) '])']

end

