function wall_thickness = measure_wall_thickness(method, seg_lumens, seg_organoid)

    % if there are any lumens:
    if isstruct(seg_lumens)

        % depending on what method the user specifies:
        switch method

            case 'nearest_lumen_point'

                wall_thickness = organoids2.measure_features.measure_wall_thickness_nearest_lumen_point(seg_lumens, seg_organoid);

        end
    
    % otherwise:
    else
        
        wall_thickness = NaN;
        
    end

end