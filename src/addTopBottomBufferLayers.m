function [fields, zGrid] = addTopBottomBufferLayers(fields, parent)

% Add border to three-dimensional parent fields to allow interpolation onto
%   1. The deepest bottom cell mid-point on the child grid, which is deeper
%       than the deepest parent cell mid-point; 
%   2. The uppermost cell mid-point on the child grid, which is shallower
%        than the uppermost parent cell mid-point.
bottomNaNLayer = 1;

% Vertical grid to be modified and outputted
zGrid = parent.zGrid;
nz = parent.nz;

% Copy bottom cell on the parent grid
zGrid.zF (nz+2) = parent.zGrid.zF(end)-parent.zGrid.dzF(end);
zGrid.dzF(nz+1) = parent.zGrid.zF(end);
zGrid.zC (nz+1) = 1/2*(parent.zGrid.zF(end-1)+parent.zGrid.zF(end));
zGrid.dzC(nz)  = parent.zGrid.zC(end-1)-parent.zGrid.zC(end);

% New number of z-points.
nz = length(zGrid.zC);

% Copy top cell on the parent grid into land.
zGrid.zF  = [ -parent.zGrid.zF(2); 
                reshape(zGrid.zF, nz+1, 1) ];

zGrid.dzF = [ parent.zGrid.zF(1)-parent.zGrid.zF(2);
                reshape(zGrid.dzF, nz, 1) ];

zGrid.zC  = [ 1/2*(zGrid.zF(1)+zGrid.zF(2));
                reshape(zGrid.zC, nz, 1) ];

zGrid.dzC = [ zGrid.zC(1)-zGrid.zC(2);
                reshape(zGrid.dzC, nz-1, 1) ];

% New number of z-points.
zGrid.nz = length(zGrid.zC);

% Create a copy of layer of NaNs on bottom
for face = 1:5
    if bottomNaNLayer
        fields{face}.T = cat(3, ...
            fields{face}.T,  NaN( size(fields{face}.T(:, :, 1)) ));

        fields{face}.S = cat(3, ...
            fields{face}.S,  NaN( size(fields{face}.S(:, :, 1)) ));

        fields{face}.U = cat(3, ...
            fields{face}.U,  NaN( size(fields{face}.U(:, :, 1)) ));

        fields{face}.V = cat(3, ...
            fields{face}.V,  NaN( size(fields{face}.V(:, :, 1)) ));
    else
        fields{face}.T = cat(3, fields{face}.T,  fields{face}.T(:, :, end));
        fields{face}.S = cat(3, fields{face}.S,  fields{face}.S(:, :, end));
        fields{face}.U = cat(3, fields{face}.U,  fields{face}.U(:, :, end));
        fields{face}.V = cat(3, fields{face}.V,  fields{face}.V(:, :, end));
    end    
end

% Copy top cells.
for face = 1:5
    fields{face}.T = cat(3, fields{face}.T(:, :, 1), fields{face}.T); 
    fields{face}.S = cat(3, fields{face}.S(:, :, 1), fields{face}.S); 
    fields{face}.U = cat(3, fields{face}.U(:, :, 1), fields{face}.U); 
    fields{face}.V = cat(3, fields{face}.V(:, :, 1), fields{face}.V); 
end
