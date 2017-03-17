function model = getDomainGrid(globalGridDir, model)

% Get horizontal grid for each face
for face = 1:5
    if model.nii(face) ~= 0

        % Load and cut the global llc grid at model-grid resolution.
        gridFileName = [globalGridDir 'llc_00' int2str(face) '_', ...
                        int2str(model.llc.nii(face)) '_', ...
                        int2str(model.llc.njj(face)) '.bin'];

        % Number of cell faces ("grid faces"?) in the x- and y-direction.
        niiG = model.llc.nii(face)+1;
        njjG = model.llc.njj(face)+1;

        % Load fields of interest from the global grid (see key above).
        idx =  1; xC  = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    
        idx =  2; yC  = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    

        idx =  6; xG  = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    
        idx =  7; yG  = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    

        idx = 15; dxG = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    
        idx = 16; dyG = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    

        % Trim xC, yC, dxG, and dyG to eliminate any possible ambiguity.
        xC = xC(1:end-1, 1:end-1);
        yC = yC(1:end-1, 1:end-1);
        
        dxG = dxG(1:end-1, :);
        dyG = dyG(:, 1:end-1);

        % Define indices
        iiC = model.ii(face, 1):model.ii(face, 2);
        jjC = model.jj(face, 1):model.jj(face, 2);

        iiG = model.ii(face, 1):model.ii(face, 2)+1;
        jjG = model.jj(face, 1):model.jj(face, 2)+1;

        % Cut grids for model domain. The accuracy of this 
        % code must be checked.
        model.hGrid{face}.xC = xC(iiC, jjC);
        model.hGrid{face}.yC = yC(iiC, jjC);

        model.hGrid{face}.xG = xG(iiG, jjG);
        model.hGrid{face}.yG = xG(iiG, jjG);

        model.hGrid{face}.dxG = dxG(iiC, jjG);
        model.hGrid{face}.dyG = dyG(iiG, jjC);

    end
end
