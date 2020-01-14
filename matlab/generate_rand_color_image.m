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

color = {'blue', 'green', 'red', 'cyan', 'magenta', 'yellow', 'black', 'white'};

img_w = 300;
img_h = 300;

% x_min,x_max; y_min,y_max; min_r,max_r
circle = [1,img_w; 1,img_h; 20,40];
polygon = [1,img_w; 1,img_h; -100,100];

commandwindow;

%%

img = 255*ones(img_w, img_h, 3);

for idx=1:800
    
    T = randi([1,2], 1);
    
    switch(T)
               
        case 1
            X = randi(circle(1,:), 1);
            Y = randi(circle(2,:), 1);
            R = randi(circle(3,:), 1);
            C = randi([1,numel(color)],1);

            img = insertShape(img, 'FilledCircle', [X, Y, R], 'Color', color{C},'Opacity',1);

        case 2
            X = randi(polygon(1,:), 1);
            Y = randi(polygon(2,:), 1);            
            P = randi(polygon(3,:), [1,6]);
            P(1:2:end) = P(1:2:end) + X;
            P(2:2:end) = P(2:2:end) + Y;
            P = cat(2, X, Y, P);
            
            C = randi([1,numel(color)],1);

            img = insertShape(img, 'FilledPolygon', P, 'Color', color{C},'Opacity',1);

    end
end

imshow(img);

%% save the file

file_name = 'D:/IUPUI/Test_data/test_blur/image_04.png';

imwrite(img, file_name);

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



