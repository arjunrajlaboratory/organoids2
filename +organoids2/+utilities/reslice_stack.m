function image_stack_new = reslice_stack(image_stack, scale_factor)

    % if the stack has 3 dimensions (assumes order is num rows X num
    % columns X num slices):
    if numel(size(image_stack)) == 3

        % get the stack in sliced in XZ:
        image_stack_resliced = permute(image_stack, [3 2 1]);
    
        % scale the XZ stack (so it doesn't appear flat):
        image_stack_new = imresize3(image_stack_resliced, [(scale_factor * size(image_stack_resliced, 1)) size(image_stack_resliced, 2) size(image_stack_resliced, 3)], 'nearest');

    % if the stack has 4 dimensions (assumes order is num rows X num
    % columns X num channels (3) X num slices)
    elseif numel(size(image_stack)) == 4
        
        % get the stack slices in XZ:
        image_stack_resliced = permute(image_stack, [4 2 3 1]);
        
        % create array to store scaled verion of stack:
        image_stack_new = zeros([scale_factor 1 1 1] .* size(image_stack_resliced), 'like', image_stack_resliced);
        
        % for each rgb channel:
        for i = 1:3
            
            image_stack_new(:,:,i,:) = imresize3(squeeze(image_stack_resliced(:,:,i,:)), ...
                [(scale_factor * size(image_stack_resliced, 1)) size(image_stack_resliced, 2) size(image_stack_resliced, 4)]);
            
        end

    end
    
end