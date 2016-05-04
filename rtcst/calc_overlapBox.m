function [ score ] = calc_overlapBox( R, vr, params )

truth = vr.Truth(:, params.start_frame:params.end_frame);
overlap = rectint(R', truth')';
area_R = (R(3, :) .* R(4, :));
area_T = (truth(3, :) .* truth(4, :));
score = overlap ./ (area_R + area_T - overlap);

end

