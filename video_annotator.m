% setup
[opts, proposal_detection_model, rpn_net, fast_rcnn_net] = faster_rcnn_setup();

% create video reader
video_file = 'videos/p101.mp4';
start_time = 112;
v = VideoReader(video_file);
curr_frame = start_time * v.FrameRate;

% process the first frame in every second
while curr_frame <= v.NumberOfFrames
    frame = read(v, curr_frame);
    fh = faster_rcnn_detect(frame, opts, proposal_detection_model, rpn_net, fast_rcnn_net);
    annotated_frame = saveAnnotatedImg(fh);
    output_file = sprintf('images/p101_%04d.png', curr_frame);
    imwrite(annotated_frame, output_file);
    close(fh);
    curr_frame = curr_frame + v.FrameRate;
end

% cleanup
faster_rcnn_cleanup();