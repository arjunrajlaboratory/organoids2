function measure_features

    % get the organoid type:
    organoid_type = organoids2.utilities.load_structure_from_file('organoid_type.mat');

    % get a list of data files:
    list_segmentation_files = dir('all_segmentations*.mat');
    
    % for each file:
    for j = 1:numel(list_segmentation_files)

        % load the data:
        data = organoids2.utilities.load_structure_from_file(list_segmentation_files(j).name);
        
        % get the stack name:
        name_stack = data.name_stack;
        
        % print status:
        fprintf('Working on %s\n', name_stack);
        
        % get voxel size:
        voxel_size = [data.voxel_size_x, data.voxel_size_y, data.voxel_size_z];
        
        % get image dimensions:
        image_height = data.height;
        image_width = data.width;
        image_depth = data.depth;
        
        % create a structure to store the features:
        features = struct;
        
        % get a list of data sets:
        list_data_sets = fieldnames(data.segmentations);
        
        % for each data set:
        for k = 1:numel(list_data_sets)
            
            % get the name of the data set:
            name_data_set = list_data_sets{k};
            
            % if there are any segmentations:
            if ~ischar(data.segmentations.(name_data_set))
                
                % for each set of objects (organoid, bud, cyst):
                for l = 1:numel(data.segmentations.(name_data_set))

                    % get the segmentations:
                    segmentations = data.segmentations.(name_data_set)(l);

                    % save the features:
                    features.(name_data_set)(l) = measure_features_for_a_data_set(segmentations, name_data_set, organoid_type, voxel_size, image_height, image_width, image_depth);
                    
                    
                end
                
            % otherwise
            else
                
                % set features to none:
                features.(name_data_set) = 'none';
                
            end
            
        end

        % save the features:
        organoids2.utilities.save_within_parfor_loop(sprintf('features_%s.mat', name_stack), features);
        
    end

end

