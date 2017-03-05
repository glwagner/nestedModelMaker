function child = getDomainGrid(gridDir, child)

for face = 1:5

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
        
end
