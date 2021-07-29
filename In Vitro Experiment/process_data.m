close all; clear; clc;

% parameters
start_min = 1;
end_min = 7;

% process excel file

% weave raw data

[num, ~, ~] = xlsread('Classification Raw Data.xlsx');

fam = num(1:61,3:42);
edans = num(64:124,3:42);

merged = zeros(size(fam,1), 2*size(fam,2));
merged(:,1:2:end) = fam;
merged(:,2:2:end) = edans;

A = merged(:,1:20);
B = merged(:,21:40);
C = merged(:,41:60);
D = merged(:,61:80);

% control group (i.e., raw protease concentrations)
ctrl = [0.2564102564	0.01754385965
0.05128205128	0.0350877193
0.07692307692	0.0350877193
0.1025641026	0.0701754386
0.07692307692	0.05263157895
0.05128205128	0.0350877193
0.02564102564	0.350877193
0.1282051282	0.08771929825
0.1538461538	0.1052631579
0.05128205128	0.0350877193
0.02564102564	0.1754385965];

% test only top features by tree bagger feature improtance
top_ftrs = 11;
ctrl_ftr_imp = [0.4975	0	0.2516	0.083	-0.0415	0	0.3895	-0.0253	0.0316	0.1604	0.4743];
[~, sorted_ftrs] = sort(ctrl_ftr_imp);
ctrl = ctrl(sorted_ftrs, :);
ctrl = ctrl(1:top_ftrs, :);

% make plots of raw data
figure
raw_data = {A, B, C, D};
cols = width(raw_data);
rows = width(raw_data{1}) / 2;
% also save data for a plate map
plate_map = zeros(rows,cols,2);
for i = 1:cols
    this_data_block = raw_data{i};
    %this_data_block = this_data_block(1:10,:);
    %this_data_block = this_data_block ./ this_data_block(1,:);
    sp = 1;
    positions = [i:cols:rows * cols];
    for j = 1:2:rows * 2
        subplot(rows, cols, positions(sp))
        yyaxis left
        plot(this_data_block(:,j))
        hold on
        yyaxis right
        plot(this_data_block(:,j+1))
        hold off
        sp = sp + 1;
        
        % plate map
        y1 = this_data_block(:,j);
        y2 = this_data_block(:,j+1);
        plate_map(ceil(j/2), i, 1) = line_best_fit(start_min:end_min, y1(start_min:end_min));
        plate_map(ceil(j/2), i, 2) = line_best_fit(start_min:end_min, y2(start_min:end_min));
    end
end

% self-normalize
% groups = [1, 2; 3, 4];
% for cols = 1:2
%     for layer = 1:2
%         g = groups(cols,:);
%         plate_map(:,g,layer) = plate_map(:,g,layer) / max(max(plate_map(:,g,layer)));
%     end
% end
% % plot as heat map
% figure; heatmap(plate_map(:,:,1));
% figure; heatmap(plate_map(:,:,2));
% plot as scatter plot
figure; aa = plate_map(:,1,1); ab = plate_map(:,1,2);
ac = plate_map(:,2,1); ad = plate_map(:,2,2);
scatter(aa, ab); hold on; scatter(ac, ad);
figure; ba = plate_map(:,3,1); bb = plate_map(:,3,2);
bc = plate_map(:,4,1); bd = plate_map(:,4,2);
scatter(ba, bb); hold on; scatter(bc, bd);


% x axis, in minutes
x = 0:end_min - 1;

% good with mixture 1
slopes = arrayfun(@(n) line_best_fit(x, A(start_min:end_min,n)), 1:width(A));
A = reshape(slopes,2,[]);
good1 = A;

% good with mixture 2
slopes = arrayfun(@(n) line_best_fit(x, B(start_min:end_min,n)), 1:width(B));
B = reshape(slopes,2,[]);
good2 = B;

% bad with mixture 1
slopes = arrayfun(@(n) line_best_fit(x, C(start_min:end_min,n)), 1:width(C));
C = reshape(slopes,2,[]);
bad1 = C;

% bad with mixture 2
slopes = arrayfun(@(n) line_best_fit(x, D(start_min:end_min,n)), 1:width(D));
D = reshape(slopes,2,[]);
bad2 = D;

% generate AUROC
% good1 = good1(1,:);
% good2 = good2(1,:);
[result] = generate_ROC_three(good1,good2,bad1,bad2,ctrl, true)

