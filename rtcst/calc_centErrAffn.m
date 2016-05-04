function [ err ] = calc_centErrAffn( R, vr, params )

truth = vr.Truth(:, params.start_frame:params.end_frame);
u = (1 + truth(3, 1)) / 2;
v = (1 + truth(4, 1)) / 2;
err = [];
for i = 1:size(R, 2)
    s = R(:, i);
    tform = affine2d([s(1) s(2) 0; s(3) s(4) 0; s(5) s(6) 1]);
    [x, y] = transformPointsForward(tform, u, v);
    tx = truth(1, i) - 0.5 + truth(3, i) / 2;
    ty = truth(2, i) - 0.5 + truth(4, i) / 2;
    dist = norm([x y] - [tx ty]);
    err = [err dist];
end

end

