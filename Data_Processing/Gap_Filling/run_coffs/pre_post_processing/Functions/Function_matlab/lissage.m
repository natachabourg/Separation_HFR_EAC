%%% JM
%%% 21/07/2010
%%% Permet de lisser les données de vitesses radiales issues de peyras
%%% Effectue le lissage meme en presence de NaNs. Lors de l'operation de
%%% moyenne, on en tient pas compte.


function [ vr_lis ] = lissage( vr,x,y,methode,N )
%%% vr: vitesses radiales brutes
%%% x,y: coordonnées cartésienne de chaque point de l'éventaile radar,
%%% obtenu en effectuant l'operation
%%% x=dist_l*cos(d2r(visee(i_station)+teta_l));
%%% y=dist_l*sin(d2r(visee(i_station)+teta_l));
%%% ou dist_l est la distance au centre du radar, et teta_l l'angle autours
%%% de la direction 0° (repère trigo). Données contenu dans le fichier
%%% *.cll
%%% methode:
%   0: lissage par une porte, revient à une moyenne simple non pondérée
%   1: poids fixes en fonction de la position au centre de la fenetre.
%   Penser à changer le parametre a pour ponderer differemment
%   2: lissage avec une fenetre gaussienne
%   3: ponderation en fonction de la distance geographique au centre de la
%   fenetre
%   4: Lissage utilisant un filtre médian

%%% N: taille de la fenetre
%disp(['Taille de la fenetre de lissage N= ', num2str(N)])

vr_lis=vr*0;

if methode<=2
    
    if methode==0
        %%% Methode 0 %%%
        %%% moyenne simple, sans ponderation
        kernel=ones(N,N); %%% moyenne simple non ponderee
    end
    
    if methode==1
        %%% Methode 1 %%%
        %%% poids fixes en fonction de la position au centre de la fenetre
        a=2; %%% paramètre de ponderation (on utilise 1/a)
        
        kernel=ones(N,N); %%% moyenne simple non ponderee
        
        if N==5
            kernel=kernel*1/(a*sqrt(5));
        end
        dec=(a*linspace(-floor(N/2),floor(N/2),N));
        kernel(round(N/2),:)=1./abs(dec);
        kernel(:,round(N/2))=1./abs(dec);
        
        j=1;
        for i=1:N
            if i<round(N/2)
                kernel(i,j)=1/(a*(round(N/2)-i)*sqrt(2));
            else kernel(i,j)=1/(a*(i-round(N/2))*sqrt(2));
            end
            j=j+1;
        end
        j=1;
        for i=N:-1:1
            if i<round(N/2)
                kernel(i,j)=1/(a*(round(N/2)-i)*sqrt(2));
            else kernel(i,j)=1/(a*(i-round(N/2))*sqrt(2));
            end
            j=j+1;
        end
        kernel(round(N/2),round(N/2))=1;
    end
    
    if methode==2
        %%% Methode 2 %%%
        %%% filtrage gaussien %%%
        [xn,yn]=meshgrid(-floor(N/2):floor(N/2),-floor(N/2):floor(N/2));
        sig=N/6;%etalement de N pixels pour 6 sigma
        kernel=1/sqrt(2*pi*sig^2)*exp(-(xn.^2+yn.^2)/(2*sig^2));
        kernel=kernel/sum(sum(kernel));
    end
    
    %%% module effectuant la moyenne sur une fenetre glissante en ne tenant pas
    %%% compte des points NaN
    for i=round(N/2):size(vr,1)-round(N/2)
        for j=round(N/2):size(vr,2)-round(N/2)
            
            vr_loc=vr(i-floor(N/2):i+floor(N/2),j-floor(N/2):j+floor(N/2));
            vr_loc=reshape(vr_loc,1,N*N);
            ker=reshape(kernel,1,N*N);
            
            ker(isnan(vr_loc)==1)=[];
            vr_loc(isnan(vr_loc)==1)=[];
            
            vr_lis(i,j)=sum(ker.*vr_loc)/sum(ker);
            
        end
    end
    
end


if methode==3
    %%% Methode 3 %%%
    %%% ponderation en fonction de la distance geographique
    for i=round(N/2):size(vr,1)-round(N/2)
        for j=round(N/2):size(vr,2)-round(N/2)
            
            vr_loc=vr(i-floor(N/2):i+floor(N/2),j-floor(N/2):j+floor(N/2));
            
            Xk=x(i-floor(N/2):i+floor(N/2),j-floor(N/2):j+floor(N/2));
            Yk=y(i-floor(N/2):i+floor(N/2),j-floor(N/2):j+floor(N/2));
            
            %%% matrice N*N contenant la distance au centre de la fenetre
            distance=sqrt((Xk-Xk(round(N/2),round(N/2))).^2+ ...
                (Yk-Yk(round(N/2),round(N/2))).^2);
            dtot=sum(sum(distance));
            kernel=dtot-distance;
            
            kernel=reshape(kernel,1,N*N);
            %%% elimination des NaN
            vr_loc=reshape(vr_loc,1,N*N);
            kernel(isnan(vr_loc)==1)=[];
            vr_loc(isnan(vr_loc)==1)=[];
            
            vr_lis(i,j)=sum(kernel.*vr_loc)/sum(kernel);
            
        end
    end
end


if methode==4   
%%%% filtrage median %%%
 vr_lis=mediane(vr,N);
end


vr_lis(isnan(vr)==1)=NaN;


end

