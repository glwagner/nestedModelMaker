function [dirz, parent] = specifyParentProperties(dirz)

% Set name of the parent output to catch.
parent.name = 'ASTE';
%parent.model.name = 'run_c65q_jra55_it0003_pk0000000002';
%parent.model.nickname = 'jra55i03';

% Parent model directories ---------------------------------------------------- 

% Direcories to parent model output and grid.
dirz.parentGrid   = ['/net/nares/raid8/ecco-shared/llc270/aste_270x450x180/' ...
                        'GRID_real8_fill9iU42Ef_noStLA/' ];

dirz.parentZGrid = [ './models/' parent.name '/grids/zGrid.mat' ];

% Directories with T, S and U, V data.  
dirz.parentTSdata = [ '/net/barents/raid16/atnguyen/llc270/aste_270x450x180/', ...
                        'output_ad/run_c65q_jra55_it0003_pk0000000002/' ...
                        'diags/STATE/' ];

dirz.parentUVdata = [ '/net/barents/raid16/atnguyen/llc270/aste_270x450x180/', ...
                        'output_ad/run_c65q_jra55_it0003_pk0000000002/' ...
                        'diags/TRSP/' ];

% Files are in [dirz.parentTSdata parent.model.TSname '.*']
parent.model.TSname = 'state_3d_set1';
parent.model.UVname = 'trsp_3d_set1';

% Directory to global grids at parent resolution.
dirz.parentGlobalGrids = dirz.parentGrid;

% Parameters specific to ASTE ------------------------------------------------- 

% Start time of the model.           
parent.model.year0   = 2002;        
parent.model.mnth0   = 1;                    
parent.model.dt      = 1200;        
parent.model.years   = 2002:2015; 

% Resolution of the parent model
parent.res = 270;
parent.nz  = 50;

parent.ii = [   1 270
                0   0
                1 270
                1 180
                1 450 ];

parent.jj = [ 361 810
                0   0 
                1 270
                1 270
                1 270 ];

% Three kinds of boundaries: 'open', 'land', and 'interior'
parent.bcs.ii{1} = { 'interior'     'open' };
parent.bcs.ii{2} = { 'land'         'land' };
parent.bcs.ii{3} = { 'interior' 'interior' };
parent.bcs.ii{4} = { 'interior'     'open' };
parent.bcs.ii{5} = { 'interior'     'land' };

parent.bcs.jj{1} = {     'open' 'interior' };
parent.bcs.jj{2} = { 'interior' 'interior' };
parent.bcs.jj{3} = { 'interior' 'interior' };
parent.bcs.jj{4} = { 'interior' 'interior' };
parent.bcs.jj{5} = {     'land' 'interior' };

% Parameters needed to convert between An's "ASTE format" and the standard LLC format.
parent.nii_asteFormat = parent.res;
parent.njj_asteFormat = 1350;
