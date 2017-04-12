function extractAndSaveInitialConditions(dirz, parent, child)

% Load model fields
fprintf('Loading parent model fields for interpolation... '), t0 = tic;

[SALT, THETA, UVEL, VVEL] = loadInitialParentFields(dirz, parent, child);
[SALT, THETA, UVEL, VVEL, parent] = modifyInitialParentFields( ...
    SALT, THETA, UVEL, VVEL, parent, child);

fprintf('done. (time = %.3f s).\n', toc(t0))

% Use inpaint_nans on 2D slices to continue model data into land regions.
% Specify inpaint method, the slices to inpaint on ('xz' or 'xy'), and 
% whether or not to check the results of the inpainting.
method = 0;
inpaintSlices = 'xz';
checkInpainting = 0;

% For checking the results of the the in-painting:
fields = {'SALT', 'THETA', 'UVEL', 'VVEL'};
unpainted.SALT = SALT;
unpainted.THETA = THETA;
unpainted.UVEL = UVEL;
unpainted.VVEL = VVEL;

for face = 1:5
    if child.nii(face) ~= 0

        [nii, njj, nz] = size(SALT{face});

        fprintf('Inpainting NaNs on %s slices on face %d...', inpaintSlices, face)
        t0=tic;

        if strcmp(inpaintSlices, 'xz')
            switch face
                case {1, 2, 3}
                    for iiy = 1:njj
                        SALT{face} (:, iiy, :) = inpaint_nans(squeeze(SALT{face} (:, iiy, :)), method);
                        THETA{face}(:, iiy, :) = inpaint_nans(squeeze(THETA{face}(:, iiy, :)), method);
                        UVEL{face} (:, iiy, :) = inpaint_nans(squeeze(UVEL{face} (:, iiy, :)), method);
                        VVEL{face} (:, iiy, :) = inpaint_nans(squeeze(VVEL{face} (:, iiy, :)), method);
                    end
                case {4, 5}
                    for iiy = 1:nii
                        SALT{face} (iiy, :, :) = inpaint_nans(squeeze(SALT{face} (iiy, :, :)), method);
                        THETA{face}(iiy, :, :) = inpaint_nans(squeeze(THETA{face}(iiy, :, :)), method);
                        UVEL{face} (iiy, :, :) = inpaint_nans(squeeze(UVEL{face} (iiy, :, :)), method);
                        VVEL{face} (iiy, :, :) = inpaint_nans(squeeze(VVEL{face} (iiy, :, :)), method);
                    end
            end
        elseif strcmp(inpaintSlices, 'xy')
            for iiz = 1:nz
                SALT{face}(:, :, iiz)  = inpaint_nans(SALT{face}(:, :, iiz), method);
                THETA{face}(:, :, iiz) = inpaint_nans(THETA{face}(:, :, iiz), method);
                UVEL{face}(:, :, iiz)  = inpaint_nans(UVEL{face}(:, :, iiz), method);
                VVEL{face}(:, :, iiz)  = inpaint_nans(VVEL{face}(:, :, iiz), method);
            end
        end

        fprintf('(time = %0.3f s).\n', toc(t0))
    end
end

fprintf('done. (time = %.3f s)', toc(t0))

% For checking the results of the the in-painting:
if checkInpainting
    painted.SALT = SALT;
    painted.THETA = THETA;
    painted.UVEL = UVEL;
    painted.VVEL = VVEL;

    figure(1), clf
    for ii = 1:length(fields)
        for zSlice = 1:parent.nz
            fprintf('field %s at z-level %d', fields{ii}, zSlice)

            ax(1) = subplot(1, 2, 1);
            pcolor(unpainted.(fields{ii}){1}(:, :, zSlice))
            shading flat
            
            ax(2) = subplot(1, 2, 2);
            pcolor(painted.(fields{ii}){1}(:, :, zSlice))
            shading flat

            ax(2).CLim = ax(1).CLim;
            linkaxes(ax)
            input('Press enter to continue')
        end
    end
end

