% calculate auc for the roc curves from the results
clear; clc; close all; 

load('results.mat');

minutes = 2:10;

auroc = zeros(numel(results), 2); % bad, good
cols = [3, 5];

for i = 1:numel(results)
    
    for j = 1:2
    
        auroc(i, j) = trapz(results{i}{cols(j)}, results{i}{cols(j)+1});
    
    end
    
end

plot(auroc);