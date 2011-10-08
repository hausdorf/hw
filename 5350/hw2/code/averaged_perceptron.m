function [w b err_avg] = averaged_perceptron(X,Y,XX,YY)
% X is NxD training data, Y is Nx1 training labels
% XX is test data, YY is test labels (ground truth)
% w is the averaged Perceptron weight vector, b is the bias, err_avg is 
% the error on the test data
    [X,XX] = normalizeData(X,XX); % just a preprocessing step
    [N D] = size(X);
    % initialized w and b
    w = zeros(1,D);
    b = 0;
    
    % note: refer to the homework PDF to understand how the averaged
    % Perceptron differs from the standard Perceptron, and implement
    % accordingly
    for iter=1:10
        for n=1:N
            % TODO: Replace the ????? with the perceptron mistake condition
            if(?????)
                % TODO: Update w
                % TODO: Update b
            end
        end
    end
    % TODO: Use the Perceptron prediction rule and compute the error (call it 
    % 'err_avg') on the test data XX (note YY are the true labels that you'll 
    % compare your predictions with) 
    err_avg = ???; % 
    
function [X,XX] = normalizeData(X,XX)
  % center
  mu = mean(X,1);
  X  = X  - repmat(mu, size(X ,1), 1);
  XX = XX - repmat(mu, size(XX,1), 1);
  
  % project down to sphere
  X  = X  ./ repmat(sqrt(sum(X .*X ,2)), 1, size(X ,2));
  XX = XX ./ repmat(sqrt(sum(XX.*XX,2)), 1, size(XX,2));