function review_3D_segmentations
    
    % get the name of the structure to segment:
    settings.name_structure = organoids2.utilities.ask_user_what_structure_to_segment;

    % ask user what channel they want to display:
    settings.string_image_display = organoids2.utilities.ask_user_to_choose_channel(fullfile(pwd, '..'), 'What channel do you want to display?');
    
    % run the gui to review the segmentations:
    organoids2.review_3D_segmentations.view(settings);

end