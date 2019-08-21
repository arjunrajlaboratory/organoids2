function channel = ask_user_to_choose_channel(path_to_images, prompt)

    % get a list of all images:
    list_images = dir(fullfile(path_to_images, 'pos*_*'));
    list_images = extractfield(list_images, 'name');
    
    % get a list of all channels:
    list_channels = unique(cellfun(@(x) x(8:end), list_images, 'UniformOutput', false));
    
    % ask user what channel they want to use:
    [index, ~] = listdlg('ListString', list_channels, 'SelectionMode', 'single', 'PromptString', prompt, 'ListSize', [400 300]);
    channel = list_channels{index};

end