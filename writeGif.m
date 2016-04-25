function writeGif( img_dir, out_file, delay_time )
%GIFWRITER: write images in the given directory into a GIF animation
if exist(img_dir, 'dir')
    files = dir(img_dir);
    n = 0;
    for i = 1:length(files)
        [~, ~, ext] = fileparts(files(i).name);
        if strcmp(ext, '.jpg') || strcmp(ext, '.png')
            im = imread(fullfile(img_dir, files(i).name));
            if n == 0
                [im, map] = rgb2ind(im, 256);
                imwrite(im, map, out_file, 'gif', 'LoopCount', Inf, 'DelayTime', delay_time);
            else
                im = rgb2ind(im, map);
                imwrite(im, map, out_file, 'gif', 'WriteMode', 'append', 'DelayTime', delay_time);
            end
            n = n + 1;
            fprintf('Processed %d frames\n', n);
        end
    end
    
else
    throw(MException('gifWriter:DirNotFound', ...
        'Directory %s not found.', img_dir));
end

end

