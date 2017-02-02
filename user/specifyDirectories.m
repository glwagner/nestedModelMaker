function dirz = specifyDirectories(parent, child)

% Check child.name and parent.model.name
if ~isfield(child, 'name')
	error(['child.name does not exist, which means that ', ...
			 'the name of the child model has not been specified'])
elseif ~isfield(parent.model, 'name')
	error(['parent.model.name does not exist, which means that '
			 'the name of model supplying open boundary conditions on the', ...
			 'parent grid has not been specified.'])
end

% Home directory
dirz.home       = [pwd '/'];
% Directory to global grids at parent and child resolution.
dirz.globalGrid.child  = ['/net/barents/raid16/weddell/raid3/gforget/grids/', ...
						'gridCompleted/llcRegLatLon/']; 
dirz.globalGrid.parent = '/net/nares/raid8/ecco-shared/llc270/global/GRID/';

% Direcories to ASTE output and grid.
dirz.parentHome   = '/net/nares/raid8/ecco-shared/llc270/aste_270x450x180/';
dirz.parentGrid   = [dirz.parentHome 'GRID_real8_fill9iU42Ef_noStLA/'];
dirz.parentData   = ['/net/barents/raid16/atnguyen/llc270/aste_270x450x180/', ...
						'output_ad/' parent.model.name '/'];

% Directory with matlab code
dirz.code       = '/data5/glwagner/Numerics/regionalGridz/matlab';

% Directories to store the child grids and obcs.
dirz.childHome  = [pwd '/models/' child.name '/'];
dirz.childGrid  = [ dirz.childHome 'grids/' ];
dirz.obcs       = [ dirz.childHome 'obcs/' ];

% Optional: specify bathymetry to plot child subdomain through plotChildDomain().
bathyPath       = ['/net/nares/raid8/ecco-shared/llc8640/', ...
		         	'run_template/Smith_Sandwell_v14p1/'];
bathyName       = 'SandS14p1_ibcao_4320x56160.bin';
dirz.bathy      = [bathyPath bathyName];
