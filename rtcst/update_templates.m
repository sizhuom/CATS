function [ T ] = update_templates( T, Nt, x, y, tau )
%UPDATE_TEMPLATES
%Input:
%   T: old templates
%   Nt: number of nontrivial templates
%   x: sparse coefficients
%   y: currently tracked target
%   tau: threshold to replace a template
%Output:
%   T_new: new templates

xn = x(1:Nt);
[min_val, min_idx] = min(abs(xn));
min_sci = min_val / norm(xn, 1);
if (min_sci < tau)
    T(:, min_idx) = y;
end

end

