function rtcst(reader, b, params, output_dir)
%% Set parameters
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

F_1 = read(reader, 1);
if (size(F_1, 3) > 1)
    F_1 = rgb2gray(F_1);
end
F_1 = im2double(F_1);

show_box(F_1, b);
img = saveAnnotatedImg(gcf);
imwrite(img, fullfile(output_dir, sprintf('frame%04d.png', 1)));

d0 = b(3) * b(4);
d = params.d;

N_s = params.N_s; % number of particles
N_t = params.N_t; % number of templates

affine_std = params.affine_std;

lambda = params.lambda; % parameter in computing the likelihood

% parameter for Customized OMP early stop
comp_eps = params.comp_eps; 
comp_eta = params.comp_eta;

% parameter for updating templates
sci_thresh = params.sci_thresh;

% for debug
temp_count = 0;

%% Initialize structures
S = create_particles(N_s, b);
s_k = S(:, 1);
T = initialize_templates(F_1, b, N_t);
E = [eye(d) -eye(d)];
Phi = randn(d, d0);
L = ones(1, N_s);

% Normalize every column of PhiA
Phi_A = [Phi*T, E];
for i = 1:N_t %size(Phi_A, 2)
    col = Phi_A(:, i);
    col = col - mean(col);
    Phi_A(:, i) = col / norm(col);
end

%% Main loop
for k = 2:reader.NumberOfFrames
    % Getting current frame
    F_k = read(reader, k);
    if (size(F_k, 3) > 1)
        F_k = rgb2gray(F_k);
    end
    F_k = im2double(F_k);
    
    % Update particles
    S = update_particles(S, s_k, affine_std);
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
    end
    
    % Estimate the new dynamic state
    s_k = sum(bsxfun(@times, S, L), 2) / sum(L);
    
    % Recalculate x
    y = affine_map(F_k, s_k, b);
    show_affine_map(y, b);
    y = y - mean(y);
    y = y / norm(y);
    Phi_y = Phi * y;
    Phi_y = Phi_y - mean(Phi_y);
    Phi_y = Phi_y / norm(Phi_y);
    x = comp(Phi_y, Phi_A, comp_eps, comp_eta);
    
    % Update templates
    [T, i] = update_templates(T, N_t, x, y, sci_thresh);
    if i > 0
        col = Phi * T(:, i);
        col = col - mean(col);
        Phi_A(:, i) = col / norm(col);
        temp_count = temp_count + 1;
    end
    
    % Resampling
%     show_particles(S, L, b, F_k); 
    S = resample_particles(S, L);

    % Showing Image
%     show_particles(S, L, b, F_k); 
    show_state_estimated(s_k, b, F_k);
    fprintf('Frame %d\n', k);
    
    img = saveAnnotatedImg(gcf);
    imwrite(img, fullfile(output_dir, sprintf('frame%04d.png', k)));

end

fprintf('Templates have been updated %d times\n', temp_count);

