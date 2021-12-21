function [substrates, compression_score] = SLICE(activity_matrix, library_size, activity_thresh, must_test_subs)
    
    % INPUTS
    % activity_matrix = proteases in rows, substrates in columns
    % library_size = number of substrates to include in final library
    % activity_thresh (optional) = threshold activity value considered to be "sensing"
    % must_test_subs (optional) = specify substrate combinations that must be tested (rows = combinations, cols = substrates)
    % OUTPUTS
    % substrates = vector of substrate indicies
    % compression_score = overall compression score for winning library
    
    [~, num_substrates] = size(activity_matrix);
    library_size = min(num_substrates, library_size);
    
    % find max size of array
    percent_max = .1;
    try user = memory; mem = user.MaxPossibleArrayBytes;
    catch; try mem = MemoryMacOS(); catch; mem = Inf; end; end
    max_num_elements = round(percent_max * mem / 8);
    num_combns_subs = nchoosek(num_substrates, library_size);
    
    % if not enough memory, limit the number of combinations to test
    if num_combns_subs * library_size > max_num_elements
        disp('Not enough memory, not all substrate combinations will be tested. This may affect your results. Consider using the "must_test_subs" variable.');
        combinations = nchoosek_rand(1:num_substrates, library_size, max_num_elements);
    else
        disp('Memory constraints satisfied, all substrate combinations will be tested.');
        combinations = nchoosek(1:num_substrates, library_size);
    end
    
    % add must test subs combinations
    try combinations = [must_test_subs; combinations]; catch; disp('Incorrect size of "must_test_subs", can not test these substrate combinations.'); end
    
    % test all combinations and save library with highest compression score
    substrates = [];
    compression_score = 0;
    [num_combns_subs, ~] = size(combinations);
    
    % calculate threshold based on percentile if not input
    if ~exist('activity_thresh', 'var'); activity_thresh = prctile(activity_matrix(:),10); end
    
    % define anonymous function for calculating variance between #
    % proteases sensed per substrate
    V = @(AM) std(sum(AM > activity_thresh));
    min_var = Inf;
    for i = 1:num_combns_subs
        si = combinations(i,:);
        [C, ~, ~] = CompressionScore(activity_matrix(:,si), activity_thresh, 0.5, 3);
        if C > 1.1 * compression_score || (C > compression_score && V(activity_matrix(:,si)) < min_var)
            substrates = si;
            min_var = V(activity_matrix(:,si));
            compression_score = C;
        end
    end
    
end