function rgb = create_rgb_image(image_stack, list_channels)

    % re-arrange so color is 3rd dimension and slice is 4th dimension:
    image_stack = permute(image_stack, [1 2 4 3]);
    
    % create empty array to store rgb image:
    rgb = zeros(size(image_stack, 1), size(image_stack, 2), 3, size(image_stack, 4), 'like', image_stack);
    
    % for each channel:
    for i = 1:size(image_stack, 3)
       
        % depending on the channel name:
        switch list_channels{i}
            
            % set the color for the channel:
            case 'dapi'
                color = [0.0 0.0 1.0];
            case 'gfp'
                color = [0.0 1.0 0.0];
            case 'cy3'
                color = [1.0 0.0 0.0];
            case '594'
                color = [0.5 0.0 0.5];
        end

        % add channel to rgb image:
        rgb = rgb + convert_stack_to_rgb(image_stack(:,:,i,:), color);
        
    end

end

function rgb = convert_stack_to_rgb(image_stack, color)
    
    % add rgb channels:
    image_stack = repmat(image_stack, 1, 1, 3, 1);
    
    % create array to store rgb image:
    rgb = zeros(size(image_stack), 'like', image_stack);
    
    % for each rgb channel:
    for i = 1:3
        
        % get slice intensity for that channel:
        rgb(:,:,i,:) = rgb(:,:,i,:) + image_stack(:,:,i,:) * color(i);
        
    end
    
end