function varargout = inpaintSliceForInterp(slice, zGrid)

    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    % inpaintSliceForInterp.m
    %
    % Inputs:
    %   slice        : a 2D slice to be modified and inpainted. The slice is
    %                  assumed to have dimension (h, z), where "h" is the 
    %                  horizontal coordinate and "z" is the vertical coordinate.
    %   
    %   zGrid        : a struct with fields 'zC', 'zF', 'dzC', and 'dzF' that 
    %                  describes the vertical grid. This structure is modified
    %                  along with the slice.
    %
    % Outputs: 
    %   paintedSlice : the modified slice with NaN's inpainted.
    %   zGrid        : the modified vertical grid struct
    %
    % This function adds top and bottom cells to slice and zGrid, and then 
    % inpaint_nans on the slice.  The slice and zGrid are modified by adding
    % cells to the top and bottom to account for
    %
    %   1. The deepest bottom cell mid-point on the child grid, which is deeper
    %       than the deepest parent cell mid-point; 
    %
    %   2. The shallowest top cell mid-point on the child grid for the same reason,
    %
    % The cell at the bottom is initialized with NaN and then inpainted, whereas 
    % the cell at the top is initialized with the same value as the cell below it.
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

    % Method for inpainting
    method = 0;

    % Add cells at top and bottom
    slice = cat(2, slice(:, 1), slice)
    slice = cat(2, slice, NaN(size(slice(:, 1))));

    % Inpaint the slice and assign to output.
    varargout{1} = inpaint_nans(slice, method);

    if nargin == 2

        % 1. Pad bottom cell on the parent grid with NaNs.
        zGrid.zF (nz+2) = zGrid.zF(end)-zGrid.dzF(end);
        zGrid.dzF(nz+1) = zGrid.zF(end);
        zGrid.zC (nz+1) = 1/2*(zGrid.zF(end-1)+zGrid.zF(end));
        zGrid.dzC(nz)   = zGrid.zC(end-1)-zGrid.zC(end);

        zGrid.nz = length(zGrid.zC);

        % 2. Copy top cell on the parent grid into land.
        zGrid.zF  = [ -zGrid.zF(1); 
                            reshape(zGrid.zF, nz+1, 1) ];

        zGrid.dzF = [ zGrid.zF(1)-zGrid.zF(2);
                             reshape(zGrid.dzF, nz, 1) ];

        zGrid.zC  = [ 1/2*(zGrid.zF(1)+zGrid.zF(2));
                            reshape(zGrid.zC, nz, 1) ];

        zGrid.dzC = [ zGrid.zC(1)-zGrid.zC(2);
                             reshape(zGrid.dzC, nz-1, 1) ];

        zGrid.nz = length(zGrid.zC)

        % Assign output
        varargout{2} = zGrid; 

    end

end
