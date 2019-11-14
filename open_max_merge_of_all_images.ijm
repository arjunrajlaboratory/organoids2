// ask user for the folder with the images:
path_folder = getDirectory("Select the folder with the images.");

// get a list of images:
list_images = getFileList(path_folder);

// for each image:
for(i = 0; i < list_images.length; i++){

	// get the path to the image:
	path_image = path_folder + list_images[i];

	// open the stack:
	open(path_image);

	// make a max merge:
	run("Z Project...", "projection=[Max Intensity]");

	// close the stack:
	close(list_images[i]);
	
}

// open the brightness and contrast toolbar:
run("Brightness/Contrast...");