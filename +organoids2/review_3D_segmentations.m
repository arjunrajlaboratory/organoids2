function review_3D_segmentations

    % get the name of the structure to segment:
    [~, structure_to_segment, ~] = fileparts(pwd);
    structure_to_segment = structure_to_segment(15:end);
    
    % get a list of segmentation types in the folder:
    list_segmentation_files = dir(fullfile(pwd, sprintf('%s*final_3D*', structure_to_segment)));
    list_segmentation_files = extractfield(list_segmentation_files, 'name');
    
    % set the path to the segmentations and images:
    gui_data.path_segmentations = pwd;
    [gui_data.path_images, ~, ~] = fileparts(pwd);
    
    % get the list of segmentation files:
    gui_data.list_segmentation_files = list_segmentation_files;
    
    % get the list of images:
    gui_data.list_images = dir(fullfile(pwd, '..', 'pos*.tif'));
    
    % run the gui to review the segmentations:
    organoids2.utilities.edit_3D_segmentations.view(gui_data);

end