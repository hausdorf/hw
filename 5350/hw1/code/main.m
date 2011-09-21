train = load('hw1-train');
test = load('hw1-test');
dev = load('hw1-dev');

total = size(test,1);
correct = 0;
for n = 1:size(dev,1)
    model = KNN('train', train(:,2:end), train(:,1), 7);
    y = KNN('predict', model, dev(n,2:end));

    if y == dev(n,1)
        correct = correct + 1;
    end
end
disp(total);
disp(correct);
