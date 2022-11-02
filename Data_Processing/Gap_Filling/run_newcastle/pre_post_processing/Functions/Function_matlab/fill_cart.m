
% programme fill_cart
% destine a "remplir" les cartes lacunaires créees par le dépouillement en DF
% PB 06/2005

% C'est l'original de Pierre, il marche: PFO le 10/9/10

function courant_r=fill_cart(dist,teta,v)

% dimensions

n_d=length(dist);
n_t=length(teta);
c=v;

% recherche des emplacements des valeurs manquantes

vide=isnan(v);
vide=double(vide);

% balayage des valeurs manquantes

for i=1:n_t
    for j=1:n_d

        if vide(i,j)==1			% la valeur n'existe pas

            % caracterisation des cellules voisines

            imin=max(i-1,1);imax=min(i+1,n_t);
            Ivmax=imax-imin+1;			% nombre d'abcisses
            jmin=max(j-1,1);jmax=min(j+1,n_d);
            Jvmax=jmax-jmin+1;			% nombre d ordonnees
            a=zeros(Ivmax,Jvmax);
            I_centre=i-imin+1;J_centre=j-jmin+1;
            for Iv=1:Ivmax
                for Jv=1:Jvmax
                    iabs=imin+Iv-1;jabs=jmin+Jv-1;
                    a(Iv,Jv)=1-vide(iabs,jabs);	% 0 si cellule vide
                end
            end

            % identification des cellules non vides autour de la cellule etudiee
            [Ivc,Jvc]=find(a==1);n_nonvide=length(Ivc);
            if n_nonvide<2;		% pas de rempli si moins de 2 cellules
            else

                % distance au barycentre des cellules non vides

                x_num=0;y_num=0;denom=n_nonvide;
                for i_bary=1:n_nonvide
                    x_num=x_num+Ivc(i_bary)-I_centre;
                    y_num=y_num+Jvc(i_bary)-J_centre;
                end
                x_bary=x_num/denom;
                y_bary=y_num/denom;
                d_bary=sqrt(x_bary*x_bary+y_bary*y_bary);
                if d_bary<0.62			%

                % interpolation lineaire entre les cellules selectionnees
                    if n_nonvide==2
                        q=0;
                        for i_int=1:2
                            iabs=imin+Ivc(i_int)-1;
                            jabs=jmin+Jvc(i_int)-1;
                            q=q+v(iabs,jabs);
                        end
                        c(i,j)=q/2;				% interpolation linéaire=moyenne
                    end
                    if n_nonvide>2
                        G=ones(n_nonvide,3);F=zeros(n_nonvide,1);
                        for i_int=1:n_nonvide				% formation des matrices (MC)
                            iabs=imin+Ivc(i_int)-1;
                            jabs=jmin+Jvc(i_int)-1;
                            G(i_int,2)=Ivc(i_int)-I_centre;
                            G(i_int,3)=Jvc(i_int)-J_centre;
                            F(i_int,1)=v(iabs,jabs);
                        end
                        P=inv(G'*G)*G'*F;
                        c(i,j)=P(1,1);
                    end
%                 else			% pas de rempli dans ce cas
                end
            end
%         else					% la valeur existe: pas de traitement
        end
    end
end


courant_r=c;

