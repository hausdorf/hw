clear;
load data;
model = perceptron_weighted('train', trX, trY, ones(size(trY)));
fprintf('Base Classifier training accuracy = %f\n', mean(trY == perceptron_weighted('predict', model, trX)));
fprintf('Base classifer test accuracy = %f\n', mean(teY == perceptron_weighted('predict', model, teX)));

for t=1:10
	boost = Boost('train', @perceptron_weighted, trX, trY, t);
	fprintf('Number of boosting rounds = %d\n',t);
	fprintf('After boosting, training accuracy = %f\n', mean(trY == Boost('predict', @perceptron_weighted, boost, trX)));
	fprintf('Atfer boosting, test accuracy = %f\n', mean(teY ==  Boost('predict', @perceptron_weighted, boost, teX)));
end
