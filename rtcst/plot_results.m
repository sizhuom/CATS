addpath('..');

% test_set = 'Car4';
test_set = 'Car1';
vr = ImageReader(['../images/' test_set]);
load(['../images/' test_set '.mat']);

centErr = calc_centErrAffn(R, vr, params);
figure;
plot(centErr);

overlap = calc_overlapAffn(R, vr, params);
figure;
plot(overlap);