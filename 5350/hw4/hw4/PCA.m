function [Z,vecs,vals] = PCA(X,d)
  
% X is N*D input data, d is desired number of projection dimensions (assume
% d<D).  Return values are the projected data Z, which should be Nxd, vecs,
% the Dxd projection matrix (consisting of the top d eigenvectors of the data
% covariance matrix), and vals, which are the eigenvalues associated with the 
% dimensions
  
[N D] = size(X);

X = X';

if d > D,
  error('PCA: you are trying to *increase* the dimension!');
end;

% first, we have to center the data, so that the mean of each dimension p
% (or the original data) is zero.  in other words, mean(X(:,p))==0 for all p.

%TODO
for i=1:D
    mn = mean(X(i,:));
    % Tends to yield numbers like 1.5 e-15; CLOSE ENOUGH.
    X(i,:) = X(i,:) - mn;
end

% next, compute the covariance matrix C of the data

%TODO
C = (1/N) * X * X';

% compute the top d eigenvalues and eigenvectors of C... 
% hint: use 'eigs' if you're in matlab or 'eig' if you're in octave
% Store the d eigenvectors in an Dxd matrix called 'vecs'

%TODO
[vecs vals] = eig(C);
vecs = vecs(:,1:d);
vals = vals(:,1:d);

% now project the data (Z will be the Nxd matrix of projections)
% to d dimensions

disp(size(X));
disp(size(vecs));
Z = X'*vecs;
