function obij = getOpenBoundaryHorizontalGrid(gridDir, model, obij)

% ----------------------------------------------------------------------------- 
% Input structures or cell-array-of structures:
%
%    gridDir     : A string that points to the grid-info bindary files.
%    model        : Structure giving open boundary info of the model.
%    obij        : Cell array of structures with open boundary conditions 
%                 properties.
%
% Outputs:
%
%    obij structure with its original fields, plus:
%
%        .xC1    : Cell center x-position of first wet point
%        .xC2    : Cell center x-position of second wet point
%        .yC1    : Cell center y-position of first wet point
%        .yC2    : Cell center y-position of second wet point
%        .xG        : Grid corner x-position along open boundary
%        .yG        : Grid corner x-position along open boundary
%        .dxG    : Grid x-spacing on open boundary (ambiguous on y-boundaries)
%        .dyG    : Grid y-spacing on open boundary (ambiguous on x-boundaries)
%
%    glw, Jan 28 2016 (wagner.greg@gmail.com)
%
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
%        1    xC            5    rA           9    dyU         13    rAw
%        2    yC            6    xG          10    rAz         14    rAs
%        3    dxF           7    yG          11    dxC         15    dxG
%        4    dyF           8    dxV         12    dyC         16    dyG
% 
% Refer to http://mitgcm.org/sealion/online_documents/node47.html for more info.
% -----------------------------------------------------------------------------  
%%% From "GRID.h":
%
%   | (3) Views showing nomenclature and indexing
%   |     for grid descriptor variables.
%   |
%   |      Fig 3a. shows the orientation, indexing and
%   |      notation for the grid spacing terms used internally
%   |      for the evaluation of gradient and averaging terms.
%   |      These varaibles are set based on the model input
%   |      parameters which define the model grid in terms of
%   |      spacing in X, Y and Z.
%   |
%   |      Fig 3b. shows the orientation, indexing and
%   |      notation for the variables that are used to define
%   |      the model grid. These varaibles are set directly
%   |      from the model input.
%   |
%   | Figure 3a
%   | =========
%   |       |------------------------------------
%   |       |                       |
%   |"PWY"********************************* etc...
%   |       |                       |
%   |       |                       |
%   |       |                       |
%   |       |                       |
%   |       |                       |
%   |       |                       |
%   |       |                       |
%   |
%   |       .                       .
%   |       .                       .
%   |       .                       .
%   |       e                       e
%   |       t                       t
%   |       c                       c
%   |       |-----------v-----------|-----------v----------|-
%   |       |                       |                      |
%   |       |                       |                      |
%   |       |                       |                      |
%   |       |                       |                      |
%   |       |                       |                      |
%   |       u<--dxF(i=1,j=2,k=1)--->u           t          |
%   |       |/|\       /|\          |                      |
%   |       | |         |           |                      |
%   |       | |         |           |                      |
%   |       | |         |           |                      |
%   |       |dyU(i=1,  dyC(i=1,     |                      |
%   | ---  ---|--j=2,---|--j=2,-----------------v----------|-
%   | /|\   | |  k=1)   |  k=1)     |          /|\         |
%   |  |    | |         |           |          dyF(i=2,    |
%   |  |    | |         |           |           |  j=1,    |
%   |dyG(   |\|/       \|/          |           |  k=1)    |
%   |   i=1,u---        t<---dxC(i=2,j=1,k=1)-->t          |
%   |   j=1,|                       |           |          |
%   |   k=1)|                       |           |          |
%   |  |    |                       |           |          |
%   |  |    |                       |           |          |
%   | \|/   |           |<---dxV(i=2,j=1,k=1)--\|/         |
%   |"SB"++>|___________v___________|___________v__________|_
%   |       <--dxG(i=1,j=1,k=1)----->
%   |      /+\                                              .
%   |       +
%   |       +
%   |     "WB"
%   |
%   |   N, y increasing northwards
%   |  /|\ j increasing northwards
%   |   |
%   |   |
%   |   ======>E, x increasing eastwards
%   |             i increasing eastwards
%   |
%   |    i: East-west index
%   |    j: North-south index
%   |    k: up-down index
%   |    u: x-velocity point
%   |    V: y-velocity point
%   |    t: tracer point
%   | "SB": Southern boundary
%   | "WB": Western boundary
%   |"PWX": Periodic wrap around in X.
%   |"PWY": Periodic wrap around in Y.
% -----------------------------------------------------------------------------  
% Message.
fprintf('Getting horizontal grid information at open boundaries... '), t1 = tic;

% Store grid properties for each open boundary condition.
for iOb = 1:length(obij)

    % Get the face of the open boundary.
    face = obij{iOb}.face;

    % Load and cut the global llc grid at model-grid resolution.
    gridFileName = [gridDir 'llc_00' int2str(face) '_', ...
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

    % Get the boundary indices on the llc grid.
    [ii, jj] = getOpenBoundaryIndices(obij{iOb}, 'llc');

    % Store grid corner and grid length information.
    obij{iOb}.xG  = xG (ii.xG,  jj.xG );
    obij{iOb}.yG  = yG (ii.yG,  jj.yG );
    obij{iOb}.dxG = dxG(ii.dxG, jj.dxG);
    obij{iOb}.dyG = dyG(ii.dyG, jj.dyG);

    % Cell center x-positions of first and second wet point.
    obij{iOb}.xC1 = xC (ii.T1, jj.T1);
    obij{iOb}.xC2 = xC (ii.T2, jj.T2);

    % Cell center y-positions of first and second wet point.
    obij{iOb}.yC1 = yC (ii.T1, jj.T1);
    obij{iOb}.yC2 = yC (ii.T2, jj.T2);

    % Reshape so all matrices have dimension (1 x nn) or (1 x nn+1)
    obij{iOb}.xG  = reshape(obij{iOb}.xG , 1, length(obij{iOb}.xG ));
    obij{iOb}.yG  = reshape(obij{iOb}.yG , 1, length(obij{iOb}.yG ));
    obij{iOb}.dxG = reshape(obij{iOb}.dxG, 1, length(obij{iOb}.dxG));
    obij{iOb}.dyG = reshape(obij{iOb}.dyG, 1, length(obij{iOb}.dyG));

    obij{iOb}.xC1 = reshape(obij{iOb}.xC1, 1, length(obij{iOb}.xC1));
    obij{iOb}.xC2 = reshape(obij{iOb}.xC2, 1, length(obij{iOb}.xC2));

    obij{iOb}.yC1 = reshape(obij{iOb}.yC1, 1, length(obij{iOb}.yC1));
    obij{iOb}.yC2 = reshape(obij{iOb}.yC2, 1, length(obij{iOb}.yC2));
    
end

fprintf('done. (time = %6.3f s)\n', toc(t1))
