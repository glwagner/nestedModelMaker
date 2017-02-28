function child = getChildBathymetry(bathyDir, child)

% This hook is needed because we only have the 1080 bathy in real*4.
if child.res == 1080
    precision = 'real*4';
else
    precision = 'real*8';
end

% Convention for indices in child.ii and child.jj.
left  = 1;
right = 2;
lower = 1;
upper = 2;

for face = 1:5
    if child.ii(face, 1) ~= 0

        % Load bathymetry.
        fprintf('Loading bathymetry... '), t1=tic;
        bathy = read_llc_fkij(bathyDir, child.res, face, ...
                            1, 1:child.res, 1:3*child.res, precision); 
        fprintf('done. (time = %6.3f s)\n', toc(t1))

        % Unmangle the bathymetry.
        bathy = unmangleLLCBathymetry(bathy, face);


        for side = 1:2
            % Add land at edges on open boundaries, using coordinates
            % obtained before domain was snapped to the super grid.
            if strcmp(child.bcs.ii{face}{side}, 'open')
                bathy( ...
                    child.unsnapped.ii(face, side),  ...
                    child.unsnapped.jj(face, lower):child.unsnapped.jj(face, upper) ...
                      ) = 0;
            end

            if strcmp(child.bcs.jj{face}{side}, 'open')
                bathy( ...
                      child.unsnapped.ii(face, left):child.unsnapped.ii(face, right),  ...
                      child.unsnapped.jj(face, side) ...
                                  ) = 0;
            end

        end

        % Store bathymetry
        ii = child.ii(face, 1):child.ii(face, 2);
        jj = child.jj(face, 1):child.jj(face, 2);

        child.bathy{face} = bathy(ii, jj);

        % Set area added during grid-snapping to land.

        % Left boundary.
        child.bathy{face}(1:child.niiPad(face, left), :) = 0;                  
        % Lower boundary.
        child.bathy{face}(:, 1:child.njjPad(face, lower)) = 0;                  

        % Right boundary (niiPad is <=0)
        child.bathy{face}( ...
            1+child.nii(face)+child.niiPad(face, right):child.nii(face), :) = 0;                  

        % Upper boundary (njjPad is <=0)
        child.bathy{face}(:, ...
            1+child.njj(face)+child.njjPad(face, upper):child.njj(face), :) = 0;                  

    else
        child.bathy{face} = [];
    end
end
