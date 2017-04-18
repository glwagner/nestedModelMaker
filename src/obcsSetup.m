function obcsSetup(child, childObij)

% north
fprintf('OB_Jnorth = ');
for face = 1:5
  found = false;
  for ob = childObij
    if ob{1}.face == face & strcmp(ob{1}.edge, 'north')
      j = ob{1}.jj(1) - child.jj(face,1) + 2;
      n = length(ob{1}.jj);
      found = true;
      fprintf('%d*%d, ', n, j);
    end
  end
  if ~found & child.nii(face) > 0
    fprintf('%d*0, ', child.nii(face));
  end
end
fprintf('\n')

% south
fprintf('OB_Jsouth = ');
for face = 1:5
  found = false;
  for ob = childObij
    if ob{1}.face == face & strcmp(ob{1}.edge, 'south')
      j = ob{1}.jj(1) - child.jj(face,1);
      n = length(ob{1}.jj);
      found = true;
      fprintf('%d*%d, ', n, j);
    end
  end
  if ~found & child.nii(face) > 0
    fprintf('%d*0, ', child.nii(face));
  end
end
fprintf('\n')

% east
fprintf('OB_Ieast = ');
for face = 1:5
  found = false;
  for ob = childObij
    if ob{1}.face == face & strcmp(ob{1}.edge, 'east')
      i = ob{1}.ii(1) - child.ii(face,1) + 2;
      n = length(ob{1}.ii);
      found = true;
      fprintf('%d*%d, ', n, i);
    end
  end
  if ~found & child.njj(face) > 0
    fprintf('%d*0, ', child.njj(face));
  end
end
fprintf('\n')

% west
fprintf('OB_Iwest = ');
for face = 1:5
  found = false;
  for ob = childObij
    if ob{1}.face == face & strcmp(ob{1}.edge, 'west')
      i = ob{1}.ii(1) - child.ii(face,1);
      n = length(ob{1}.ii);
      found = true;
      fprintf('%d*%d, ', n, i);
    end
  end
  if ~found & child.njj(face) > 0
    fprintf('%d*0, ', child.njj(face));
  end
end
fprintf('\n')

end
