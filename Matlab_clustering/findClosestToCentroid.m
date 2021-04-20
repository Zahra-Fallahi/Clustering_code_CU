function [ centroids_vec, mult_numb_close_vec ] = findClosestToCentroid( data_to_cluster,indices_hierarch,numClusters, ...
    detailled_plot,average_baseline,scale_flag)
%FINDCLOSESTTOCENTROID Find the indices of the buildings closest to the centroid
%   Closest is determined by kmeans with one cluster

centroids_vec        = zeros(numClusters,1);  % location of centroid
mult_numb_close_vec  = zeros(numClusters,1);  % multiplier: how much buildings in the cluster?

numsteps = length(data_to_cluster(1,:));      % number of time steps



%%
if detailled_plot
    figure;
end

for i = 1:numClusters
    % find cases closest to centroid of each cluster
    clust_data = data_to_cluster(indices_hierarch == i,:); % profiles belonging to one cluster
    [~,~,~,D] = kmeans(clust_data,1); % distances from the centroids
    [~,I] = min(D);   % index closest to the centroid
    I2 = I(1,1);  % in case there are 2 closest: pick the first one
    
    prof_selected = clust_data(I2,:);  % selected profile
    % find selected profile
    j = 1;
    while sum( data_to_cluster(j,:) == prof_selected ) < numsteps
        j=j+1; % not found: go one further
    end
    centroids_vec(i,1) = j;
    
    % multiplier number of buildings
    if scale_flag==1
        mult_numb_close_vec(i,1) = sum(average_baseline(indices_hierarch == i)./average_baseline(j));
%         mult_numb_close_vec(i,1) = sum(var_baseline(indices_hierarch == i)./var_baseline(j));
    else
        mult_numb_close_vec(i,1) = sum( indices_hierarch == i );
    
    end
    if detailled_plot
        subplot(2*ceil(numClusters)/5,5,i*2-1)
        plot(clust_data');
        subplot(2*ceil(numClusters)/5,5,i*2)
        plot(mean(clust_data,1),'r'); hold on;
        plot(data_to_cluster(j,:),'k');
    end
end


end

