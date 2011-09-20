function res = KNN(mode, varargin)
  % usage is one of the two following:
  %    model = KNN('train', X, Y, K); % X,Y are the labeled training data
  %    Y     = KNN('predict', model, X); % X is the test data. Y is the predictions
    
  switch lower(mode),
   case 'name'
    res = 'KNN';
    
   case 'train'
    if nargin ~= 4,
      error('training requires three arguments: X, Y and K');
    end
    % ma
    [NX,DX] = size(varargin{1});
    [NY,DY] = size(varargin{2});
    if NX ~= NY,
      error('there must be the same number of data points in X and Y');
    end;
    if DY ~= 1,
      error('Y must have only one column');
    end
    if ~isscalar(varargin{3}),
      error('K must be a scalar');
    end
    if (varargin{3} < 1),
      error('K must be strictly positive');
    end
    % return "model" -- for KNN this is really simple
    res = {};
    res.trainX = varargin{1};
    res.trainY = varargin{2};
    res.K      = varargin{3};
    
    
    
   case 'predict'
    % check arguments
    if nargin ~= 3,
      error('prediction requires two arguments: the model, and X');
    end;
    model = varargin{1};
    X = varargin{2};
    
    if ~isfield(model,'trainX') || ~isfield(model,'trainY') || ~isfield(model,'K'),
      error('model does not appear to be a KNN model');
    end;
    
    if size(X,2) ~= size(model.trainX,2),
      error('dimension mismatch');
    end;
    
    % set up output
    N = size(X,1);
    res = zeros(N,1);
    
    % compute predictions
    for n=1:N,
      res(n) = KNNpredict(model.trainX, model.trainY, model.K, X(n,:));
    end;
  
   otherwise
    error('unknown KNN mode: need "train" or "predict"');
  end;

  
  
function y = KNNpredict(trX,trY,K,X)
  % trX is NxD, trY is Nx1, K is 1x1 and X is 1xD
  % we return a single value 'y' which is the predicted class

  % TODO: write this function
    
