function [fields, parent] = modifyInitialParentFields(fields, parent, child)

% Add border to three-dimensional parent fields to allow interpolation onto
%   1. The deepest bottom cell mid-point on the child grid, which is deeper
%       than the deepest parent cell mid-point; 
%   2. The child-grid cells that are adjacent to interior boundaries between
%       faces, which require information across face.

% Names of temperature, salinitiy, and velocitiy vectors in the struct 
% "fields".
names = {'T', 'S', 'U', 'V'};

% Copy bottom cell on the parent grid
parent.zGrid.zF (parent.nz+2) = parent.zGrid.zF(end)-parent.zGrid.dzF(end);
parent.zGrid.dzF(parent.nz+1) = parent.zGrid.zF(end);
parent.zGrid.zC (parent.nz+1) = 1/2*(parent.zGrid.zF(end-1)+parent.zGrid.zF(end));
parent.zGrid.dzC(parent.nz) = parent.zGrid.zC(end-1)-parent.zGrid.zC(end);
parent.nz = length(parent.zGrid.zC);

for face = 1:5
    if child.nii(face) ~= 0
        for nn = 1:numel(names)
            fields{face}.(names{nn}) = ...
                cat(3, fields{face}.(names{nn}),  NaN(size(fields{face}.(names{nn})(:, :, 1))));
        end
    end
end


% Copy top cell on the parent grid into land.
parent.zGrid.zF  = [ -parent.zGrid.zF(1); 
                    reshape(parent.zGrid.zF, parent.nz+1, 1) ];

parent.zGrid.dzF = [ parent.zGrid.zF(1)-parent.zGrid.zF(2);
                     reshape(parent.zGrid.dzF, parent.nz, 1) ];

parent.zGrid.zC  = [ 1/2*(parent.zGrid.zF(1)+parent.zGrid.zF(2));
                    reshape(parent.zGrid.zC, parent.nz, 1) ];

parent.zGrid.dzC = [ parent.zGrid.zC(1)-parent.zGrid.zC(2);
                     reshape(parent.zGrid.dzC, parent.nz-1, 1) ];

parent.nz = length(parent.zGrid.zC);

for face = 1:5
    if child.nii(face) ~= 0
        for nn = 1:numel(names)
            fields{face}.(names{nn}) = ...
                cat(3, fields{face}.(names{nn})(:, :, 1), fields{face}.(names{nn}) ); 
        end
    end
end

% Along each interior boundary, add the neighboring strip of field and grid points
% from the adjacent face.

% Key
left  = 1;
right = 2;
lower = 1;
upper = 2;

