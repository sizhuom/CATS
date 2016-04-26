%% Setup
addpath('..');

%% Open video and set parameters
% vr = VideoReader('Person.wmv');
% vr = ImageReader('../images/Dog');
% vr = ImageReader('../images/Basketball');
% vr = ImageReader('../images/BlurCar2');
% vr = ImageReader('../images/Car4');
% vr = ImageReader('../images/test_walking_person');
vr = ImageReader('../images/test_rolling_ball');
% vr = ImageReader('../images/test_basketball');
% vr = ImageReader('../images/Car1');
output_dir = '../images/result';

b = vr.Truth(:, 1);

params.start_frame = 1;

params.d = 100;

params.N_s = 100; % number of particles
params.N_t = 100; % number of templates

params.affine_std = [0.03,0.005,0.005,0.03,10,10];

params.lambda = 10; % parameter in computing the likelihood

% parameter for Customized OMP early stop
params.comp_eps = 0.01; 
params.comp_eta = params.d/2;

% parameter for updating templates
params.sci_thresh = 0.2;

% parameter for debugging
params.draw_particles = true;
params.show_cropped = false;

%% Tracking
rtcst(vr, b, params, output_dir);