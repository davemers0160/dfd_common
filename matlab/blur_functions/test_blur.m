format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%% build the sample data and the blur kernel

% bluring kernel - box filter
% kernel_size = 3;
% kernel = ones(1,kernel_size);
% kernel = kernel/(numel(kernel));

% gaussian kernel
kernel_size = 51;

sigma_start = 0.1;
sigma_step = 0.05;
sigma_stop = 6.20;

%sigma = sigma_start:sigma_step:sigma_stop;

max_blur_radius = 50;

commandwindow;

%% run the bluring algorithm

threshold = 1/255;

blur_radius = [0:1:max_blur_radius];

% create a single knife edge line
data = cat(2, zeros(1, 100), 255*ones(1, 100+100));

fprintf('float[,] kernel = new float[,] {\n');

sigma = sigma_start;

for idx=1:numel(blur_radius)
    
    num = -1;
    while(num < blur_radius(idx))
    
        kernel = create_1D_gauss_kernel(kernel_size, sigma);

        blur_data = conv(data, kernel,'same');
        blur_data = blur_data(1:200);

        match = (blur_data > (blur_data(1)+threshold)) == (blur_data < (blur_data(end)-threshold));

        num = sum(match);
        sigma = sigma + sigma_step;
    end
    
    %fprintf('sigma: %1.4f, num: %03d\n', sigma(idx), num);
    fprintf('{');
    str = '';
    for jdx=26:kernel_size
        str = strcat(str, num2str(kernel(jdx), '%1.5ff, '));
    end
    str = strcat(str(1:end-1),'},');
    fprintf('%s\n', str);
    
    %sigma = sigma - sigma_step;
    
end

fprintf('};\n');

    
% while(num < 20)
%     blur_data = (conv(blur_data, kernel,'same'));
% 
%     % count the number of "pixels" affected
%     %t1 = (blur > 0);
%     %t2 = (blur < blur(end)); 
% 
%     %num = sum((t1+t2)==2)
% 
%     num = sum((blur_data > 0) == (blur_data < blur_data(end)));
% end

% blur_data = blur_data(1:200);

bp = 1;

%% plot the results

figure(plot_num)
plot([1:kernel_size], kernel, 'b')
hold on
plot_num = plot_num + 1;

figure(plot_num)
plot(data(1:200), 'b')
hold on
plot(blur_data, '--r')
plot_num = plot_num + 1;

figure(plot_num)
image(blur_data);
colormap(gray(256));
plot_num = plot_num + 1;

