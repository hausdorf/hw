clear all;
data = load('hw1-train');
X = data(:,2:end);
Y = data(:,1);
data = load('hw1-test');
XX = data(:,2:end);
YY = data(:,1);
% run the standard Perceptron
[w b err] = perceptron(X,Y,XX,YY);
fprintf('The error of the standard Perceptron = %f\n',err);
% run the averaged Perceptron
[w b err_avg] = averaged_perceptron(X,Y,XX,YY);
fprintf('The error of the averaged Perceptron = %f\n',err_avg);
