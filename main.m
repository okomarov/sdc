%% Load House info
path2proj = fullfile(getenv('USERPROFILE'), 'Documents','github','SDC');
hprices = importHouseprices(path2proj);
hmeta   = importHousemeta(path2proj);
%%
% BoundingBox (1u = 1m)
s.bbox = double([min(hprices.Oseast1M), min(hprices.Osnrth1M); max(hprices.Oseast1M), max(hprices.Osnrth1M)])/100;

% Read backdrop raster image (1px = 100m)
rastermap   = fullfile(path2proj, 'data','minisc_gb','data','RGB_TIF_compressed','MiniScale_(relief1)_R16.tif');
info        = imfinfo(rastermap);
backdrop    = imread(rastermap, 'PixelRegion',{info.Height-[s.bbox(2,2) s.bbox(1,2)],s.bbox(1:2,1)});
s.bdratio = size(backdrop,1)/size(backdrop,2);

% Build GUI
h.f = figure('GraphicsSmoothing', 'off','Position',[400 ,100, 1100, 900],...
             'Resize','off','Name','Price explorer','MenuBar','None',...
             'Toolbar','figure');
s.axwidth  = 850;
s.yoffset  = 25;
s.xoffset  = 25; 
h.a        = axes('NextPlot','add','Xlim',s.bbox(:,1),'Ylim',s.bbox(:,2),...
                  'Units','pix','Position',[s.xoffset, s.yoffset, s.axwidth, s.axwidth*s.bdratio],...
                   'Color','none','Layer','Top','Box','on','Xtick',[],'Ytick',[],...
                   'Xcolor',[.4,.4,.4],'Ycolor',[.6,.6,.6]);
h.statspanel = uipanel('Title','Info','Units','pix','BorderType','etchedin',...
                       'Position',[2*s.xoffset+s.axwidth, s.yoffset, 175,400]);
h.layerpanel = uipanel('Units','pix','BorderType','beveledin','Backg','white',...
                       'Position',[2*s.xoffset+s.axwidth, s.yoffset+400+15, 175, 391]);
               
% Plot               
h.backdrop = image(s.bbox(:,1),s.bbox([2,1],2),imgBrighten(backdrop,.4),'Parent',h.a);

% Scatter 10% of the points
npoints  = numel(hprices.Oseast1M);
isample  = randsample(npoints, ceil(0.1*npoints));
h.points = line(hprices.Oseast1M(isample)/100, hprices.Osnrth1M(isample)/100,...
               'LineStyle','none','Marker','o', 'MarkerFaceColor',lines(1),...
               'MarkerEdgeColor','none','MarkerSize',1.5);
% s       = scatter(hprices.Oseast1M(isample)/100, hprices.Osnrth1M(isample)/100,4, log(double(hprices.Price(isample)/100)),'o','filled');

% Draw circle of 100km distance
pcenter  = find(hmeta.Distance_London == 0,1,'first');
c        = double([hmeta.Oseast1M(pcenter),hmeta.Osnrth1M(pcenter)])/100;
radius   = 1000;
theta    = (0:0.01:2*pi)';
circ     = [c(1) + radius.*cos(theta), c(2) + radius.*sin(theta)];

% Draw hull
% p        = convhull(double(hprices.Oseast1M),double(hprices.Osnrth1M));
% circ     = double([hprices.Oseast1M(p),hprices.Osnrth1M(p)])/100;

h.circle = plot(circ(:,1),circ(:,2),'-r');
Bnd = importBoundaries('district_borough_unitary_ward_region.shp');

% Build bnd subs
[ip2m, price2meta] = mapPostcode(hprices.Postcode, hmeta.Pcd, hmeta.Pcd2);
[iward, meta2bnd] = ismember(hmeta.Ward, char(Bnd.CODE),'rows');
subs = zeros(size(hprices,1),1,'uint16');
subs(ip2m) = meta2bnd(price2meta(ip2m));
subs = subs + 1;

% Average
avg  = accumarray(subs, double(hprices.Price),[],@mean);
avg  = avg(2:end);

% Plot tiles
h = plotBoundaries(Bnd,'cdata',avg);
