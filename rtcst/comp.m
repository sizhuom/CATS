function [ x ] = comp( y, A, eps, eta )
%COMP : Customized OMP
%Input:
%   y: a normalized observation of length d
%   A: a mapped template set of size d*n
%   eps: a recovery residual, 0 < eps << 1
%   eta: sparsity, 0 < eta << n
%Output:
%   x: recovered coefficients, length n

d = size(A, 1);
n = size(A, 2);
r = y;
L = zeros(eta, 1);
P = zeros(d, eta);

for t = 1:eta
    [~, l] = max(r' * A);
    L(t) = l;
    P(:, t) = A(:, l);
    xt = P(:, 1:t) \ y;
    r = y - P(:, 1:t) * xt;
    if norm(r) < eps
        break;
    end
end

x = zeros(n, 1);
x(L(1:t)) = xt;

end

