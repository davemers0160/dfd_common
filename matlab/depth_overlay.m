function RGB = depth_overlay(img, DepthMap)

    rows = size(DepthMap,1);
    cols = size(DepthMap,2);
    RGB = 0;
    
    figure()
    set(gcf,'position',([100,100,800,600]),'color','w')
    surf(cols:-1:1,1:rows,DepthMap,'CData',img,'FaceColor','texturemap', 'EdgeColor','none');
    view(-160,60);
    hold on
    axis off

%     RGB = ind2rgb(DepthMap,colormap(jet(256)));
%     figure()
%     image(RGB)
%     axis off
    %imwrite(RGB, strcat(scriptpath,'\color_depthmap.png'));

end