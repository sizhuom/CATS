function [ T, i ] = update_templates( T, Nt, x, y, tau )
%UPDATE_TEMPLATES
%Input:
%   T: old templates
%   Nt: number of nontrivial templates
%   x: sparse coefficients
%   y: currently tracked target
%   tau: threshold to replace a template
%Output:
%   T_new: new templates
%   i: index of the templated replaced. 0 if none

i = 0;
xn = x(1:Nt);
sci = norm(xn, 1) / norm(x, 1)
if (sci < tau)
    idx = find(xn == 0);
    i = idx(randi(length(idx)));
    T(:, i) = y;
end

end

