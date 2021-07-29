function trans_data = data2bins(data,bins)

% use quantile to define bins, bins are of equal number of cases, not equal width

trans_data = zeros(size(data));
num_per_bin = ceil(size(data,1)/bins);
for i=1:size(data,2)
    [Y,I] = sort(data(:,i), 'ascend');
    for j=1:bins
        trans_data(I((j-1)*num_per_bin+1:min(j*num_per_bin,size(data,1))),i)=j;
    end
end
trans_data = trans_data/max(max(trans_data));
return

