function child = bathymetryAdjustments(child)
% removes ocean that is not connected

for face = 1:5
  if child.ii(face, 1) ~= 0
    % land sea mask
    mask_full = zeros(size(child.bathy{face}));
    mask_full(child.bathy{face}<0) = 1;
    % connected mask to be created
    mask_cnct = zeros(size(child.bathy{face}));
    % specify one point that's in the domain (allow user specification!)
    mask_cnct(200,100) = 1;
    % counter of added cells per iteration
    n = 1;
    % while new cells are added
    while n > 0
      n = 0;
      % look west
      for i = 1:child.nii(face)-1
        for j = 1:child.njj(face)
          if mask_cnct(i,j) == 0 && mask_full(i,j) == 1 && mask_cnct(i+1,j) == 1
            mask_cnct(i,j) = 1;
            n = n + 1;
          end
        end
      end
      % look east
      for i = 2:child.nii(face)
        for j = 1:child.njj(face)
          if mask_cnct(i,j) == 0 && mask_full(i,j) == 1 && mask_cnct(i-1,j) == 1
            mask_cnct(i,j) = 1;
            n = n + 1;
          end
        end
      end
      % look north
      for i = 1:child.nii(face)
        for j = 1:child.njj(face)-1
          if mask_cnct(i,j) == 0 && mask_full(i,j) == 1 && mask_cnct(i,j+1) == 1
            mask_cnct(i,j) = 1;
            n = n + 1;
          end
        end
      end
      % look south
      for i = 1:child.nii(face)
        for j = 2:child.njj(face)
          if mask_cnct(i,j) == 0 && mask_full(i,j) == 1 && mask_cnct(i,j-1) == 1
            mask_cnct(i,j) = 1;
            n = n + 1;
          end
        end
      end
    end
    % apply new mask
    child.bathy{face} = child.bathy{face} .* mask_cnct;
  end
end
