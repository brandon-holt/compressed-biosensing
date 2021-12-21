clear;clc;
addpath(horzcat(fileparts(pwd), '/SLICE'));

substrates = 50;
proteases = 10;
n_subs_specific = 10;
n_subs_promiscuous = 5;
map = rand(proteases, substrates);

% generate initial heatmap
must_test_specific = [];
must_test_promiscuous = [];
for s = 1:substrates
    
    if mod(s, n_subs_promiscuous * 2) == 0
        n_hi = 2;
        i_hi = [(s / n_subs_promiscuous) - 1, s / n_subs_promiscuous];
        must_test_promiscuous = [must_test_promiscuous, s];
    elseif mod(s + 1, n_subs_specific / 2) == 0
        n_hi = 1;
        i_hi = (s + 1) / (n_subs_specific / 2);
        must_test_specific = [must_test_specific, s];
    else     
        n_hi = round(randrange(0, proteases));
        i_hi = randperm(proteases, n_hi);
    end
    
    for i = i_hi
        map(i, s) = randrange(7,10);
    end
    
end

% choose specific library (best library with 10 substrates)
[subs_specific, C_specific] = SLICE(map, n_subs_specific, 1, must_test_specific);

% choose promiscuous library (best library with 5 substrates)
[subs_promiscuous, C_promiscuous] = SLICE(map, n_subs_promiscuous, 1, must_test_promiscuous);

% plot results
f = figure;
subplot(3,1,1)
heatmap(map, 'Colormap', gray, 'CellLabelColor', 'none');
title('Activity Matrix');
xlabel('Substrates'); ylabel('Proteases');
subplot(3,1,2);
heatmap(map(:,subs_specific), 'Colormap', gray, 'CellLabelColor', 'none');
title('Specific Library (10 substrates)');
xlabel('Substrates'); ylabel('Proteases');
subplot(3,1,3)
heatmap(map(:,subs_promiscuous), 'Colormap', gray, 'CellLabelColor', 'none');
title('Promiscuous Library (5 substrates)');
xlabel('Substrates'); ylabel('Proteases');