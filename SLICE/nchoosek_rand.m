function [C] = nchoosek_rand(v, k, max_elements)

    max_num_combns = floor(max_elements / k);
    
    C = zeros(max_num_combns, k);
    
    for i = 1:max_num_combns
        
        C(i,:) = randsample(v, k);
        
    end

end