%% Setup
addpath('..');

%% Open video and set parameters
% vr = VideoReader('Person.wmv');
vr = ImageReader('../images/Dog');
% vr = ImageReader('../images/Basketball');
% vr = ImageReader('../images/BlurCar2');
% vr = ImageReader('../images/Car4');
num_frames = floor(vr.Duration * vr.FrameRate);
F_1 = read(vr, 1);
if (size(F_1, 3) > 1)
    F_1 = rgb2gray(F_1);
end
F_1 = im2double(F_1);

% b = [ 1 1 50 40 ]; % bounding box
b = vr.Truth(:, 1);
show_box(F_1, b);

d0 = b(3) * b(4);
d = 100;

N_s = 200; % number of particles
N_t = 100; % number of templates

alpha_std = 0;
t_std = 5;

lambda = 3; % parameter in computing the likelihood

% parameter for Customized OMP early stop
comp_eps = 0.01; 
comp_eta = d/2;

% parameter for updating templates
sci_thresh = 0.3;

%% Initialize structures
S = create_particles(N_s);
T = initialize_templates(F_1, b, N_t);
% E = [eye(d0) -eye(d0)];
% A = [T E];
E = [eye(d) -eye(d)];
Phi = randn(d, d0);
L = ones(1, N_s);

%% Main loop
for k = 2:num_frames
    % Getting current frame
    F_k = read(vr, k);
    if (size(F_k, 3) > 1)
        F_k = rgb2gray(F_k);
    end
    F_k = im2double(F_k);
%     F_k = F_1;
    
    % Normalize every column of PhiA
    Phi_A = [Phi*T, E];
    for i = 1:size(Phi_A, 2)
        col = Phi_A(:, i);
        col = col - mean(col);
        Phi_A(:, i) = col / norm(col);
    end
    
    % Update particles
    S = update_particles(S, alpha_std, t_std);
    for i = 1:N_s
        % Get normalized mapped observation Phi_y corresponding to i-th particle
        y = affine_map(F_k, S(:, i), b);
        y = y - mean(y);
        y = y / norm(y);
        if (sum(isnan(y)) > 0)
            L(i) = 0;
            continue;
        end
        Phi_y = Phi * y;
        Phi_y = Phi_y - mean(Phi_y);
        Phi_y = Phi_y / norm(Phi_y);
        
        % Solve x using Customized OMP
        x = comp(Phi_y, Phi_A, comp_eps, comp_eta);
        
        % Calculate residual
        x_t = zeros(size(x));
        x_t(1:N_t) = x(1:N_t);
        r = norm(Phi_y - Phi_A * x_t);
        
        % Calculate observation likelihood
        L(i) = exp(-lambda * r);
        if (isnan(L(i)))
            break;
        end
        
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
    T = update_templates(T, N_t, x, y, sci_thresh);
    
    % Resampling
    show_particles(S, L, b, F_k); 
%     waitforbuttonpress;
    S = resample_particles(S, L);

    % Showing Image
%     show_particles(S, L, b, F_k); 
%     show_state_estimated(s_k, b, F_k);
    fprintf('Frame %d\n', k);
%     break;

end

