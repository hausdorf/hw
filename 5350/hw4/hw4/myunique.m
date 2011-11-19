function x = myunique(x)
  x  = sort(x);
  ii = 1;
  while ii < length(x),
    if x(ii) == x(ii+1),
      x(ii) = [];
    else
      ii = ii + 1;
    end;
  end;
  