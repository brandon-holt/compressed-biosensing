clear; clc; close all;

% generate heatmap
act_map = []; %rows are proteases, columns are substrates

num_proteases = 11;

% each tab is a different protease
for p = 1:num_proteases
    [A, ~, ~] = xlsread('Heatmap Raw Data.xlsx',p+1);
    %x = A(3:end, 1);
    A = A(3:end, 2:end);
    x = 1:length(A);
    slopes = arrayfun(@(n) line_best_fit(x, A(:,n)), 1:width(A));
    A = reshape(slopes,1,[]);
    act_map = [act_map; A];
end

% plot all cleavage curves
figure;
f = 1;
for p = 1:num_proteases
    [A, ~, ~] = xlsread('Heatmap Raw Data.xlsx',p+1);
    x = A(3:end, 1);
    A = A(3:end, 2:end);
    for s = 1:width(A)
        subplot(num_proteases, width(A), f);
        plot(x, A(:,s), '-o')
        f = f + 1;
    end
end

% log transform data
act_map(act_map < 0) = 0;
act_map = log(act_map);
act_map(act_map == -Inf) = 0;
act_map(act_map == 0) = 0.01;


figure
heatmap(act_map)
title("Activity Map")
ylabel("Proteases")
xlabel("Substrates")



% test all combinations of two substrates
weight = 0.5;
threshold = 0.1;
option = 3;
worst_score = Inf;
best_score = -Inf;
worst_combo = [];
best_combo = [];
all_real_scores_2 = [];
for subA = 1:2:size(act_map,2)
    for subB = 2:2:size(act_map,2)
        
        this_combo = [subA, subB];
        
        this_score = CompressionScore(act_map(:,this_combo), threshold, weight, option);
        all_real_scores_2 = [all_real_scores_2, this_score];
        
        if (this_score > best_score)
            best_score = this_score;
            best_combo = this_combo;
        elseif (this_score < worst_score)
            worst_score = this_score;
            worst_combo = this_combo;
        end
    end
end

% plot histogram of compression scores
compression_scores = [];
num_subs = width(act_map);
for lib_size = 2:num_subs-1
    lib_combos = nchoosek([1:num_subs], lib_size);
    for i = 1:length(lib_combos)
        subset = lib_combos(i,:);
        sub_library = act_map(:, subset);
        [score, ~, ~] = CompressionScore(sub_library, threshold, weight, option);
        compression_scores = [compression_scores, score];
    end
end

figure
h = histogram(compression_scores);
data = [h.BinEdges(2:end); h.BinCounts];
med_val = median(compression_scores);

% plot histogram of compression scores of library size 2
compression_scores_2 = [];
num_subs = width(act_map);
lib_size = 2;
lib_combos = nchoosek([1:num_subs], lib_size);
for i = 1:length(lib_combos)
    subset = lib_combos(i,:);
    sub_library = act_map(:, subset);
    [score, ~, ~] = CompressionScore(sub_library, threshold, weight, option);
    compression_scores_2 = [compression_scores_2, score];
end


figure
h = histogram(compression_scores_2);
data_2 = [h.BinEdges(2:end); h.BinCounts];

figure
h = histogram(all_real_scores_2);
data_real_2 = [h.BinEdges(2:end); h.BinCounts];
