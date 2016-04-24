classdef ImageReader
    %IMAGEREADER: Class that simulates VideoReader's API for reading images
    
    properties
        Dir
        Filelist
        Duration
        FrameRate
        NumberOfFrames
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
                    if strcmp(ext, '.jpg') || strcmp(ext, '.png')
                        obj.Filelist{obj.Duration+1} = files(i).name;
                        obj.Duration = obj.Duration + 1;
                    end
                end
                obj.NumberOfFrames = obj.Duration;
                obj.FrameRate = 1;
                
                truthFile = fopen(fullfile(d, 'groundtruth_rect.txt'), 'r');
                line = fgets(truthFile);
                if (sum(line == ',') > 0)
                    fseek(truthFile, 0, 'bof');
                    obj.Truth = fscanf(truthFile, '%d,%d,%d,%d', [4 Inf]);
                else
                    fseek(truthFile, 0, 'bof');
                    obj.Truth = fscanf(truthFile, '%d', [4 Inf]);
                end
                fclose(truthFile);
                
            else
                throw(MException('ImageReader:DirNotFound', ...
                    'Directory %s not found.', img_dir));
            end
        end
        
        function f = read(obj, i)
            f = imread(fullfile(obj.Dir, 'img', obj.Filelist{i}));
        end
    end
    
end

