function boundary_coords_fix = redraw_segmentation(boundary_coords_original, boundary_coords_fix, image_height, image_width)

    % get x and y coordinates:
    boundary_coords_original_x = boundary_coords_original(:,2);
    boundary_coords_original_y = boundary_coords_original(:,1);
    boundary_coords_fix_x = boundary_coords_fix(:,2);
    boundary_coords_fix_y = boundary_coords_fix(:,1);
    
    % get index of original coordinates that is closest to the FIRST fix
    % coordinate:
    [~, index_first] = min(pdist2([boundary_coords_original_x boundary_coords_original_y], [boundary_coords_fix_x(1) boundary_coords_fix_y(1)], 'euclidean'));
    
    % get the index of the original coordinates that is closest to the LAST
    % fix coordinate:
    [~, index_last] = min(pdist2([boundary_coords_original_x boundary_coords_original_y], [boundary_coords_fix_x(end) boundary_coords_fix_y(end)], 'euclidean'));
    
    % cut the original coordinates into two segments:
    if index_first < index_last
        boundary_coords_original_x_1 = boundary_coords_original_x(index_first:index_last);
        boundary_coords_original_x_2 = [boundary_coords_original_x(index_last:end); boundary_coords_original_x(1:index_first)];
        boundary_coords_original_y_1 = boundary_coords_original_y(index_first:index_last);
        boundary_coords_original_y_2 = [boundary_coords_original_y(index_last:end); boundary_coords_original_y(1:index_first)];
    else
        boundary_coords_original_x_1 = [boundary_coords_original_x(index_first:end); boundary_coords_original_x(1:index_last)];
        boundary_coords_original_x_2 = boundary_coords_original_x(index_last:index_first);
        boundary_coords_original_y_1 = [boundary_coords_original_y(index_first:end); boundary_coords_original_y(1:index_last)]; 
        boundary_coords_original_y_2 = boundary_coords_original_y(index_last:index_first);
    end
    
    % combine the fix coordinates with each segment:
    boundary_coords_both_x_1 = [boundary_coords_fix_x; boundary_coords_original_x_1];
    boundary_coords_both_x_2 = [boundary_coords_fix_x; boundary_coords_original_x_2];
    boundary_coords_both_y_1 = [boundary_coords_fix_y; boundary_coords_original_y_1];
    boundary_coords_both_y_2 = [boundary_coords_fix_y; boundary_coords_original_y_2];
    
    % create masks:
    mask_1 = zeros(image_height, image_width);
    mask_2 = zeros(image_height, image_width);
    for i = 1:numel(boundary_coords_both_x_1)
        mask_1(boundary_coords_both_x_1(i), boundary_coords_both_y_1(i)) = 1;
    end
    for i = 1:numel(boundary_coords_both_x_2)
        mask_2(boundary_coords_both_x_2(i), boundary_coords_both_y_2(i)) = 1;
    end
    
    % close any small holes in the masks:
    mask_1 = imclose(mask_1, strel('square', 3));
    mask_2 = imclose(mask_2, strel('square', 3));
    
    % get the area of each mask:
    area_1 = regionprops(mask_1, 'Area');
    area_2 = regionprops(mask_2, 'Area');
    
    % combine the fix coordinates with whichever segment had the larger
    % area:
    if area_1.Area > area_2.Area 
        boundary_coords_fix = [boundary_coords_both_y_1 boundary_coords_both_x_1];
    else
        boundary_coords_fix = [boundary_coords_both_y_2 boundary_coords_both_x_2];
    end
    
end