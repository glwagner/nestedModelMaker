function child = modifyBathymetry(child)
% user-specified modifications of the bathymetry

% close Strait of Gibraltar
child.bathy{1}(384,135:147) = 0;

end

