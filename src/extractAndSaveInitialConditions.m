function extractAndSaveInitialConditions(dirz, parent, child)

% Load model fields
fprintf('Loading parent model fields for interpolation... '), t0 = tic;

names = {'T', 'S', 'U', 'V'};
fields = loadInitialParentFields(dirz, parent, child);
[fields, parent] = modifyInitialParentFields(fields, parent, child);

fprintf('done. (time = %.3f s).\n', toc(t0))

% Use inpaint_nans on 2D slices to continue model data into land regions.
% Specify inpaint method, the slices to inpaint on ('xz' or 'xy'), and 
% whether or not to check the results of the inpainting.
method = 0;
inpaintSlices = 'xz';
checkInpainting = 0;

% For checking the results of the the in-painting:
unpainted = fields;

for face = 1:5
    if child.nii(face) ~= 0

        [nii, njj, nz] = size(fields{face}.S);

        fprintf('Inpainting NaNs on %s slices on face %d...', inpaintSlices, face)
        t0=tic;

        if strcmp(inpaintSlices, 'xz')
            switch face
                case {1, 2, 3}
                    for iiy = 1:njj
                        for nn = 1:numel(names)
                            fields{face}.(names{nn})(:, iiy, :) = ...
                                inpaint_nans(squeeze(fields{face}.(names{nn}) (:, iiy, :)), method);
                        end
                    end
                case {4, 5}
                    for iiy = 1:nii
                        for nn = 1:numel(names)
                            fields{face}.(names{nn})(iiy, :, :) = ...
                                inpaint_nans(squeeze(fields{face}.(names{nn}) (iiy, :, :)), method);
                        end
                    end
            end
        elseif strcmp(inpaintSlices, 'xy')
            for iiz = 1:nz
                for nn = 1:numel(names)
                    fields{face}.(names{nn})(:, :, iiz) = ...
                        inpaint_nans(fields{face}.(names{nn})(:, :, iiz), method);
                end
            end
        end

        fprintf('(time = %0.3f s).\n', toc(t0))
    end
end

% For checking the results of the the in-painting:
if checkInpainting
    face = 1;

    figure(1), clf
    for nn = 1:length(names)
        for zSlice = 1:parent.nz
            fprintf('field %s at z-level %d', names{ii}, zSlice)

            ax(1) = subplot(1, 2, 1);
            pcolor(unpainted{face}.(names{nn})(:, :, zSlice))
            shading flat
            
            ax(2) = subplot(1, 2, 2);
            pcolor(fields{face}.(names{nn})(:, :, zSlice))
            shading flat

            ax(2).CLim = ax(1).CLim;
            linkaxes(ax)
            input('Press enter to continue')
        end
    end
end

% Interpolation - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
%{
fprintf('Allocating memory for the initial condition...'), t1=tic;
for face = 1:5
    if child.nii(face) ~= 0
        for nn = 1:numel(names)
            initCond{face}.(names{nn}) = ...
                zeros(child.nii(face), child.njj(face), child.nz);
        end
    end
end
fprintf('done. (time = %0.3f s).\n', toc(t1))
%}

% Interpolate in z.
for face = 1:5
    if child.nii(face) ~= 0
        fprintf('Interpolating fields in z on face %d: ', face)
        t1=tic;

        for nn = 1:numel(names)
            fprintf('%s... ', names{nn})
            zInterped{face}.(names{nn}) = interp1( parent.zGrid.zC, ...
               permute(fields{face}.(names{nn}), [3 1 2]), ...
               child.zGrid.zC );

            % Return matrices to indexing form (y, x, z)
            zInterped{face}.(names{nn}) = ...
                permute(zInterped{face}.(names{nn}), [2 3 1]);
        end

        fprintf('done. (time = %0.3f s).\n', toc(t1))
    
    end
end

% Open files for saving
precision = 'real*4';
for cellName = names
    name = cellName{:};
    icFileName.(name) = sprintf('%s0_%dx%dx%d.bin', ...
        name, child.nEast, child.nNorth, child.nz);

    disp( icFileName.(name) )

    icFile.(name) = fopen(['out/' icFileName.(name)], 'w', 'ieee-be') ;
end


% Interpolate in x and y and save the result
interpMethod = 'linear';
for iiz = 1:child.nz
    for face = 1:5
        if child.nii(face) ~= 0

            fprintf(['Interpolating and saving fields in ' ...
                'xy on face %d at z = %0.3f m... '], ...
                face, child.zGrid.zC(iiz)), t1=tic;

            % T and S
            X = parent.hGrid{face}.xC;
            Y = parent.hGrid{face}.yC;

            Xq = child.hGrid{face}.xC;
            Yq = child.hGrid{face}.yC;

            xySlices.T = griddata(X, Y, zInterped{face}.T(:, :, iiz), ...
                            Xq, Yq, interpMethod);
                            
            xySlices.S = griddata(X, Y, zInterped{face}.S(:, :, iiz), ...
                            Xq, Yq, interpMethod);

            % U
            X = parent.hGrid{face}.xU;
            Y = parent.hGrid{face}.yU;

            Xq = child.hGrid{face}.xU;
            Yq = child.hGrid{face}.yU;

            xySlices.U = griddata(X, Y, zInterped{face}.U(:, :, iiz), ...
                            Xq, Yq, interpMethod);

            % V
            X = parent.hGrid{face}.xV;
            Y = parent.hGrid{face}.yV;

            Xq = child.hGrid{face}.xV;
            Yq = child.hGrid{face}.yV;

            xySlices.V = griddata(X, Y, zInterped{face}.V(:, :, iiz), ...
                            Xq, Yq, interpMethod);

            % Write initial condition slices to icFile
            fwrite(icFile.T, xySlices.T, precision)
            fwrite(icFile.S, xySlices.S, precision)
            fwrite(icFile.U, xySlices.U, precision)
            fwrite(icFile.V, xySlices.V, precision)
       
            fprintf('done. (time = %0.3f s).\n', toc(t1))

        end
    end
end

% Close files
fclose(icFile.T)
fclose(icFile.S)
fclose(icFile.U)
fclose(icFile.V)
