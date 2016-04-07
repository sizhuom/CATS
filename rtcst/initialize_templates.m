function [ A ] = initialize_templates( F1, b, Nt )
%INITIALIZE_TEMPLATES
%Input:
%   F1: first frame of the video
%   b: bounding box of the object in F1, in (x, y, w, h)
%   Nt: number of (non-trivial) templates
%   d: reduced dimension of the observation
%Output:
%   A: templates matrix, size d0*(Nt+2d0)

% initialization
H = size(F1, 1);
W = size(F1, 2);
d0 = b(3) * b(4);
x1 = b(1); y1 = b(2); x2 = b(1)+b(3)-1; y2 = b(2)+b(4)-1;
A = zeros(d0, Nt+2*d0);

% target template set 
% first template is defined by the bounding box
t = F1(y1:y2, x1:x2);
A(:, 1) = normalize(t);
% then generate the rest by shifting one pixel each time
ds = 1;
dx = -1;
dy = 0;
i = 1;
while i <= Nt
    x1n = x1 + dx; x2n = x2 + dx;
    y1n = y1 + dy; y2n = y2 + dy;
    if ~(x1n < 0 || x2n > W || y1n < 0 || y2n > H)
        i = i + 1;
        t = F1(y1n:y2n, x1n:x2n);
        A(:, i) = normalize(t);
    end
    
    if dy >= 0
        dx = dx + 1;
        if dx > ds
            ds = ds + 1;
            dx = -ds;
        end
        dy = -(ds - abs(dx));
    else
        dy = -dy;
    end
end
    
% trivial templates
A(:, Nt+1:Nt+d0) = eye(d0);
A(:, Nt+d0+1:Nt+2*d0) = -eye(d0);

end

function t_n = normalize(t)
t_n = t(:);
t_n = t_n - mean(t_n);
t_n = t_n / norm(t_n);
end