function [acc,ri,pre,rec,fsc,nes,vi,nvi] = cluster_eval(Y,z)
  
  N = length(Y);
  if length(z) ~= N,
    error('cluster_eval: mismatched sizes');
  end;

  % compute rand index
  ri = 0;
  for n=1:N,
    for m=(n+1):N,
      if (Y(n)==Y(m)) == (z(n)==z(m)),
        ri = ri+1;
      end;
    end;
  end;
  ri = ri * 2 / N / (N-1);

  % compute precision/recall/fscore
  nT = 0;
  nH = 0;
  nI = 0;
  for n=1:N,
    for m=(n+1):N,
      if Y(n) == Y(m),
        nT = nT + 1;
      end;
      if z(n) == z(m),
        nH = nH + 1;
        if Y(n) == Y(m),
          nI = nI + 1;
        end;
      end;
    end;
  end;
  pre = 1; rec = 1; fsc = 1;
  if nH > 0, pre = nI / nH; end;
  if nT > 0, rec = nI / nT; end;
  if nH+nT>0, fsc = 2*pre*rec/(pre+rec); end;

  % compute normalized edit score
  nes = 1 - (ced(Y,z) + ced(z,Y)) / 2 / N;
  
  % compute variation of information
  hY = 0; hz = 0; mi = 0;
  for k=myunique(z)',
    pk = sum(z==k) / N;
    hz = hz - plogp(pk);
  end;
  for k=myunique(Y)',
    pk = sum(Y==k) / N;
    hY = hY - plogp(pk);

    for k2=myunique(z)',
      pk2 = sum(z==k2) / N;
      pkk = sum(Y==k & z==k2) / N;
      mi = mi + plogp(pkk) - plogp(pkk,pk) - plogp(pkk,pk2);
    end;
  end;
  vi  = hY + hz - 2 * mi;
  nvi = 1 - vi / log(N);
  
  
  % accuracy is defined as vi
  acc = nvi;

function v = plogp(p,q)
  if nargin < 2, q = p; end;
  if p <= 0,
    v = 0;
  else
    v = p * log(q);
  end;
  
function v = ced(Y,z)
  N  = length(Y);
  
  kY = myunique(Y)';
  kz = myunique(z)';
  
  bucket = zeros(N,1);
  for k=kY,
    % find most similar cluster
    bestK2 = -1;
    bestS  = -Inf;
    for k2=kz,
      s = sum(Y==k & z==k2);
      if s > bestS,
        bestS  = s;
        bestK2 = k2;
      end;
    end;
    bucket(z==bestK2) = k;
  end;
  
  v = sum(Y ~= bucket);
