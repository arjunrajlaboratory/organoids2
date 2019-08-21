function [image, image_properties] = load_lsm_stack(path_to_stack)

    % read the image:
    [image, image_properties] = organoids2.utilities.load_lsm_stack.lsmread(path_to_stack);

    % eliminate time dimension of stack:
    image = squeeze(image);

    % re-arrange slice dimensions  to [rows cols slices channels]:
    image = permute(image, [3 4 2 1]);

end