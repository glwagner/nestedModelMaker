function child = getDomainGrid(gridDir, child)

for face = 1:5
    if child.nii(face) ~= 0

        % Load and cut the global llc grid at model-grid resolution.
        gridFileName = [gridDir 'llc_00' int2str(face) '_', ...
                        int2str(child.llc.nx(face)) '_', ...
                        int2str(child.llc.ny(face)) '.bin'];

        % Number of cell faces ("grid faces"?) in the x- and y-direction.
        nxG = child.llc.nx(face)+1;
        nyG = child.llc.ny(face)+1;

        % Load fields of interest from the global grid (see key above).
        idx =  1; xC  = read_slice(gridFileName, nxG, nyG, idx, 'real*8');    
        idx =  2; yC  = read_slice(gridFileName, nxG, nyG, idx, 'real*8');    

        idx =  6; xG  = read_slice(gridFileName, nxG, nyG, idx, 'real*8');    
        idx =  7; yG  = read_slice(gridFileName, nxG, nyG, idx, 'real*8');    

        idx = 15; dxG = read_slice(gridFileName, nxG, nyG, idx, 'real*8');    
        idx = 16; dyG = read_slice(gridFileName, nxG, nyG, idx, 'real*8');    

        % Trim xC, yC, dxG, and dyG to eliminate any possible ambiguity.
        xC = xC(1:end-1, 1:end-1);
        yC = yC(1:end-1, 1:end-1);
        
        dxG = dxG(1:end-1, :);
        dyG = dyG(:, 1:end-1);

        % Define indices
        iiC = child.ii(face, 1):child.ii(face, 2);
        jjC = child.jj(face, 1):child.jj(face, 2);

        iiG = child.ii(face, 1):child.ii(face, 2)+1;
        jjG = child.jj(face, 1):child.jj(face, 2)+1;

        % Cut grids for child domain. The accuracy of this 
        % code must be checked.
        child.grid{face}.xC = xC(iiC, jjC);
        child.grid{face}.yC = yC(iiC, jjC);

        child.grid{face}.xG = xG(iiG, jjG);
        child.grid{face}.yG = xG(iiG, jjG);

        child.grid{face}.dxG = dxG(iiC, jjG);
        child.grid{face}.dyG = dyG(iiG, jjC);

    end
end

load([ dirz.childGrid 'zgrid.mat' ], 'zgrid')

% Store properties of the vertical grid.
child.zF  = zgrid.zf';
child.zC  = 1/2*(zgrid.zf(2:end)+zgrid.zf(1:end-1))';
child.dzF = zgrid.delz';
child.dzC = child.zC(2:end)-child.zC(1:end-1);

% Ensure grid convention is positive upwards.
child.zF  = -abs(child.zF);
child.zC  = -abs(child.zC);

