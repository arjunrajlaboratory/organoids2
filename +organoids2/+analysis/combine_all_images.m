function combine_all_images(features, paths_images, file_name)

    % get how much to downsize the images by:
    downsize_factor = str2double(inputdlg('How much do you want to downsize the images by?', ''));

    % get various variables from the features file:
    list_features = organoids.run_analysis.utilities.get_list_features(features);

    % get type of sorting:
    options_sort = {'By_Perturbation', 'By_Perturbation_Then_Feature', 'By_Feature', 'Randomly'};
    type_sort = options_sort{listdlg('ListString', options_sort, ...
        'SelectionMode', 'single', ...
        'PromptString', 'How do you want to sort the images?', ...
        'ListSize', [300 100])};
    
    % ask user how they want to label the images:
    options_label = {'Type of Sort', 'Organoid Number', 'Both', 'None'};
    type_label = options_label{listdlg('ListString', options_label, ...
        'SelectionMode', 'single', ...
        'PromptString', 'How do you want to label the images?', ...
        'ListSize', [300 100])};

    % load the images and create outline images from segmentations::
    features = organoids.run_analysis.utilities.combine_all_images.load_images(features, paths_images);

    % resize images (crop in Z -> downsize in XY -> make all same size):
    features = organoids.run_analysis.utilities.combine_all_images.resize_images(features, 'images', downsize_factor, type_label);
    features = organoids.run_analysis.utilities.combine_all_images.resize_images(features, 'outlines', downsize_factor, type_label);
    features = organoids.run_analysis.utilities.combine_all_images.resize_images(features, 'images_outlines', downsize_factor, type_label);

    % sort the organoids:
    [features, label_sort] = organoids.run_analysis.utilities.combine_all_images.sort_organoids(features, list_features, type_sort);

    % create stitched image:
    [stitch_images, features] =     organoids.run_analysis.utilities.combine_all_images.create_stitched_image(features, 'images', type_sort, type_label, label_sort);
    [stitch_outlines, ~] =          organoids.run_analysis.utilities.combine_all_images.create_stitched_image(features, 'outlines', type_sort, type_label, label_sort);
    [stitch_images_outlines, ~] =   organoids.run_analysis.utilities.combine_all_images.create_stitched_image(features, 'images_outlines', type_sort, type_label, label_sort);

    % save:
    organoids.run_analysis.utilities.combine_all_images.save_stitched_images(stitch_images, 'images', file_name);
    organoids.run_analysis.utilities.combine_all_images.save_stitched_images(stitch_outlines, 'outlines', file_name);
    organoids.run_analysis.utilities.combine_all_images.save_stitched_images(stitch_images_outlines, 'images_outlines', file_name);

end