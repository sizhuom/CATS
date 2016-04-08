classdef ImageReader
    %IMAGEREADER: Class that simulates VideoReader's API for reading images
    
    properties
        Dir
        Filelist
        Duration
        FrameRate
        Truth
    end
    
    methods
        function obj = ImageReader(d)
            img_dir = fullfile(d, 'img');
            if exist(img_dir, 'dir')
                obj.Dir = d;
                
                files = dir(img_dir);
                obj.Filelist = {};
                obj.Duration = 0;
                for i = 1:length(files)
                    [~, ~, ext] = fileparts(files(i).name);
                    if strcmp(ext, '.jpg')
                        obj.Filelist{obj.Duration+1} = files(i).name;
                        obj.Duration = obj.Duration + 1;
                    end
                end
                obj.FrameRate = 1;
                
                truthFile = fopen(fullfile(d, 'groundtruth_rect.txt'), 'r');
                obj.Truth = fscanf(truthFile, '%d', [4 Inf]);
                fclose(truthFile);
                
            else
                throw(MException('ImageReader:DirNotFound', ...
                    'Directory %s not found.', img_dir));
            end
        end
        
        function f = read(obj, i)
            f = imread(obj.Filelist{i});
        end
    end
    
end

