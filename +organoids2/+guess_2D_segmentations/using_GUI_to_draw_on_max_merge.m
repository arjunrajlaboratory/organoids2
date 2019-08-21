function using_GUI_to_draw_on_max_merge

    % get the name of the structure to segment:
    settings.name_structure = organoids2.utilities.ask_user_what_structure_to_segment;
    
    % set the seed location:
    settings.seed_location = 'outside';
    
    % ask user what channel they want to use for the calculations:
    settings.string_image_calculate = organoids2.utilities.ask_user_to_choose_channel(fullfile(pwd, '..'), 'What channel do you want to use for calculations?');

    % ask user what channel they want to display:
    settings.string_image_display = organoids2.utilities.ask_user_to_choose_channel(fullfile(pwd, '..'), 'What channel do you want to display?');
    
    % run the gui to review the segmentations:
    organoids2.review_2D_segmentations.view(settings);

end