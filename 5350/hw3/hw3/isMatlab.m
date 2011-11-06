function b = isMatlab()
versionIds = version=='7';
if versionIds(1),
  b = 1;
else
  b = 0;
end;
