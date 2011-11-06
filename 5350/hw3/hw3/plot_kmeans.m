function plot_kmeans(X,mu,z,score)
  
  [N D] = size(X);
  
  if nargin < 4,
    mu = mean(X);
    z  = ones(N,1);
    score = Inf;
  end;
  
  if D~=2,
    error('plot_kmeans: plotting only first two dimensions');
  end;
  
  colMu = ['bo';'ro';'ko';'mo';'go';'co';'yo'];
  colPt = ['bx';'rx';'kx';'mx';'gx';'cx';'yx'];
  
  hold on;
  allK = myunique(z);
  for ii=1:length(allK),
    % plot points
    
    plot(X(z==allK(ii), 1), ...
         X(z==allK(ii), 2), ...
         colPt(ii,:));
    
    % plot center
    plot(mu(ii,1), mu(ii,2), colMu(ii,:));
  end;
  
  title(sprintf('K=%d, score=%g', length(allK), score));
  hold off;
  