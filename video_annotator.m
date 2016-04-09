% setup
clear;
[opts, proposal_detection_model, rpn_net, fast_rcnn_net] = faster_rcnn_setup(false);

% create video reader
video_file = 'videos/cat2.mp4'
start_time = 0;
v = VideoReader(video_file)
curr_frame = start_time * v.FrameRate + 1;

% process the first frame in every second
while curr_frame <= v.NumberOfFrames
    frame = read(v, curr_frame);
    [fh, pts, detected] = faster_rcnn_detect(frame, opts, proposal_detection_model, rpn_net, fast_rcnn_net);
    %fh = figure; imshow(frame);
    annotated_frame = saveAnnotatedImg(fh);
    output_file = sprintf('images/p101_%04d.png', curr_frame);
    imwrite(annotated_frame, output_file);
    close(fh);
    if detected
        break
    end
    curr_frame = curr_frame + v.FrameRate;
end

if ~detected
    throw MException('CATS:CatNotFound','Cat doesn't exist in the video!!!');
end

% coordinates of the corners of the bounding box
pt_UL = round(pts(1,:));
pt_LL = round(pts(2,:));
pt_UR = round(pts(3,:));
pt_LR = round(pts(4,:));

% cleanup
% faster_rcnn_cleanup();