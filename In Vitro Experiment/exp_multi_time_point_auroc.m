% experiment plotting AUROCS for classification experiment at various time
% points to show that the good library outperforms the bad library at all
% time points

start_point = 1;
max_end_point = 10;
results = cell(max_end_point - start_point, 1);

fig = figure();

for end_point = start_point+1:max_end_point
    result = process_data_fxn(start_point, end_point);
    results{end_point - start_point} = result;
    subplot(3,3,end_point - start_point);
    plot(result{3}, result{4}); hold on;
    plot(result{5}, result{6}); hold off;
    legend("good", "bad"); legend("location", "southeast");
end