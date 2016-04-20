function S = resample_particles(S, L)

Q = L / sum(L, 2);
R = cumsum(Q, 2);

N = size(S, 2);
T = rand(1, N);

[~, I] = histc(T, R);
S = S(:, I + 1);
