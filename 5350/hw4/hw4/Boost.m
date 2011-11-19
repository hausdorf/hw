function res = Boost(mode, learn, varargin)
% usage is one of the two following:
%   boost = Boost('train', @learner, X, Y, numRounds, learner-args)
%   Y     = Boost('predict', @learner, boost, X, numRounds) -- numRounds is optional
  
  switch lower(mode),
    case 'name',
      res = 'Boost';
      
    case 'train',
      if nargin < 5,
        error('Boost training requires at least five arguments');
      end;
      
      [NX,DX] = size(varargin{1});
      [NY,DY] = size(varargin{2});
      
      if NX ~= NY,
        error('Boost: there must be the same number of data points in X and Y');
      end;
      if DY ~= 1,
        error('Boost: Y must have only one column');
      end
      if ~all(varargin{2}==-1 | varargin{2}==1),
        error('boosting only defined for binary (-1/1) problems');
      end;

      res = BoostTrain(learn, varargin{1}, varargin{2}, varargin{3}, varargin{4:end});
      
      
    case 'predict',
      % check arguments
      if nargin ~= 4 && nargin ~= 5,
        error('Boost: prediction requires three (or four) arguments: the learner, model, and X (and maybe numRounds)');
      end;
      boost = varargin{1};
      X     = varargin{2};
      maxRounds = length(boost.alphas);
      if nargin == 5 && varargin{3} < maxRounds, 
        maxRounds = varargin{3}; 
      end;
    
      % compute predictions
      res = BoostPredict(learn, boost, X, maxRounds);
  
    otherwise
      error('unknown mode');
  end;
      
  
function boost = BoostTrain(learn, X, Y, numRounds, varargin)
  % as usual, X is N*D, Y is N*1.  'learn' is the "weak learner",
  % numRounds is the number of rounds of boosting we should run, and
  % varargin are arguments that we should pass to 'learn'.
  
  % initialize our output: boost will contain three fields: models,
  % alphas and errors.  these will each be (at most) numRounds long.  the
  % models field will store the binary classifiers.  the alphas field
  % will store the alphas associated with each iteration, and the errors
  % field will store the associated error rate
  boost = {};
  boost.models = {};
  boost.alphas = {};
  boost.errors = {};
 
  N = length(Y);      % how many examples are there?
  
  W = ones(N,1) / N;  % initialize to uniform instance weights
  
  for t=1:numRounds,
    fprintf('+'); myflush;
    
    % compute hypothesis... that is, we train a weak learning on X/Y,
    % with instance weights given by W.  the following command does this
    % and returns a classifier 'h':
    h = feval(learn, 'train', X, Y, W, varargin{:});

    
    % now we need to boost.  in order to do this, we first compute the
    % predictions of the weak learner that we just trained on X:
    P = feval(learn, 'predict', h, X);
    
    % TODO: next, compute the error 'e' associated with this weak learner:
    e = ???;
  
    % store this in the "error"
    boost.errors{t} = e;
    
    % if the error is too high, stop.
    if e >= 0.5,
      break;
    end;
    
    % TODO: compute alpha and update weights
    a = ???;
    W = ???;
    
    % store
    boost.models{t} = h;
    boost.alphas{t} = a;
  end;

function Y = BoostPredict(learn, boost, X, maxRounds)
  % learn is the base learner (see BoostTrain to see how to call
  % prediction), boost is the learned boost model (it contains fields
  % like models, alphas, etc.), X is the N*D data to predict, and
  % maxRounds is the maximum number of boosting rounds we should use
  % (i.e., even if the length of boost.models is longer).
  
  N = size(X,1);
  
  % store our output variables
  Y = zeros(N,1);

  % compute predictions...
  for t=1:maxRounds,
    % TODO: make predictions and update Y
  end;
  
  
