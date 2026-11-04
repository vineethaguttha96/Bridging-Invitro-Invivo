% prompt the user to select the files to read in
[fileNames, filePath] = uigetfile('*.txt', 'Select the cell data files', 'MultiSelect', 'on');

% load the data from the selected files
data = cell(numel(fileNames), 1);
for i = 1:numel(fileNames)
  data{i} = load(fullfile(filePath, fileNames{i}));
end

% create a new figure
figure;
hold on;

% plot the lines for each cell
for i = 1:numel(fileNames)
  % extract the x and y coordinates for the cell
  x = data{i}(:,3);
  y = data{i}(:,4);
  
  % subtract the first x and y coordinates from all coordinates
  x = x - x(1);
  y = y - y(1);
  
  % plot the relative x and y coordinates as a line
  plot(x, y,'Linewidth',2,'Color','#59bfff');
end

% plot the end points for each cell
for i = 1:numel(fileNames)
  % extract the x and y coordinates for the cell
  x = data{i}(:,3);
  y = data{i}(:,4);
  
  % subtract the first x and y coordinates from all coordinates
  x = x - x(1);
  y = y - y(1);

  % plot the final position of the cell as a dot
  plot(x(end), y(end),'o', 'MarkerEdgeColor','#0da2ff','MarkerFaceColor', '#0da2ff');
end



% add labels to the axes
xlabel('x (mm)');
ylabel('y (mm)');
grid on;
box on;
set(gca, 'LineWidth', 2);