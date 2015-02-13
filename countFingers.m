function [num_fingers, final_mask, cx, cy] = countFingers(largest_blob)
	% compute centroid of blob (center of mass)
	stats=regionprops(largest_blob,'Centroid');
    cx=stats.Centroid(1);
    cy=stats.Centroid(2);

    % compute hand's contour
    boundary=bwboundaries(largest_blob);
    % compute min distance from centroid to boundary 
    % to approximate palm's radius
    minDist=2*300*300;
    for i=1:length(boundary)
        cell=boundary{i,1};
        for j=1:length(cell)
        	y=cell(j,1);
            x=cell(j,2);
            sqrDist=(cx-x)*(cx-x)+(cy-y)*(cy-y);
            if(sqrDist<minDist)
                minDist=sqrDist;
            end
        end    
    end

    % create morphological structuring element of a disk of size of the approximate hand radius
	sed=strel('disk',round(sqrt(minDist)/2.1));
	% erode hand mask (fingers disappear)
    final_mask=imerode(largest_blob,sed);
    % dilate previous mask (get approximate palm)
    final_mask=imdilate(final_mask,sed);
    % subtract palm from hand (get fingers)
    final_mask=largest_blob-final_mask;
    % get rid of small blobs (noise)
    final_mask=bwareaopen(final_mask,300);
    % erode a bit
    final_mask=imerode(final_mask,strel('disk',2));
    % get rid of small blobs (noise)
    final_mask=bwareaopen(final_mask,400);
    % compute number of fingers up
    [L,num_fingers]=bwlabel(final_mask,8);
    % clear image border
    final_mask=imclearborder(final_mask,8);
end