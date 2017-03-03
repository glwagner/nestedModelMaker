function [obij, obuv] = snapOpenBoundariesToSuperGrid(obij, obuv, child)

% Extract parameters from obij and obuv structures for convenience.
face = obij.face;
[nn, nz, nt] = size(obuv.T1);

%% Convention for indices in child.ii and child.jj.
left  = 1;
right = 2;
lower = 1;
upper = 2;

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

        end

        % Right next.
        if child.niiPad(face, right) ~= 0

            % Pad with zeros.
            pad = zeros(-child.niiPad(face, right), nz, nt);

            % The order of pad and obuv.** is the crucial bit here.
            obuv.T1 = cat(1, obuv.T1, pad);
            obuv.T2 = cat(1, obuv.T2, pad);
            obuv.S1 = cat(1, obuv.S1, pad);
            obuv.S2 = cat(1, obuv.S2, pad);
            obuv.U  = cat(1, obuv.U , pad);
            obuv.V  = cat(1, obuv.V , pad);

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

        end

        % Top next.
        if child.njjPad(face, upper) ~= 0

            % Pad with zeros.
            pad = zeros(-child.njjPad(face, upper), nz, nt);

            % The order of pad and obuv.** is the crucial bit here.
            obuv.T1 = cat(1, obuv.T1, pad);
            obuv.T2 = cat(1, obuv.T2, pad);
            obuv.S1 = cat(1, obuv.S1, pad);
            obuv.S2 = cat(1, obuv.S2, pad);
            obuv.U  = cat(1, obuv.U , pad);
            obuv.V  = cat(1, obuv.V , pad);

        end
end
