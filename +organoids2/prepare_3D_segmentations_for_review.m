function prepare_3D_segmentations_for_review

    % get a list of the 2D segmentation files:
    list_files = dir('*guess_3D*.mat');
    
    % for each file:
    for i = 1:numel(list_files)
        
        % get the original file name:
        file_name_original = list_files(i).name;
        
        % get the new file name:
        file_name_new = strrep(file_name_original, 'guess', 'final');
        
        % copy and rename the file:
        copyfile(file_name_original, file_name_new);
        
    end

end