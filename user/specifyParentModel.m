function parent = specifyParentModel(parent)

% Set name of the parent output to catch.
parent.model.name = 'run_c65q_jra55_it0003_pk0000000002';
parent.model.nickname = 'jra55i03';

% The directory with U and T is 
% [dirz.parentData parent.model.TDir
parent.model.UDir = 'diags/TRSP/';
parent.model.TDir = 'diags/STATE/';

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
parent.iOff = [   0   0   0   0  0 ];
parent.jOff = [ 360   0   0   0    0 ];

% Not sure exactly what these are and how they relate to the entries of (.nx, .ny)
% CHANGE NAME.
parent.nx0 = parent.res;
parent.ny0 = 1350;

