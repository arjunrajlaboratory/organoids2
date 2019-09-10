function save_stitched_images(image, image_type, file_name)

    % get the full file name:
    file_name = sprintf('%s_%s', file_name, image_type);

    %%% First, we save the last slice of the image as an image.

    % save the last slice of the stitch as a normal .tif file:
    imwrite(squeeze(image(:,:,end,:)), fullfile(pwd, [file_name '.tif']));
    
    %%% Next, we need to format the image to accomodate the functions for
    %%% writing videos.
    
    % reshape the image to flip the order of slices and channels:
    image = permute(image, [1 2 4 3]);
    
    % convert to uint8:
    image = im2uint8(image);
    
    %%% Next, we save the video.
   
    % create the video object:
    image_video = VideoWriter(fullfile(pwd, [file_name '.mp4']), 'MPEG-4');
    image_video.FrameRate = 4;
    
    % open the video:
    open(image_video);
    
    % write the video:
    for i = 1:size(image, 4)
        writeVideo(image_video, image(:,:,:,i));
    end
    
    % close the video object:
    close(image_video);
    
end