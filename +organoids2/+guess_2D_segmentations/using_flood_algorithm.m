function using_flood_algorithm

    % get the name of the structure to segment:
    [~, structure_to_segment, ~] = fileparts(pwd);
    structure_to_segment = structure_to_segment(15:end);
    
    % set the seed location:
    switch structure_to_segment
        case 'lumens'
            seed_location = 'inside';
        case 'organoid'
            seed_location = 'outside';
        otherwise
            error('No seed location set for segmenting %s', structure_to_segment);
    end
    
    % ask user what tolerance they would like to use:
    default_tolerance = inputdlg('What tolerance would you like to use?', '');
    default_tolerance = str2double(default_tolerance{1});

    % ask user what channel they want to use for the calculations:
    channel_calculate = organoids2.utilities.ask_user_to_choose_channel(fullfile(pwd, '..'), 'What channel do you want to use?');
    
    % get a list of images:
    list_images = dir(fullfile(pwd, '..', sprintf('*%s*', channel_calculate)));
    
    % get the number of images:
    num_images = numel(list_images);
    
    % for each image:
    for i = 1:num_images
        
        % get the image name:
        image_name = list_images(i).name(1:6);
        
        % display status:
        fprintf('Working on %s\n', image_name);
        
        % load the image:
        image = readmm(fullfile(pwd, '..', list_images(i).name));
        image = image.imagedata;

        % guess the segmentations:
        segmentations = guess_segmentations(image, seed_location, default_tolerance);
        
        % remove any segmentations touching the corners:
        segmentations = organoids2.utilities.remove_segmentations_touching_corners(segmentations, size(image, 2), size(image, 1));
        
        % save the segmentations:
        save(sprintf('%s_guess_2D_%s.mat', structure_to_segment, image_name), 'segmentations');
        
    end

end

function segmentations = guess_segmentations(image, seed_location, default_tolerance)

    % get number of slices:
    num_slices = size(image, 3);
    
    %%% First, we want to create a structure to store the segmentations:
    [segmentations(1:num_slices).slice] = deal(0);
    [segmentations(1:num_slices).segmentation_id] = deal(0);
    [segmentations(1:num_slices).boundary] = deal([]);
    [segmentations(1:num_slices).mask] = deal([]);
    
    %%% Next, we want to smooth the image stack (as this makes the
    %%% segmentations less susceptible to noise).
    
    % smooth the image:
    image_smooth = zeros(size(image), 'like', image);
    
    % for each slice:
    for i = 1:num_slices
        
        % smooth the image:
        image_smooth(:,:,i) = imgaussfilt(image(:,:,i), 1); 
       
    end

    %%% Next, we want to guess the segmentation for each slice. Note that
    %%% this currently can only guess 1 segmentation per slice (which is
    %%% not the case when there are multiple lumens). Also, note to future
    %%% self that making this guess multiple segmentations per slice would
    %%% be very non-trivial (as this script and others are built to assume
    %%% that).
    
    % for each slice:
    for i = 1:num_slices
        
        %%% First, we need to set a seed point to use.

        % if the type of segmentation is inside:
        if strcmp(seed_location, 'inside')
            
            % get the centroid of the largest "hole" on the slice to use as the seed point:
            seed_point = find_largest_hole_centroid(image_smooth(:,:,i));
            
        % if the type of segmentation is outside:
        elseif strcmp(seed_location, 'outside')
            
            % use the upper left corner of the image as the seed point:
            seed_point = [10 10];
            
        end
        
        %%% Next, we need to get the boundary from the seed point:
        
        % get the coordinates of the object:
        [boundary, mask] = organoids2.utilities.expand_seed_point_to_boundary(image_smooth(:,:,i), i, seed_point, seed_location, default_tolerance);

        % save the results:
        segmentations(i).slice = i;
        segmentations(i).segmentation_id = i;
        segmentations(i).boundary = boundary;
        segmentations(i).mask = mask;
        
    end

end

function centroid = find_largest_hole_centroid(image_slice)

    % get edge image:
    image_binary = edge(image_slice, 'log');

    % dilate the edge image:
    image_binary = imdilate(image_binary, strel('disk',10));

    % remove objects on the border and invert scale:
    image_binary = ~imclearborder(image_binary);

    % get the centroids of each object:
    objects_centroids = regionprops(image_binary, 'Centroid');
    objects_centroids = struct2cell(objects_centroids);

    % get the area of each object:
    objects_areas = regionprops(image_binary, 'Area');
    objects_areas = cell2mat(struct2cell(objects_areas));

    % get the centroid of the object with the largest area and round to whole number:
    [~, index] = max(objects_areas);
    centroid = round(objects_centroids{index});

end