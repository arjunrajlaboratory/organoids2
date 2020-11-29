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
        
        % get the path to the segmentation file:
        path_segmentation_file = fullfile(pwd, list_folders_segmentations(i).name, sprintf('%s_final_3D_%s.mat', name_segmentation, name_stack));
        
        % if the segmentation file exists:
        if isfile(path_segmentation_file)
        
            % load the segmentation file:
            segmentations_temp_2D = organoids2.utilities.load_structure_from_file(path_segmentation_file);
            
            % if the segmentation file is nuclear:
            if strcmp(name_segmentation, 'nuclei')
                
                % if the nuclear segmentations were analyzed with cellpose:
                if exist('segmentations_nuclei/cellpose_images', 'dir') == 7
                
                    % remove any segmentations not connected to other
                    % segmentations:
                    segmentations_temp_2D = remove_unconnected_segmentations(segmentations_temp_2D);
                
                end
                
            end

            % save segmentation:
            segmentations.(name_segmentation) = segmentations_temp_2D;
        
        end
        
    end
        
    % get a list of fodlers containing cells:
    list_folders_cells = dir('cells*');
    
    % for each cell folder:
    for i = 1:numel(list_folders_cells)
        
        % get the name of the cell type:
        name_cell = list_folders_cells(i).name;
        
        % load the cell file:
        segmentations_temp_2D = organoids2.utilities.load_structure_from_file(fullfile(pwd, list_folders_cells(i).name, sprintf('%s_%s.mat', name_cell, name_stack)));
        
        % format the cells data into a structure:
        segmentations_temp_2D = format_cells_coordinates(segmentations_temp_2D);
        
        % save:
        segmentations.(name_cell) = segmentations_temp_2D;
        
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

% function to remove unconnected segmentations:
function segmentations = remove_unconnected_segmentations(segmentations)
        
    % get a list of 3D object numbers:
    list_3D_objects = unique(extractfield(segmentations, 'object_num'));

    % get the number of 2D objects in each 3D object:
    number_2D_objects_per_3D_object = zeros(size(list_3D_objects));
    for i = 1:numel(list_3D_objects)
        number_2D_objects_per_3D_object(i) = nnz(extractfield(segmentations, 'object_num') == list_3D_objects(i));
    end

    % get a list of 3D objects with only 1 member:
    list_3D_objects_unconnected = list_3D_objects(number_2D_objects_per_3D_object < 2);

    % for each unconnected object:
    for i = 1:numel(list_3D_objects_unconnected)
        [~, rows_remove] = organoids2.utilities.get_structure_results_matching_number(segmentations, 'object_num', list_3D_objects_unconnected(i));
        segmentations(rows_remove) = [];
    end

end

% function to get structure with entry for each 3D cell:
function cells_struct = format_cells_coordinates(cells_array)

    % get the number of cells:
    num_cells = size(cells_array, 1);
    
    % create a structure to store the cells:
    [cells_struct(1:num_cells).slice] = deal(0);
    [cells_struct(1:num_cells).boundary] = deal([]);
    [cells_struct(1:num_cells).mask] = deal([]);
    [cells_struct(1:num_cells).object_num] = deal(0);
    
    % for each cell:
    for i = 1:num_cells
       
        % get the data
        cells_struct(i).slice = cells_array(i,4);
        cells_struct(i).boundary = cells_array(i,2:4);
        cells_struct(i).mask = cells_array(i,2:4);
        cells_struct(i).object_num = cells_array(i,1);
        
    end

end