function S_new = update_particles(S, s_k, param_std)

sc			= sqrt(sum(s_k(1:4).^2)/2);
std_aff		= param_std.*[1, sc, sc, 1, sc, sc];
% std_aff = param_std;
    
nsamples = size(S, 2);
S(1, :) = log(S(1, :));
S(4, :) = log(S(4, :));

S_new = bsxfun(@times, randn([6, nsamples]), std_aff') ...
    + S;

S_new(1, :) = exp(S_new(1, :));
S_new(4, :) = exp(S_new(4, :));
