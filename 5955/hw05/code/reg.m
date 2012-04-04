load M.dat
[m,n] = size(M);


% Question 1
for k = 1:10
	[U,S,V] = svd(M);
	Uk = U(:, 1:k);
	Sk = S(1:k, 1:k);
	Vk = V(:,1:k);
	Mk = Uk*Sk*Vk';

	% Here is the answer
	%fprintf('k, norm: %d, %f\n', k, norm(M-Mk,2));
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
	% Here is the answer
	norm(M-P*M,2);
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
	% Here is the answer
	norm(M-P*M,2);
end


% Question 3
load X.dat
load Y.dat
s = [0.1, 0.3, 0.5, 1.0, 2.0];
[_, d] = size(s);
[xr, xd] = size(X);
[yr, yd] = size(Y);
% Part A
A = inverse(X' * X)*X'*Y;

% Here is the answer
norm(Y-X*A,2);

for i = 1:d
	As = inverse(X' * X + s(i)*eye(6))*X'*Y;
	% Here is the answer
	norm(Y-X*As,2);
end


% PART B
X1 = X(1:8, :);
Y1 = Y(1:8);
A = inverse(X1' * X1)*X1'*Y1;
% Here is the answer
norm(Y(9:10)-X(9:10, :)*A,2);
for i = 1:d
	As = inverse(X1' * X1 + s(i)*eye(6))*X1'*Y1;
	% Here is the answer
	norm(Y(9:10)-X(9:10, :)*As,2);
end


X2 = X(3:10, :);
Y2 = Y(3:10);
A = inverse(X2' * X2)*X2'*Y2;
% Here is the answer
norm(Y(1:2)-X(1:2, :)*A,2);
for i = 1:d
	As = inverse(X2' * X2 + s(i)*eye(6))*X2'*Y2;
	% Here is the answer
	norm(Y(1:2)-X(1:2, :)*As,2);
end


X3 = [X(1:4, :); X(7:10, :)];
Y3 = [Y(1:4); Y(7:10)];
A = inverse(X3' * X3)*X3'*Y3;
% Here is the answer
norm(Y(5:6)-X(5:6, :)*A,2);
for i = 1:d
	As = inverse(X3' * X3 + s(i)*eye(6))*X3'*Y3;
	% Here is the answer
	norm(Y(5:6)-X(5:6, :)*As,2);
end
