function [ CORR2D ] = nancorr_2d( PARAM1,PARAM2,dim )
%%% MARMAIN
%%% 2012/10/04
%%%
%%% Compute correlation along dimension 1 ou 2

if dim == 1
    PARAM1=PARAM1';
    PARAM2=PARAM2';
end

%%% remove NaN
isNoNan= isnan(PARAM1)==0 & isnan(PARAM2)==0 ;
PARAM1=PARAM1(isNoNan);
PARAM2=PARAM2(isNoNan);



PARAM1_MEAN=mean(PARAM1,2);
PARAM2_MEAN=mean(PARAM2,2);




CORR2D=  nansum( (PARAM1 - repmat(PARAM1_MEAN,1,size(PARAM1,2)))...
              .* (PARAM2 - repmat(PARAM2_MEAN,1,size(PARAM2,2))) ,2) ...
           ./  ( sqrt(nansum((PARAM1 - repmat(PARAM1_MEAN,1,size(PARAM1,2))).^2,2))...
               .*sqrt(nansum((PARAM2 - repmat(PARAM2_MEAN,1,size(PARAM2,2))).^2,2)) );
    


end

