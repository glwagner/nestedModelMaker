To get a regional domain:

Step1: get indices
selectSouthAtlanticGrid.m

Step2: cut mitgrid.XXXX
my_grid_load_native.m

Step3: get bathymetr (from somewhere)
get_bathy.m

Step4: get Init conditions
get_3dfields.m
get_fields.m
get_initTS_ice_incomplete_notuse.m

Step5: get obcs
step0_setup_indices.m
step1_extract_obcs.m
step2_interp_obcs.m
step3_fix_bathy.m

Step6: determining how many cpus needed:
plot_tile.m

Step7: run model from niter0=0 to determine deltaT
lookat_stdout.m

Step8: tune viscosity as needed:
reconstruct_visc.m
lookat_dxgdyg.m

Step9: tune bathymetry if needed to get rid of unstable points:
fix_bathy_poststep3.m
