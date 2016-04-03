%% Open video and set parameters
vr = VideoReader('Person.wmv');
num_frames = floor(vr.Duration * vr.FrameRate);
F1 = read(vr, 1);

b = [ 1 1 50 40 ]; % bounding box
d0 = b(3) * b(4);
d = ceil(d0 * 0.01);

N_s = 4000; % number of particles
N_t = 20; % number of templates

alpha_std = 0.03;
t_std = 5;

lambda = 1; % parameter in computing the likelihood

% parameter for Customized OMP early stop
comp_eps = 0.01; 
comp_eta = ceil((N_t + 2 * d) * 0.01);

%% Initialize structures
S = create_particles(N_s);
A = initialize_templates(F1, b, N_t, d);
Phi = randn(d, d0);

%% Main loop
for k = 2:num_frames
    
    % Getting current frame
    F_k = read(vr, k);
    
    % Normalize every column of PhiA
    Phi_A = Phi * A;
    for i = 1:size(Phi_A, 2)
        col = Phi_A(:, i);
        Phi_A(:, i) = col / norm(col);
    end
    
    % Update particles
    S = update_particles(S, alpha_std, t_std);
    L = zeros(1, N_s);
    for i = 1:N_s
        % Get normalized mapped observation Phi_y corresponding to i-th particle
        y = affine_map(F_k, S(:, i), b);
        Phi_y = Phi * y;
        Phi_y = Phi_y / norm(Phi_y);
        
        % Solve x using Customized OMP
        x = comp(Phi_y, Phi_A, comp_eps, comp_eta);
        
        % Calculate residual
        r = norm(Phi_y - Phi_A * x);
        
        % Calculate observation likelihood
        L(i) = exp(-lambda * r);
    end
    
    % Estimate the new dynamic state
    s_k = sum(bsxfun(@times, S, L), 2) / sum(L);
    
    % Recalculate x
    y = affine_map(F_k, s_k, b);
    Phi_y = Phi * y;
    Phi_y = Phi_y / norm(Phi_y);
    x = comp(Phi_y, Phi_A, comp_eps, comp_eta);
    
    % Update templates
    A = update_templates(A, x);
    
    % Resampling
    S = resample_particles(S, L);

    % Showing Image
%    show_particles(S, b, F_k); 
    show_state_estimated(S, b, F_k);

end

