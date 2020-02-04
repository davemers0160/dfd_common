format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%% shape parameters

%color = {'blue', 'green', 'red', 'cyan', 'magenta', 'yellow', 'black', 'white', [0.5, 0.5, 0.5]};
% color = {[0 0 1]; [0 1 0]; [1 0 0]; [0 1 1]; [1 0 1]; [1 1 0]; [0 0 0]; [1 1 1]; [0.5 0.5 0.5]};                    

% http://alumni.media.mit.edu/~wad/color/numbers.html
% color = {[0, 0, 0];[87, 87, 87]/255;[173, 35, 35]/255;[42, 75, 215]/255;...
%          [29, 105, 20]/255;[129, 74, 25]/255;[129, 38, 192]/255;[160, 160, 160]/255;...
%          [129, 197, 122]/255;[157, 175, 255]/255;[41, 208, 208]/255;[255, 146, 51]/255;...
%          [255, 238, 51]/255;[233, 222, 187]/255;[255, 205, 243]/255;[255, 255, 255]/255};
%      
% 6-7-6 RGB color palette https://en.wikipedia.org/wiki/List_of_software_palettes
green = [0, 42, 85, 128, 170, 212, 255];
color = {};
for r=0:5
    for g=0:6
        for b=0:5
            color{end+1} = [51*r, green(g+1), 52*b]/255;
        end
    end
end

commandwindow;

%% create the folders
save_path = 'D:/IUPUI/Test_data/test_blur7/';

warning('off');
mkdir(save_path);
mkdir(save_path, 'images');
mkdir(save_path, 'depth_maps');
warning('on');

%% show the colors
% img_w = 50;
% img_h = 250;
% img = [];
% 
% for idx=1:numel(color)
%     img = cat(2, img, cat(3, color{idx}(1).*ones(img_h, img_w), color{idx}(2).*ones(img_h, img_w), color{idx}(3).*ones(img_h, img_w))); 
% end
% 
% figure(plot_num)
% imshow(img)
% plot_num = plot_num + 1;

%% start to create the images
img_w = 400;
img_h = 400;

%img_w_range = 20:379;
%img_h_range = 20:379;
img_w_range = 10:389;
img_h_range = 10:389;

blk_h = 35;
blk_w = 35;
max_dim = max(blk_h,blk_w);

dm_values = [0, 9:1:232];

% x_min,x_max; y_min,y_max; min_r,max_r
rect = [1,blk_w; 1,blk_h; ceil(max_dim/8),ceil(max_dim/5)];
circle = [1,blk_w; 1,blk_h; ceil(max_dim/8),ceil(max_dim/5)];
polygon = [1,blk_w; 1,blk_h; -ceil(max_dim/6),ceil(max_dim/6)];
shape_lims = {circle, polygon, rect};

fprintf('%s\n\n', save_path);

tic;
parfor kdx=0:99
    
    % get the random background color
    bg_color = randi([1,numel(color)],1);
    img = cat(3, color{bg_color}(1).*ones(img_h, img_w), color{bg_color}(2).*ones(img_h, img_w), color{bg_color}(3).*ones(img_h, img_w));
    dm = zeros(img_h, img_w, 3);
    
    D = randi([2, numel(dm_values)],1,50);
    D = sort(unique(D));
    
    for idx=1:numel(D)
        
        % get the number of shapes for a given depth map value
        N = randi([floor(exp((3.7*(numel(D)-idx))/numel(D))),ceil(exp((4.0*(numel(D)-idx))/numel(D)))], 1);
        dm_blk = (dm_values(D(idx))/255)*ones(blk_h, blk_w, 3);
        
        for jdx=1:N
            S = randi([15,30], 1);
            [block] = gen_rand_image(blk_h, blk_w, S, color, shape_lims);

            X = randi([1,img_w-blk_w], 1);
            Y = randi([1,img_h-blk_h], 1);

            img(Y:Y+blk_h-1, X:X+blk_w-1,:) = block;
            dm(Y:Y+blk_h-1, X:X+blk_w-1,:) = dm_blk;
        end
    end

    img = img(img_h_range, img_w_range, :);
    dm = dm(img_h_range, img_w_range, :);

    % save the image file and depth maps
    image_num = num2str(kdx, '%03d');

    img_filename = strcat('images/image_', image_num, '.png');
    imwrite(img, strcat(save_path, img_filename));

    dm_filename = strcat('depth_maps/dm_', image_num, '.png');
    imwrite(dm, strcat(save_path, dm_filename));
    
    fprintf('%s, %s, 0.32, 0.01, 256\n', img_filename, dm_filename);
    
end

toc;


