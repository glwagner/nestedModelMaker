function tidalNamelist(cl)

% Save constituent periods to periods.txt.

% add TMD path
addpath(genpath('/net/barents/raid16/vocana/llc4320/NA2160x1080/run_template/joernc/tides/tmd_mar_203/TMD2.03'));

% find periods
periods = zeros(length(cl),1);
for i = 1:length(cl)
  [ispec, am, ph, omega, alpha, constitNum] = constit(cl(i,:));
  periods(i) = 2*pi/omega;
end

% write to file: name, period in hours, period in seconds
fileID = fopen('periods.txt', 'w');
fprintf(fileID,'name:        ');
for i = 1:length(cl)
  fprintf(fileID, '%4s         ', cl(i,:));
end
fprintf(fileID, '\n');
fprintf(fileID, 'period (hr): ');
fprintf(fileID, '%12.6f ', periods'/3600);
fprintf(fileID, '\n');
fprintf(fileID, 'period (s):  ');
fprintf(fileID, '%12.6f ', periods');
fclose(fileID);

end
