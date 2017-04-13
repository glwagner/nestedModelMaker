function model = getDomainGrid(globalGridDir, model)

% ----------------------------------------------------------------------------- 
% Note about the binary file in "gridFileName" and MITgcm's grid structure:
%     The binary file in "gridFileName" contains grid information about horizontal
%     discretiation in the "LLC" coordinate system.  Each of the vertical levels
%     in the binary file correspond to a horizontal field in x,y on one of the 
%     LLC faces.  The fields have different dimensions: for example, "xC" is 
%     an array that contains the x-position of the cell cetners, while "xG"
%     contains the x-position of the cell corners; this means that "xG" is
%     larger than xC by one point in both x and y.  In the binary file name
%     "gridFileName", this means that all the files have the dimension of xG.  
%     In the case that the field being stored is smaller than xG in one or
%     both dimensions, the final point in the field is set to zero.  Below,
%     the fields that are smaller than xG (and yG) are trimmed to their actual
%     actual dimension (thus exCluding the padded zeros on the edges) for 
%     clarity. 
% -----------------------------------------------------------------------------  
%%% Key for idx:
%        1    xC            5    rAc          9    dyU         13    rAw
%        2    yC            6    xG          10    rAz         14    rAs
%        3    dxF           7    yG          11    dxC         15    dxG
%        4    dyF           8    dxV         12    dyC         16    dyG
% 
% Refer to http://mitgcm.org/sealion/online_documents/node47.html for more info.
% -----------------------------------------------------------------------------  

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

        idx =  3; dxF = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    
        idx =  4; dyF = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    

        idx =  5; rAc = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    

        idx =  6; xG  = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    
        idx =  7; yG  = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    

        idx =  8; dxV = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    
        idx =  9; dyU = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    

        idx = 10; rAz = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    

        idx = 11; dxC = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    
        idx = 12; dyC = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    

        idx = 13; rAw = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    
        idx = 14; rAs = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    

        idx = 15; dxG = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    
        idx = 16; dyG = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    

        % TODO: Remove trimming and ensure there are no consequences 
        % TODO: down the line.

        % Trim xC, yC, dxG, and dyG to eliminate any possible ambiguity.
        xC = xC(1:end-1, 1:end-1);
        yC = yC(1:end-1, 1:end-1);
        
        dxG = dxG(1:end-1, :);
        dyG = dyG(:, 1:end-1);

        % TODO: Cut all fields to model domain (right now only 
        % TODO: xC, yC, xG, yG, dxG, and dyG are being cut)

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
