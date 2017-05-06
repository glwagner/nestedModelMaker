function child = discardUnconnectedOcean(child)

% Removes ocean that is not connected.
figure(2)

for face = 1:5
  if child.ii(face, 1) ~= 0

    ax = subplot(2, 3, face), hold on, ax.YDir = 'normal';
    imagesc(child.bathy{face}'), daspect([1 1 1])
    plot(child.oceanPoint(face, 1), child.oceanPoint(face, 2), 'ro')

    % Land sea mask
    mask_full = zeros(size(child.bathy{face}));
    mask_full(child.bathy{face}<0) = 1;

    % Connected mask to be created
    mask_cnct = zeros(size(child.bathy{face}));
    mask_cnct(child.oceanPoint(face, 1), child.oceanPoint(face, 2)) = 1;

    % While new cells are being added
    n = 1;
    while n > 0
      n = 0;

      % Look west
      for i = 1:child.nii(face)-1
        for j = 1:child.njj(face)
          if mask_cnct(i,j) == 0 && mask_full(i,j) == 1 && mask_cnct(i+1,j) == 1
            mask_cnct(i,j) = 1;
            n = n + 1;
          end
        end
      end

      % Look east
      for i = 2:child.nii(face)
        for j = 1:child.njj(face)
          if mask_cnct(i,j) == 0 && mask_full(i,j) == 1 && mask_cnct(i-1,j) == 1
            mask_cnct(i,j) = 1;
            n = n + 1;
          end
        end
      end

      % Look north
      for i = 1:child.nii(face)
        for j = 1:child.njj(face)-1
          if mask_cnct(i,j) == 0 && mask_full(i,j) == 1 && mask_cnct(i,j+1) == 1
            mask_cnct(i,j) = 1;
            n = n + 1;
          end
        end
      end

      % Look south
      for i = 1:child.nii(face)
        for j = 2:child.njj(face)
          if mask_cnct(i,j) == 0 && mask_full(i,j) == 1 && mask_cnct(i,j-1) == 1
            mask_cnct(i,j) = 1;
            n = n + 1;
          end
        end
      end
    end

    % Apply new mask
    child.bathy{face} = child.bathy{face} .* mask_cnct;

  end
end
