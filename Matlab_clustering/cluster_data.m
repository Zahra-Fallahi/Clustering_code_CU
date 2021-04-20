
function [ind_clust, Centroid, multiplier]=cluster_data(Data, NumofClusters, method,flag, Base_mean)
%% cluster the data

if strcmpi(method,'kmeans')
    
    [ind_clust, Cent_k, sumd, D] = kmeans(Data,NumofClusters); %kmeans clustering
    
else
    
    ind_clust = clusterdata(Data,'maxclust',NumofClusters,'linkage','ward'); % hierarchical clustering
    
end

[ Centroid, multiplier]= findClosestToCentroid( Data,ind_clust,NumofClusters,0,Base_mean,flag );

end