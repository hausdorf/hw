train = load('hw1-train');
test = load('hw1-test');
dev = load('hw1-dev');
file = fopen('out', 'w');

for t = [1:2:20]
    total = size(dev,1);
    correct = 0;

    for n = 1:size(dev,1)
        %for n = 1:1
        model = KNNweighted('train', train(:,2:end), train(:,1), t);
        y = KNNweighted('predict', model, dev(n,2:end));

        if y == dev(n,1)
            correct = correct + 1;
        end
    end
    fprintf(file, 'K %.0f\tTotal %f\tcorrect %f\tPercent %f\n', t, total, correct, correct/total);
end

disp(total);
disp('CORRECT');
disp(correct);
