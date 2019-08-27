function structure_to_segment = ask_user_what_structure_to_segment

    % list of structures:
    list_structures = {'nuclei_XY_guess', 'nuclei_XY_final', 'nuclei_XZ_guess', 'nuclei_XZ_final', 'lumens_guess', 'lumens_final', 'organoid_guess', 'organoid_final', 'buds_guess', 'buds_final'};

    % ask user what structure they are segmenting:
    [index, ~] = listdlg('ListString', list_structures, 'SelectionMode', 'single', 'PromptString', 'What structure do you want to segment?', 'ListSize', [400 300]);
    
    % get structure to segment:
    structure_to_segment = list_structures{index};

end