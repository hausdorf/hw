versionIds = version=='7';
if versionIds(1),
  % looks like matlab -- do nothing
else
  % looks like octave -- flush
  fflush(1);
end;
