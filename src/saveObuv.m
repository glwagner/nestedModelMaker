function saveObuv(dirz, child, childObij, childObuv)

for edge = {'west', 'east', 'south', 'north'}
  % initialize boundary fields with zeros
  if strcmp(edge, 'west') | strcmp(edge, 'east')
    n = sum(child.njj);
  else
    n = sum(child.nii);
  end
  U = zeros(n, child.nz, child.nObcMonths);
  V = zeros(n, child.nz, child.nObcMonths);
  T = zeros(n, child.nz, child.nObcMonths);
  S = zeros(n, child.nz, child.nObcMonths);
  % look for open boundaries and fill in values
  for face = 1:5
    for ib = 1:length(childObij)
      if childObij{ib}.face == face & strcmp(childObij{ib}.edge, edge)
        if strcmp(edge, 'west') | strcmp(edge, 'east')
          i0 = sum(child.njj(1:face-1))+1;
          i1 = sum(child.njj(1:face));
        else
          i0 = sum(child.nii(1:face-1))+1;
          i1 = sum(child.nii(1:face));
        end
        U(i0:i1,:,:) = childObuv{ib}.U;
        V(i0:i1,:,:) = childObuv{ib}.V;
        T(i0:i1,:,:) = childObuv{ib}.T1;
        S(i0:i1,:,:) = childObuv{ib}.S1;
      end
    end
  end
  % save U
  file = sprintf('OB%cu_%dx%dx%d.bin', upper(edge{1}(1)), n, child.nz, child.nObcMonths);
  f = fopen([dirz.childInput, file], 'w', 'ieee-be');
  fwrite(f, U, 'real*4');
  fclose(f);
  % save V
  file = sprintf('OB%cv_%dx%dx%d.bin', upper(edge{1}(1)), n, child.nz, child.nObcMonths);
  f = fopen([dirz.childInput, file], 'w', 'ieee-be');
  fwrite(f, V, 'real*4');
  fclose(f);
  % save T
  file = sprintf('OB%ct_%dx%dx%d.bin', upper(edge{1}(1)), n, child.nz, child.nObcMonths);
  f = fopen([dirz.childInput, file], 'w', 'ieee-be');
  fwrite(f, T, 'real*4');
  fclose(f);
  % save S
  file = sprintf('OB%cs_%dx%dx%d.bin', upper(edge{1}(1)), n, child.nz, child.nObcMonths);
  f = fopen([dirz.childInput, file], 'w', 'ieee-be');
  fwrite(f, S, 'real*4');
  fclose(f);
end

end
