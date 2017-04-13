function tiling(child)

% step through the tiles and determine whether there is ocean
tileNumber = 0;
blankTiles = [];
for i = 1:5
  for ni = 1:child.nii(i)/child.tileSize
    for nj = 1:child.njj(i)/child.tileSize
      tileNumber = tileNumber + 1;
      % indices of tile
      ii = (ni-1)*child.tileSize+1:ni*child.tileSize;
      jj = (nj-1)*child.tileSize+1:nj*child.tileSize;
      if all(all(child.bathy{i}(ii,jj)==0))
        % no ocean!
        blankTiles = [blankTiles tileNumber];
      end
    end
  end
end

fprintf('---------- TILING ----------\n')
fprintf('Super-grid size:       %d\n', child.nSuperGrid)
fprintf('Tile size:             %d\n', child.tileSize)
fprintf('Number of tiles:       %d\n', tileNumber)
fprintf('Number of blank tiles: %d\n', length(blankTiles))
fprintf('Number of used tiles:  %d\n', tileNumber - length(blankTiles))
fprintf('Blank tiles:\n')
for i = 1:length(blankTiles)
  fprintf(' %d,', blankTiles(i))
end
fprintf('\n')

end
