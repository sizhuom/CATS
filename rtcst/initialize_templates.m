function [ A ] = initialize_templates( F1, b, Nt, d )
%INITIALIZE_TEMPLATES
%Input:
%   F1: first frame of the video
%   b: bounding box of the object in F1, in (x, y, w, h)
%   Nt: number of (non-trivial) templates
%   d: reduced dimension of the observation
%Output:
%   A: templates matrix, size d0*(Nt+2d)

d0 = b(3) * b(4);

end

