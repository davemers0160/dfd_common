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
color = {[0 0 1]; [0 1 0]; [1 0 0]; [0 1 1]; [1 0 1]; [1 1 0]; [0 0 0]; [1 1 1]; [0.5 0.5 0.5]};                    

img_w = 400;
img_h = 400;

% x_min,x_max; y_min,y_max; min_r,max_r
circle = [1,img_w; 1,img_h; 10,20];
polygon = [1,img_w; 1,img_h; -50,50];

commandwindow;

%% start to create the images
dm_values = [0, 8:1:232];

save_path = 'D:/IUPUI/Test_data/test_blur3/';

fprintf('%s\n\n', save_path);

for kdx=0:255

    C = randi([1,numel(color)],1);
    img = cat(3, color{C}(1).*ones(img_w, img_h), color{C}(2).*ones(img_w, img_h), color{C}(3).*ones(img_w, img_h));
%     img = zeros(img_w, img_h, 3);
    dm = zeros(img_w, img_h, 3);

    for idx=1:numel(dm_values)

        % get the number of shapes for a given depth map value
        N = randi([0,5], 1);

        dm_val = [idx, idx, idx]/255.0;
        
        for jdx=1:N
            % get the shape type
            T = randi([1,2], 1);
%             V = idx;

            switch(T)

                case 1
                    X = randi(circle(1,:), 1);
                    Y = randi(circle(2,:), 1);
                    R = randi(circle(3,:), 1);
                    C = randi([1,numel(color)],1);

                    img = insertShape(img, 'FilledCircle', [X, Y, R], 'Color', color{C}, 'Opacity',1, 'SmoothEdges', false);
                    dm = insertShape(dm, 'FilledCircle', [X, Y, R], 'Color', dm_val, 'Opacity',1, 'SmoothEdges', false);

                case 2
                    X = randi(polygon(1,:), 1);
                    Y = randi(polygon(2,:), 1);            
                    P = randi(polygon(3,:), [1,6]);
                    P(1:2:end) = P(1:2:end) + X;
                    P(2:2:end) = P(2:2:end) + Y;
                    P = cat(2, X, Y, P);

                    C = randi([1,numel(color)],1);

                    img = insertShape(img, 'FilledPolygon', P, 'Color', color{C}, 'Opacity',1, 'SmoothEdges', false);
                    dm = insertShape(dm, 'FilledPolygon', P, 'Color', dm_val, 'Opacity',1, 'SmoothEdges', false);

            end
        end
    end

%     figure(1)
%     imshow(img);
% 
%     figure(2)
%     imshow(dm);

    % save the image file and depth maps
    image_num = num2str(kdx, '%03d');

    img_filename = strcat('images/image_', image_num, '.png');
    imwrite(img, strcat(save_path, img_filename));

    dm_filename = strcat('depth_maps/dm_', image_num, '.png');
    imwrite(dm, strcat(save_path, dm_filename));
    
    fprintf('%s, %s, 0.32, 0.01, 256, \n', img_filename, dm_filename);
    
end

return;

%% this adds a capabilityy to write out individual depth maps

min_depth = 0;
max_depth = 255;

for idx=min_depth:max_depth
    gt = idx*ones(300,300);

    imwrite(uint8(gt), strcat('D:/IUPUI/Test_data/test_blur/depth_',num2str(idx,'%03d'),'.png'));

end

%% write out the blur image input

for idx=0:4

    for jdx=0:255
        fprintf('images/image_%02d.png, depth_maps/depth_%03d.png, 0.32, 0.01, 256, %03d\n', idx, jdx, jdx);
    end

end



