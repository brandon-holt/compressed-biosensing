function slope = line_best_fit(x, y)
    %x = 1:numel(y);
    p = polyfit(x, y, 1);
    slope = p(1);
end