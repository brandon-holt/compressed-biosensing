function [norm_data] = quantile_normalization(data)
% useless, matlab bioinfo toolbox has it

% [norm_data] = quantile_normalization(data)
% http://discover.nci.nih.gov/microarrayAnalysis/Affymetrix.Preprocessing.jsp

norm_data = zeros(size(data));
for i=1:size(data,2)
    norm_data(:,i) = prctile(data(:,1),quantile(data(:),data(:,1)));
end