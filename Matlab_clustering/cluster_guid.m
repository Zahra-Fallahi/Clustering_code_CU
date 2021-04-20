function centroid_dict = cluster_guid(ind_method,cluster_number, list,centroids_manual,indices)

temp1 = list(centroids_manual(ind_method).case(cluster_number).centroids_vec(indices(ind_method).case(cluster_number).cluster));

centroid_dict = containers.Map (list,temp1);

end