function obij = getOpenBoundaryVerticalGrid_child(bathyDir, model, obij, zGrid)

% Get the vertical grid for the child grid.  A bit messy right now and
% reliant on the proper structure of input 'zgrid'.

% Store grid properties for each open boundary condition.
for iOb = 1:model.nOb

	% Store properties of the vertical grid.
	obij{iOb}.zF  = zGrid.zF;
	obij{iOb}.zC  = zGrid.zC;
	obij{iOb}.dzF = zGrid.dzF;
	obij{iOb}.dzC = zGrid.dzC;

    % Get the indices of the open boundary in llc coordinates.
    [ii, jj] = getOpenBoundaryIndices(obij{iOb}, 'llc');

    % This hook is needed because we only have the 1080 bathy in real*4.
    if model.res == 1080
        precision = 'real*4';
    else
        precision = 'real*8';
    end

    % Load bathymetry.
    fprintf('Loading model grid bathymetry... '), t1=tic;
    bathy = read_llc_fkij(bathyDir, model.res, obij{iOb}.face, ...
                        1, 1:model.res, 1:3*model.res, precision); 
    fprintf('done. (time = %6.3f s)\n', toc(t1))

    % Unmangle the bathymetry.
    bathy = unmangleLLCBathymetry(bathy, obij{iOb}.face);

    % Depth at first and second wet point. 
    obij{iOb}.depth1 = bathy(ii.T1, jj.T1);
    obij{iOb}.depth2 = bathy(ii.T2, jj.T2);
    
    % Number of grid points in the vertical 
    obij{iOb}.nz = length(obij{iOb}.zC);

end
