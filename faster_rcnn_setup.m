function [opts, proposal_detection_model, rpn_net, fast_rcnn_net] = faster_rcnn_setup()
% adapted from script_faster_rcnn_demo.m
close all;
clc;
clear mex;
clear is_valid_handle; % to clear init_key
addpath(pwd); % add the current folder to path
cd faster_rcnn; % enter the faster_rcnn folder
run('startup');
%% -------------------- CONFIG --------------------
opts.caffe_version          = 'caffe_faster_rcnn';
opts.gpu_id                 = auto_select_gpu;
active_caffe_mex(opts.gpu_id, opts.caffe_version);

opts.per_nms_topN           = 6000;
opts.nms_overlap_thres      = 0.7;
opts.after_nms_topN         = 300;
opts.use_gpu                = true;

opts.test_scales            = 600;

%% -------------------- INIT_MODEL --------------------
%model_dir                   = fullfile(pwd, 'output', 'faster_rcnn_final', 'faster_rcnn_VOC0712_vgg_16layers'); %% VGG-16
model_dir                   = fullfile(pwd, 'output', 'faster_rcnn_final', 'faster_rcnn_VOC0712_ZF'); %% ZF
proposal_detection_model    = load_proposal_detection_model(model_dir);

proposal_detection_model.conf_proposal.test_scales = opts.test_scales;
proposal_detection_model.conf_detection.test_scales = opts.test_scales;
if opts.use_gpu
    proposal_detection_model.conf_proposal.image_means = gpuArray(proposal_detection_model.conf_proposal.image_means);
    proposal_detection_model.conf_detection.image_means = gpuArray(proposal_detection_model.conf_detection.image_means);
end

caffe.init_log(fullfile(pwd, 'caffe_log'));
% proposal net
rpn_net = caffe.Net(proposal_detection_model.proposal_net_def, 'test');
rpn_net.copy_from(proposal_detection_model.proposal_net);
% fast rcnn net
fast_rcnn_net = caffe.Net(proposal_detection_model.detection_net_def, 'test');
fast_rcnn_net.copy_from(proposal_detection_model.detection_net);

% set gpu/cpu
if opts.use_gpu
    caffe.set_mode_gpu();
else
    caffe.set_mode_cpu();
end       

%% -------------------- WARM UP --------------------
% the first run will be slower; use an empty image to warm up

for j = 1:2 % we warm up 2 times
    im = uint8(ones(375, 500, 3)*128);
    if opts.use_gpu
        im = gpuArray(im);
    end
    [boxes, scores]             = proposal_im_detect(proposal_detection_model.conf_proposal, rpn_net, im);
    aboxes                      = boxes_filter([boxes, scores], opts.per_nms_topN, opts.nms_overlap_thres, opts.after_nms_topN, opts.use_gpu);
    if proposal_detection_model.is_share_feature
        [boxes, scores]             = fast_rcnn_conv_feat_detect(proposal_detection_model.conf_detection, fast_rcnn_net, im, ...
            rpn_net.blobs(proposal_detection_model.last_shared_output_blob_name), ...
            aboxes(:, 1:4), opts.after_nms_topN);
    else
        [boxes, scores]             = fast_rcnn_im_detect(proposal_detection_model.conf_detection, fast_rcnn_net, im, ...
            aboxes(:, 1:4), opts.after_nms_topN);
    end
end

%% -------------------- RESET PWD --------------------
cd ..;