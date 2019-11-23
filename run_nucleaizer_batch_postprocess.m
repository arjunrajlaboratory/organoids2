function run_nucleaizer_batch_postprocess

    % load the key:
    load('key.mat');
    
    % get a list of results images:
    list_results = dir(fullfile('results', 'key*.tiff'));
    
    % for each result image:
    for i = 1:numel(list_results)
        
        % determine the key:
        temp_key = str2double(list_results(i).name(4:6));
        
        % determine the original path:
        temp_path = find([key{2,:}] == temp_key);
        temp_path = key{1, temp_path};
        
        % get the old image name:
        temp_image_name = list_results(i).name(18:end);
        
        % get the image type:
        temp_image_type = list_results(i).name(8:16);
        
        % copy the results to the original folder:
        copyfile(fullfile(list_results(i).folder, list_results(i).name), fullfile(temp_path, 'segmentations_nuclei', temp_image_type, 'results', temp_image_name));
        
    end

end