function [ y ] = affine_map( F, s, b )
%AFFINE_MAP
%Input:
%   F: current frame
%   s: affine parameters, [ a1, a2, a3, a4, t1, t2 ]
%   b: bounding box of the object in F1, in (x, y, w, h)
%Output:
%   y: mapped observation, size d0=w*h

% R = imref2d(size(F));
R = imref2d([b(4) b(3)], [b(1)+0.5 b(1)+b(3)+0.5], [b(2)+0.5 b(2)+b(4)+0.5]);
tform = affine2d([s(1) s(2) 0; s(3) s(4) 0; s(5) s(6) 1]);
% Fw = imwarp(F, invert(tform), 'OutputView', R);
% y = Fw(b(2):b(2)+b(4)-1, b(1):b(1)+b(3)-1);
y = imwarp(F, invert(tform), 'OutputView', R);
% figure; imshow(Fw);
% figure; imshow(y);
y = y(:);

end