% function to measure features for a set of segmentations:
function features = measure_features_for_a_data_set(segmentations_all, name_data_set, organoid_type, voxel_size, image_height, image_width, image_depth)
    
    %%% First, we need to crop the organoid so that we are always comparing
    %%% the same amount of each data set. For example, if the data set is
    %%% per-organoid I want to measure features ONLY on the bottom half.
    %%% Alternatively, if the data set is per-bud I want to measure
    %%% features ONLY when I have the full bud segmentations. This is
    %%% necessary because I cannot image the same amount of each organoid.
    
    % depending on the name of the data set, set the method for cropping the segmentations:
    switch name_data_set
        case 'per_organoid'
            switch organoid_type
                case 'MDCK'
                    method_crop = 'crop at slice where organoid area largest';
                case 'Intestine'
                    method_crop = 'crop at slice where cyst area largest';
            end
        case 'per_bud'
            method_crop = 'none';
        case 'per_cyst'
            method_crop = 'crop at slice where organoid area largest';
    end
        
    % get the cropped segmentations:
    [segmentations_all, features.slice_middle] = organoids2.measure_features.crop_segmentations(segmentations_all, method_crop, image_height, image_width, image_depth);
    
    %%% Next, we want to measure all the features that involve a single
    %%% segmentation type.
    
    % get a list of segmentation types:
    list_segmentation_types = fieldnames(segmentations_all);
    
    % for each segmentation type:
    for i = 1:numel(list_segmentation_types)
        
        % get the name of the segmentation:
        name_segmentation = list_segmentation_types{i};
        
        % get the segmentations:
        segmentations_temp = segmentations_all.(name_segmentation);
        
        % get the masks:
        masks_temp = organoids2.measure_features.get_3D_mask(segmentations_temp, image_height, image_width, image_depth);
        
        % volume:
        switch name_segmentation
            case {'organoid', 'buds', 'cyst', 'lumens', 'nuclei'}
                volume = organoids2.measure_features.measure_volume(masks_temp, voxel_size);
                features.(sprintf('feature_volume_%s_mean', name_segmentation)) = mean(volume);
                features.(sprintf('feature_volume_%s_st_dev', name_segmentation)) = std(volume);
        end
        
        % total volume:
        switch name_segmentation
            case {'organoid', 'buds', 'cyst', 'lumens', 'nuclei'}
                volume_total = organoids2.measure_features.measure_volume_total(volume);
                features.(sprintf('feature_volume_total_%s', name_segmentation)) = volume_total;
        end
        
        % number:
        switch name_segmentation
            case {'buds', 'lumens', 'nuclei', 'cells_Lgr5', 'cells_Paneth'}
                number = organoids2.measure_features.measure_number_objects(segmentations_temp);
                features.(sprintf('feature_number_%s', name_segmentation)) = number;
        end
 
        % surface area:
        switch name_segmentation
            case {'organoid', 'buds', 'cyst', 'lumens', 'nuclei'}
                surface_area = organoids2.measure_features.measure_surface_area(segmentations_temp);
                features.(sprintf('feature_surface_area_%s_mean', name_segmentation)) = mean(surface_area);
                features.(sprintf('feature_surface_area_%s_st_dev', name_segmentation)) = std(surface_area);
        end
        
        % radius Z:
        switch name_segmentation
            case {'organoid', 'buds', 'cyst', 'lumens', 'nuclei'}
                radius_Z = organoids2.measure_features.measure_radius_Z(segmentations_temp);
                features.(sprintf('feature_radius_Z_%s_mean', name_segmentation)) = mean(radius_Z);
                features.(sprintf('feature_radius_Z_%s_st_dev', name_segmentation)) = std(radius_Z);
        end
        
        % radius XY:
        switch name_segmentation
            case {'organoid', 'buds', 'cyst', 'lumens', 'nuclei'}
                radius_XY = organoids2.measure_features.measure_radius_XY(segmentations_temp, masks_temp, voxel_size(1), 'XY');
                features.(sprintf('feature_radius_XY_%s_mean', name_segmentation)) = mean(radius_XY);
                features.(sprintf('feature_radius_XY_%s_st_dev', name_segmentation)) = std(radius_XY);
        end
        
        % major axis (XY):
        switch name_segmentation
            case {'organoid', 'buds', 'cyst', 'lumens', 'nuclei'}
                major_axis = organoids2.measure_features.measure_radius_XY(segmentations_temp, masks_temp, voxel_size(1), 'major');
                features.(sprintf('feature_major_axis_%s_mean', name_segmentation)) = mean(major_axis);
                features.(sprintf('feature_major_axis_%s_st_dev', name_segmentation)) = std(major_axis);
        end
        
        % minor axis (XY):
        switch name_segmentation
            case {'organoid', 'buds', 'cyst', 'lumens', 'nuclei'}
                minor_axis = organoids2.measure_features.measure_radius_XY(segmentations_temp, masks_temp, voxel_size(1), 'minor');
                features.(sprintf('feature_minor_axis_%s_mean', name_segmentation)) = mean(minor_axis);
                features.(sprintf('feature_minor_axis_%s_st_dev', name_segmentation)) = std(minor_axis);
        end
        
        % major-to-minor-axis (XY):
        switch name_segmentation
            case {'organoid', 'buds', 'cyst', 'lumens', 'nuclei'}
                major_to_minor_axis = organoids2.measure_features.measure_ratio(major_axis, minor_axis);
                features.(sprintf('feature_major_to_minor_axis_%s_mean', name_segmentation)) = mean(major_to_minor_axis);
                features.(sprintf('feature_major_to_minor_axis_%s_st_dev', name_segmentation)) = std(major_to_minor_axis);
        end
        
        % eccentricity (XY):
        switch name_segmentation
            case {'organoid', 'buds', 'cyst', 'lumens', 'nuclei'}
                eccentricity = organoids2.measure_features.measure_radius_XY(segmentations_temp, masks_temp, voxel_size(1), 'eccentricity');
                features.(sprintf('feature_eccentricity_%s_mean', name_segmentation)) = mean(eccentricity);
                features.(sprintf('feature_eccentricity_%s_st_dev', name_segmentation)) = std(eccentricity);
        end

        % radius-Z-to-radius-XY:
        switch name_segmentation
            case {'organoid', 'buds', 'cyst', 'lumens', 'nuclei'}
                radius_Z_to_radius_XY = organoids2.measure_features.measure_ratio(radius_Z, radius_XY);
                features.(sprintf('feature_radius_Z_to_radius_XY_%s_mean', name_segmentation)) = mean(radius_Z_to_radius_XY);
                features.(sprintf('feature_radius_Z_to_radius_XY_%s_st_dev', name_segmentation)) = std(radius_Z_to_radius_XY);
        end
        
        % solidity:
        switch name_segmentation
            case {'organoid', 'buds', 'cyst', 'lumens', 'nuclei'}
                solidity = organoids2.measure_features.measure_solidity(masks_temp);
                features.(sprintf('feature_solidity_%s_mean', name_segmentation)) = mean(solidity);
                features.(sprintf('feature_solidity_%s_st_dev', name_segmentation)) = std(solidity);
        end
        
        % 3D radius:
        switch name_segmentation
            case {'organoid'}
                radius_3D = organoids2.measure_features.measure_radius_3D(segmentations_temp, voxel_size(3));
                features.(sprintf('feature_radius_3D_%s_st_dev', name_segmentation)) = std(radius_3D);
                features.(sprintf('feature_radius_3D_%s_c_v', name_segmentation)) = std(radius_3D) / mean(radius_3D);
        end
        
    end
    
    %%% Next, we want to measure all features the involve multiple
    %%% segmentation types:

    % number internal and external nuclei:
    if nnz(contains(list_segmentation_types, 'nuclei'))
        [features.feature_number_nuclei_internal, features.feature_number_nuclei_external] = organoids2.measure_features.measure_number_internal_external_nuclei(segmentations_all.lumens, segmentations_all.nuclei);
    end
    
    % external cell height:
    external_cell_height = organoids2.measure_features.measure_external_cell_height('nearest_lumen_point', segmentations_all.lumens, segmentations_all.organoid);
    features.feature_external_cell_height_mean = mean(external_cell_height);
    features.feature_external_cell_height_st_dev = std(external_cell_height);
    
    % external cell width:
    if nnz(contains(list_segmentation_types, 'nuclei'))
        external_cell_width = organoids2.measure_features.measure_external_cell_width(segmentations_all.lumens, segmentations_all.nuclei);
        features.feature_external_cell_width_mean = mean(external_cell_width);
        features.feature_external_cell_width_st_dev = std(external_cell_width);
    end
    
    % fractional volume:
    if nnz(contains(list_segmentation_types, 'buds'))
        volume_fractional_buds = organoids2.measure_features.measure_ratio(features.feature_volume_total_buds, features.feature_volume_organoid_mean);
        features.feature_volume_fractional_buds = mean(volume_fractional_buds);
    end
    if nnz(contains(list_segmentation_types, 'cyst'))
        volume_fractional_cyst = organoids2.measure_features.measure_ratio(features.feature_volume_total_cyst, features.feature_volume_organoid_mean);
        features.feature_volume_fractional_cyst = mean(volume_fractional_cyst);
    end
    if nnz(contains(list_segmentation_types, 'lumens'))
        volume_fractional_lumens = organoids2.measure_features.measure_ratio(features.feature_volume_total_lumens, features.feature_volume_organoid_mean);
        features.feature_volume_fractional_lumens = mean(volume_fractional_lumens);
    end
    if nnz(contains(list_segmentation_types, 'nuclei'))
        volume_fractional_nuclei = organoids2.measure_features.measure_ratio(features.feature_volume_total_nuclei, features.feature_volume_organoid_mean);
        features.feature_volume_fractional_nuclei = mean(volume_fractional_nuclei);
    end
    
    % density:
    if nnz(contains(list_segmentation_types, 'buds'))
        density_buds = organoids2.measure_features.measure_ratio(features.feature_number_buds, features.feature_volume_organoid_mean);
        features.feature_density_buds = mean(density_buds);
    end
    if nnz(contains(list_segmentation_types, 'lumens'))
        density_lumens = organoids2.measure_features.measure_ratio(features.feature_number_lumens, features.feature_volume_organoid_mean);
        features.feature_density_lumens = mean(density_lumens);
    end
    if nnz(contains(list_segmentation_types, 'nuclei'))
        density_nuclei = organoids2.measure_features.measure_ratio(features.feature_number_nuclei, features.feature_volume_organoid_mean);
        features.feature_density_nuclei = mean(density_nuclei);
    end
    
    % cell volume:
    if nnz(contains(list_segmentation_types, 'nuclei'))
        features.feature_cell_volume_mean = organoids2.measure_features.measure_cell_volume(features.feature_volume_organoid_mean, features.feature_volume_total_lumens, features.feature_number_nuclei);
    end
    
