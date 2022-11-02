function plot_stick(x_date,u,v,varargin)

%MARMAIN - 13/12/2011
%   plot time serie of vectors in the curent figure
%   size of date(nt,1), u(nt,1), v(nt,1) must be the same
%   sca should be calculated as follow to get a good scaling:
%   sca=1/max(sqrt(u.^2+v.^2));  

y_date = 0*x_date; %%% to have the grid and to plot the vectors at y=0

%%% scaling du courant
sca = max(abs(u + 1i*v));
sca_x = max(x_date);

%%% trace
if nargin == 4
    col = varargin{1};
else
    col = 'b';
end
a = quiver(x_date/sca_x,y_date,u/sca,v/sca,0,col);
set(a,'ShowArrowHead','off');
axis equal

x = [x_date(1)/sca_x x_date(end)/sca_x];
y  =zeros(1,2);
hold on
plot(x,y,'-k')
hold off

%%% repere orthonorme pour bonne representation des fleches
%%% axis
set(gca,'xlim',[x_date(1)/sca_x-1 x_date(end)/sca_x+1],'ylim',[-1 1]);

%%% Y tick
Ytickpos = [-1 -0.5 0 0.5 1];

Ytickval = [{num2str(-1*sca,'%.1f')}; {num2str(0.5*sca,'%.1f')};...
            {num2str(0,'%.1f')}; ...
            {num2str(0.5*sca,'%.1f')}; {num2str(1*sca,'%.1f')}];

set(gca,'Ytick',Ytickpos,'Yticklabel',Ytickval, ...
    'fontweight','bold','fontsize',10 );

%%% Y tick
Xtickpos = [0 0.5 1];

Xtickval = [{num2str(x_date(1),'%.1f')}; ...
            {num2str((x_date(1)+x_date(end))/2,'%.1f')}; ...
            {num2str(x_date(end),'%.1f')}];

set(gca,'Xtick',Xtickpos,'Xticklabel',Xtickval, ...
    'fontweight','bold','fontsize',10 );

