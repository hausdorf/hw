X = load('test_kmeans.txt');


fprintf('First, we just plot some data...\n\n');
myflush;

figure(1); title('figure 1');
plot_kmeans(X);

mypause;



fprintf(['Now, we test the K=2 implementation of kmeans; if this looks\n' ...
         'totally unreasonable, you probably have a bug.  We use (totally)\n' ...
         'random initialization...\n\n']);

myflush;

figure(2); title('figure 2');
[mu,z,score] = kmeans(X,2);
plot_kmeans(X,mu,z,score);

mypause;



fprintf(['Now, we run sixteen times with different initializations and\n' ...
         'compare the scores.  For this, we will run with K=3, which seems\n' ...
         'more reasonable for this data...\n\n']);
myflush;

figure(3); title('figure 3');
for ii=1:16,
  [mu,z,score] = kmeans(X,3);
  subplot(4,4,ii);
  plot_kmeans(X,mu,z,score);
end;
mypause;




fprintf(['Now, we run sixteen times with different (furthest) initializations\n' ...
         'and compare the scores.  For this, we will run with K=3, which\n' ...
         'seems more reasonable for this data...\n\n']);
myflush;

figure(4); title('figure 4');
for ii=1:16,
  [mu,z,score] = kmeans(X,3,'furthest');
  subplot(4,4,ii);
  plot_kmeans(X,mu,z,score);
end;
mypause;



fprintf('Finally, we consider score as a function of K...\n\n');
myflush;

allK = [2 3 4 5 6 8 10 15 20];
allS = Inf + zeros(size(allK));
allMu = {}; allZ = {};
for ii=1:length(allK),
  fprintf('  k=%d...', allK(ii)); myflush;
  for rep=1:20,
    [mu,z,score] = kmeans(X,allK(ii),'furthest');
    if score < allS(ii),
      allS(ii) = score;
      allMu{ii} = mu;
      allZ{ii} = z;
    end;
  end;
end;
fprintf('\n');
figure(5); title('figure 5');
plot(allK,allS,'bx-');
xlabel('K'); ylabel('score');


figure(6); title('figure 6');
for ii=1:5,
  subplot(2,3,ii);
  plot_kmeans(X,allMu{ii},allZ{ii},allS(ii));
end;
mypause;
