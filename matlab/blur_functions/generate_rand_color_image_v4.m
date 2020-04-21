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
% color_palette = 'basic';

% http://alumni.media.mit.edu/~wad/color/numbers.html
% color = {[0, 0, 0];[87, 87, 87]/255;[173, 35, 35]/255;[42, 75, 215]/255;...
%          [29, 105, 20]/255;[129, 74, 25]/255;[129, 38, 192]/255;[160, 160, 160]/255;...
%          [129, 197, 122]/255;[157, 175, 255]/255;[41, 208, 208]/255;[255, 146, 51]/255;...
%          [255, 238, 51]/255;[233, 222, 187]/255;[255, 205, 243]/255;[255, 255, 255]/255};
% color_palette = 'mit';

% 6-7-6 RGB color palette https://en.wikipedia.org/wiki/List_of_software_palettes
green = [0, 42, 85, 128, 170, 212, 255];
color = {};
for r=0:5
    for g=0:6
        for b=0:5
            color{end+1} = [51*r, green(g+1), 51*b]/255;
        end
    end
end
color_palette = '676';

% full RGB


commandwindow;

%% create the folders
save_path = 'D:/IUPUI/Test_data/tb12_test/';

warning('off');
mkdir(save_path);
mkdir(save_path, 'images');
mkdir(save_path, 'depth_maps');
warning('on');

% the number of images to generate - not including the intensity variants
num_images = 10;
img_offset = 0;

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

%% setup the blurring paramters

% gaussian kernel size
kernel_size = 51;

% sigma values for gaussian kernel
% this sigma ranges from 0 - 50 pixel blur radius
sigma = [0.100,0.250,0.300,0.450,0.500,0.700,0.750,0.900,0.950,1.150,1.200,1.350,1.400,1.600,1.650,1.850,1.900,...
    2.100,2.150,2.300,2.350,2.550,2.600,2.800,2.850,3.050,3.100,3.300,3.350,3.500,3.550,3.750,3.800,4.000,4.050,...
    4.250,4.300,4.450,4.500,4.700,4.750,4.950,5.000,5.200,5.250,5.450,5.500,5.750,5.800,6.150,6.200];

% these are the candidate pixel blur radius to test
% 2 meters - 10 meters
% br1 = [9, 11, 13, 13, 14, 14, 15, 15, 15];
% br2 = [7, 4, 3, 2, 2, 1, 1, 1, 0];
% 30 - 49 meters - 1 meter increments
br1 = [3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11, 11, 12, 12, 13, 13, 14, 14, 15, 15];
br2 = [31, 30, 30, 29, 28, 27, 26, 26, 25, 24, 24, 23, 23, 22, 22, 21, 21, 20, 20, 19];

% depth map values - arrange from lowest to highest with 0 being the lowest
% depthmap_range = [0:1:49];
depthmap_range = [0:1:19];
max_depthmap = max(depthmap_range(:));
num_dm_values = numel(depthmap_range);

%% create all of the image generation parameters

% max number of depth map values for a single image
DM_N = floor(numel(depthmap_range)/2);

% initial number of objects at the first depthmap value
num_objects = 40;          

% block dimensions
blk_h = 50;
blk_w = 50;
max_blk_dim = max(blk_h, blk_w);

% build inmage dimensions
img_w = 400 + ceil(blk_w/2);
img_h = 400 + ceil(blk_h/2);
max_dim = max(img_w, img_h);

% make this cropping a mod 16 number
%img_w_range = 20:379;
%img_h_range = 20:379;
img_w_range = 17:400;
img_h_range = 17:400;

% intensity values to simulate different light conditions
int_values = [0.2, 0.4, 0.6, 0.8, 1.0];

% x_min,x_max; y_min,y_max; min_r,max_r
rect = [ceil(max_blk_dim/7), ceil(max_blk_dim/5)];
circle = [ceil(max_blk_dim/7), ceil(max_blk_dim/5)];
polygon = [-ceil(max_blk_dim/5), ceil(max_blk_dim/5)];
shape_lims = {circle, polygon, rect};

