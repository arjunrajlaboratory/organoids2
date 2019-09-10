function [stitch, features] = create_stitched_image(features, image_field_to_use, type_sort, type_label, label_sort)

    % depending on the type of sort:
    switch type_sort
        
        case {'By_Feature', 'Randomly'}
            
            % create stitched image:
            [stitch, features] = organoids.run_analysis.utilities.combine_all_images.create_stitched_image.square(features, image_field_to_use);
            
        case {'By_Perturbation', 'By_Perturbation_Then_Feature'}
            
            % create stitched image:
            [stitch, features] = organoids.run_analysis.utilities.combine_all_images.create_stitched_image.rows(features, image_field_to_use);
        
    end
    
    % depending on the label the user wants to add:
    switch type_label
        
        % if the user wants the sorting style on the image:
        case {'Type of Sort', 'Both'}
    
            % add label to stitch:
            stitch = organoids.run_analysis.utilities.combine_all_images.create_stitched_image.add_label_to_stitch(stitch, label_sort, 'lower_right', 12);
    
    end
    
end