function saveGrid(dirz, child)

% save grid files for each face

for i = 1:5

  f = fopen(sprintf('%stile%03d.mitgrid', dirz.childInput, i), 'w', 'ieee-be');

  if ~isempty(child.hGrid{i})

    % extract fields from child struct
    xC = child.hGrid{i}.xC;
    yC = child.hGrid{i}.yC;
    dxF = child.hGrid{i}.dxF;
    dyF = child.hGrid{i}.dyF;
    rAc = child.hGrid{i}.rAc;
    xG = child.hGrid{i}.xG;
    yG = child.hGrid{i}.yG;
    dxV = child.hGrid{i}.dxV;
    dyU = child.hGrid{i}.dyU;
    rAz = child.hGrid{i}.rAz;
    dxC = child.hGrid{i}.dxC;
    dyC = child.hGrid{i}.dyC;
    rAw = child.hGrid{i}.rAw;
    rAs = child.hGrid{i}.rAs;
    dxG = child.hGrid{i}.dxG;
    dyG = child.hGrid{i}.dyG;
  
    % pad with zeros to same size
    xC(end+1,end+1) = 0;
    yC(end+1,end+1) = 0;
    dxF(end+1,end+1) = 0;
    dyF(end+1,end+1) = 0;
    rAc(end+1,end+1) = 0;
    dxC(:,end+1) = 0;
    rAw(:,end+1) = 0;
    dyG(:,end+1) = 0;
    dyC(end+1,:) = 0;
    rAs(end+1,:) = 0;
    dxG(end+1,:) = 0;

    % save to file
    fwrite(f, xC, 'real*8');
    fwrite(f, yC, 'real*8');
    fwrite(f, dxF, 'real*8');
    fwrite(f, dyF, 'real*8');
    fwrite(f, rAc, 'real*8');
    fwrite(f, xG, 'real*8');
    fwrite(f, yG, 'real*8');
    fwrite(f, dxV, 'real*8');
    fwrite(f, dyU, 'real*8');
    fwrite(f, rAz, 'real*8');
    fwrite(f, dxC, 'real*8');
    fwrite(f, dyC, 'real*8');
    fwrite(f, rAw, 'real*8');
    fwrite(f, rAs, 'real*8');
    fwrite(f, dxG, 'real*8');
    fwrite(f, dyG, 'real*8');

  end

  fclose(f);

end

end