%         %% Next, we want to measure any features involving cell type:
%         
%         % if there is cell type data:
%         if isfield(segmentations, 'cells')
%             
%             % for each cell type:
%             for i = 1:numel(segmentations.cells)
%                 
%                 % get the number of cells in the organoid:
%                 features.(sprintf('feature_num_cells_%s', segmentations.cells(i).type)) = organoids2.measure_features.measure_num_cell_type(segmentations.cells(i).coordinates);
% 
%                 % get the cell height:
%                 heights = organoids2.measure_features.measure_cell_height(segmentations.cells(i).coordinates_um, voxel_size(3));
%                 features.(sprintf('feature_height_mean_%s', segmentations.cells(i).type)) = mean(heights);
%                 features.(sprintf('feature_height_st_dev_%s', segmentations.cells(i).type)) = std(heights);
% 
%                 % get the distance to the nearest cell of the same type:
%                 cell_neighbor_distance = organoids2.measure_features.measure_distance_to_nearest_cell(segmentations.cells(i).coordinates_um);
%                 features.(sprintf('feature_distance_nearest_neighbor_mean_%s', segmentations.cells(i).type)) = mean(cell_neighbor_distance);
%                 features.(sprintf('feature_distance_nearest_neighbor_st_dev_%s', segmentations.cells(i).type)) = std(cell_neighbor_distance);
%                 
%             end
% 
%         end

end