function run_nucleaizer_batch_preprocess(paths_to_data)
    
    % get the number of folders:
    num_folders = numel(paths_to_data);
    
    % make a folder to store the renamed images:
    mkdir(fullfile(pwd, 'images'));
    
    % make a folder to store the results:
    mkdir(fullfile(pwd, 'results'));

    % create a variable to store the key the connects a folder to a unique
    % number:
    key = cell(num_folders, 2);

    % for each folder:
    for i = 1:numel(paths_to_data)
        
        % save to key:
        key{1,i} = paths_to_data{i};
        key{2,i} = i;
       
        % resave the images in a format convenient for batching nucleaizer:
        resave_images_for_batching(key{1,i}, key{2,i}, 'slices_XY');
        resave_images_for_batching(key{1,i}, key{2,i}, 'slices_XZ');

    end

    % save the key:
    save('key.mat', 'key');
    
end

% function to prepare images:
function resave_images_for_batching(path_to_data, key_number, image_type)

    % get a list of slices:
    list_slices = dir(fullfile(path_to_data, 'segmentations_nuclei', image_type, 'p*.tif'));
    
    % for each slice:
    for i = 1:numel(list_slices)
       
        % get the current image name:
        image_name_current = list_slices(i).name;
        
        % get the new image name:
        image_name_new = sprintf('key%03d_%s_%s', key_number, image_type, image_name_current);
        
        % copy and rename image:
        copyfile(fullfile(list_slices(i).folder, image_name_current), fullfile(pwd, 'images', image_name_new));
        
    end

end