function [dirz, child] = specifyChildProperties(dirz, child)

% Child grid specifications --------------------------------------------------- 

% Directory to child-grid bathymetry and grids for 1080 grid.
dirz.childBathy = ['/data5/glwagner/Numerics/nestedModelMaker/bathymetry/', ...
                        'bathy1080_g5_r4.bin'];
dirz.childGlobalGrids = ['/net/barents/raid16/weddell/raid3/gforget/grids/', ...
                                'gridCompleted/llcRegLatLon/llc_1080/']; 

% Resolution of the child grid.
child.res  = 1080;

% Properties of the global llc grid on which the child lives.
child.llc.nii = [ [1 1 1]*child.res [3 3]*child.res ];
child.llc.njj = [ [3 3]*child.res [1 1 1]*child.res ];

% ----------------------------------------------------------------------------- 
% Parameters of the planned child model run.

% Time span of the forward simulation.  The forward simulation will 
% extend from the month parent.tspan.months(1) in year parent.tspan.years(1) to
% month parent.tspan.months(2) in year parent.tspan.years(2).
child.tspan.years =  [ 2003 2013 ];
child.tspan.months = [    1    1 ];

% Length of the open boundary condition to be extracted.  Due to the MITgcm's
% linear interpolation of open boundary conditions, The number of months of 
% boundary condition to be extracted is 3 + the number of months in the forward 
% simulation.
child.nObcMonths = 2 + 12*(child.tspan.years(2)-child.tspan.years(1)) ...
    + (child.tspan.months(2)-child.tspan.months(1));            

% Boundaries of the child model in global llc coordinates, at parent-grid
% resolution.
child.parent.ii = [   1 169
                      0   0    
                      0   0    
                      0   0    
                    330 420 ];

child.parent.jj = [ 391 481
                      0   0
                      0   0
                      0   0
                    230 270 ];

% Three kinds of boundaries: 'open', 'land', and 'interior'
child.bcs.ii{1} = { 'interior'     'land' };
child.bcs.ii{2} = { 'interior' 'interior' };
child.bcs.ii{3} = { 'interior' 'interior' };
child.bcs.ii{4} = { 'interior' 'interior' };
child.bcs.ii{5} = {     'open'     'open' };

child.bcs.jj{1} = {     'open'     'open' };
child.bcs.jj{2} = { 'interior' 'interior' };
child.bcs.jj{3} = { 'interior' 'interior' };
child.bcs.jj{4} = { 'interior' 'interior' };
child.bcs.jj{5} = {     'land' 'interior' };

% Count open boundaries.
child.nOb = 0;
for face = 1:5, for side = 1:2, 
    if strcmp(child.bcs.ii{face}{side}, 'open')
        child.nOb = child.nOb+1; 
    elseif strcmp(child.bcs.jj{face}{side}, 'open')
        child.nOb = child.nOb+1; 
    end
end, end

% Dimension of super grid to stick the child grid to.
child.nSuperGrid = 60;

% Dimension of computational tile (nSuperGrid must be a multiple of this)
child.tileSize = 60;

% Bathymetry adjustment:
% Specify indices of grid cells that are part of the main ocean domain on each
% face. The code will determine what part of the ocean in the child domain is
% connected to these points and discard everything else (lakes, obstructed
% ocean, etc.). The bathymetry plots that are generated should be consulted to
% pick these points.
child.oceanPoint = [[50,50]; [NaN,NaN]; [NaN,NaN]; [NaN,NaN]; [100,200]];

% Extra ----------------------------------------------------------------------- 
% Directories to store the child grids and obcs.
dirz.home  = [ './models/' child.name '/'];
dirz.childGrid = [ dirz.home 'grids/' ];
dirz.childInput = [ dirz.home 'input/' ];

dirz.childZGrid = ['/data5/glwagner/Numerics/nestedModelMaker/grids/' ...
                    'vertical/z_101.mat'];
