% first, load the results if they exist
h = fopen('pca_results.mat','rb');  % open to check if the file exists
if h >= 0,  % open successful -- read data
  fclose(h);
  fprintf('loading data from results.mat\n'); myflush;
  load pca_results;
else  % otherwise, start from beginning
  fprintf('initializing empty results\n'); myflush;
  pca_results = {};
end;

fname = 'mnist';
fprintf('loading data from %s.mat\n', fname); myflush;
load(fname);
X = trainX;
Y = trainY;

fprintf(['Next, we run PCA and project down to three dimensions.  We will\n' ...
         'plot all pairs of dimensions so we can get a sense of how things\n' ...
         'break down.\n\n']);
myflush;
mypause;

if ~isfield(pca_results, 'pcavecs'),
  tic
  [Z,vecs,vals] = PCA(X,50);   % for now, do 50 dimensions just so we get the eigenvalues
  pca_results.pcaZ = Z;
  pca_results.pcavecs = vecs;
  pca_results.pcavals = vals;
  toc
  
  mysave(pca_results);
end;


figure(1);
plot(1:50, pca_results.pcavals, 'bx-');
title('fig 1: PCA eigenvalues');
xlabel('dimensionality');
ylabel('eigenvalue');
mysaveas(figure(1), 'pca_fig1.pdf');

figure(2);
Z = pca_results.pcaZ;
colors = ['bx';'rx';'kx';'mx';'gx';'cx';'yx'];
subplot(1,3,1);
plot(Z(:,1), Z(:,2), 'w.');
hold on;
for y=1:5,
  plot(Z(Y==y,1), Z(Y==y,2), colors(y,:));
end;
hold off;
title('blue=1, red=2');

subplot(1,3,2);
plot(Z(:,3), Z(:,2), 'w.');
hold on;
for y=1:5,
  plot(Z(Y==y,3), Z(Y==y,2), colors(y,:));
end;
hold off;
title('black=3');

subplot(1,3,3);
plot(Z(:,1), Z(:,3), 'w.');
hold on;
for y=1:5,
  plot(Z(Y==y,1), Z(Y==y,3), colors(y,:));
end;
hold off;
title('magenta=4, green=5');
mysaveas(figure(2), 'pca_fig2.pdf');

mypause


fprintf(['Now, we look at restorations of the original images based on the\n' ...
         'PCA eigen-decomposition.\n\n']);

myflush;

allD = [3 6 12 25 50];
for ii=1:length(allD),
  N = size(X,1);
  XX = Z(:,1:allD(ii))*(pinv(Z(:,1:allD(ii)))*(X-ones(N,1)*mean(X)))+ones(N,1)*mean(X);
  err = sum(sum((X-XX).*(X-XX))) / prod(size(X));
  figure(2+ii);
  %title(sprintf('fig %d: restored images with %d dims'));
  if isMatlab,
    draw_digits(XX(1:15:end,:), Y(1:15:end));
  end;
  mysaveas(figure(2+ii), sprintf('pca_fig%d.pdf', 2+ii));
  fprintf('  dim %d --> sum eig %g --> restoration error %g\n', allD(ii), sum(pca_results.pcavals(1:allD(ii))), err);
end;

jj = 2+ii+1;

