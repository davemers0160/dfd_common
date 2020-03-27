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
kernel_size = 3;
kernel = ones(1,kernel_size);
kernel = kernel/(numel(kernel));

%[kernel] = create_1D_gauss_kernel(kernel_size, 1.0);

% create a single knife edge line
data = cat(2, zeros(1, 200), 255*ones(1, 200+100));

%% run the bluring algorithm

num = 0;

blur_data = data;

while(num < 20)
    blur_data = (conv(blur_data, kernel,'same'));

    % count the number of "pixels" affected
    %t1 = (blur > 0);
    %t2 = (blur < blur(end)); 

    %num = sum((t1+t2)==2)

    num = sum((blur_data > 0) == (blur_data < blur_data(end)));
end

blur_data = blur_data(1:400);

num

%% plot the results

figure(plot_num)
plot(kernel, 'b')
hold on
plot_num = plot_num + 1;

figure(plot_num)
plot(data, 'b')
hold on
plot(blur_data, '--r')
plot_num = plot_num + 1;

