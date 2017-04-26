function child = modifyBathymetry(child)
% user-specified modifications of the bathymetry

% close Strait of Gibraltar
child.bathy{1}(768,270:294) = 0;

end

