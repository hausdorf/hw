function [Z,vecs,vals] = KPCA(X,d)
  
% X is NxD input data, d is desired number of projection dimensions (assumed
% d<D).  Return values are the projected data Z, which should be Nxd, vecs,
% the N*d projection matrix (the eigenvectors of the NxN kernel matrix), and 
% vals, which are the eigenvalues associated with the dimensions
  
[N D] = size(X);

if d > D,
  error('Kernel PCA: you are trying to *increase* the dimension!');
end;

% compute the NxN kernel matrix K from the data X
% we will use an RBF kernel here having a bandwidth 0.1
% RBF kernel for two examples xi and xj is defined as 
% exp(-||xi-xj||^2/(sigma^2))where sigma is the bandwidth parameter
% The (i,j)-th entry K(i,j) of the kernel matrix denotes the similarity 
% between example i and example j
%TODO
K = zeros(N,N);
for i=1:N
    for j=1:N
        K(i,j) = exp(norm(X(i,:) - X(j,:), 2));
    end
end

% now center the kernel matrix K that you computed above
% (see the slides from the class)
%TODO
ONE = zeros(N,N);
for i=1:N
    for j=1:N
        ONE(i,j) = 1.0 / N;
    end
end

KT = K - ONE*K - K*ONE + ONE*K*ONE;

% finally do eigendecomposition of K and take the top
% d eigenvalues and eigenvectors. Store the d eigenvectors
% in an Nxd matrix called 'vecs'

%TODO
[vecs vals] = eig(K);
vecs = vecs(1:d,:)';
vals = vals(1:d,:)';

% now project the data (Z will be the Nxd matrix of projections)
% to d dimensions

Z = K*vecs;
