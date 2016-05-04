function [ score ] = calc_overlapAffn( R, vr, params )

truth = vr.Truth(:, params.start_frame:params.end_frame);
u = [1 1 truth(3) truth(3)];
v = [1 truth(4) truth(4) 1];
score = [];

for i = 1:size(R, 2)
    s = R(:, i);
    tform = affine2d([s(1) s(2) 0; s(3) s(4) 0; s(5) s(6) 1]);
    [x, y] = transformPointsForward(tform, u, v);
    xmin = min(x); xmax = max(x);
    ymin = min(y); ymax = max(y);
    box = [xmin, ymin, xmax-xmin+1, ymax-ymin+1];
    overlap = rectint(box, truth(:, i)');
    area_R = box(3) * box(4);
    area_T = truth(3, i) * truth(4, i);
    new_score = overlap ./ (area_R + area_T - overlap);
    score = [score new_score];
end


end

