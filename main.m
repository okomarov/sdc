%% Load House info
path2proj = fullfile(getenv('USERPROFILE'), 'Documents','github','SDC');
hprices = importHouseprices(path2proj);
hmeta   = importHousemeta(path2proj);
%%
% BoundingBox (1u = 1m)
bbox = double([min(hprices.Oseast1M), min(hprices.Osnrth1M); max(hprices.Oseast1M), max(hprices.Osnrth1M)])/100;

% Read backdrop raster image (1px = 100m)
rastermap = fullfile(path2proj, 'data','minisc_gb','data','RGB_TIF_compressed','MiniScale_(relief1)_R16.tif');
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
% s       = scatter(hprices.Oseast1M(isample)/100, hprices.Osnrth1M(isample)/100,4, log(double(hprices.Price(isample)/100)),'o','filled');
colormap('jet')

% Detect partial and empty constituencies
% Draw circle of 100km distance
% pcenter  = find(hmeta.Distance_London == 0,1,'first');
% c        = double([hmeta.Oseast1M(pcenter),hmeta.Osnrth1M(pcenter)])/100;
% radius   = 1000;
% theta    = (0:0.01:2*pi)';
% circ     = [c(1) + radius.*cos(theta), c(2) + radius.*sin(theta)];

% Draw hull
p        = convhull(double(hprices.Oseast1M),double(hprices.Osnrth1M));
circ     = double([hprices.Oseast1M(p),hprices.Osnrth1M(p)])/100;

plot(circ(:,1),circ(:,2),'-r')
filename = fullfile(path2proj, 'data','bdline_essh_gb','Data','district_borough_unitary_ward_region.shp');
Bnd = shaperead(filename,'boundingbox',bbox*100);

[ip2m, price2meta] = mapPostcode(hprices.Postcode, hmeta.Pcd, hmeta.Pcd2);
[~, meta2bnd] = ismember(hmeta.Ward, char({Bnd.CODE}),'rows');

subs = zeros(size(hprices,1),1,'uint16');
subs(ip2m) = meta2bnd(price2meta(ip2m));
subs = subs + 1;
avg  = accumarray(subs, hprices.Price,[],@mean);
avg  = avg(2:end);

h = plotBoundaries(Bnd,'cdata',log(avg+1));
