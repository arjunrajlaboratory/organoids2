function data = get_coords_in_um(data)

    % get a list of data organizations:
    list_organizations = fieldnames(data.segmentations);

    % for each type of data organization:
    for i = 1:numel(list_organizations)
        
        % if there is any data:
        if ~ischar(data.segmentations.(list_organizations{i}))
        
            % get a list of fields:
            list_fields = fieldnames(data.segmentations.(list_organizations{i}));

            % for each segmentation:
            for j = 1:numel(data.segmentations.(list_organizations{i}))

                % for each field:
                for k = 1:numel(list_fields)

                    % get the segmentations:
                    temp_segmentations = data.segmentations.(list_organizations{i})(j).(list_fields{k});

                    % get the coordinates in um (in addition to pixels):
                    temp_segmentations = organoids2.utilities.convert_coords_pixel_to_um(temp_segmentations, 'boundary', data.voxel_size_x, data.voxel_size_y, data.voxel_size_z);
                    temp_segmentations = organoids2.utilities.convert_coords_pixel_to_um(temp_segmentations, 'mask', data.voxel_size_x, data.voxel_size_y, data.voxel_size_z);

                    % save:
                    data.segmentations.(list_organizations{i})(j).(list_fields{k}) = temp_segmentations;

                end

            end
       
        end
        
    end
    
end