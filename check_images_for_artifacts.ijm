// ask user which directory to use:
path_folder = getDirectory("Choose a Directory");	

// get a list of images in the directory:
list_images = getFileList(path_folder);

// for each image in the directory:
for (i = 0; i < 2; i++) { 

	// get the path to the image:
	path_file = path_folder + list_images[i];

	// open the file:
	open(path_file);

	// turn on the orthogonal view:
	run("Orthogonal Views");
	
	// wait for user to close the image:
	waitForUser("Done");

	// close the orthogonal view:
	run("Orthogonal Views");

	// close the file:
	selectWindow(list_images[i]);
	close();
	
}