function [ err ] = calc_centErrBox( R, vr, params )

truth = vr.Truth(:, params.start_frame:params.end_frame);
err = [];
for i = size(R, 2)
    x = R(1, i) - 0.5 + R(3, i) / 2;
    y = R(2, i) - 0.5 + R(4, i) / 2;
    tx = truth(1, i) - 0.5 + truth(3, i) / 2;
    ty = truth(2, i) - 0.5 + truth(4, i) / 2;
    dist = norm([x y] - [tx ty]);
    err = [err dist];
end


end

