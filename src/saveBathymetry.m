function saveBathymetry(dirz, child)

f = fopen([dirz.childInput 'bathy.bin'], 'w', 'ieee-be');
for i = 1:5
  fwrite(f, child.bathy{i}, 'real*4');
end
fclose(f);

end
