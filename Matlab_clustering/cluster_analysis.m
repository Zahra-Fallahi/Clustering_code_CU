
% Main file for evaluating the clustring results. Comparison of attributes
% and clustering methods
clc


%% General flags and information
%[main_datafolder,flag_data_manual]=General_inputs_clustring;

%% what is the data?
%% If the line below is commented, provide a Baseline and a Shaped table for buildings. each row shows the time series data of the buildings....
	% A day of 5 min data for 10 buildings should generate matrices of 10 by 288 for Baseline and Shaped
% [Shaped, Baseline]=Case_inputs_clustring(0); % data for evaluation and clustring % input=1 only HVAC load else total load in [W]
%%

Baseline_mean=mean(Baseline,2);

%% what is the attribute?

timestep=5;
data_manual = Cluster_attribute(Baseline,Shaped,timestep,1,2, Shaped_2);%(Baseline,Shaped,What is the moving average time step?,which day?,Do you want full day data to be used?)
data_bench = movmean(Shaped,1,2); % We benchmark the clustring with the load shaped values
data_bench_2 = movmean(Shaped_2,1,2); % We benchmark the clustring with the load shaped values
data_base  = movmean(Baseline,1,2); %we evaluate the clustring goodness for baseline timeseries
%% data representation
%%%%%%%%%%%%%% what is the method? How many cluster? %%%%%%%%%%%%%%%%%%%%%%
indices=struct;
centroids_manual=struct;
centroids_random=struct;
err_clust=struct;
err_bench=struct;

%numClustVec=[1 2 3 4 6 8 10 15 20 25 30 40 50 80 100 120 140 142];% 12 14];% 16 32 64 128 254];% 512 1024 2048 2098];
numClustVec = [1,2,3,4,5,6,10,20,50,100,150,200,250,300,350,365];
method='hierarchical'; 

for data_counter=1:length(data_manual)
    counterclusts = 0;
    data_clust=data_manual(data_counter).case;
    indices(data_counter).name=data_manual(data_counter).name;
    indices(data_counter).method=method;
    flag=data_manual(data_counter).scale_flag;
    
    for numClusters = numClustVec
        
        counterclusts = counterclusts+1;
        
        if data_counter==1
            %percent=floor(numClusters/2098*1000)/10;
            percent=floor(numClusters/365*1000)/10;
            labelx{counterclusts}= [mat2str(numClusters),' (',num2str(percent),' %)'];
        end
        indices(data_counter).case(counterclusts).number=numClusters;
        [indices(data_counter).case(counterclusts).cluster,...
            centroids_manual(data_counter).case(counterclusts).centroids_vec,...
            centroids_manual(data_counter).case(counterclusts).mult_numb_close_vec]=...
            cluster_data(data_clust, numClusters, method,flag,Baseline_mean);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%% random selection %%%%%%%%%%%%%%%%%%%%%%%
        number_of_rand_cases = 20;      % how many random cases to run? was 50 initially
        centroids_random(data_counter).case(counterclusts). centroid_vec= ...
            ceil(rand(numClusters,number_of_rand_cases)*size(Baseline,1)); % centroids for random clustering
        centroids_random(data_counter).case(counterclusts).mult_numb_close_vec = ...
            length(Baseline)/numClusters*ones(numClusters,number_of_rand_cases); % multiplication factor for random selected cases
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Evaluation %%%%%%%%%%%%%%%%%%%%%%%%%
        err_metric='CV'; % choose the error metric from the list : MAE, CV, RMSE
        centroids=centroids_manual(data_counter).case(counterclusts).centroids_vec; multiplier=centroids_manual(data_counter).case(counterclusts).mult_numb_close_vec; centroid_rand=centroids_random(data_counter).case(counterclusts). centroid_vec; multiplier_rand=centroids_random(data_counter).case(counterclusts).mult_numb_close_vec;
        
        % evaluation for clustring method
        [err_clust(data_counter).cluster(counterclusts,1),...
            err_clust(data_counter).random(:,counterclusts), err_clusters(data_counter).cluster(counterclusts,1)]= evaluateError( ...
            data_base, centroids, multiplier,centroid_rand, multiplier_rand, 0, 'temp', 'temp',err_metric ,indices(data_counter).case(counterclusts).cluster);
        
        % evaluation for shaped trend representation
        [err_bench(data_counter).cluster(counterclusts,1),...
            err_bench(data_counter).random(:,counterclusts)]= evaluateError (...
            data_bench, centroids, multiplier,centroid_rand, multiplier_rand, 0, 'temp', 'temp',err_metric ,indices(data_counter).case(counterclusts).cluster);
        
        % evaluation for shaped trend representation 2
%         [err_bench_2(data_counter).cluster(counterclusts,1),...
%             err_bench_2(data_counter).random(:,counterclusts)]= evaluateError (...
%             data_bench_2, centroids, multiplier,centroid_rand, multiplier_rand, 0, 'temp', 'temp',err_metric , indices(data_counter).case(counterclusts).cluster);
%         
    end
    
end


%% Data visualization
% for data_counter=1:length(data_manual)
%     figure;
%     plot(1:length(numClustVec),err_clust(data_counter).cluster*10^2,'LineWidth',2); hold on;
%     boxplot( err_clust(data_counter).random(:,:)*10^2 ,'Labels',labelx ); ylabel([err_metric,' total demand (%)']); %
%     xlabel('Number of clusters (sample size %)')
%     title(['Baseline prediction by ',data_manual(data_counter).name, ' clustring'])
    
    %     figure;
    %     plot(1:length(numClustVec),err_bench(data_counter).cluster*10^-6,'LineWidth',2); hold on;
    %     boxplot( err_bench(data_counter).random(:,:)*10^-6 ); %ylabel('MAE total demand (MW)'); %
    %     xlabel('Sample size (%)')
    %     title(['Evaluation, ',data_manual(data_counter).name])
    
% end
figure;
hold on;
 for data_counter=1:length(data_manual)
    plot(1:length(numClustVec),err_clust(data_counter).cluster,'LineWidth',3); 
    leg(data_counter) = {data_manual(data_counter).name};
 end

 
ylabel([err_metric, '(%)']); %
xlabel('Number of clusters (sample size %)')
title('Baseline load prediction')
%leg={'Baseline', 'Smooth'};
ax=gca;
ax.XTick=1:length(labelx);
ax.XTickLabel=labelx;
ax.XTickLabelRotation=45;
ax.FontSize=15;
ax.FontName='Serif';
legend(leg)
box on
% figure;
% for data_counter=1:length(data_manual)
%     plot(1:length(numClustVec),err_bench(data_counter).cluster*10^2,'--','LineWidth',2); hold on;
% end
% ylabel([err_metric,' total demand (%)']); %
% xlabel('Number of clusters (sample size %)')
% title('Shaped load prediction')
% legend( data_manual.name);
% ax=gca;
% ax.XTick=1:length(labelx);
% ax.XTickLabel=labelx;
% ax.XTickLabelRotation=45;
% ax.FontSize=15;




