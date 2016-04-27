%% setup
clear;
[opts, proposal_detection_model, rpn_net, fast_rcnn_net] = faster_rcnn_setup(true);

%% create video reader
video_file = 'C:\Users\Alex\Videos\Running cat - slow motion 100fps.mp4'
start_time = 7;
vr = VideoReader(video_file)
curr_frame = round(start_time * vr.FrameRate + 1);

%% detection
while curr_frame <= vr.NumberOfFrames
    frame = read(vr, curr_frame);
    [fh, pts, detected] = faster_rcnn_detect(frame, opts, proposal_detection_model, rpn_net, fast_rcnn_net);
    %fh = figure; imshow(frame);
    annotated_frame = saveAnnotatedImg(fh);
    output_file = sprintf('images/detection_results/p101_%04d.png', curr_frame);
    %imwrite(annotated_frame, output_file);
    close(fh);
    if detected
        break
    end
    curr_frame = curr_frame + 1;
end

if ~detected
    throw MException('CATS:CatNotFound','Cat doesn't exist in the video!!!');
end

%% coordinates of the corners of the bounding box
pt_UL = round(pts(1,:));
pt_LL = round(pts(2,:));
pt_UR = round(pts(3,:));
pt_LR = round(pts(4,:));

%% cleanup
faster_rcnn_cleanup();

%% Setup
addpath('rtcst');

%% Open video and set parameters
% vr = VideoReader('Person.wmv');
% vr = ImageReader('../images/Dog');
% vr = ImageReader('../images/Basketball');
% vr = ImageReader('../images/BlurCar2');
% vr = ImageReader('../images/Car4');
% vr = ImageReader('../images/test_walking_person');
% vr = ImageReader('../images/test_rolling_ball');
% vr = ImageReader('../images/test_basketball');
% vr = ImageReader('../images/Car1');
output_dir = 'images/result';

% b = vr.Truth(:, 1);
b = zeros(4);
b(1:2) = pt_UL;
b(3:4) = pt_LR - pt_UL;

params.start_frame = curr_frame;

params.d = 100;

params.N_s = 200; % number of particles
params.N_t = 100; % number of templates

params.affine_std = [0.03,0.005,0.005,0.03,10,10];

params.lambda = 10; % parameter in computing the likelihood

% parameter for Customized OMP early stop
params.comp_eps = 0.01; 
params.comp_eta = params.d/2;

% parameter for updating templates
params.sci_thresh = 0.2;

% parameter for debugging
params.draw_particles = false;
params.show_cropped = false;

%% Tracking
rtcst(vr, b, params, output_dir);