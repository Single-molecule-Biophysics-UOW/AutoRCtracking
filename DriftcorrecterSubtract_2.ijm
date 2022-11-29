//Step 2 of automatic analysis of RC replication 
// requires average drift file calculcated in step 1 - DriftAverage_1.m

rename("temp1");
run("Split Channels");
selectWindow("C1-temp1")
setSlice(1);
for (i=1; i<=nSlices;i++){
	dx=-getResult('x',i-1);
	dy=-getResult('y',i-1);
	run("Translate...", "x=" + dx + " y=" + dy + " interpolation=Bicubic");
	run("Next Slice [>]");
}

setSlice(1);
run("Duplicate...", "use");
rename("1stSlice");
imageCalculator("Subtract stack", "C1-temp1","1stSlice");
selectWindow("1stSlice");
close();
selectWindow("C1-temp1");
setSlice(1);
run("Delete Slice");

selectWindow("C2-temp1")
setSlice(1);
for (i=1; i<=nSlices;i++){
	dx=-getResult('x',i-1);
	dy=-getResult('y',i-1);
	run("Translate...", "x=" + round(dx) + " y=" + round(dy) + " interpolation=None");
	run("Next Slice [>]");
}
setSlice(1);
run("Duplicate...", "use");
rename("1stSlice");
imageCalculator("Subtract stack", "C2-temp1","1stSlice");
selectWindow("1stSlice");
close();
selectWindow("C2-temp1");
setSlice(1);
run("Delete Slice");

run("Merge Channels...", "c1=C1-temp1 c2=C2-temp1 create");

IJ.log("Finished!");

