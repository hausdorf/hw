function draw_digits(X,Y)

[N,D] = size(X);

if D ~= 784,
  error('images are the wrong size');
end;

if N > 40,
  error('too many images: max 40');
end;

DY = floor(sqrt(N));
DX = ceil(N/DY);

colormap([(0:63)'/63 (0:63)'/63 (0:63)'/63]);
for n=1:N,
  subplot(DY,DX,n);
  image(uint8(255*reshape(X(n,:),28,28)'));
  if nargin >= 2,
    title(sprintf('y=%d',Y(n)));
  end;
  axis off;
end;

