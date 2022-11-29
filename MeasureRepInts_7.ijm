//Step 7 of automatic analysis of fluorophores during RC replication 
// requires ROIs determined in step 6 - GetRepInts_6.m

sourceFolder ="XXX"; //enter folder path
fovFolder="tracker1"; //folder path for Field of view
mainmolFolder="Molecules/";

molecules = getFileList(sourceFolder + fovFolder + mainmolFolder);
for (m=0; m<=molecules.length-1; m++){
	molFolder="Molecule_"+m+"/"; 
	files = getFileList(sourceFolder + fovFolder + mainmolFolder + molFolder); // Find all files in the source folder
	//Array.show(files);
	open(sourceFolder + fovFolder + mainmolFolder + molFolder+files[3]);
	open(sourceFolder + fovFolder + mainmolFolder + molFolder+files[1]);
	rename("temp1");
	run("Split Channels");
	selectWindow("C1-temp1");
	run("Close");
	
	// Get ROIs from results table
	setOption("ExpandableArrays", true);
	Slice=newArray;
	for (i=0; i<=nResults-1;i++){
		slice = getResult("slice", i); 
		x=getResult('X',i);
		y=getResult('Y',i); 
		run("Specify...", "width=5 height=5 x=&x y=&y slice=&slice centered"); // Make a square ROI of size 5x5 pixels centered around the coordinate. 
    	roiManager("Associate", "true");
    	roiManager("Add"); // Add to the ROI manager. 
    	Slice[i]=slice;
	}
	IJ.renameResults("temp");//rename the results table
	selectWindow("temp");
	run("Close");

	run("Set Measurements...", "integrated redirect=None decimal=0");//Set measurements to calculate the integrated intensity.

	roiManager("Measure");// measure the intensity
	// For calculations done later, we need to add a trajectory and a slice column.
	for(t=0;t<nResults;t++){
		setResult("trajectory", t, m);
		setResult("slice",t,Slice[t]);
	}
	IJ.renameResults("peak");//rename the results table
	roiManager("Deselect");
	selectWindow("peak");
	saveAs("Results",sourceFolder + fovFolder + mainmolFolder + molFolder+"Intensity.xls");
	selectWindow("Intensity.xls");
	run("Close");
	
	// To calculate the local background intensity we increase the size of the ROI.
	n = roiManager("count");
	for (i=0; i<n; i++) {
		roiManager("Select", i);
		getSelectionCoordinates(x, y);
		Roix=x[0];
		Roiy=y[0];
		slice=Slice[i];
		run("Specify...", "width=11 height=5 x=&Roix y=&Roiy slice=&slice centered"); // Make BG ROI bigger on x-axis (1-3 px bigger)
		roiManager("Update");
		}
	roiManager("Deselect");

	roiManager("Measure");
	N=nResults+1;
	for(r=0;r<nResults;r++){
		setResult("trajectory", r, m);
		setResult("slice",r,Slice[r]);
	}
	selectWindow("Results");
	IJ.renameResults("bg");
	roiManager("Deselect");
	roiManager("reset");
	selectWindow("bg");
	saveAs("Results",sourceFolder + fovFolder + mainmolFolder + molFolder+"BgInt.xls");
	selectWindow("BgInt.xls");
	run("Close");
	run("Close All"); // close all open movies
	
}
IJ.log("Finished!!");
	