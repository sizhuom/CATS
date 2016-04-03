function [ y ] = affine_map( F, s, b )
%AFFINE_MAP
%Input:
%   F: current frame
%   s: affine parameters, [ a1, a2, a3, a4, t1, t2 ]
%   b: bounding box of the object in F1, in (x, y, w, h)
%Output:
%   y: mapped observation, size d0=w*h

d0 = b(3) * b(4);

end

