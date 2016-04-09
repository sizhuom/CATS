function [fh, pts, detected] = faster_rcnn_detect( im, opts, proposal_detection_model, rpn_net, fast_rcnn_net )

if opts.use_gpu
    im = gpuArray(im);
end

% test proposal
th = tic();
[boxes, scores]             = proposal_im_detect(proposal_detection_model.conf_proposal, rpn_net, im);
t_proposal = toc(th);
th = tic();
aboxes                      = boxes_filter([boxes, scores], opts.per_nms_topN, opts.nms_overlap_thres, opts.after_nms_topN, opts.use_gpu);
t_nms = toc(th);

% test detection
th = tic();
if proposal_detection_model.is_share_feature
    [boxes, scores]             = fast_rcnn_conv_feat_detect(proposal_detection_model.conf_detection, fast_rcnn_net, im, ...
        rpn_net.blobs(proposal_detection_model.last_shared_output_blob_name), ...
        aboxes(:, 1:4), opts.after_nms_topN);
else
    [boxes, scores]             = fast_rcnn_im_detect(proposal_detection_model.conf_detection, fast_rcnn_net, im, ...
        aboxes(:, 1:4), opts.after_nms_topN);
end
t_detection = toc(th);

fprintf('Image (%dx%d): time %.3fs (resize+conv+proposal: %.3fs, nms+regionwise: %.3fs)\n', ...
    size(im, 2), size(im, 1), t_proposal + t_nms + t_detection, t_proposal, t_nms+t_detection);

% visualize
classes = proposal_detection_model.classes;
%boxes_cell = cell(length(classes), 1);
boxes_cell = cell(1,1);
thres = 0.6;

boxes_cell{1} = [boxes(:, 29:32),scores(:,8)];
boxes_cell{1} = boxes_cell{1}(nms(boxes_cell{1},0.3), :);

I = boxes_cell{1}(:, 5) >= thres;
detected = sum(I);
boxes_cell{1} = boxes_cell{1}(I, :);
[~,index] = max(boxes_cell{1}(:,5));

x1 = boxes_cell{1}(index,1);
x2 = boxes_cell{1}(index,3);
y1 = boxes_cell{1}(index,2);
y2 = boxes_cell{1}(index,4);

pt_UL = [x1,y1];
pt_LL = [x1,y2];
pt_UR = [x2,y1];
pt_LR = [x2,y2];

pts = [pt_UL; pt_LL; pt_UR; pt_LR];

%for i = 1:length(boxes_cell)
%    boxes_cell{i} = [boxes(:, (1+(i-1)*4):(i*4)), scores(:, i)];
%    boxes_cell{i} = boxes_cell{i}(nms(boxes_cell{i}, 0.3), :);
%    
%    I = boxes_cell{i}(:, 5) >= thres;
%    boxes_cell{i} = boxes_cell{i}(I, :);
%end

fh = figure();
%showboxes(im, boxes_cell, classes, 'voc');
legends = cell(1,1);
legends{1} = 'cat';
showboxes(im, boxes_cell, legends, 'voc');
pause(0.1);

end