rect_l = [ceil(max_dim/18), ceil(max_dim/12)];
circle_l= [ceil(max_dim/18), ceil(max_dim/12)];
polygon_l = [-ceil(max_dim/8), ceil(max_dim/8)];
shape_lims_l = {circle_l, polygon_l, rect_l};

%% start to create the images
save_name = strcat(save_path,'input_gen_',datestr(now,'yyyymmdd_HHMMSS'),'.txt');
file_id = fopen(save_name, 'w');

fprintf('# %s\n\n', color_palette);
fprintf(file_id, '# %s\n\n', color_palette);

fprintf('%s\n\n', save_path);
fprintf(file_id, '%s\n\n', save_path);

tic;
parfor kdx=0:(num_images-1)
    
    % get the random background color
    %bg_color = randi([1,numel(color)],1);
    %img1 = cat(3, color{bg_color}(1).*ones(img_h, img_w), color{bg_color}(2).*ones(img_h, img_w), color{bg_color}(3).*ones(img_h, img_w));
    %img2 = cat(3, color{bg_color}(1).*ones(img_h, img_w), color{bg_color}(2).*ones(img_h, img_w), color{bg_color}(3).*ones(img_h, img_w));
    % create an image as a background instead of a solid color
    img1 = gen_rand_image(img_h, img_w, 400, color, shape_lims_l);
    img2 = img1;
    
    % generate the first depthmap value - use the largest (farthest) value
    dm = (max_depthmap/255)*ones(img_h, img_w, 3);
     
    % blur that backgraound according to the depthmap value
    k1 = create_gauss_kernel(kernel_size, sigma( br1( max_depthmap + 1 ) + 1 ) );
    k2 = create_gauss_kernel(kernel_size, sigma( br2( max_depthmap + 1 ) + 1 ) );

    % blur the layer and the blur_mask
    img1 = imfilter(img1, k1, 'corr', 'replicate', 'same');
    img2 = imfilter(img2, k2, 'corr', 'replicate', 'same');
        
    % randomly generate DM_N depth values 
    if(depthmap_range(end) >= depthmap_range(1))
        D = randi([depthmap_range(1), depthmap_range(end-1)], 1, DM_N);
    else
        D = randi([depthmap_range(end), depthmap_range(2)], 1, DM_N);
    end
    D = sort(unique(D), 'descend');
    
    for idx=1:numel(D)
        
        layer_img1 = img1;
        layer_img2 = img2;        
        
        % get the number of shapes for a given depth map value
        min_N = ceil(exp((3.7*(num_objects-idx))/num_objects));
        max_N = ceil(exp((4.0*(num_objects-idx))/num_objects));
        N = randi([min_N, max_N], 1);
        
        %dm_index = find(depthmap_range == D(idx), 1, 'first');
        %dm_blk = (depthmap_range(dm_index)/255)*ones(blk_h, blk_w, 3);
        %fprintf('depthmap_range(dm_index): %d\n', depthmap_range(dm_index));
        dm_blk = (D(idx)/255)*ones(blk_h, blk_w, 3);
        
        % create the overlay mask and mask block
        blur_mask = ones(img_h+blk_h, img_w+blk_w);
        blur_mask_blk = zeros(blk_h, blk_w);
        
        for jdx=1:N
            % the number of shapes in an image block
            S = randi([25,45], 1);
            block = gen_rand_image(blk_h, blk_w, S, color, shape_lims);
            
            A = randi([0, 89], 1, 1);
            block = imrotate(block, A, 'nearest', 'loose');
            blur_mask_blk_r = imrotate(blur_mask_blk, A, 'nearest', 'loose');
            
            % check for a depthmap value of 0 and handle as a special case
            if(D(idx) == 0)
                dm_blk_r = imrotate(dm_blk+1, A, 'nearest', 'loose');
                rotation_mask = dm_blk_r > 0;
                dm_blk_r = imrotate(dm_blk, A, 'nearest', 'loose');                
            else
                dm_blk_r = imrotate(dm_blk, A, 'nearest', 'loose');
                rotation_mask = dm_blk_r > 0;                
            end
            
            X = randi([1,img_w-blk_w], 1);
            Y = randi([1,img_h-blk_h], 1);
            
            layer_img1 = overlay_with_mask(layer_img1, block, rotation_mask, X, Y);
            layer_img2 = overlay_with_mask(layer_img2, block, rotation_mask, X, Y);
            dm = overlay_with_mask(dm, dm_blk_r, rotation_mask, X, Y);
            blur_mask = overlay_with_mask(blur_mask, blur_mask_blk_r, rotation_mask, X, Y);
            
        end
        
        % create the 2-D gaussian kernel using the depth map value indexing the sigma array
        d_idx = D(idx) + 1;
        %fprintf('d_idx, br1( d_idx ) + 1: %d, %d\n', d_idx, br1( d_idx ) + 1);

        k1 = create_gauss_kernel(kernel_size, sigma( br1( d_idx ) + 1 ) );
        k2 = create_gauss_kernel(kernel_size, sigma( br2( d_idx ) + 1 ) );
        
        % blur the layer and the blur_mask
        LI_1 = imfilter(layer_img1, k1, 'corr', 'replicate', 'same');
        BM_1 = imfilter(blur_mask, k1, 'corr', 'replicate', 'same');
        LI_2 = imfilter(layer_img2, k2, 'corr', 'replicate', 'same');
        BM_2 = imfilter(blur_mask, k2, 'corr', 'replicate', 'same');
        
        % bring the images back down to the original size
        LI_1 = LI_1(1:img_h, 1:img_w, :);
        BM_1 = BM_1(1:img_h, 1:img_w, :);
        LI_2 = LI_2(1:img_h, 1:img_w, :);
        BM_2 = BM_2(1:img_h, 1:img_w, :);
        
        % blending the current layer image and the previous image
        img1 = (LI_1.*(1-BM_1) + (img1.*BM_1));
        img2 = (LI_2.*(1-BM_2) + (img2.*BM_2));
        
        bp = 1;
        
    end

    img1 = img1(img_h_range, img_w_range, :);
    img2 = img2(img_h_range, img_w_range, :);
    dm = dm(img_h_range, img_w_range, :);
    
    image_num = num2str(kdx+img_offset, '%03d');
    dm_filename = strcat('depth_maps/dm_', image_num, '.png');
    imwrite(dm, strcat(save_path, dm_filename));

    % now that the image has been created let's run through the intensity
    % values
    
    for jdx=1:numel(int_values)
        
        img_int1 = img1*int_values(jdx);
        img_int2 = img2*int_values(jdx);
        
        % save the image file and depth maps

        image_int = num2str(int_values(jdx)*100, '%03d');
        
        img_filename1 = strcat('images/image_f1_', image_num, '_', image_int, '.png');
        img_filename2 = strcat('images/image_f2_', image_num, '_', image_int, '.png');
        
        imwrite(img_int1, strcat(save_path, img_filename1));
        imwrite(img_int2, strcat(save_path, img_filename2));
        
        fprintf('%s, %s, %s\n', img_filename1, img_filename2, dm_filename);
    end
        
end

toc;

for kdx=0:(num_images-1)
    % save the image file and depth maps
    image_num = num2str(kdx+img_offset, '%03d');
    dm_filename = strcat('depth_maps/dm_', image_num, '.png');
    
    for jdx=1:numel(int_values)
        image_int = num2str(int_values(jdx)*100, '%03d');
        img_filename1 = strcat('images/image_f1_', image_num, '_', image_int, '.png');
        img_filename2 = strcat('images/image_f2_', image_num, '_', image_int, '.png');
        fprintf(file_id, '%s, %s, %s\n', img_filename1, img_filename2, dm_filename);   
    end
    
end

fclose(file_id);
