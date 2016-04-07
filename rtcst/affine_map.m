function [ y ] = affine_map( F, s, b )
%AFFINE_MAP
%Input:
%   F: current frame
%   s: affine parameters, [ a1, a2, a3, a4, t1, t2 ]
%   b: bounding box of the object in F1, in (x, y, w, h)
%Output:
%   y: mapped observation, size d0=w*h

tform = affine2d([s(1) s(2) 0; s(3) s(4) 0; s(5) s(6) 1]);
Fw = imwarp(F, invert(tform));
y = Fw(b(1):b(1)+b(3)-1, b(2):b(2)+b(4)-1);
y = y(:);

end

