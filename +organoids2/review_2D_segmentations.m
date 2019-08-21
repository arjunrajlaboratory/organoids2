function review_2D_segmentations

    % get the name of the structure to segment:
    settings.name_structure = organoids2.utilities.ask_user_what_structure_to_segment;
    
    % set the seed location:
    switch settings.name_structure
        case {'lumens_final', 'buds_final'}
            settings.seed_location = 'inside';
        case 'organoid_final'
            settings.seed_location = 'outside';
        otherwise
            error('No seed location set for segmenting %s', settings.name_structure);
    end
    
    % ask user what channel they want to use for the calculations:
    settings.string_image_calculate = organoids2.utilities.ask_user_to_choose_channel(fullfile(pwd, '..'), 'What channel do you want to use for calculations?');

    % ask user what channel they want to display:
    settings.string_image_display = organoids2.utilities.ask_user_to_choose_channel(fullfile(pwd, '..'), 'What channel do you want to display?');
    
    % run the gui to review the segmentations:
    organoids2.review_2D_segmentations.view(settings);

end