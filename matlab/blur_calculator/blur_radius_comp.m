format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

commandwindow;

%% Setup the lens and camera parameters
px_size = 0.0048;               % pixel size (mm)
fl = [9.88, 2.0];              % mm
f_num = [2.9200, 1.0090];       % unitless 4.0090
%d_o = [265000, 495];           % mm
d_o = [26500000, 4950];           % mm
range = [0.1:0.1:50.0]*1000;   % mm 

%% run the parameters through the calc_blur_radius function and plot the results

blur_radius = [];
coc_near = [];
coc_far = [];

for idx=1:numel(f_num) 
    [blur_radius(idx,:)] = calc_blur_radius(d_o(idx), fl(idx), f_num(idx), range);  
end

blur_diff = abs(blur_radius(1,:) - blur_radius(2,:));

px_max = 14;
%px = ceil(max(blur_radius(:))/px_size);
y_axis_ticks = [0:px_size:px_size*px_max];
y_axis_labels = num2str(y_axis_ticks'/px_size);

%% Plot the main blur radius curve
save_location = 'D:\IUPUI\PhD\Images\Optics';
lw = 1.0;

figure(plot_num)
set(gcf,'position',([100,100,1200,600]),'color','w')
hold on
box on
grid on

p1 = plot(range/1000, blur_radius(1,:), 'LineWidth', lw, 'LineStyle', '-', 'Marker', '.', 'Color', 'b', 'MarkerSize', 9);
p2 = plot(range/1000, blur_radius(2,:), 'LineWidth', lw, 'LineStyle', '-', 'Marker', '.', 'Color', 'g', 'MarkerSize', 9);
    
plot(range/1000, blur_diff, 'LineWidth', lw, 'LineStyle', '--', 'Marker', 'none', 'Color', 'k', 'MarkerSize', 9);

% plot(S_range/1000, px*px_size, 'LineWidth', lw, 'LineStyle', '-', 'Marker', 'none', 'Color', 'k', 'MarkerSize', 9);
% plot([0, S_range(end)/1000], [CoC_max, CoC_max], 'LineWidth', lw, 'LineStyle', '--', 'Marker', 'none', 'Color', 'g', 'MarkerSize', 9);
% stem([Dn, Df],[100, 100], 'LineWidth', lw, 'LineStyle', '-', 'Marker', 'none', 'Color', 'r', 'MarkerSize', 9);

set(gca,'FontSize', 13, 'fontweight','bold');

% X-Axis
xlim([range(1) range(end)]/1000);
xticks([range(1):10000:range(end)]/1000);
xtickangle(90);
xtickformat('%2.1f');
xlabel('Distance From Lens (m)', 'fontweight','bold','FontSize', 13);

% Y-Axis
y_plt_max = y_axis_ticks(end);
y_plt_min = 0;
ylim([y_plt_min, y_plt_max]);
yticks(y_axis_ticks);
yticklabels(y_axis_labels);
%ytickformat('%2.3f');
ylabel('Blur Radius (pixels)', 'fontweight','bold','FontSize', 13);

title('Object Distance vs. Radius of Blur', 'fontweight','bold','FontSize', 16);
legend('Blur Radius 1','Blur Radius 2', 'Blur Radius Difference', 'location', 'southeast');
ax = gca;
ax.Position = [0.07 0.12 0.91 0.81];

%print(plot_num, '-dpng', fullfile(save_location,'blur_radius2.png'));

plot_num = plot_num + 1;


%% quantize the results for a given pixel size
% 
% figure(plot_num)
% set(gcf,'position',([100,100,1200,600]),'color','w')
% hold on
% box on
% grid on
% %plot(S_range/1000, CoC/px_size,'.-b');
% plot(range/1000, px,'-k');
% %plot([0, range(end)/1000], ceil([CoC_max/px_size, CoC_max/px_size]),'-r');
% 
% set(gca, 'xlim', limits, 'fontweight','bold');
% set(gca, 'ylim', [0, px(end) + 2], 'fontweight','bold');
% 
% xlabel('Distance From Lens (m)', 'fontweight','bold');
% ylabel('Blur Radius (pixels)', 'fontweight','bold');
% title('Object Distance vs. Radius of Blur', 'fontweight','bold');
% 
% legend(strcat('Quantized Blur Radius px_{size}:',32, num2str(px_size*1000), '{\mu}m'),strcat('R_{max} =', 32, num2str(ceil(CoC_max/px_size))), 'location', 'southeast');
% 
% ax = gca;
% ax.Position = [0.05 0.11 0.93 0.83];
% 
% plot_num = plot_num + 1;