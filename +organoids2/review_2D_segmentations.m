function review_2D_segmentations

    % get the name of the structure to segment:
    [~, structure_to_segment, ~] = fileparts(pwd);
    structure_to_segment = structure_to_segment(15:end);
    
    % set the seed location:
    switch structure_to_segment
        case {'lumens', 'buds', 'nuclei'}
            settings.seed_location = 'inside';
        case 'organoid'
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