function saveObTides(child, childObij, childObTides)

[nconst, l] = size(childObTides{1}.am_u);

for edge = {'west', 'east', 'south', 'north'}
  % initialize boundary fields with zeros
  if strcmp(edge, 'west') | strcmp(edge, 'east')
    n = sum(child.njj);
  else
    n = sum(child.nii);
  end
  am = zeros(nconst, n);
  ph = zeros(nconst, n);
  % look for open boundaries and fill in values
  for face = 1:5
    for ib = 1:length(childObij)
      if childObij{ib}.face == face & strcmp(childObij{ib}.edge, edge)
        if strcmp(edge, 'west') | strcmp(edge, 'east')
          i0 = sum(child.njj(1:face-1))+1;
          i1 = sum(child.njj(1:face));
          am(:,i0:i1) = childObTides{ib}.am_u;
          ph(:,i0:i1) = childObTides{ib}.ph_u;
        else
          i0 = sum(child.nii(1:face-1))+1;
          i1 = sum(child.nii(1:face));
          am(:,i0:i1) = childObTides{ib}.am_v;
          ph(:,i0:i1) = childObTides{ib}.ph_v;
        end
      end
    end
  end
  % save amplitude
  file = sprintf('OB%cam_%dx%d.bin', upper(edge{1}(1)), n, nconst);
  f = fopen(['out/', file], 'w', 'ieee-be');
  fwrite(f, am', 'real*4');
  fclose(f);
  % save phase
  file = sprintf('OB%cph_%dx%d.bin', upper(edge{1}(1)), n, nconst);
  f = fopen(['out/', file], 'w', 'ieee-be');
  fwrite(f, ph', 'real*4');
  fclose(f);
end

end
