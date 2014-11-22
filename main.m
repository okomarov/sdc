function main

%% GUI frame
h = GUIframe();
%% Load House info
path2proj = fullfile(getenv('USERPROFILE'), 'Documents','github','SDC');
hprices = importHouseprices(path2proj);
hmeta   = importHousemeta(path2proj);
%%
% BoundingBox (1u = 1m)
s.bbox = double([min(hprices.Oseast1M), min(hprices.Osnrth1M); max(hprices.Oseast1M), max(hprices.Osnrth1M)])/100;
set(h.Axis,'Xlim',s.bbox(:,1),'Ylim',s.bbox(:,2));

% Read backdrop raster image (1px = 100m)
rastermap   = fullfile(path2proj, 'data','minisc_gb','data','RGB_TIF_compressed','MiniScale_(relief1)_R16.tif');
info        = imfinfo(rastermap);
backdrop    = imread(rastermap, 'PixelRegion',{info.Height-[s.bbox(2,2) s.bbox(1,2)],s.bbox(1:2,1)});

% Plot               
h.Map = image(s.bbox(:,1),s.bbox([2,1],2),imgBrighten(backdrop,.4),'Parent',h.Axis);

% Scatter 10% of the points
npoints  = numel(hprices.Oseast1M);
isample  = randsample(npoints, ceil(0.1*npoints));
h.Scatter = line(hprices.Oseast1M(isample)/100, hprices.Osnrth1M(isample)/100,...
               'LineStyle','none','Marker','o', 'MarkerFaceColor',lines(1),...
               'MarkerEdgeColor','none','MarkerSize',1.5,'Visible','off');
% s       = scatter(hprices.Oseast1M(isample)/100, hprices.Osnrth1M(isample)/100,4, log(double(hprices.Price(isample)/100)),'o','filled');

% Draw hull
% p        = convhull(double(hprices.Oseast1M),double(hprices.Osnrth1M));
% circ     = double([hprices.Oseast1M(p),hprices.Osnrth1M(p)])/100;
% Draw circle of 100km distance
pcenter  = find(hmeta.Distance_London == 0,1,'first');
c        = double([hmeta.Oseast1M(pcenter),hmeta.Osnrth1M(pcenter)])/100;
radius   = 1000;
theta    = (0:0.01:2*pi)';
circ     = [c(1) + radius.*cos(theta), c(2) + radius.*sin(theta)];
h.Circle = plot(circ(:,1),circ(:,2),'-r','Visible','off');

% Import boundaries
Bnd = importBoundaries('district_borough_unitary_ward_region.shp');

% Build bnd subs
[ip2m, price2meta] = mapPostcode(hprices.Postcode, hmeta.Pcd, hmeta.Pcd2);
[iward, meta2bnd] = ismember(hmeta.Ward, char(Bnd.CODE),'rows');
subs = zeros(size(hprices,1),1,'uint16');
subs(ip2m) = meta2bnd(price2meta(ip2m));
subs = subs + 1;

% Average
avg   = accumarray(subs, double(hprices.Price),[],@mean);
s.avg = avg(2:end);

% Plot tiles
hh = plotBoundaries(Bnd,'cdata',s.avg);


% Set callbacks
set(h.Layerspanel.BodyCheckBoundaries,          'Callback',@toggleLayer)
set(h.Layerspanel.BodyCheckBoundariesExcluded,  'Callback',@toggleLayer)
set(h.Layerspanel.BodyCheckDeals,               'Callback',@toggleLayer)
set(h.Layerspanel.BodyCheckMap,                 'Callback',@toggleLayer)
set(h.Layerspanel.BodyCheckTiles,               'Callback',@toggleLayer)

    function toggleLayer(obj,evt)
        onoff = {'off','on'};
        vals  = [0,1];
        pos   = mod(obj.Value+2,2)+1;
        obj.Value = vals(pos);
        switch obj.Tag
            case 'map'
                set(h.Map,'Visible',onoff{pos});
            case 'scatter'
                set(h.Scatter,'Visible',onoff{pos});
            case 'boundaries'
                set(h.Boundaries,'Visible',onoff{pos});
            case 'excluded'
                set(h.Excluded	,'Visible',onoff{pos});
                set(h.Circle    ,'Visible',onoff{pos});
            case 'tiles'
                set(h.Tiles,'Visible',onoff{pos});
        end
    end
end