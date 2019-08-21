function wall_thickness = measure_wall_thickness_nearest_lumen_point(seg_lumens, seg_organoid)

    % get coordinates of the organoid:
    coords_organoid = seg_organoid.boundary_um;

    % get coordinates of lumen:
    coords_lumens = [];
    for i = 1:numel(seg_lumens)
        coords_lumens = [coords_lumens; seg_lumens(i).boundary_um];
    end

    % get number of organoid coordinates:
    num_coords_organoid = size(coords_organoid, 1);
    
    % create empty array to store wall thickness:
    wall_thickness = zeros(num_coords_organoid, 1);
    
    % for each organoid coordinate:
    for i = 1:num_coords_organoid
       
        % get the wall thickness as the distance between the organoid
        % coordinate and the nearest lumen coordinate:
        wall_thickness(i) = min(pdist2(coords_organoid(i,:), coords_lumens, 'euclidean'));
        
    end

end