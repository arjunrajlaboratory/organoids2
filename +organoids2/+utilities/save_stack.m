function save_stack(image_stack, image_name)

    % get number of slices:
    num_slices = size(image_stack, 3);
    
    % save first slice:
    imwrite(image_stack(:, :, 1), image_name)
    
    % save all other slices:
    for i = 2:num_slices

        imwrite(image_stack(:, :, i), image_name, 'writemode', 'append');
        
    end

end