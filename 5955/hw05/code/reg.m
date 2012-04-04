load M.dat
[m,n] = size(M)

% Question 1
for k = 1:10
	[U,S,V] = svd(M);
	Uk = U(:, 1:k);
	Sk = S(1:k, 1:k);
	Vk = V(:,1:k);
	Mk = Uk*Sk*Vk';

	fprintf('k, norm: %d, %f\n', k, norm(M-Mk,2));
end

% Question 2
% find top t rows by L2 norm
for t = 1:30
	Cs = [];
	for j = 1:n
		c = M(:,j);
		sj = norm(c)^2;
		Cs = [Cs' [sj; j]]';
	end
	srtCs = sortrows(Cs, -1);
	toptCs = srtCs(1:t,:);

	[a,b] = size(toptCs);
	C = [];
	for i = 1:a
		C = [C M(:,toptCs(i,2))];
	end

	P = C*inverse(C'*C)*C';
	norm(M-P*M,2)
end

% find 
[U,S,V] = svd(M);
k = 5;
for t = 1:30
	Ws = [];
	for j = 1:n
		Uk = U(:,1:k);
		wj = norm(Uk*Uk'*M(:,j))^2;
		Ws = [Ws' [wj; j]]';
	end
	srtWs = sortrows(Ws, -1);
	toptWs = srtWs(1:t,:);

	[a,b] = size(toptWs);
	C = [];
	for i = 1:a
		C = [C M(:,toptWs(i,2))];
	end

	P = C*inverse(C'*C)*C';
	norm(M-P*M,2)
end

