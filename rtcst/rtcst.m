%% Setup
addpath('..');

%% Open video and set parameters
%vr = VideoReader('Person.wmv');
vr = ImageReader('../images/Dog');
num_frames = floor(vr.Duration * vr.FrameRate);
F1 = im2double(rgb2gray(read(vr, 1)));

% b = [ 1 1 50 40 ]; % bounding box
b = vr.Truth(:, 1);
show_box(F1, b);

d0 = b(3) * b(4);
d = 100;

N_s = 200; % number of particles
N_t = 100; % number of templates

alpha_std = 0.03;
t_std = 5;

lambda = 100; % parameter in computing the likelihood

% parameter for Customized OMP early stop
comp_eps = 0.01; 
comp_eta = d/2;

% parameter for updating templates
sci_thresh = 0.1;

%% Initialize structures
S = create_particles(N_s);
A = initialize_templates(F1, b, N_t);
Phi = randn(d, d0);

%% Main loop
for k = 2:num_frames
    
    % Getting current frame
    F_k = read(vr, k);
    F_k = im2double(rgb2gray(F_k));
    
    % Normalize every column of PhiA
    Phi_A = Phi * A;
    for i = 1:size(Phi_A, 2)
        col = Phi_A(:, i);
        col = col - mean(col);
        Phi_A(:, i) = col / norm(col);
    end
    
    % Update particles
    S = update_particles(S, alpha_std, t_std);
    L = zeros(1, N_s);
    for i = 1:N_s
        % Get normalized mapped observation Phi_y corresponding to i-th particle
        y = affine_map(F_k, S(:, i), b);
        y = y - mean(y);
        y = y / norm(y);
        Phi_y = Phi * y;
        Phi_y = Phi_y - mean(Phi_y);
        Phi_y = Phi_y / norm(Phi_y);
        
        % Solve x using Customized OMP
        x = comp(Phi_y, Phi_A, comp_eps, comp_eta);
        
        % Calculate residual
        r = norm(Phi_y - Phi_A * x);
        
        % Calculate observation likelihood
        L(i) = exp(-lambda * r);
        
%         find(x>0)
%         r
%         L(i)
%         waitforbuttonpress;
%         close all;
%         break;
    end
    
    % Estimate the new dynamic state
    s_k = sum(bsxfun(@times, S, L), 2) / sum(L);
    
    % Recalculate x
    y = affine_map(F_k, s_k, b);
    Phi_y = Phi * y;
    Phi_y = Phi_y / norm(Phi_y);
    x = comp(Phi_y, Phi_A, comp_eps, comp_eta);
    
    % Update templates
    A = update_templates(A, N_t, x, y, sci_thresh);
    
    % Resampling
    S = resample_particles(S, L);

    % Showing Image
    show_particles(S, b, F_k); 
%     show_state_estimated(s_k, b, F_k);
    
%     break;

end

