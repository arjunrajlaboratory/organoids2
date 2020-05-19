function prepare_2D_segmentations_for_review

    % get the name of the structure to segment:
    [~, structure_to_segment, ~] = fileparts(pwd);
    structure_to_segment = structure_to_segment(15:end);
    
    % if that structure is nuclei:
    if strcmp(structure_to_segment, 'nuclei')
        
        if exist('slices_XY', 'dir') && exist('slices_XZ', 'dir')
        
            % format the results from nucleaizer:
            process_nucleaizer_results('slices_XY', 'nuclei_XY');
            process_nucleaizer_results('slices_XZ', 'nuclei_XZ');
        
        elseif exist('cellpose_images', 'dir') && exist('cellpose_results', 'dir')
            
            % format the results from cellpose:
            process_cellpose_results;
            
        end
        
    end

    % get a list of the 2D segmentation files:
    list_files = dir('*guess_2D*.mat');
    
    % for each file:
    for i = 1:numel(list_files)
        
        % get the original file name:
        file_name_original = list_files(i).name;

        % get the new file name:
        file_name_new = strrep(file_name_original, 'guess', 'final');
        
        % depending on the name of the structure:
        switch structure_to_segment
            
            % for buds:
            case 'buds'
                
                % load the segmentations:
                segmentations_guess = organoids2.utilities.load_structure_from_file(file_name_original);
                
                % create the structure to store segmentations:
                segmentations_final = organoids2.review_2D_segmentations.model(file_name_new);
                
                % if there are no segmentations:
                if ischar(segmentations_guess)
                    
                    % do nothing:
                    
                % otherwise
                else
                    
                    % load the image:
                    image = readmm(fullfile(list_files(i).folder, '..', sprintf('%s_dapi.tif', list_files(i).name(end-9:end-4))));
                    num_slices = image.numplanes;
                    
                    % get the number of annotations on each slice:
                    num_annotations_per_slice = numel(segmentations_guess);

                    % for each annotation:
                    for j = 1:num_annotations_per_slice

                        % for each slice:
                        for k = 1:num_slices

                            % get the boundary coords:
                            coords_boundary = segmentations_guess(j).boundary;

                            % get the mask coords:
                            coords_mask = segmentations_guess(j).mask;

                            % update the slice number on the coords:
                            coords_boundary(:,3) = deal(k);
                            coords_mask(:,3) = deal(k);

                            % add the data:
                            segmentations_final = segmentations_final.add_segmentation(coords_boundary, coords_mask);

                        end

                    end

                end
                
                % save the segmentations:
                segmentations_final.save_segmentations;
                
            % for everything else:
            otherwise

                % copy and rename the file:
                copyfile(file_name_original, file_name_new);
                
        end

        
    end

end

% function to format cellpose results:
function process_cellpose_results

    % get a list of result files:
    list_results = dir(fullfile('cellpose_results', '*.tif'));
    list_results = extractfield(list_results, 'name');

    % get list of stacks:
    list_stacks = unique(cellfun(@(x) x(1:9), list_results, 'UniformOutput', false));

    % for each stack:
    for index_stack = 1:numel(list_stacks)

        % get name and type of stack:
        name_stack = list_stacks{index_stack};
        type_stack = name_stack(1:2);

        % get result files for the stack:
        list_results_for_stack = list_results(contains(list_results, name_stack));
        
        % create structure to store results:
        results = struct;
        results.slice = 1;
        results.boundary = [];
        results.mask = [];

        % for each result file:
        for index_slice = 1:numel(list_results_for_stack)

            % get the slice number:
            name_slice = list_results_for_stack{index_slice};
            num_slice = str2double(name_slice(strfind(name_slice, '_s') + 2:strfind(name_slice, '_s') + 4));

            % load the result:
            mask = imread(fullfile('cellpose_results', name_slice));

            % if there are any objects:
            if nnz(mask) ~= 0

                % format the results into coordinates:
                results_slice = convert_cellpose_mask_to_coordinates(mask, num_slice);

                % save the results:
                results = [results, results_slice];


            end

        end
        
        % remove the first placeholder:
        results(1) = [];

        % add a segmentation id:
        for index_segmentation = 1:numel(results)
            results(index_segmentation).segmentation_id = index_segmentation;
        end
        
        % save:
        save(sprintf('nuclei_%s_guess_2D_%s.mat', type_stack, name_stack(4:9)), 'results');

    end
    
end

% function to convert cellpose mask to coordinates:
function results = convert_cellpose_mask_to_coordinates(mask, num_slice)
    
    list_objects = setdiff(unique(mask), 0)';

    num_objects = numel(list_objects);
    
    colors = hsv(num_objects);
    colors = colors * (2^16 - 1);
        
    [results(1:num_objects).slice] = deal(0);
    [results(1:num_objects).boundary] = deal([]);
    [results(1:num_objects).mask] = deal([]);
    
    for index_object = 1:num_objects
        
        mask_object = mask == list_objects(index_object);
        
        object_boundary = bwboundaries(mask_object, 'noholes');
        object_boundary = object_boundary{1};
        
        [coords_boundary, coords_mask] = organoids2.utilities.get_boundary_and_mask_from_coords(object_boundary(:,2), object_boundary(:,1), size(mask, 2), size(mask, 1), num_slice);
        
        results(index_object).slice = num_slice;
        results(index_object).boundary = coords_boundary;
        results(index_object).mask = coords_mask;
                        
    end

end

% function to format nucleaizer results:
function process_nucleaizer_results(folder, structure_name)

    % get a list of all results files:
    list_files = dir(fullfile(folder, 'results', 'pos*.tiff'));
    
    % get a list of all image stacks:
    list_images = unique(cellfun(@(x) x(1:6), extractfield(list_files, 'name'), 'UniformOutput', false));
    
    % for each image stack:
    for i = 1:numel(list_images)
       
        % create a structure to store the results:
        results = struct;

        % start the index tracker:
        index = 1;

        % get a list of all relevant results files:
        list_files_image_stack = organoids2.utilities.get_structure_results_containing_string(list_files, 'name', list_images{i});
        
        % for each results file:
        for j = 1:numel(list_files_image_stack)
            
            % load the mask:
            mask = readmm(fullfile(list_files_image_stack(j).folder, list_files_image_stack(j).name));
            mask = mask.imagedata;

            % get a list of object numbers:
            list_object_nums = unique(mask);
            list_object_nums(list_object_nums == 0) = [];

            % get the number of objects:
            num_objects = numel(list_object_nums);
            
            % for each object:
            for k = 1:num_objects

                % get the mask for just that object:
                mask_object = mask == list_object_nums(k);

                % get the boundary:
                boundary = bwboundaries(mask_object);

                % if there are any boundaries:
                if numel(boundary) ~= 0

                    % get the slice number:
                    num_slice = str2double(list_files_image_stack(j).name(9:11));

                    % get boundary:
                    coords_x = boundary{1}(:,2);
                    coords_y = boundary{1}(:,1);

                    % format boundary and mask (like I normally do):
                    [coords_boundary, coords_mask] = organoids2.utilities.get_boundary_and_mask_from_coords(coords_x, coords_y, size(mask, 2), size(mask, 1), num_slice);

                    % save:
                    results(index).slice = num_slice;
                    results(index).segmentation_id = index;
                    results(index).boundary = coords_boundary;
                    results(index).mask = coords_mask;

                    % increment the index:
                    index = index + 1;

                end

            end
            
        end

        % save the results:
        save(sprintf('%s_guess_2D_%s.mat', structure_name, list_images{i}), 'results');
        
    end

end