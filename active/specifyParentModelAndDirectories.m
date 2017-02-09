function [dirz, parent] = specifyParentModelAndDirectories(parent, child)

% ----------------------------------------------------------------------------- 
% Basics.

% Check child.name and parent.model.name
if ~isfield(child, 'name')
	error(['child.name does not exist, which means that ', ...
			 'the name of the child model has not been specified'])
end

% Home directory
dirz.home       = '~/Numerics/nestedModelMaker/';

% ----------------------------------------------------------------------------- 
% Parent model.

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

% Start time of the model.	  	  Current name:
parent.model.year0   = 2002;		
parent.model.mnth0   = 1;			% moStart
parent.model.dt      = 1200;		
parent.model.years   = 2002:2015; 	% number of years to get boundary data.

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
parent.nz		 = 50;

% Global grid that the parent lives on
parent.llc.nx = [ [1 1 1]*parent.res [1 1]*3*parent.res ];
parent.llc.ny = [ [1 1]*3*parent.res [1 1 1]*parent.res ];

% Offset of parent grid within global grid, for each face.
% This means that to move from global- to parent-grid coordinates, we computes
%
% 		parent.ii = global.ii + parent.iOff(face).
%
parent.offset.ii = [   0   0   0   0  0 ];
parent.offset.jj = [ 360   0   0   0  0 ];

% Boundaries of the parent model.
parent.ii =	[    1		  135
						     0		    0	
						     0		    0	
						     0		    0	
						   158	    228		];

parent.jj =	[  227      292
						     0		    0	
						     0		    0	
						     0		    0	
						   136      270	  ];
				
% Not sure exactly what these are and how they relate to the entries of (.nx, .ny)
% CHANGE NAME.
parent.nx0 = parent.res;
parent.ny0 = 1350;

% ----------------------------------------------------------------------------- 
% Child grid specifications.
% Directory to global grids at child resolution.
dirz.globalGrids.child  = ['/net/barents/raid16/weddell/raid3/gforget/grids/', ...
						'gridCompleted/llcRegLatLon/']; 

% Directories to store the child grids and obcs.
dirz.child.home  = [ dirz.home '/models/' child.name '/'];
dirz.child.grid  = [ dirz.child.home 'grids/' ];
dirz.child.obcs  = [ dirz.child.home 'obcs/' ];
% ----------------------------------------------------------------------------- 
% Finalities.

% Directory with matlab code
dirz.code       = '/data5/glwagner/Numerics/regionalGridz/matlab';

% Optional: specify bathymetry to plot child subdomain through plotChildDomain().
bathyPath       = ['/net/nares/raid8/ecco-shared/llc8640/', ...
		         	'run_template/Smith_Sandwell_v14p1/'];
bathyName       = 'SandS14p1_ibcao_4320x56160.bin';
dirz.bathy      = [bathyPath bathyName];
