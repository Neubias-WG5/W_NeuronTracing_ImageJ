// Author: Sébastien Tosi (IRB Barcelona)
// modified by Anatole Chessel to make it run
// in batch mode, reading parameters from the command line
//
// The macro will trace neurons using simple vesselness filter and thresholding.
// Use FIJI to run the macro with a command similar to
// java -Xmx6000m -cp jars/ij.jar ij.ImageJ -headless --console -macro IJSegmentClusteredNuclei.ijm "input=/media/baecker/donnees/mri/projects/2017/liege/in, output=/media/baecker/donnees/mri/projects/2017/liege/out, radius=5, threshold=-0.5"


// Version: 1.
// Date: 09/07/2018

setBatchMode(true);

// Path to input image and output image (label mask)
inputDir = "/dockershare/666/in/";
outputDir = "/dockershare/666/out/";

// Functional parameters
// Workflow parameters
TubeRad = 4;
BackgroundLvl = 5;
CloseRad = 1;

arg = getArgument();
parts = split(arg, ",");

//for(i=0; i<parts.length; i++) {
//	nameAndValue = split(parts[i], "=");
//	if (indexOf(nameAndValue[0], "input")>-1) inputDir=nameAndValue[1];
//	if (indexOf(nameAndValue[0], "output")>-1) outputDir=nameAndValue[1];
//	if (indexOf(nameAndValue[0], "radius")>-1) LapRad=nameAndValue[1];
//	if (indexOf(nameAndValue[0], "threshold")>-1) LapThr=nameAndValue[1];
//}

images = getFileList(inputDir);

for(i=0; i<images.length; i++) {
	image = images[i];
	if (endsWith(image, ".tif")) {
		// Open image
		open(inputDir + "/" + image);
		wait(100);
		// Processing
		run("Tubeness", "sigma=4 use");
		Stack.getStatistics(voxelCount, mean, min, max);
		setThreshold(BackgroundLvl, max);
		setOption("BlackBackground", false);
		run("Convert to Mask", "method=Default background=Dark");
		run("Maximum 3D...", "x="+d2s(CloseRad,0)+" y="+d2s(CloseRad,0)+" z="+d2s(CloseRad,0));
		run("Minimum 3D...", "x="+d2s(CloseRad,0)+" y="+d2s(CloseRad,0)+" z="+d2s(CloseRad,0));
		setOption("BlackBackground", true);
		run("Fill Holes", "stack");
		//run("3D Fill Holes");
		run("Skeletonize", "stack");
		//run("Skeletonize (2D/3D)");
		rename("Skel");
		//run("Analyze Skeleton (2D/3D)", "prune=none");
		selectImage("Skel");
		
		// Export results
		save(outputDir + "/" + image);
		
		// Cleanup
		run("Close All");
	}
}
run("Quit");
