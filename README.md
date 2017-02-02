# nestedModelMaker
"nestedModelMaker" helps generate grids, initial conditions, and open boundary conditions for MITgcm models nested inside larger and coarser-resolution simulations.

To use:
	1. Create a new directory in ./models (for example: mkdir "./models/testModel").
	2. Copy into the m-files in ./userExamples.
	3. Point the main script "nestedModelMaker.m" at your new model by changing the variable "child.name" to the name of your new model (for example: "child.name = testModel").
	4. Open MATLAB and run the script nestedModelMaker.m

For more advanced usage, the user must edit the files copied from ./userExamples.
