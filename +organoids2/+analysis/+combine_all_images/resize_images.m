function features = resize_images(features, image_type_to_resize, downsize_factor, type_label)
    
    %%% Next, we want to downsize the images in XY (so the computations are
    %%% faster and the stitched images smaller). 
    
    features = organoids.run_analysis.utilities.combine_all_images.resize_images.downsize_images(features, image_type_to_resize, downsize_factor);
    
    %%% Next, we want to determine what size the tiles need to be to fit
    %%% all the organoids. Then, we need to convert each image into that size.
    
    features = organoids.run_analysis.utilities.combine_all_images.resize_images.make_all_images_same_size(features, image_type_to_resize, type_label);

end