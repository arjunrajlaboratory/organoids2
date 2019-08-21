function measure_features_single_object

    % get a list of data files:
    list_segmentation_files = dir('all_segmentations*.mat');
    
    % for each file:
    for j = 1:numel(list_segmentation_files)

        % get the stack name:
        name_stack = list_segmentation_files(j).name(end-9:end-4);
        
        % load the data:
        segmentations = organoids2.utilities.load_structure_from_file(sprintf('all_segmentations_%s.mat', name_stack));
        
        % load the image info:
        image_info = organoids2.utilities.load_structure_from_file(sprintf('image_info_%s.mat', name_stack));
        
        % get voxel size:
        voxel_size = [image_info.voxel_size_x, image_info.voxel_size_y, image_info.voxel_size_z];
        
        % get image dimensions:
        image_height = image_info.height;
        image_width = image_info.width;
        image_depth = image_info.depth;
        
        %% First, we want to figure out the slice at which the organoid is the largest. We'll only consider the segmentations below that slice (ideally, the bottom half of the organoid).
        
        % if there are segmentations:
        if isfield(segmentations, 'seg_3D')
            
            % if there are organoid segmentations:
            if isfield(segmentations.seg_3D, 'organoid')
        
                % get the slice at the middle of the organoid (where area largest):
                mask_organoid = organoids2.measure_features.get_3D_mask(segmentations.seg_3D.organoid, image_height, image_width, image_depth);
                slice_middle = organoids2.measure_features.get_slice_largest_area(mask_organoid);
                slice_middle = slice_middle.slice;

                % save:
                features.slice_middle = slice_middle;

                % get list of segmentation types:
                list_segmentation_types = fieldnames(segmentations.seg_3D);

                % get number of segmentation tpyes:
                num_segmentation_types = numel(list_segmentation_types);

                % for each type of segmentation:
                for i = 1:num_segmentation_types

                    % remove objects above the middle:
                    segmentations.seg_3D.(list_segmentation_types{i}) = organoids2.measure_features.remove_objects_above_middle(segmentations.seg_3D.(list_segmentation_types{i}), slice_middle);

                end      
            
            end
        
        end
        
        %% Next, we want to measure all features that involve only one segmentation type.
        
        % if there are segmentations:
        if isfield(segmentations, 'seg_3D')
            
            % get list of segmentation types:
            list_segmentation_types = fieldnames(segmentations.seg_3D);
            
            % for each type of segmentation:
            for i = 1:num_segmentation_types

                % get type of segmentation:
                segmentation_type = list_segmentation_types{i};
                
                disp(segmentation_type);

                % get segmentations:
                segmentations_temp = segmentations.seg_3D.(segmentation_type);

                % get masks (used for measuring some features):
                masks = organoids2.measure_features.get_3D_mask(segmentations_temp, image_height, image_width, image_depth);

                % volume:
                volume = organoids2.measure_features.measure_volume(masks, voxel_size);
                features.(sprintf('feature_volume_%s_mean', segmentation_type)) = mean(volume);
                features.(sprintf('feature_volume_%s_st_dev', segmentation_type)) = std(volume);

                % total volume:
                volume_total = organoids2.measure_features.measure_volume_total(volume);
                features.(sprintf('feature_volume_total_%s', segmentation_type)) = volume_total;

                % number:
                number = organoids2.measure_features.measure_number_objects(segmentations_temp);
                features.(sprintf('feature_number_%s', segmentation_type)) = number;

                % surface areas:
                surface_area = organoids2.measure_features.measure_surface_area(masks, voxel_size);
                features.(sprintf('feature_surface_area_%s_mean', segmentation_type)) = mean(surface_area);
                features.(sprintf('feature_surface_area_%s_st_dev', segmentation_type)) = std(surface_area);

                % height:
                height = organoids2.measure_features.measure_height(segmentations_temp);
                features.(sprintf('feature_height_%s_mean', segmentation_type)) = mean(height);
                features.(sprintf('feature_height_%s_st_dev', segmentation_type)) = std(height);

                % radius - normal:
                radius = organoids2.measure_features.measure_radius(segmentations_temp, masks, voxel_size(1), 'normal');
                features.(sprintf('feature_radius_%s_mean', segmentation_type)) = mean(radius);
                features.(sprintf('feature_radius_%s_st_dev', segmentation_type)) = std(radius);

                % radius - major axis:
                radius_major_axis = organoids2.measure_features.measure_radius(segmentations_temp, masks, voxel_size(1), 'major');
                features.(sprintf('feature_radius_major_axis_%s_mean', segmentation_type)) = mean(radius_major_axis);
                features.(sprintf('feature_radius_major_axis_%s_st_dev', segmentation_type)) = std(radius_major_axis);

                % radius - minor axis:
                radius_minor_axis = organoids2.measure_features.measure_radius(segmentations_temp, masks, voxel_size(1), 'minor');
                features.(sprintf('feature_radius_minor_axis_%s_mean', segmentation_type)) = mean(radius_minor_axis);
                features.(sprintf('feature_radius_minor_axis_%s_st_dev', segmentation_type)) = std(radius_minor_axis);

                % major-to-minor-axis:
                major_to_minor_axis = organoids2.measure_features.measure_ratio(radius_major_axis, radius_minor_axis);
                features.(sprintf('feature_major_to_minor_axis_%s_mean', segmentation_type)) = mean(major_to_minor_axis);
                features.(sprintf('feature_major_to_minor_axis_%s_st_dev', segmentation_type)) = std(major_to_minor_axis);

                % eccentricity:
                eccentricity = organoids2.measure_features.measure_radius(segmentations_temp, masks, voxel_size(1), 'eccentricity');
                features.(sprintf('feature_eccentricity_%s_mean', segmentation_type)) = mean(eccentricity);
                features.(sprintf('feature_eccentricity_%s_st_dev', segmentation_type)) = std(eccentricity);

                % height-to-width:
                height_to_width = organoids2.measure_features.measure_ratio(height, radius_equivalent);
                features.(sprintf('feature_height_to_width_%s_mean', segmentation_type)) = mean(height_to_width);
                features.(sprintf('feature_height_to_width_%s_st_dev', segmentation_type)) = std(height_to_width);

            end
            
        end
        %% Next, we want to measure any features that involve multiple segmentation types. 
        
        % if there are segmentations:
        if isfield(segmentations, 'seg_3D')
            
            % get list of segmentation types:
            list_segmentation_types = fieldnames(segmentations.seg_3D);

            % wall thickness:
            wall_thickness = organoids2.measure_features.measure_wall_thickness('nearest_lumen_point', segmentations.seg_3D.lumens, segmentations.seg_3D.organoid);
            features.feature_wall_thickness_mean = mean(wall_thickness);
            features.feature_wall_thickness_st_dev = std(wall_thickness);

            % for each segmentation type:
            for i = 1:num_segmentation_types

                % get type of segmentation:
                segmentation_type = list_segmentation_types{i};

                % if the segmentation type is not organoid:
                if ~strcmp(segmentation_type, 'organoid')

                    % fractional volume:
                    volume_fractional = organoids2.measure_features.measure_ratio(features.(sprintf('feature_volume_total_%s', segmentation_type)), features.feature_volume_organoid_mean);
                    features.(sprintf('feature_volume_fractional_%s', segmentation_type)) = mean(volume_fractional);

                    % density:
                    density = organoids2.measure_features.measure_ratio(features.(sprintf('feature_number_%s', segmentation_type)), features.feature_volume_organoid_mean);
                    features.(sprintf('feature_density_%s', segmentation_type)) = density;

                end

            end
        
        end
        
        %% Next, we want to measure any features involving cell type:
        
        % if there is cell type data:
        if isfield(segmentations, 'cells')
            
            % for each cell type:
            for i = 1:numel(segmentations.cells)
                
                % get the number of cells in the organoid:
                features.(sprintf('feature_num_cells_%s', segmentations.cells(i).type)) = organoids2.measure_features.measure_num_cell_type(segmentations.cells(i).coordinates);

                % get the cell height:
                heights = organoids2.measure_features.measure_cell_height(segmentations.cells(i).coordinates_um, voxel_size(3));
                features.(sprintf('feature_height_mean_%s', segmentations.cells(i).type)) = mean(heights);
                features.(sprintf('feature_height_st_dev_%s', segmentations.cells(i).type)) = std(heights);

                % get the distance to the nearest cell of the same type:
                cell_neighbor_distance = organoids2.measure_features.measure_distance_to_nearest_cell(segmentations.cells(i).coordinates_um);
                features.(sprintf('feature_distance_nearest_neighbor_mean_%s', segmentations.cells(i).type)) = mean(cell_neighbor_distance);
                features.(sprintf('feature_distance_nearest_neighbor_st_dev_%s', segmentations.cells(i).type)) = std(cell_neighbor_distance);
                
            end

        end
        
        % save the features:
        save(sprintf('features_%s.mat', name_stack), 'features');
        
    end

end