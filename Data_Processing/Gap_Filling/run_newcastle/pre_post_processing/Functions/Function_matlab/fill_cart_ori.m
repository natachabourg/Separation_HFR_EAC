% programme fill_cart
% destine a "remplir" les cartes lacunaires créees par le dépouillement en DF
% PB 06/2005

    function courant_r=fill_cart(dist,teta,v)


% dimensions

    n_d=length(dist);
    n_t=length(teta);
    c=v;

% recherche des emplacements des valeurs manquantes

    vide=isnan(v);

% balayage des valeurs manquantes

for i=1:n_t
for j=1:n_d

if vide(i,j)==1                        % la valeur n'existe pas

% caracterisation des cellules voisines

        imin=max(i-1,1);imax=min(i+1,n_t);Ivmax=imax-imin+1;
        jmin=max(j-1,1);jmax=min(j+1,n_d);Jvmax=jmax-jmin+1;
        a=zeros(Ivmax,Jvmax);
        x=a;y=a;
        for Iv=1:Ivmax
        for Jv=1:Jvmax
            I_centre=i-imin+1;J_centre=j-jmin+1;
            x(Iv,Jv)=Iv-I_centre;y(Iv,Jv)=Jv-J_centre;
%            if Iv==I_centre&Jv==J_centre        % on ne teste pas la cellule etudiee
%            else
            a(Iv,Jv)=1-vide(Iv+imin-1,Jv+jmin-1);    % 0 si cellule vide
%            end
        end
        end

% identification des cellules non vides autres que la cellule etudiee

        [Ivc,Jvc]=find(a==1);n_nonvide=length(Ivc);
        if n_nonvide<2;break;end            % pas de rempli si moins de 2 cellules

% distance au barycentre des cellules non vides

        x_num=0;y_num=0;denom=n_nonvide;
            for i_bary=1:n_nonvide
                x_num=x_num+x(Ivc(i_bary),Jvc(i_bary));
                y_num=y_num+y(Ivc(i_bary),Jvc(i_bary));
            end
        x_bary=x_num/denom;
        y_bary=y_num/denom;
        d_bary=sqrt(x_bary*x_bary+y_bary*y_bary);
        if d_bary>0.6;break;end                % pas de rempli dans ce cas


% interpolation lineaire entre les cellules selectionnees

        if n_nonvide==2
        q=0;
            for i_int=1:2
                iabs=i+x(Ivc(i_int),Jvc(i_int));
                jabs=j+y(Ivc(i_int),Jvc(i_int));
                q=q+v(iabs,jabs);
            end
        c(i,j)=q/2;                % interpolation linéaire=moyenne
        end

        if n_nonvide>2

        G=ones(n_nonvide,3);F=zeros(n_nonvide,1);
            for i_int=1:n_nonvide                % formation des matrices (MC)
                iabs=i+x(Ivc(i_int),Jvc(i_int));
                jabs=j+y(Ivc(i_int),Jvc(i_int));
                G(i_int,2)=x(Ivc(i_int),Jvc(i_int));
                G(i_int,3)=y(Ivc(i_int),Jvc(i_int));
                F(i_int,1)=v(iabs,jabs);
            end

        P=inv(G'*G)*G'*F;
        c(i,j)=P(1,1);
        end




else                            % la valeur existe: pas de traitement
end

end
end

    courant_r=c;


end

