%% plotting 2 D for clustering
% data_base is the hourly smooth baseline

for hour = 210:12:250
    hour = 212
    %figure
    hold on
    for c=1:4
        ind_plt = (indices(4).case(4).cluster==b(c));
        x = data_bench(ind_plt,hour);
        y = data_bench(ind_plt,hour+6);
        
        h1 = plot( x ,y ,'o','MarkerSize', 5);
        set(h1, 'markerfacecolor', get(h1, 'color')); 
    end
end