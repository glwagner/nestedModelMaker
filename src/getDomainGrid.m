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

        % rAw = rAu (west, u-face), rAs = rAv (south, v-face)
        idx = 13; rAw = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    
        idx = 14; rAs = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    

        idx = 15; dxG = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    
        idx = 16; dyG = read_slice(gridFileName, niiG, njjG, idx, 'real*8');    

        % location of these:
        %   at centers: xC, yC, dxF, dyF, rAc
        %   at corners: xG, yG, dxV, dyU, rAz
        %   at u-faces: dxC, rAw, dyG
        %   at v-faces: dyC, rAs, dxG

        % Trim to eliminate any possible ambiguity.
        xC = xC(1:end-1, 1:end-1);
        yC = yC(1:end-1, 1:end-1);
        dxF = dxF(1:end-1, 1:end-1);
        dyF = dyF(1:end-1, 1:end-1);
        rAc = rAc(1:end-1, 1:end-1);

        dxC = dxC(:, 1:end-1);
        rAw = rAw(:, 1:end-1);
        dyG = dyG(:, 1:end-1);

        dyC = dyC(1:end-1, :);
        rAs = rAs(1:end-1, :);
        dxG = dxG(1:end-1, :);

        % Define indices
        iiC = model.ii(face, 1):model.ii(face, 2);
        jjC = model.jj(face, 1):model.jj(face, 2);

        iiG = model.ii(face, 1):model.ii(face, 2)+1;
        jjG = model.jj(face, 1):model.jj(face, 2)+1;

        % Cut grids for model domain.
        model.hGrid{face}.xC = xC(iiC, jjC);
        model.hGrid{face}.yC = yC(iiC, jjC);

        model.hGrid{face}.dxF = dxF(iiC, jjC);
        model.hGrid{face}.dyF = dyF(iiC, jjC);

        model.hGrid{face}.rAc = rAc(iiC, jjC);

        model.hGrid{face}.xG = xG(iiG, jjG);
        model.hGrid{face}.yG = yG(iiG, jjG);

        model.hGrid{face}.dxV = dxV(iiG, jjG);
        model.hGrid{face}.dyU = dyU(iiG, jjG);

        model.hGrid{face}.rAz = rAz(iiG, jjG);

        model.hGrid{face}.dxC = dxC(iiG, jjC);
        model.hGrid{face}.dyC = dyC(iiC, jjG);

        model.hGrid{face}.rAw = rAw(iiG, jjC);
        model.hGrid{face}.rAs = rAs(iiC, jjG);

        model.hGrid{face}.dxG = dxG(iiC, jjG);
        model.hGrid{face}.dyG = dyG(iiG, jjC);

        switch face
            case {1, 2}
                model.hGrid{face}.xU = xG(iiC, jjC);
                model.hGrid{face}.yU = yC(iiC, jjC);

                model.hGrid{face}.xV = xC(iiC, jjC);
                model.hGrid{face}.yV = yG(iiC, jjC);
            case 3
                warning('Operations on face 3 are not supported!')

                model.hGrid{face}.xU = xG(iiC, jjC);
                model.hGrid{face}.yU = yC(iiC, jjC);

                model.hGrid{face}.xV = xC(iiC, jjC);
                model.hGrid{face}.yV = yG(iiC, jjC);
            case {4, 5}
                model.hGrid{face}.xU = xC(iiC, jjC);
                model.hGrid{face}.yU = yG(iiC, jjC);

                model.hGrid{face}.xV = xG(iiC, jjC);
                model.hGrid{face}.yV = yC(iiC, jjC);
        end
    end
end
