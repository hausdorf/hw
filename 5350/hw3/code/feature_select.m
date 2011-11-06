function [scores indices] = feature_select(X,Y,m)
% do correlation based feature selection
    [N D] = size(X);
    pcc = zeros(1,D);
    % compute *absolute* PCC for each feature
    for d=1:D
      avg_d = mean(X(:,d));
      avg_Y = mean(Y);

      numerator = 0;
      denom1 = 0;
      denom2 = 0;
      for n=1:N
        numerator = numerator + (X(n,d) - avg_d) * (Y(n) - avg_Y);
        denom1 = denom1 + (X(n,d) - avg_d)^2;
        denom2 = denom2 + (Y(n) - avg_Y)^2;
      end
      rd = abs(numerator / sqrt(denom1 * denom2));
      pcc(d) = rd;
    end

    % sort the features and return the feature indices of 
    % the top m features
    [scores, indices] = sort(pcc);
    scores = scores(1,1:m);
    indices = indices(1,1:m);

