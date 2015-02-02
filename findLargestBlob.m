function [largest_blob] = findLargestBlob( hsv_color, hsv_img )

    % the size of the 'slice' around the hsv color that was picked
    hue_percentage=0.2;
    lower_hue = hsv_color(1)-hue_percentage/2;
    hsv_mask = hsv_img(:,:,1) >= lower_hue | hsv_img(:,:,1) >= 1+lower_hue;
    upper_hue = hsv_color(1)+hue_percentage/2;  
    hsv_mask = hsv_mask & (hsv_img(:,:,1) < upper_hue | hsv_img(:,:,1) < 1-upper_hue);
    % how much of the saturation part we want
    saturation_percentage = 0.6;
    hsv_mask = hsv_mask & hsv_img(:,:,2) >= hsv_color(2)-saturation_percentage/2 & hsv_img(:,:,2) < hsv_color(2)+saturation_percentage/2;


    % once the mask is created, we want to find the largest blob
    % so return connected component with largest area
    labeled_img = bwlabel(hsv_mask);
    num = max(unique(labeled_img));
    max_area = 0;
    for a = 1:num
        objectlabel = a;
        regionOfObject = (labeled_img==a);
        areaOfObject = sum(regionOfObject(:));
        if (areaOfObject > max_area)
     	    max_area = areaOfObject;
     	    largest_blob = regionOfObject;
        end
    end
end
