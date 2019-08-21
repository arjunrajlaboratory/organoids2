function coords = get_all_coordinates_within_radius(point, radius)

    % get all possible x coordinates values:
    coords_x = point(1)-radius:point(1)+radius;

    % get all possible y coordinate values:
    coords_y = point(2)-radius:point(2)+radius;
    
    % get all cobinations of x and y coordinates:
    coords = combvec(coords_x, coords_y)';

end