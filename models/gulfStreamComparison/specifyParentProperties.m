function [dirz, parent] = specifyParentProperties(dirz)

parent.name = 'ASTE';

% Parent model directories ---------------------------------------------------- 

% Set name of the parent output to catch.
parent.model.name = 'run_c65q_jra55_it0003_pk0000000002';
parent.model.nickname = 'jra55i03';

% Direcories to parent model output and grid.
gridPrefix = '/net/nares/raid8/ecco-shared/llc270/aste_270x450x180/';
dirz.parentGrid   = [gridPrefix 'GRID_real8_fill9iU42Ef_noStLA/'];

% Directories with T, S and U, V data.  
dataPrefix = ['/net/barents/raid16/atnguyen/llc270/aste_270x450x180/', ...
                        'output_ad/run_c65q_jra55_it0003_pk0000000002/'];
dirz.parentTSdata = [dataPrefix 'diags/STATE/'];
dirz.parentUVdata = [dataPrefix 'diags/TRSP/'];

% Tracer files are in [dirz.parentTSdata parent.model.TSname '.*']
parent.model.TSname = 'state_3d_set1';
% Velocity files are in [dirz.parentUVdata parent.model.UVname '.*']
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

% ASTE specification.
parent.nx([1 3]) = parent.res;
parent.nx(2)     = 0;
parent.nx(4)     = 180;
parent.nx(5)     = 450;

parent.ny(1)     = 450;
parent.ny(2)     = 0;
parent.ny(3:5)   = parent.res;
parent.nz        = 50;

% Global grid that the parent lives on
parent.llc.nx = [ parent.res([1 1 1]) 3*parent.res([1 1]) ];
parent.llc.ny = [ 3*parent.res([1 1]) parent.res([1 1 1]) ];

% Offset of parent grid within global grid, for each face.
% This means that to move from global- to parent-grid coordinates, we compute
%
% 		ii (parent coordinates) = ii (global coordinates) + parent.offset.ii.

parent.offset.ii = [   0   0   0   0  0 ];
parent.offset.jj = [ 360   0   0   0  0 ];
    
% Not sure exactly what these are and how they relate to the entries of (.nx, .ny)
parent.nx0 = parent.res;
parent.ny0 = 1350;

%{
% ----------------------------------------------------------------------------- 
% Parameters of the child grid in global coordinates, at parent resolution ---- 

% Time span of the forward simulation.  The forward simulation will 
% extend from the month parent.tspan.months(1) in year parent.tspan.years(1) to
% month parent.tspan.months(2) in year parent.tspan.years(2).
parent.tspan.years =  [ 2003 2003 ]; 
parent.tspan.months = [    1    2 ]; 

% Length of the open boundary condition to be extracted.  Due to the MITgcm's
% linear interpolation of open boundary conditions, The number of months of 
% boundary condition to be extracted is 2 + the number of months in the forward 
% simulation.
parent.nObcMonths = 2 + 12*(parent.tspan.years(2)-parent.tspan.years(1)) ...
    + (parent.tspan.months(2)-parent.tspan.months(1));            

% Boundaries of the child model in global llc coordinates, at parent-grid
% resolution.
parent.ii = [   1 135
                0   0    
                0   0    
                0   0    
              159 224 ];

parent.jj = [ 587 652
                0   0
                0   0
                0   0
              136 270 ];

% Three kinds of boundaries: 'open', 'land', and 'interior'
parent.bcs.ii{1} = { 'interior'     'land' };
parent.bcs.ii{2} = { 'interior' 'interior' };
parent.bcs.ii{3} = { 'interior' 'interior' };
parent.bcs.ii{4} = { 'interior' 'interior' };
parent.bcs.ii{5} = {     'open'     'open' };

parent.bcs.jj{1} = {     'open'     'open' };
parent.bcs.jj{2} = { 'interior' 'interior' };
parent.bcs.jj{3} = { 'interior' 'interior' };
parent.bcs.jj{4} = { 'interior' 'interior' };
parent.bcs.jj{5} = {     'land' 'interior' };

% Count open boundaries.
parent.nOb = 0;
for face = 1:5, for side = 1:2, 
    if strcmp(parent.bcs.ii{face}{side}, 'open')
        parent.nOb = parent.nOb+1; 
    elseif strcmp(parent.bcs.jj{face}{side}, 'open')
        parent.nOb = parent.nOb+1; 
    end
end, end
%}
