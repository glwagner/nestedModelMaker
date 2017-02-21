function obij = getOpenBoundaryVerticalGrid_model(bathyDir, model, obij, zgrid)

% Get the vertical grid for the child grid.  A bit messy right now and
% reliant on the proper structure of input 'zgrid'.

% Store grid properties for each open boundary condition.
for iOb = 1:model.nOb

	% Store properties of the vertical grid.
	obij{iOb}.zF  = zgrid.zf';
	obij{iOb}.zC  = 1/2*(zgrid.zf(2:end)+zgrid.zf(1:end-1))';
	obij{iOb}.dzF = zgrid.delz';
	obij{iOb}.dzC = obij{iOb}.zC(2:end)'-obij{iOb}.zC(1:end-1)';

    % Ensure grid convention is positive upwards.
    obij{iOb}.zF  = -abs(obij{iOb}.zF);
    obij{iOb}.zC  = -abs(obij{iOb}.zC);

    % Get the indices of the open boundary in llc coordinates.
    [ii, jj] = getOpenBoundaryIndices(obij{iOb}, 'llc');

    % Load bathymetry.
    disp(' '), disp('Loading model grid bathymetry...'), t1=tic;
    bathy = read_llc_fkij(bathyDir, model.res, obij{iOb}.face, ...
                        1, 1:model.res, 1:3*model.res, 'real*8'); 
    disp(['   ... done loading model grid bathymetry (time = ', ...
             num2str(toc(t1), '%6.3f') ' s)'])

    % Depth at first and second wet point.
    obij{iOb}.depth1 = bathy(ii.T1, jj.T1);
    obij{iOb}.depth2 = bathy(ii.T2, jj.T2);
    
    % Number of grid points in the vertical 
    obij{iOb}.nz = length(obij{iOb}.zC);

end
