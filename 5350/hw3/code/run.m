clear;
% now let's do feature selection
% try a varying number of selected features, train KNN using the selected
% features, and test 
for m=1:15
        load train;
        [scores indices] = feature_select(X,Y,m);
        % run KNN with K=1 using the selected features
        model = KNN('train', X(:,indices), Y, 1);
        load test;
        Ypred = KNN('predict', model, X(:,indices)); % important: test using only the selected features
        acc(m) = mean(Ypred==Y);
end
disp(acc);
