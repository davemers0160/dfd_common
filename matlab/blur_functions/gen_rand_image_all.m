function [img] = gen_rand_image_all(img_h, img_w, N, limits)

    %{circle, polygon, rect}
    circle = limits{1};
    polygon = limits{2};
    rect = limits{3};
    
    % get the random background color
    color = randi([0,255],1,3)/255;
    img = cat(3, color(1).*ones(img_h, img_w), color(2).*ones(img_h, img_w), color(3).*ones(img_h, img_w));
    
    for idx=1:N
        % get the shape type
        T = randi([1,3], 1);

        % get the random color for the shape
        C = randi([0,255],1,3)/255;
        while(C == color)
            C = randi([0,255],1,3)/255;
        end

        switch(T)
            case 1
                %X = randi(circle(1,:), 1);
                %Y = randi(circle(2,:), 1);
                X = randi([1,img_w], 1);
                Y = randi([1,img_h], 1);
                R = randi(circle(1,:), 1);

                img = insertShape(img, 'FilledCircle', [X, Y, R], 'Color', C, 'Opacity',1, 'SmoothEdges', false);

            case 2
%                 X = randi(polygon(1,:), 1);
%                 Y = randi(polygon(2,:), 1);
                X = randi([1,img_w], 1);
                Y = randi([1,img_h], 1);
                P = randi(polygon(1,:), [1,6]);
                P(1:2:end) = P(1:2:end) + X;
                P(2:2:end) = P(2:2:end) + Y;
                P = cat(2, X, Y, P);

                img = insertShape(img, 'FilledPolygon', P, 'Color', C, 'Opacity',1, 'SmoothEdges', false);

            case 3
%                 X = randi(rect(1,:), 1);
%                 Y = randi(rect(2,:), 1); 
                X = randi([1,img_w], 1);
                Y = randi([1,img_h], 1);
                W = randi(rect(1,:), 1);
                H = randi(rect(1,:), 1);

                img = insertShape(img, 'FilledRectangle', [X, Y, W, H], 'Color', C, 'Opacity',1, 'SmoothEdges', false);
        end
    end
    

end