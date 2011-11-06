function [scores indices] = feature_select(X,Y,m)
% do correlation based feature selection
    [N D] = size(X);
    pcc = zeros(1,D);
    % compute *absolute* PCC for each feature
    for d=1:D
        pcc(d) = ???
    end
    % sort the features and return the feature indices of 
    % the top m features
