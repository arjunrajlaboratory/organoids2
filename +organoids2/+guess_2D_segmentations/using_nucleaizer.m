function using_nucleaizer
    
    % ask user what channel they want to use for the calculations:
    channel_calculate = organoids2.utilities.ask_user_to_choose_channel(fullfile(pwd, '..'), 'What channel do you want to use?');
    
    % get a list of images:
    list_images = dir(fullfile(pwd, '..', sprintf('*%s*', channel_calculate)));
    
    % get the number of images:
    num_images = numel(list_images);
    
    % create folders to store each set of slices:
    directory_XY = 'slices_XY';
    directory_XZ = 'slices_XZ';
    mkdir(directory_XY);
    mkdir(directory_XZ);

    % for each image:
    for i = 1:num_images
        
        % get the image name:
        image_name = list_images(i).name(1:6);
        
        % load the XY stack:
        stack_XY = readmm(fullfile(pwd, '..', list_images(i).name));
        stack_XY = stack_XY.imagedata;
        
        % create the XZ stack:
        stack_XZ = create_XZ_stack(stack_XY);
        
        % save the slices
        save_slices(stack_XY, 1, image_name, directory_XY);
        save_slices(stack_XZ, 9, image_name, directory_XZ);
        
    end
    
    % create a folder to store the nucleaizer results:
    mkdir(fullfile('slices_XY', 'results'));
    mkdir(fullfile('slices_XZ', 'results'));

end

% function to create the XZ stack:
function stack_XZ = create_XZ_stack(stack_XY)

    % get the stack in sliced in XZ:
    stack_XZ = permute(stack_XY, [3 2 1]);

    % scale using nearest neighbor interpolation:
    stack_XZ = imresize3(stack_XZ, [(6 * size(stack_XZ, 1)) size(stack_XZ, 2) size(stack_XZ, 3)], 'nearest');

    % smooth the image:
    for j = 1:size(stack_XZ, 3)
        stack_XZ(:,:,j) = imgaussfilt(stack_XZ(:,:,j), [2, 0.5]);
    end

end

% function to save slices:
function save_slices(image_stack, slice_frequency, image_name, directory)

    % for each slice:
    for i = 1:slice_frequency:size(image_stack, 3)
        
        % save the slice:
        imwrite(image_stack(:,:,i), fullfile(directory, sprintf('%s_s%03d.tif', image_name, i)));
        
    end

end