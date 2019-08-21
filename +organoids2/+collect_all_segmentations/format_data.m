function data = format_data(data)

    % get a list of segmentations and cell types:
    list_fields = fieldnames(data.segmentations);
    list_segmentations = list_fields(~contains(list_fields, 'cells'));
    list_cell_types = list_fields(contains(list_fields, 'cells'));
    
    % for each segmentation:
    for i = 1:numel(list_segmentations)
        
        % get the segmentations:
        segmentations_temp_2D = data.segmentations.(list_segmentations{i}).segmentations_2D;
        
        % get the coordinates in um (in addition to pixels):
        segmentations_temp_2D = organoids2.utilities.convert_coords_pixel_to_um(segmentations_temp_2D, 'boundary', data.voxel_size_x, data.voxel_size_y, data.voxel_size_z);
        segmentations_temp_2D = organoids2.utilities.convert_coords_pixel_to_um(segmentations_temp_2D, 'mask', data.voxel_size_x, data.voxel_size_y, data.voxel_size_z);
        
        % get the structure where each entry is a 3D (not 2D) object:
        segmentations_temp_3D = get_structure_per_3D_segmentation(segmentations_temp_2D);
        
        % save:
        data.segmentations.(list_segmentations{i}).segmentations_2D = segmentations_temp_2D;
        data.segmentations.(list_segmentations{i}).segmentations_3D = segmentations_temp_3D;
        
    end
    
    % for each cell type:
    for i = 1:numel(list_cell_types)
        
        % get the cells:
        cells_temp_2D = data.segmentations.(list_cell_types{i}).cells_2D;
        
        % get the coordinates in um (in addition to pixels):
        cells_temp_2D = organoids2.utilities.convert_coords_pixel_to_um(cells_temp_2D, 'boundary', data.voxel_size_x, data.voxel_size_y, data.voxel_size_z);
        
        % get the structure where each entry is a 3D (not 2D) object:
        cells_temp_3D = get_structure_per_3D_cell(cells_temp_2D);
        
        % save:
        data.segmentations.(list_cell_types{i}).cells_2D = cells_temp_2D;
        data.segmentations.(list_cell_types{i}).cells_3D = cells_temp_3D;
        
    end
    
end

% function to get structure with entry for each 3D segmentation:
function seg_3D = get_structure_per_3D_segmentation(seg_2D)

    % if there are NO objects:
    if ~isstruct(seg_2D)
        
        % save the structure as an empty:
        seg_3D = seg_2D;
        
    % otherwise:
    else
        
        % get list of 3D objects:
        list_objects_3D = unique(extractfield(seg_2D, 'object_num'));
        num_objects_3D = numel(list_objects_3D);
        
        % create structure to save 3D objects:
        seg_3D = struct;
        [seg_3D(1:num_objects_3D).slices] = deal([]);
        [seg_3D(1:num_objects_3D).boundary] = deal([]);
        [seg_3D(1:num_objects_3D).boundary_um] = deal([]);
        [seg_3D(1:num_objects_3D).mask] = deal([]);
        [seg_3D(1:num_objects_3D).mask_um] = deal([]);

        % for each 3D object:
        for k = 1:num_objects_3D

            % get all 2D objects:
            seg_2D_object = organoids2.utilities.get_structure_results_matching_number(seg_2D, 'object_num', list_objects_3D(k));

            % combine all coordinates:
            coords_boundary = seg_2D_object(1).boundary;
            coords_boundary_um = seg_2D_object(1).boundary_um;
            coords_mask = seg_2D_object(1).mask;
            coords_mask_um = seg_2D_object(1).mask_um;
            for l = 2:numel(seg_2D_object)
               coords_boundary = [coords_boundary; seg_2D_object(l).boundary]; 
               coords_boundary_um = [coords_boundary_um; seg_2D_object(l).boundary_um]; 
               coords_mask = [coords_mask; seg_2D_object(l).mask];
               coords_mask_um = [coords_mask_um; seg_2D_object(l).mask_um];
            end

            % save to structure:
            seg_3D(k).slices = unique(coords_boundary(:,3));
            seg_3D(k).boundary = coords_boundary;
            seg_3D(k).boundary_um = coords_boundary_um;
            seg_3D(k).mask = coords_mask;
            seg_3D(k).mask_um = coords_mask_um;

        end
    
    end

end

% function to convert cell coordinates from array to struct:
function cells_struct_3D = get_structure_per_3D_cell(cells_struct_2D)

    % get a list of cell ids:
    cell_ids = unique(extractfield(cells_struct_2D, 'object_num'));

    % get number of cells:
    num_cells = numel(cell_ids);
    
    % create structure to store cells:
    [cells_struct_3D(1:num_cells).slices] = deal(0);
    [cells_struct_3D(1:num_cells).boundary] = deal([]);
    [cells_struct_3D(1:num_cells).boundary_um] = deal([]);
    
    % for each cell:
    for i = 1:num_cells
        
        % get all entries for this cell:
        cells_struct_2D_temp = organoids2.utilities.get_structure_results_matching_number(cells_struct_2D, 'object_num', cell_ids(i));
        
        % combine all coordinates:
        coords_boundary = cells_struct_2D_temp(1).boundary;
        coords_boundary_um = cells_struct_2D_temp(1).boundary_um;
        for l = 2:numel(cells_struct_2D_temp)
           coords_boundary = [coords_boundary; cells_struct_2D_temp(l).boundary]; 
           coords_boundary_um = [coords_boundary_um; cells_struct_2D_temp(l).boundary_um]; 
        end

        % save to structure:
        cells_struct_3D(i).slices = unique(coords_boundary(:,3));
        cells_struct_3D(i).boundary = coords_boundary;
        cells_struct_3D(i).boundary_um = coords_boundary_um;

    end

end