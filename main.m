%% Load House info
path2proj = fullfile(getenv('homepath'), 'Documents','github','SDC');
hprices = importHouseprices(path2proj);
hmeta   = importHousemeta(path2proj);
%%
% BoundingBox
bbox = double([min(hprices.Oseast1M), min(hprices.Osnrth1M); max(hprices.Oseast1M), max(hprices.Osnrth1M)])/100;

% Read backdrop raster image
rastermap = '.\data\minisc_gb\data\RGB_TIF_compressed\MiniScale_(relief1)_R16.tif';
info      = imfinfo(rastermap);
backdrop  = imread(rastermap, 'PixelRegion',{info.Height-[bbox(2,2) bbox(1,2)],bbox(1:2,1)});

% Plot
figure('GraphicsSmoothing', 'off');
image(bbox(:,1),bbox([2,1],2),backdrop)
axis equal tight
set(gca,'Ydir','normal','NextPlot','add')
alpha(0.6)
axis(bbox(:)')

% Scatter 10% of the points
npoints = numel(hprices.Oseast1M);
isample = randsample(npoints, ceil(0.1*npoints));
s       = line(hprices.Oseast1M(isample)/100, hprices.Osnrth1M(isample)/100,...
               'LineStyle','none','Marker','o', 'MarkerFaceColor',lines(1),...
               'MarkerEdgeColor','none','MarkerSize',1.5);
s       = scatter(hprices.Oseast1M(isample)/100, hprices.Osnrth1M(isample)/100,4, log(double(hprices.Price(isample)/100)),'o','filled');
colormap('jet')           

% Add constituency boundaries
constboundaries = '.\data\bdline_essh_gb\Data\westminster_const_region.shp';
% info = shapeinfo(constboundaries);
S               = shaperead(constboundaries,'boundingbox',bbox*100);
nS              = numel(S);

% Detect partial and empty constituencies
% Draw circle of 100km distance
pcenter  = find(hmeta.Distance_London == 0,1,'first');
c        = double([hmeta.Oseast1M(pcenter),hmeta.Osnrth1M(pcenter)])/100;
radius   = 1000;
theta    = (0:0.01:2*pi)';
circ     = [c(1) + radius.*cos(theta), c(2) + radius.*sin(theta)];
plot(circ(:,1),circ(:,2),'-r')
% Partial if polygon intersects circle
ipart = false(nS,1);
pop   = zeros(nS,2);
for ii = 1:nS
    S(ii).X = S(ii).X/100;
    S(ii).Y = S(ii).Y/100;
    ipart(ii) = any(inpolygon(circ(:,1),circ(:,2), S(ii).X, S(ii).Y));
    pop(ii,:) = [S(ii).X(1), S(ii).Y(1)];
end
Spart = S(ipart);

% Empty if any point of the boundary not in circle
iempty = ~inpolygon(pop(:,1),pop(:,2), circ(:,1),circ(:,2));

% Drop
S(iempty | ipart) = [];
mapshow(Spart,'FaceColor','None','EdgeColor','k','LineWidth',1.5)
mapshow(S,'FaceColor','None','EdgeColor','g','LineWidth',1.5)

% 
% constboundaries = '.\data\bdline_essh_gb\Data\parish_region.shp';
% info = shapeinfo(constboundaries);
% S    = shaperead(constboundaries,'boundingbox',bbox*100);
% for ii = 1:numel(S)
%     S(ii).X = S(ii).X/100;
%     S(ii).Y = S(ii).Y/100;
% end
% mapshow(S,'FaceColor','None','EdgeColor','g','LineWidth',2)
% mapshow(S(strcmpi({S.AREA_CODE},'CPC'),:),'FaceColor','None','EdgeColor','k','LineWidth',1.5)

