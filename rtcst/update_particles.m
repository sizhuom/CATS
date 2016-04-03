function S = update_particles(S, alpha_std, t_std)

N = size(S, 2);

S(1:4, :) = S(1:4, :) + alpha_std * randn(4, N);
S(5:6, :) = S(5:6, :) + t_std * randn(2, N);