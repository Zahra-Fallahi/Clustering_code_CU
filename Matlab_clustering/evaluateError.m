function [ Err_clust,Err_rand, err_clusters ] = evaluateError( data_to_evaluate,centroids_vec,mult_numb_close_vec,centroids_rand,mult_numb_rand, plotPerSampleSize, titleprefix, ylabelhere,metric , indices)
%evaluateMAE evaluate MAE and plot the difference

% evaluate MAE for data-based clustering
%% load data
prof_full = sum(data_to_evaluate,1);   % original data
prof_clust = mult_numb_close_vec'*data_to_evaluate(centroids_vec,:);  % reconstructed data with clustering
%% error calculation for price signal.
% 
 mult = ones(size(data_to_evaluate,1),1);
 data_clust = ones(size(data_to_evaluate,1),24);
 prof_full = reshape(data_to_evaluate',1,[]);

 for i = 1:size(data_to_evaluate,1)
     mult(i) = sum(data_to_evaluate(i,:),2)./sum(data_to_evaluate(centroids_vec(indices(i)),:),2);
     data_clust(i,:) = mult(i).* data_to_evaluate(i,:);
 end
 prof_clust = reshape(data_clust',1,[]);

Err_clust = calc_err(prof_full, prof_clust,metric);  % MAE of both data

% evaluate MAE for random clustering
%% load data
% number_of_rand_cases = length(centroids_rand(1,:));
% Err_rand = zeros(number_of_rand_cases,1);
% prof_rand = zeros(number_of_rand_cases,length(data_to_evaluate(1,:)));
% for i = 1:number_of_rand_cases
%     prof_rand(i,:) = mult_numb_rand(:,i)'*data_to_evaluate(centroids_rand(:,i),:);
%     Err_rand(i,1) = calc_err(prof_full, prof_rand(i,:),metric); 
% end


%% price data
%later 
 Err_rand = 0;
%% Error Within cluster

for i = 1:length(centroids_vec)
    prof1_c(i,:) = sum(data_to_evaluate(indices == i,:),1);
    prof2_c(i,:) = data_to_evaluate(centroids_vec(i),:).*mult_numb_close_vec(i);
    
    
    err_within (i) = calc_err(prof1_c(i,:), prof2_c(i,:),metric);
end

err_clusters = mean(err_within);


%%

if plotPerSampleSize
    % resize the data to plot?
    if strcmp(ylabelhere,'Demand (MW)')
        rescalefac = 10^-6; % data from W to MW
    else
        rescalefac = 1; % don't change data
    end
    
    figure('Position',[200,200,700,300]);
    subplot(1,3,1);
    plot(prof_full*rescalefac,'k'); hold on;
    plot(prof_clust*rescalefac,'g');
    xlabel('Time (hour)'); ylabel(ylabelhere); title('Full (bl) and clust (gr)')
    subplot(1,3,2);
    plot(prof_rand'*rescalefac);
    xlabel('Time (hour)'); ylabel(ylabelhere); title('Random')
    subplot(1,3,3);
    boxplot( [Err_clust*ones(number_of_rand_cases,1)  Err_rand  ]*10^-6,'Labels',{'Clust','Rand'} ); ylabel(['MAE ' ylabelhere]); %
    title([ num2str(length(centroids_rand(:,1))) ' samples.' titleprefix])
end


end