% Remember: ii (1st index) is left-right; jj (2nd index) is up-down.
% "Left" or "lower" means first index, "right" or "upper" means final index.
for face = 1:5
    if child.nii(face) ~= 0

        % Left: ii=1.
        if strcmp(child.bcs.ii{face}{left}, 'interior')
            switch face
                case 1
                    % Note: left edge of face 1 is upper edge of face 5
                    neighbor = 5;
                    permutation = 1;
                case 2
                    % Note: left edge of face 2 is right edge of face 1.
                    neighbor = 1;
                    permutation = 0;
                case 3
                    error('Face 3 is not yet supported.')
                    % Note: left edge of face 3 is upper edge of face 1.
                    neighbor = 1;
                    permutation = 1;
                case 4
                    error('Actions involving face 3 are not supported.')
                    % Note: left edge of face 4 is right edge of face 3.
                    neighbor = 3;
                    permutation = 0;
                case 5
                    error('Actions involving face 3 are not supported.')
                    % Note: left edge of face 5 is upper edge of face 3.
                    neighbor = 3;
                    permutation = 1;
            end

            if permutation
               permuteKey2 = [2 1];
               permuteKey3 = [2 1 3];
               % Target indices on neighboring face
               ii = 1:parent.nii(neighbor);
               jj = parent.njj(neighbor);
            else
                permuteKey2 = [1 2];
                permuteKey3 = [1 2 3];
                % Target indices on neighboring face
                ii = parent.nii(neighbor);
                jj = 1:parent.njj(neighbor);
            end

            % Add cells on left side.
            for nn = 1:numel(names)
                fields{face}.(names{nn}) = cat(1, ...
                    permute(fields{neighbor}.(names{nn})(ii, jj, :), permuteKey3), ...
                    fields{face}.(names{nn}));
            end

            parent.hGrid{face}.xC = cat(1, ...
                permute(parent.hGrid{neighbor}.xC(ii, jj, :), permuteKey2), ...
                parent.hGrid{face}.xC);

            parent.hGrid{face}.yC = cat(1, ...
                permute(parent.hGrid{neighbor}.yC(ii, jj, :), permuteKey2), ...
                parent.hGrid{face}.yC);

        end

        % Right: ii=end.
        if strcmp(child.bcs.ii{face}{right}, 'interior')
            % Add cells.
            switch face
                case 1
                    % Note: right edge of face 1 is left edge of face 2.
                    neighbor = 2;
                    permutation = 0;
                case 2
                    % Note: right edge of face 2 is lower edge of face 4.
                    neighbor = 4;
                    permutation = 1;
                case 3
                    error('Face 3 is not yet supported.')
                    % Note: right edge of face 3 is left edge of face 4.
                    neighbor = 4;
                    permutation = 0;
                case 4
                    error('The right edge of face 4 is Antarctica.')
                case 5
                    error('The right edge of face 5 is Antarctica.')
            end

            if permutation
               permuteKey2 = [2 1];
               permuteKey3 = [2 1 3];
               % Target indices on neighboring face
               ii = 1:parent.nii(neighbor);
               jj = 1;
            else
                permuteKey2 = [1 2];
                permuteKey3 = [1 2 3];
                % Target indices on neighboring face
                ii = 1;
                jj = 1:parent.njj(neighbor);
            end

            for nn = 1:numel(names)
                % Add cells on right side.
                fields{face}.(names{nn}) = cat(1, ...
                    fields{face}.(names{nn}), ...
                    permute(fields{neighbor}.(names{nn})(ii, jj, :), permuteKey3));
            end

            parent.hGrid{face}.xC = cat(1, ...
                parent.hGrid{face}.xC, ...
                permute(parent.hGrid{neighbor}.xC(ii, jj, :), permuteKey2));

            parent.hGrid{face}.yC = cat(1, ...
                parent.hGrid{face}.yC, ...
                permute(parent.hGrid{neighbor}.yC(ii, jj, :), permuteKey2));

        end

        if strcmp(child.bcs.jj{face}{lower}, 'interior')
            % Add cells.
            switch face
                case 1
                    error('Lower edge of face 1 is Antarctica')
                case 2
                    error('Lower edge of face 2 is Antarctica')
                case 3
                    error('Lower edge of face 3 is Russia')
                case 4
                    % Note: lower edge of face 4 is right edge of face 2.
                    neighbor = 2;
                    permutation = 1;
                case 5
                    % Note: lower edge of face 5 is upper edge of face 4.
                    neighbor = 4;
                    permutation = 0;
            end

            if permutation
               permuteKey2 = [2 1];
               permuteKey3 = [2 1 3];
               % Target indices on neighboring face
               ii = parent.nii(neighbor);
               jj = 1:parent.njj(neighbor);
            else
                permuteKey2 = [1 2];
                permuteKey3 = [1 2 3];
                % Target indices on neighboring face
                ii = 1:parent.nii(neighbor);
                jj = parent.njj(neighbor);
            end

            % Add cells on left side.
            for nn = 1:numel(names)
                % Add cells on the lower side.
                fields{face}.(names{nn}) = cat(2, ...
                    permute(fields{neighbor}.(names{nn})(ii, jj, :), permuteKey3), ...
                    fields{face}.(names{nn}));
            end

            parent.hGrid{face}.xC = cat(2, ...
                permute(parent.hGrid{neighbor}.xC(ii, jj, :), permuteKey2), ...
                parent.hGrid{face}.xC);

            parent.hGrid{face}.yC = cat(2, ...
                permute(parent.hGrid{neighbor}.yC(ii, jj, :), permuteKey2), ...
                parent.hGrid{face}.yC);

        end

        if strcmp(child.bcs.jj{face}{upper}, 'interior')
            % Add cells.
            switch face
                case 1
                    error('Actions involving face 3 are not supported.')
                    % Note: upper edge of face 1 is left edge of face 3.
                    neighbor = 3;
                    permutation = 1;
                case 2
                    error('Upper edge of face 2 is Russia')
                case 3
                    error('Actions involving face 3 are not supported.')
                    % Note: upper edge of face 3 is left edge of face 5
                    neighbor = 5;
                    permutation = 1;
                case 4
                    % Note: upper edge of face 4 is lower edge of face 5.
                    neighbor = 5;
                    permutation = 0;
                case 5
                    % Upper edge of face 5 is left edge of face 1.
                    neighbor = 1;
                    permutation = 1;
            end

            if permutation
               permuteKey2 = [2 1];
               permuteKey3 = [2 1 3];
               % Target indices on neighboring face
               ii = 1;
               jj = 1:parent.njj(neighbor);
            else
                permuteKey2 = [1 2];
                permuteKey3 = [1 2 3];
                % Target indices on neighboring face
                ii = 1:parent.nii(neighbor);
                jj = 1;
            end

            for nn = 1:numel(names)
                % Add cells on right side.
                fields{face}.(names{nn}) = cat(2, ...
                    fields{face}.(names{nn}), ...
                    permute(fields{neighbor}.(names{nn})(ii, jj, :), permuteKey3));
            end

            parent.hGrid{face}.xC = cat(2, ...
                parent.hGrid{face}.xC, ...
                permute(parent.hGrid{neighbor}.xC(ii, jj, :), permuteKey2));

            parent.hGrid{face}.yC = cat(2, ...
                parent.hGrid{face}.yC, ...
                permute(parent.hGrid{neighbor}.yC(ii, jj, :), permuteKey2));

        end
    end
end
