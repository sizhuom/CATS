%% Setup
addpath('..');

%% Open video and set parameters
test_set = 'test_rolling_ball';

vr = ImageReader(['../images/' test_set]);
output_dir = ['../images/' test_set '__result'];

params.start_frame = 1;
params.end_frame = vr.NumberOfFrames;

bbox = vr.Truth(:, 1)';
videoFrame = im2double(read(vr, params.start_frame));

% Draw the returned bounding box around the detected face.
videoOut = insertObjectAnnotation(videoFrame,'rectangle',bbox,'obj');
figure(1), imshow(videoOut);

if size(videoFrame, 3) == 3
    [channel,~,~] = rgb2hsv(videoFrame);
else
    channel = videoFrame;
end

figure(2), imshow(channel);
rectangle('Position',bbox(1,:),'LineWidth',2,'EdgeColor',[1 1 0])

%% Tracking
% Create a tracker object.
tracker = vision.HistogramBasedTracker;

% Initialize the tracker histogram using the Hue channel pixels from the
% nose.
initializeObject(tracker, channel, bbox);

% Track the face over successive video frames until the video is finished.
for k = params.start_frame+1:params.end_frame

    % Extract the next video frame
    videoFrame = im2double(read(vr, k));

    % RGB -> HSV
    if size(videoFrame, 3) == 3
        [channel,~,~] = rgb2hsv(videoFrame);
    else
        channel = videoFrame;
    end

    % Track using the Hue channel data
    bbox = step(tracker, channel);

    % Insert a bounding box around the object being tracked
    videoOut = insertObjectAnnotation(videoFrame,'rectangle',bbox,'obj');

    % Display the annotated video frame
    figure(1), imshow(videoOut);

end