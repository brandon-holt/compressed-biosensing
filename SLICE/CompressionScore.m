function [score, s1, s2] = CompressionScore(X, threshold, weight,option)
    D = pdist(X','cosine'); 
    s1 = mean(D); %Score 1: dependent on substrate vs substrate randomness
    
    binX = [X]; %copying X where substrates are COLUMNS
    
    binX(X <= threshold) = 0; %For Options 1 & 2
    binX(X > threshold) = 1;
    
    switch (option)
        case 1
            s2 = sum(binX, 2);
            s2(s2 <= 0) = 0;
            s2(s2 > 0) = 1;
            s2 = mean(s2); %(Option 1): what area of proteases does this library cover
        case 2
            [~,c] = size(binX); 
            s2 = sum(binX, 2); 
            s2 = mean(s2/c); %(Option 2): what area of proteases does this library cover
        case 3
            s2 = mean(X, 2);
            s2(s2 <= threshold) = 0;
            s2(s2 > threshold) = 1;
            s2 = mean(s2); %Score 2 (Option 3): what area of proteases does this library cover
        case 4
           s2 = mean(X, 2); %will get close to 6, less variance
           s2 = mean(s2/max(s2)); %(Option 4): what area of proteases does this library cover
    end
    
    score = weight*s1 + (1-weight)*s2; %s1 - substrate orthogonality s2 - protease coverage
end