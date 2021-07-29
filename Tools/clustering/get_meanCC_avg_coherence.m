function m = get_meanCC_avg_coherence(data, idx) 
% m = get_absCC_PCA_coherence(data, idx)
% (idx is the clustering result of genes/rows)

data = per_gene_normalization(data); data = data./norm(data(1,:));

m = zeros(1,max(idx));
for i=1:max(idx)
    data_tmp = data(idx==i,:);
    module_mean_tmp = mean(data_tmp,1); 
    module_mean_tmp = module_mean_tmp/norm(module_mean_tmp);
    m(i) = mean(module_mean_tmp*data_tmp');
end

return
