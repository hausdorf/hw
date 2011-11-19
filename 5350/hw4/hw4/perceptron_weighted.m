function res = perceptron_weighted(mode, varargin)
  % usage is one of the two following:
  %    model = perceptron('train', X, Y, weights);
  %    Y     = perceptron('predict', model, X);

  switch lower(mode),
   case 'name'
    res = 'perceptron';
    
   case 'train'
    if nargin ~= 4,
      error('training requires three arguments: X, Y and weights');
    end

    X = varargin{1};
    Y = varargin{2};
    W = varargin{3};
    
    [NX,DX] = size(X);
    [NY,DY] = size(Y);
    [NW,DW] = size(W);
    if NX ~= NY,
      error('there must be the same number of data points in X and Y');
    end;
    if NX ~= NW,
      error('there must be the same number of data points in X and W');
    end;
    if DY ~= 1,
      error('Y must have only one column');
    end
    if DW ~= 1,
      error('W must have only one column');
    end


    % return "model" -- for DT, we have to build it
    res = {};
    [res.weights,res.bias] = trainPerceptron(X, sign(Y-0.5), W);
    
    
   case 'predict'
    % check arguments
    if nargin ~= 3,
      error('prediction requires two arguments: the model, and X');
    end;
    model = varargin{1};
    X = varargin{2};
    
    if ~isfield(model,'weights'),
      error('model does not appear to be a perceptron model');
    end;
    if ~isfield(model,'bias'),
      error('model does not appear to be a perceptron model');
    end;
    
    % set up output
    N = size(X,1);
    res = zeros(N,1);
    
    % compute predictions
    for n=1:N,
      res(n) = predictPerceptron(model.weights, model.bias, X(n,:));
    end;
  
   otherwise
    error('unknown perceptron mode: need "train" or "predict"');
  end;

  
function [w,b] = trainPerceptron(trX, trY, W)
  [N D] = size(trX);
  w = zeros(D,1);
  b = 0;
  % run 10 iteration
  for iter=1:3
  for n=1:N,
    if sign(trY(n) * (trX(n,:) * w + b)) <= 0,
      % if error, update
      w = w + trY(n) * W(n) * trX(n,:)';
      b = b + trY(n) * W(n);
    end;
  end;
  end
  
  
function y = predictPerceptron(w, b, X)
  y = sign(X*w+b);
  
