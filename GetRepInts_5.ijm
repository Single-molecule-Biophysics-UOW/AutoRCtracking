//Step 5 of automatic analysis of fluorophores during RC replication

sourceFolder ="XXX"; //enter folder path
fovFolder="tracker1"; //folder path for Field of view
mainmolFolder="Molecules/";

molecules = getFileList(sourceFolder + fovFolder + mainmolFolder);
for (m=0; m<=molecules.length-1; m++){
	molFolder="Molecule_"+m+"/"; 
	files = getFileList(sourceFolder + fovFolder + mainmolFolder + molFolder); // Find all files in the source folder

	open(sourceFolder + fovFolder + mainmolFolder + molFolder+files[3]);
	open(sourceFolder + fovFolder + mainmolFolder + molFolder+files[1]);
	rename("temp1");
	run("Split Channels");
	selectWindow("C1-temp1");
	run("Close");
	N=nResults;
	// Get DNA ROIs from results table
	for (i=0; i<=N-1; i++){ 
		slice = getResult("slice", i); 
		setSlice(slice+1);
		x=getResult('x',i);
		y=getResult('y',i)-10; //subtract 10,due to expansion of ROI in lineprofiler
		run("Specify...", "width=5 height=5 x=&x y=&y slice=&slice centered"); // Make a square ROI of size 5x5 pixels centered around the coordinate. 
		run("Specify...", "width=10 height=25 x=&x y=&y slice=&slice centered"); //change size of ROI 
		run("Peak Finder", "use_discoidal_averaging_filter inner_radius=1 outer_radius=3 threshold=4 threshold_value=0 selection_radius=2 minimum_distance=8 background=40 slice");
		n=roiManager("Count");
		if (n==0){
			RepX=newArray();
			RepY=newArray();
			Array.fill(RepX,0);
			Array.fill(RepY,0);
			Array.show("RepCoords",RepX, RepY);
			SliceFolder="Slice/";
			File.makeDirectory(sourceFolder + fovFolder + mainmolFolder+ molFolder + SliceFolder);
			selectWindow("RepCoords");
			saveAs("Results", sourceFolder + fovFolder + mainmolFolder+ molFolder + SliceFolder +"Slice_"+i+".csv");
			selectWindow("RepCoords");
			close("RepCoords");
		}else{
			roiManager("List");
			selectWindow("C2-temp1");
			run("Select None");
			roiManager("reset");
			SliceFolder="Slice/";
			File.makeDirectory(sourceFolder + fovFolder + mainmolFolder+ molFolder + SliceFolder);
			selectWindow("Overlay Elements");
			saveAs("Results", sourceFolder + fovFolder + mainmolFolder+ molFolder + SliceFolder +"Slice_"+i+".csv");
			selectWindow("Overlay Elements");
			close("Overlay Elements");
		}
		selectWindow("Results");
		}
		selectWindow("Results");
		run("Close");
		selectWindow("C2-temp1");
		run("Close");
}
IJ.log("Finished!!");
		
		
