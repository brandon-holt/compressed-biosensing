function [result] = process_data_fxn(start_min, end_min)

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
    [result] = generate_ROC_three(good1,good2,bad1,bad2,ctrl, false)
end