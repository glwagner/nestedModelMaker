function [childObij, childObuv] = snapOpenBoundaryToSuperGrid(childObij, childObuv, child)

% Loop over open boundaries
for iOb = 1:length(childObij)

    % Rename structure for convenience
    obij = childObij{iOb};
    obuv = childObuv{iOb};

    % Extract parameters from obij and obuv structures for convenience.
    face = obij.face;
    [nn, nz, nt] = size(obuv.T1);

    % Convention for indices in child.ii and child.jj.
    left  = 1; right = 2;
    lower = 1; upper = 2;

    switch obij.edge
        case {'south', 'north'}

            % Pad right and left. Left first
            if child.niiPad(face, left) ~= 0

                % Pad with zeros.
                pad = zeros(child.niiPad(face, left), nz, nt);

                % The order of pad and obuv.** is the crucial bit here.
                obuv.T1 = cat(1, pad, obuv.T1);
                obuv.T2 = cat(1, pad, obuv.T2);
                obuv.S1 = cat(1, pad, obuv.S1);
                obuv.S2 = cat(1, pad, obuv.S2);
                obuv.U  = cat(1, pad, obuv.U );
                obuv.V  = cat(1, pad, obuv.V );

                % Remake index vectors.
                obij.ii = obij.ii(1)-child.niiPad(face, left):obij.ii(end);
                obij.jj = obij.jj(ones(1, length(obij.ii)));

            end

            % Right next.
            if child.niiPad(face, right) ~= 0

                % Pad with zeros.
                pad = zeros(child.niiPad(face, right), nz, nt);

                % The order of pad and obuv.** is the crucial bit here.
                obuv.T1 = cat(1, obuv.T1, pad);
                obuv.T2 = cat(1, obuv.T2, pad);
                obuv.S1 = cat(1, obuv.S1, pad);
                obuv.S2 = cat(1, obuv.S2, pad);
                obuv.U  = cat(1, obuv.U , pad);
                obuv.V  = cat(1, obuv.V , pad);

                % Remake index vectors.
                obij.ii = obij.ii(1):obij.ii(end)+child.niiPad(face, right);
                obij.jj = obij.jj(ones(1, length(obij.ii)));

            end

        case {'east', 'west'}

            % Pad top and bottom. Bottom first.
            if child.njjPad(face, lower) ~= 0

                % Pad with zeros.
                pad = zeros(child.njjPad(face, lower), nz, nt);

                % The order of pad and obuv.** is the crucial bit here.
                obuv.T1 = cat(1, pad, obuv.T1);
                obuv.T2 = cat(1, pad, obuv.T2);
                obuv.S1 = cat(1, pad, obuv.S1);
                obuv.S2 = cat(1, pad, obuv.S2);
                obuv.U  = cat(1, pad, obuv.U );
                obuv.V  = cat(1, pad, obuv.V );

                % Remake index vectors.
                obij.jj = obij.jj(1)-child.njjPad(face, lower):obij.jj(end);
                obij.ii = obij.ii(ones(1, length(obij.jj)));

            end

            % Top next.
            if child.njjPad(face, upper) ~= 0

                % Pad with zeros.
                pad = zeros(child.njjPad(face, upper), nz, nt);

                % The order of pad and obuv.** is the crucial bit here.
                obuv.T1 = cat(1, obuv.T1, pad);
                obuv.T2 = cat(1, obuv.T2, pad);
                obuv.S1 = cat(1, obuv.S1, pad);
                obuv.S2 = cat(1, obuv.S2, pad);
                obuv.U  = cat(1, obuv.U , pad);
                obuv.V  = cat(1, obuv.V , pad);

                % Remake index vectors.
                obij.jj = obij.jj(1):obij.jj(end)+child.njjPad(face, upper);
                obij.ii = obij.ii(ones(1, length(obij.jj)));

            end
    end

    % Reassign structures.
    childObij{iOb} = obij;
    childObuv{iOb} = obuv;

end