% Interpolation - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
fprintf('Allocating memory for the initial condition...'), t1=tic;
for face = 1:5
    if child.nii(face) ~= 0
        initialCondition{face}.T = zeros(child.nii(face), child.njj(face), child.nz);
        initialCondition{face}.S = zeros(child.nii(face), child.njj(face), child.nz);
        initialCondition{face}.U = zeros(child.nii(face), child.njj(face), child.nz);
        initialCondition{face}.V = zeros(child.nii(face), child.njj(face), child.nz);
    end
end
fprintf('done. (time = %0.3f s).\n', toc(t1))

% Interpolate in z.
for face = 1:5
    if child.nii(face) ~= 0
        fprintf('Interpolating fields in z on face %d: ', face)
        t1=tic;

        fprintf('salt... ')
        zInterpedFields{face}.S  = interp1( parent.zGrid.zC, ...
                                       permute(SALT{face}, [3 1 2]), ...
                                       child.zGrid.zC );

        fprintf('theta... ')
        zInterpedFields{face}.T = interp1( parent.zGrid.zC, ...
                                       permute(THETA{face}, [3 1 2]), ...
                                       child.zGrid.zC );

        fprintf('u... ')
        zInterpedFields{face}.U  = interp1( parent.zGrid.zC, ...
                                       permute(UVEL{face}, [3 1 2]), ...
                                       child.zGrid.zC );

        fprintf('and v... ')
        zInterpedFields{face}.V  = interp1( parent.zGrid.zC, ...
                                       permute(VVEL{face}, [3 1 2]), ...
                                       child.zGrid.zC );

        % Return matrices to indexing form (x, y, z)
        zInterpedFields{face}.T = permute(zInterpedFields{face}.T, [2 3 1]);
        zInterpedFields{face}.S = permute(zInterpedFields{face}.S, [2 3 1]);
        zInterpedFields{face}.U = permute(zInterpedFields{face}.U, [2 3 1]);
        zInterpedFields{face}.V = permute(zInterpedFields{face}.V, [2 3 1]);

        fprintf('done. (time = %0.3f s).\n', toc(t1))
    end
end

%{
% Interpolate in x and y.
interpolationMethod = 'linear';
for face = 1:5
    if child.nii(face) ~= 0
        fprintf('Interpolating fields in xy on face %d', face)
        for iiz = 1:child.nz

            size(parent.hGrid{face}.xC)
            size(parent.hGrid{face}.yC)
            size(zInterpedFields{face}.T(:, :, iiz))
            size(child.hGrid{face}.xC)
            size(child.hGrid{face}.yC)

            max(max(parent.hGrid{face}.xC))
            min(min(parent.hGrid{face}.xC))

            max(max(parent.hGrid{face}.yC))
            min(min(parent.hGrid{face}.yC))

            max(max(child.hGrid{face}.xC))
            min(min(child.hGrid{face}.xC))

            max(max(child.hGrid{face}.yC))
            min(min(child.hGrid{face}.yC))

            initialCondition{face}.T(:, :, iiz) = ...
                griddata( parent.hGrid{face}.xC, parent.hGrid{face}.yC, ...
                         zInterpedFields{face}.T(:, :, iiz), ...
                         child.hGrid{face}.xC, child.hGrid{face}.yC, ...
                        interpolationMethod);

            initialCondition{face}.S(:, :, iiz) = ...
                griddata( parent.hGrid{face}.xC, parent.hGrid{face}.yC, ...
                         zInterpedFields{face}.S(:, :, iiz), ...
                         child.hGrid{face}.xC, child.hGrid{face}.yC, ...
                        interpolationMethod);

            initialCondition{face}.U(:, :, iiz) = ...
                griddata( parent.hGrid{face}.xC, parent.hGrid{face}.yC, ...
                         zInterpedFields{face}.U(:, :, iiz), ...
                         child.hGrid{face}.xC, child.hGrid{face}.yC, ...
                        interpolationMethod);

            initialCondition{face}.V(:, :, iiz) = ...
                griddata( parent.hGrid{face}.xC, parent.hGrid{face}.yC, ...
                         zInterpedFields{face}.V(:, :, iiz), ...
                         child.hGrid{face}.xC, child.hGrid{face}.yC, ...
                        interpolationMethod);

        end
        fprintf('done. (time = %0.3f s).\n', toc(t1))
    end
end
%}
