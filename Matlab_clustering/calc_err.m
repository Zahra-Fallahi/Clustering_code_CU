function [err] = calc_err(prof1, prof2,metric)
if strcmpi(metric,'MAE')
    % calculate the mean absolute error
    err = sum( abs( prof1 - prof2 ) )/length(prof1) ;
elseif strcmpi(metric,'NMAE')
    err = (sum( abs( prof1 - prof2 ) )/length(prof1))./mean(prof1) ;
elseif strcmpi(metric,'RMSE')
    err = sqrt(sum((( prof1 - prof2 ).^2)./length(prof1)))  ;
elseif strcmpi(metric,'CV')
    err = sqrt(sum((( prof1 - prof2 ).^2)./length(prof1)))./mean(prof1).*100  ;
elseif strcmpi(metric,'MBE')
    err = sum( ( prof1 - prof2 ) )/length(prof1) ;
elseif strcmpi(metric,'NMBE')
    err = sum( ( prof1 - prof2 ) )/length(prof1)./mean(prof1) ;
end

end
