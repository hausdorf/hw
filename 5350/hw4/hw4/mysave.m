function mysave(results)

if isMatlab,
  % save in v6 compatible version
  save -v6 'results.mat' results;
else
  % save in matlab-compatible version
  save -mat 'results.mat' results;
end;
