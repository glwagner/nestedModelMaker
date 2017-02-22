function [dirz, parent] = specifyParentModelAndDirectories(parent, child)

% ----------------------------------------------------------------------------- 
% Too much must be specified in this function:
%   - Names, directories, and grid parameters for the parent model
%   - The interior of the child model on the global llc grid, 
%       at parent-grid resolution
%   - Directories for the child grid.
% ----------------------------------------------------------------------------- 

% Basics ---------------------------------------------------------------------- 

% Check child.name and parent.model.name
if ~isfield(child, 'name')
	error(['child.name does not exist, which means that ', ...
			 'the name of the child model has not been specified'])
end

% Home directory
dirz.home       = './';

% Parent model directories ---------------------------------------------------- 

% Set name of the parent output to catch.
parent.model.name = 'run_c65q_jra55_it0003_pk0000000002';
parent.model.nickname = 'jra55i03';

% Direcories to parent model output and grid.
gridPrefix = '/net/nares/raid8/ecco-shared/llc270/aste_270x450x180/';
dirz.parent.grid   = [gridPrefix 'GRID_real8_fill9iU42Ef_noStLA/'];

% Directories with T, S and U, V data.  
dataPrefix = ['/net/barents/raid16/atnguyen/llc270/aste_270x450x180/', ...
						'output_ad/run_c65q_jra55_it0003_pk0000000002/'];
dirz.parent.data.TS = [dataPrefix 'diags/STATE/'];
dirz.parent.data.UV = [dataPrefix 'diags/TRSP/'];

% Tracer files are in [dirz.parent.data.TS parent.model.TSname '.*.data']
parent.model.TSname = 'state_3d_set1';
% Velocity files are in [dirz.parent.data.UV parent.model.UVname '.*.data']
parent.model.UVname = 'trsp_3d_set1';

% Directory to global grids at parent resolution.
dirz.globalGrids.parent = dirz.parent.grid;

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

% ----------------------------------------------------------------------------- 
% Parameters of the child grid in global coordinates, at parent resolution ---- 

% Time span of the forward simulation.  The forward simulation will 
% extend from the month parent.tspan.months(1) in year parent.tspan.years(1) to
% month parent.tspan.months(2) in year parent.tspan.years(2).
parent.tspan.years =  [ 2002 2003 ]; 
parent.tspan.months = [    2    2 ]; 

% Length of the open boundary condition to be extracted.  Due to the MITgcm's
% linear interpolation of open boundary conditions, The number of months of 
% boundary condition to be extracted is 2 + the number of months in the forward 
% simulation.
parent.nObcMonths = 2 + 12*(parent.tspan.years(2)-parent.tspan.years(1)) ...
                     + (parent.tspan.months(2)-parent.tspan.months(1));			

% Boundaries of the child model in global llc coordinates, at parent-grid
% resolution.
parent.ii =	[    1		  135
			     0		    0	
			     0		    0	
			     0		    0	
			   159	      224     ];

parent.jj =	[  587        652
			     0	        0	
			     0	        0	
			     0	        0	
			   136        270	  ];

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
                    
% Child grid specifications --------------------------------------------------- 

% Directories to store the child grids and obcs.
dirz.child.home  = [ dirz.home 'models/' child.name '/'];
dirz.child.grid  = [ dirz.child.home 'grids/' ];
dirz.child.obcs  = [ dirz.child.home 'obcs/' ];

% Directory to child-grid bathymetry and grids
%dirz.child.bathy = ['/data5/glwagner/Numerics/nestedModelMaker/bathymetry/', ...
%                        'bathy1080_g5_r4.bin'];
%dirz.globalGrids.child  = ['/net/barents/raid16/weddell/raid3/gforget/grids/', ...
%								'gridCompleted/llcRegLatLon/llc_1080/']; 

dirz.globalGrids.child  = ['/net/barents/raid16/weddell/raid3/gforget/grids/', ...
								'gridCompleted/llcRegLatLon/']; 
bathyName  = 'SandS14p1_ibcao_4320x56160.bin';
dirz.child.bathy = ['/data5/glwagner/Numerics/nestedModelMaker/bathymetry/' bathyName ];

% Finalities ------------------------------------------------------------------ 

% Directory with matlab code
dirz.code  = '/data5/glwagner/Numerics/regionalGridz/matlab/';

% Directory to high-res bathymetry.
bathyName  = 'SandS14p1_ibcao_4320x56160.bin';
dirz.bathy = ['/data5/glwagner/Numerics/nestedModelMaker/bathymetry/' bathyName ];

%bathyPath  = ['/net/nares/raid8/ecco-shared/llc8640/', ...
%		         					'run_template/Smith_Sandwell_v14p1/'];
%dirz.bathy = [bathyPath bathyName];
