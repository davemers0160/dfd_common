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

img_w = 600;
img_h = 600;

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

file_name = 'D:/IUPUI/Test_data/test_blur/image_00.png';

imwrite(img, file_name);



