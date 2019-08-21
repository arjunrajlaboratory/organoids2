function objects = convert_coords_pixel_to_um(objects, field, scale_x, scale_y, scale_z)

    % if there are any segmentations:
    if isstruct(objects)

        % add field to store converted coordinates:
        [objects(1:end).(sprintf('%s_um', field))] = deal([]);

        % for each object:
        for i = 1:numel(objects)

            % convert the coordinates:
            objects(i).(sprintf('%s_um', field))(:,1) = objects(i).(field)(:,1) * scale_x;
            objects(i).(sprintf('%s_um', field))(:,2) = objects(i).(field)(:,2) * scale_y;
            objects(i).(sprintf('%s_um', field))(:,3) = objects(i).(field)(:,3) * scale_z;

        end
        
    end
    
end