function review_2D_segmentations

    % get the name of the structure to segment:
    [~, structure_to_segment, ~] = fileparts(pwd);
    structure_to_segment = structure_to_segment(15:end);
    
    % set the seed location:
    switch structure_to_segment
        case {'lumens', 'nuclei'}
            gui_data.seed_location = 'inside';
        case {'organoid', 'buds'}
            gui_data.seed_location = 'outside';
        otherwise
            error('No seed location set for segmenting %s', structure_to_segment);
    end
    
    % get a list of segmentation types in the folder:
    list_segmentation_files = dir(fullfile(pwd, sprintf('%s*final_2D*', structure_to_segment)));
    list_segmentation_files = extractfield(list_segmentation_files, 'name');
    list_segmentation_types = unique(cellfun(@(x) x(1:strfind(x, 'final')-2), list_segmentation_files, 'UniformOutput', false));
    
    % if there is more than one type of data in the folder:
    if numel(list_segmentation_types) ~= 1
        
        % ask user which type of segmentation they want to review:
        [index, ~] = listdlg('ListString', list_segmentation_types, 'PromptString', 'Which structure do you want to review?', 'SelectionMode', 'single');
        
        % update the list of segmentation files:
        list_segmentation_files = list_segmentation_files(contains(list_segmentation_files, list_segmentation_types{index}));
        
    end
    
    % set the path to the segmentations and images:
    gui_data.path_segmentations = pwd;
    [gui_data.path_images, ~, ~] = fileparts(pwd);
    
    % get the list of segmentation files:
    gui_data.list_segmentation_files = list_segmentation_files;
    
    % get the list of images:
    gui_data.list_images = dir(fullfile(pwd, '..', 'pos*.tif'));
    
    % run the gui to review the segmentations:
    organoids2.utilities.edit_2D_segmentations.view(gui_data);

end