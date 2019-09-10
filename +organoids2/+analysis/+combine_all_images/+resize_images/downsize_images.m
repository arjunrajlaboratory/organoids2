function features = downsize_images(features, image_type_to_resize, downsize_factor)

    % for each organoid:
    for i = 1:numel(features)
       
        % downsize the images (note this only affects the first two
        % dimensions):
        features(i).(image_type_to_resize) = imresize(features(i).(image_type_to_resize), (1 / downsize_factor));
        
    end

end