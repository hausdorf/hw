function res = KNN(type, varargin)
  % usage is one of the two following:
  %    model = KNN('train', X, Y, K); % X,Y are the labeled training data
  %    Y     = KNN('predict', model, X); % X is the test data. Y is the predictions
    
  switch lower(type),
   case 'name'
    disp('HERE');
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



% Computes \ell_2 of two D-length vectors x and y
function dist = eucdist(x, y)
  % Pointwise subtract of features
  z = x - y;

  % Sum up squares of features
  total = 0;
  for n = 1:size(z,2)
      total = z(n) * z(n);
  end

  % Return square root of the sum of squares
  dist = sqrt(total)


function y = KNNpredict(trX,trY,K,X)
  % run: disp( KNN('predict', KNN('train', training(:, 2:end), training(:,1), 3), test(1, 2:end)) );
  % trX is NxD, trY is Nx1, K is 1x1 and X is 1xD
  % we return a single value 'y' which is the predicted class

  % TODO: write this function
  dist = eucdist([5 7 9], [2 3 4]);
  
  y = 10;
