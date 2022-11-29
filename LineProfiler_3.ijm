//Step 3 of automatic analysis of RC replication 
//requires drift corrected FOV, molecules replicating down and Molecules selected as ROIs

sourceFolder ="XXX"; //enter folder path
fovFolder="tracker1"; //folder path for Field of view
File.makeDirectory(sourceFolder + fovFolder);// Create folder if it doesn't already exist.

rename("temp1");
run("Split Channels");
selectWindow("C1-temp1")

row=0;
for (r=0; r<roiManager("count"); r++){ // for each molecule 
	roiManager("Select", r);
	for (s=1; s<=nSlices; s++){ // for each slice 
		setSlice(s);
		setKeyDown("alt"); // changes from horizontal axis profile to vertical
		profile = getProfile(); //get vertical intensity profile of each slice for the length of the ROI 
		setKeyDown("none");
		for (i=0; i<profile.length; i++){ // save data 
			setResult("Value",row, profile[i]); //measured profile data 
			setResult("Ypos",row, i); //Ypos number 
			setResult("slice",row, s); //slice number 
			setResult("trajectory",row, r); //trajectory number 
			row=row+1;
		}
	}
}

saveAs("Results",sourceFolder+fovFolder + "Profiles.xls");
IJ.renameResults("test");
close("test")

run("Merge Channels...", "c1=C1-temp1 c2=C2-temp1 create");


for (r=0; r<roiManager("count"); r++){
	roiManager("Select", r);
	run("Duplicate...", "title=temp duplicate");
	mainmolFolder="Molecules/";
	File.makeDirectory(sourceFolder + fovFolder + mainmolFolder);// Create folder if it doesn't already exist.
	molFolder="Molecule_"+r+"/";
	File.makeDirectory(sourceFolder + fovFolder + mainmolFolder+ molFolder);// Create folder if it doesn't already exist.
	
	run("Reslice [/]...", "output=1.000 start=Left avoid");
	run("Z Project...", "projection=[Average Intensity]");
	run("Rotate 90 Degrees Left");
	run("Enhance Contrast", "saturated=0.35");
	saveAs("Jpeg", sourceFolder + fovFolder + mainmolFolder+ molFolder + "kymograph");
	selectWindow("Reslice of temp");
	run("Close");
	selectWindow("AVG_Reslice of temp");
	run("Close");
	selectWindow("temp");
	run("Close");
}

n = roiManager("count");
for (i=0; i<n; i++) {
	roiManager("Select", i);
	getSelectionBounds(sx, sy, sw, sh);
	Roix=sx-10;
	Roiy=sy-10;
	Roiw=sw+20;
	Roih=sh+20;
	run("Specify...", "width=&Roiw height=&Roih x=&Roix y=&Roiy"); // Make a square ROI of size 19x19 pixels at the same positions. 
	roiManager("Update");
	
}
roiManager("Deselect");

for (r=0; r<roiManager("count"); r++){
	roiManager("Select", r);
	run("Duplicate...", "title=temp duplicate");
	molFolder="Molecule_"+r+"/";
	saveAs("Tiff", sourceFolder + fovFolder + mainmolFolder+ molFolder +"movie");

	selectWindow("movie.tif");
	run("Split Channels");
	close();
	selectWindow("C1-movie.tif");
	slice=nSlices-10;
	run("Z Project...", "start=slice projection=[Average Intensity]");

	//Take line scans of molecule to determine Xpos 
	row=0;
	selectWindow("AVG_C1-movie.tif");
	h = getHeight();
	w= getWidth();
	for (i=0; i<=h; i++) {
		makeLine(0, i, w, i); //Make line at very top + width of movie, for the height of the movie, take a line scan. 
		setKeyDown("none");
		profile2 = getProfile();
		for (k=0; k<profile2.length; k++){
			setResult("Value",row, profile2[k]);
			setResult("Xpos",row, k+1);
			setResult("height",row, i);
			row=row+1;
		}
	}
	saveAs("Results",sourceFolder+fovFolder + mainmolFolder+ molFolder +"ProfileForXpos.xls");
	IJ.renameResults("test");
	close("test");
	selectWindow("AVG_C1-movie.tif");
	run("Close");
	selectWindow("C1-movie.tif");
	run("Close");
	
}

IJ.log("Finished!!");