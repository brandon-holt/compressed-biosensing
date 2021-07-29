function [substrates, compression_score] = SLICE(activity_matrix, library_size, activity_thresh)
    
    % INPUTS
    % activity_matrix = proteases in rows, substrates in columns
    % library_size = number of substrates to include in final library
    % activity_thresh (optional) = threshold of activity considered to be "sensing"
    % OUTPUTS
    % substrates = vector of substrate indicies
    % compression_score = overall compression score for winning library
    
    [~, num_substrates] = size(activity_matrix);
    library_size = min(num_substrates, library_size);
    
    % find max size of array
    percent_max = .1;
    try user = memory; mem = user.MaxPossibleArrayBytes;
    catch; mem = MemoryMacOS(); end
    max_num_elements = round(percent_max * mem / 8);
    num_combns_subs = nchoosek(num_substrates, library_size);
    
    % if not enough memory, limit the number of combinations to test
    if num_combns_subs * library_size > max_num_elements
        combinations = nchoosek_rand(1:num_substrates, library_size, max_num_elements);
    else
        combinations = nchoosek(1:num_substrates, library_size);
    end
    
    % test all combinations and save library with highest compression score
    substrates = [];
    compression_score = 0;
    [num_combns_subs, ~] = size(combinations);
    
    % calculate threshold based on percentile if not input
    if ~exist('activity_thresh', 'var'); activity_thresh = prctile(activity_matrix(:),10); end

    for i = 1:num_combns_subs
        si = combinations(i,:);
        [C, ~, ~] = CompressionScore(activity_matrix(:,si), activity_thresh, 0.5, 3);
        if C > compression_score; substrates = si; end
        compression_score = max(compression_score, C);
    end
    
end