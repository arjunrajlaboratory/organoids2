function data = collect_all_data_into_one_structure(name_stack)

    % load the image info to get image dimensions and voxel sizes:
    image_info = organoids2.utilities.load_structure_from_file(sprintf('image_info_%s.mat', name_stack));
    height = image_info.height;
    width = image_info.width;
    depth = image_info.depth;
    voxel_size_x = image_info.voxel_size_x;
    voxel_size_y = image_info.voxel_size_y;
    voxel_size_z = image_info.voxel_size_z;
    
    % create structure to store segmentations:
    segmentations = struct;
    
    % get a list of folders containing segmentations:
    list_folders_segmentations = dir('segmentations*');
    
    % for each segmentation folder:
    for i = 1:numel(list_folders_segmentations)
       
        % get the name of the segmentation:
        name_segmentation = list_folders_segmentations(i).name(15:end);
        
        % load the segmentation file:
        segmentations_temp_2D = organoids2.utilities.load_structure_from_file(fullfile(pwd, list_folders_segmentations(i).name, sprintf('%s_final_3D_%s.mat', name_segmentation, name_stack)));
        
        % remove the segmentation id field:
        if ~ischar(segmentations_temp_2D)
            segmentations_temp_2D = rmfield(segmentations_temp_2D, 'segmentation_id');
        end
        
        % save segmentation:
        segmentations.(name_segmentation).segmentations_2D = segmentations_temp_2D;
        
    end
        
    % get a list of fodlers containing cells:
    list_folders_cells = dir('cells*');
    
    % for each cell folder:
    for i = 1:numel(list_folders_cells)
        
        % get the name of the cell type:
        name_cell = list_folders_cells(i).name;
        
        % load the cell file:
        cells_temp_2D = organoids2.utilities.load_structure_from_file(fullfile(pwd, list_folders_cells(i).name, sprintf('%s_%s.mat', name_cell, name_stack)));
        
        % format the cells data into a structure:
        cells_temp_2D = format_cells_coordinates(cells_temp_2D);
        
        % save:
        segmentations.(name_cell).cells_2D = cells_temp_2D;
        
    end
    
    % save info to the structure:
    data = struct;
    data.name_stack = name_stack;
    data.height = height;
    data.width = width;
    data.depth = depth;
    data.voxel_size_x = voxel_size_x;
    data.voxel_size_y = voxel_size_y;
    data.voxel_size_z = voxel_size_z;
    data.segmentations = segmentations;
    
end

% function to get structure with entry for each 3D cell:
function cells_struct = format_cells_coordinates(cells_array)

    % get the number of cells:
    num_cells = size(cells_array, 1);
    
    % create a structure to store the cells:
    [cells_struct(1:num_cells).slice] = deal(0);
    [cells_struct(1:num_cells).boundary] = deal([]);
    [cells_struct(1:num_cells).object_num] = deal(0);
    
    % for each cell:
    for i = 1:num_cells
       
        % get the data
        cells_struct(i).slice = cells_array(i,4);
        cells_struct(i).boundary = cells_array(i,2:4);
        cells_struct(i).object_num = cells_array(i,1);
        
    end

end