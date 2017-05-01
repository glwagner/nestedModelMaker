function saveObTides(dirz, child, childObij, childObTides)

% This function saves tidal amplitudes and phases along open boundaries
% in the format required by MITgcm and its LLC grid convention. This 
% convention concatenates all open boundaries for each grid-direction
% (rather than physical direction)

[nconst, ~] = size(childObTides{1}.am_u);

for edge = {'west', 'east', 'south', 'north'}

    % Initialize boundary fields with zeros
    switch edge{:}
        case {'west', 'east'}
            n = sum(child.njj);
        case {'north', 'south'}
            n = sum(child.nii);
    end

    am = zeros(nconst, n);
    ph = zeros(nconst, n);

    % Look for open boundaries and fill in non-zero values
    for face = 1:5
        for ib = 1:length(childObij)

            if childObij{ib}.face == face & strcmp(childObij{ib}.edge, edge)

                switch edge{:}
                    case {'west', 'east'}
                        i0 = sum(child.njj(1:face-1))+1;
                        i1 = sum(child.njj(1:face));
      
                        am(:, i0:i1) = childObTides{ib}.am_u;
                        ph(:, i0:i1) = childObTides{ib}.ph_u;
                    case {'north', 'south'}
                        i0 = sum(child.nii(1:face-1))+1;
                        i1 = sum(child.nii(1:face));
      
                        am(:, i0:i1) = childObTides{ib}.am_v;
                        ph(:, i0:i1) = childObTides{ib}.ph_v;
                 end

            end
        end
    end

    % Save amplitude
    filename = sprintf('OB%cam_%dx%d.bin', upper(edge{1}(1)), n, nconst);
    file = fopen([dirz.childInput, filename], 'w', 'ieee-be');
    fwrite(file, am', 'real*4');
    fclose(file);

    % Save phase
    filename = sprintf('OB%cph_%dx%d.bin', upper(edge{1}(1)), n, nconst);
    file = fopen([dirz.childInput, filename], 'w', 'ieee-be');
    fwrite(file, ph', 'real*4');
    fclose(file);
end
