function using_GUI_to_draw_on_max_merge

    % get the name of the structure to segment:
    [~, structure_to_segment, ~] = fileparts(pwd);
    structure_to_segment = structure_to_segment(15:end);
    
    % get a list of images:
    list_images = dir(fullfile(pwd, '..', '*.lsm'));
    
    % get the number of images:
    num_images = numel(list_images);
    
    % for each image:
    for i = 1:num_images
        
        % get the name of the segmentations file:
        name_file = fullfile(pwd, sprintf('%s_guess_2D_%s.mat', structure_to_segment, list_images(i).name(1:6)));
        
        % if the file does not exist:
        if ~exist(name_file, 'file')
        
            % create an empty segmentations variable:
            segmentations = 'none';

            % save the segmentations:
            save(name_file, 'segmentations');
            
        end
        
    end
    
    % set the seed location:
    gui_data.seed_location = 'outside';
    
    % set the path to the segmentations and images:
    gui_data.path_segmentations = pwd;
    [gui_data.path_images, ~, ~] = fileparts(pwd);
    
    % get the list of segmentation files:
    gui_data.list_segmentation_files = dir(fullfile(pwd, sprintf('%s*guess_2D*', structure_to_segment)));
    gui_data.list_segmentation_files = extractfield(gui_data.list_segmentation_files, 'name');
    
    % get the list of images:
    gui_data.list_images = dir(fullfile(pwd, '..', 'pos*.tif'));
    
    % run the gui to review the segmentations:
    organoids2.utilities.edit_2D_segmentations.view(gui_data);

end