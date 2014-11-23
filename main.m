function [h,s] = main

%% GUI frame
h = GUIframe();
h.Spinner.start;
drawnow
%% Load stuff
s.path2proj = fullfile(getenv('USERPROFILE'), 'Documents','github','SDC');
s.hprices = importHouseprices(s.path2proj);
s.hmeta   = importHousemeta(s.path2proj);
s.bnd     = importBoundaries('district_borough_unitary_ward_region.shp');
% BoundingBox (1u = 1m)
s.bbox = double([min(s.hprices.Oseast1M), min(s.hprices.Osnrth1M); max(s.hprices.Oseast1M), max(s.hprices.Osnrth1M)])/100;
% Read backdrop raster image (1px = 100m)
s = importBackdrop(s);
%% Analysis
% Build boundary subs
[ip2m, price2meta] = mapPostcode(s.hprices.Postcode, s.hmeta.Pcd, s.hmeta.Pcd2);
[iward, meta2bnd]  = ismember(s.hmeta.Ward, char(s.bnd.CODE),'rows');
tilenum            = zeros(size(s.hprices,1),1,'uint16');
tilenum(ip2m)      = meta2bnd(price2meta(ip2m));
s.tilenum          = tilenum + 1;

% Count
tmp     = accumarray(s.tilenum, 1);
s.count = tmp(2:end);

% Average
tmp   = accumarray(s.tilenum, double(s.hprices.Price),[],@mean);
s.avg = tmp(2:end);
s.pname = 'avg';
% Average Rank
idx                    = s.avg ~= 0; 
s.avgrank              = zeros(size(idx));
[~,~,s.avgrank(idx,1)] = histcounts(s.avg(idx), prctile(s.avg(idx),0:100));
s.avgrank(idx)         = 101-s.avgrank(idx);

% Area weighted
s.area = s.avg./s.bnd.HECTARES;
% Area rank
idx                    = s.area ~= 0; 
s.arearank             = zeros(size(idx));
[~,~,s.arearank(idx,1)] = histcounts(s.area(idx), prctile(s.area(idx),0:100));
s.arearank(idx)         = 101-s.arearank(idx);

% Trend
t       = datenum(s.hprices.Trdate) - min(datenum(s.hprices.Trdate))+1;
Eab     = accumarray(s.tilenum, t.*double(s.hprices.Price),[],@mean);
Ea      = accumarray(s.tilenum, t,[],@mean); 
Eb      = accumarray(s.tilenum, double(s.hprices.Price),[],@mean);
s.trend = (Eab-Ea.*Eb)./accumarray(s.tilenum, t.^2,[],@mean);
s.trend(isnan(s.trend)) = 0;
% Trend rank
idx                      = s.trend ~= 0; 
s.trendrank              = zeros(size(idx));
[~,~,s.trendrank(idx,1)] = histcounts(s.trend(idx), prctile(s.trend(idx),0:100));
s.trendrank(idx)         = 101-s.trendrank(idx);

%% Plot

% Backdrop image
set(h.Axis,'Xlim',s.bbox(:,1),'Ylim',s.bbox(:,2));
h.Map = image(s.bbox(:,1),s.bbox([2,1],2),imgBrighten(s.backdrop,.4),'Parent',h.Axis);

% Scatter of the deals (5%)
npoints  = numel(s.hprices.Oseast1M);
isample  = randsample(npoints, ceil(0.05*npoints));
h.Scatter = line(s.hprices.Oseast1M(isample)/100, s.hprices.Osnrth1M(isample)/100,...
               'LineStyle','none','Marker','o', 'MarkerFaceColor',lines(1),...
               'MarkerEdgeColor','none','MarkerSize',1.7,'Visible','off');
% s       = scatter(s.hprices.Oseast1M(isample)/100, s.hprices.Osnrth1M(isample)/100,4, log(double(s.hprices.Price(isample)/100)),'o','filled');

% Draw hull
% p        = convhull(double(s.hprices.Oseast1M),double(s.hprices.Osnrth1M));
% circ     = double([s.hprices.Oseast1M(p),s.hprices.Osnrth1M(p)])/100;
% Draw circle of 100km distance
pcenter  = find(s.hmeta.Distance_London == 0,1,'first');
s.center = double([s.hmeta.Oseast1M(pcenter),s.hmeta.Osnrth1M(pcenter)])/100;
radius   = 1000;
theta    = (0:0.01:2*pi)';
circ     = [s.center(1) + radius.*cos(theta), s.center(2) + radius.*sin(theta)];
h.Circle = plot(circ(:,1),circ(:,2),'-r','Visible','off');

% Boundaries and tiles
[h,s.idrop,s.ipart] = plotBoundaries(s.bnd,'cdata',s.avg,'handles',h);
s.Tileid = cell2mat(get(h.Tiles.Children,'UserData'));
set(h.Boundaries,'Color',[0.5,0.5,0.5]);
set(h.Excluded  ,'Color',[0.15,0.15,0.15]);
h.Previoustile = [];

% Postcode scatter
h.PostcodeMarker = scatter(0,0,50,'red','+');

% Number formatting
dn    = java.text.DecimalFormat;
s.fmt = @(x) char(dn.format(round(x)));
%% Set callbacks

% Layer checkboxes
child = h.Layerspanel.Body.Children;
for ii = 1:numel(child)
    set(child(ii),'Callback',@toggleLayer);
end

% Tile radiobuttons
set(h.Tilespanel.Body,'SelectionChangedFcn',@selectTilesType)

% Single tiles
child = h.Tiles.Children;
for ii = 1:numel(child)
    set(child(ii),'ButtonDownFcn',@clickOnTile);
end

% Postcode lookup
set(h.PostcodeEdit,'KeyPressFcn',@postcodeLookup)
drawnow

% Refresh spinner
h.Spinner.stop;
set(h.Spinnercomp,'Visible','off');
%% Callbacks
    
    function toggleLayer(obj,~)
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
                children = h.Tilespanel.Body.Children;
                for jj = 1:numel(children)
                    set(children(jj),'Enable',onoff{pos});
                end
        end
    end

    function selectTilesType(obj,~)
        tiles  = h.Tiles.Children;
        ntiles = numel(tiles);
        cdata  = zeros(size(s.idrop,1),3);
        switch obj.SelectedObject.Tag
            case 'average'
                s.pname = 'avg';
                cdata(~s.idrop,:) = indexcdata(s.avg(~s.idrop));
            case 'weighted'
                s.pname = 'area';
                cdata(~s.idrop,:) = indexcdata(s.area(~s.idrop));
            case 'trend'
                s.pname = 'trend';
                cdata(~s.idrop,:) = indexcdata(s.trend(~s.idrop));
        end
        for jj = 1:ntiles
            set(tiles(jj,:), 'FaceColor', cdata(s.Tileid(jj),:))
        end
        clickOnTile(h.Previoustile)
        drawnow
    end
    
    function clickOnTile(obj,~)
        if ~isempty(obj)
            id = obj.UserData;
            hh = h.Tilesinfopanel.BodyName;   set(hh, 'string',sprintf('%s%s', hh.Tag, s.bnd.NAME{id}))
            hh = h.Tilesinfopanel.BodyCode;   set(hh, 'string',sprintf('%s%s', hh.Tag, s.bnd.CODE{id}))
            hh = h.Tilesinfopanel.BodyArea;   set(hh, 'string',sprintf('%s%s', hh.Tag, s.fmt(s.bnd.HECTARES(id))))
            hh = h.Tilesinfopanel.BodyNdeals; set(hh, 'string',sprintf('%s%s', hh.Tag, s.fmt(s.count(id))))
            hh = h.Tilesinfopanel.BodyPrice;  set(hh, 'string',sprintf('%s%s', hh.Tag, s.fmt(s.(s.pname)(id))))
            hh = h.Tilesinfopanel.BodyRank;   set(hh, 'string',sprintf('%s%d', hh.Tag, s.([s.pname 'rank'])(id)))
            set(h.Previoustile,'EdgeColor','none')
            set(obj,'EdgeColor','red')
            h.Previoustile = obj;
            drawnow
        end
    end
    
    function postcodeLookup(obj,evt)
        if strcmpi(evt.Key,'return')
            drawnow
            pattern = upper(regexprep(strtrim(obj.String),' {2,}',' '));
            len     = numel(pattern);
            xy      = [0,0];
            
            % Invalid
            if len > 8 || len < 6 
                textcolor = 'red';
                stats     = 'invalid';
            else
                imatch = all(bsxfun(@eq, s.hprices.Postcode(:,1:len), pattern),2);
                n      = nnz(imatch);
                if n > 0
                    textcolor = 'green';
                    xy        = [s.hprices.Oseast1M(imatch)/100,s.hprices.Osnrth1M(imatch)/100];
                    stats     = s.hprices(imatch,:);
                    tile      = h.Tiles.Children(unique(s.tilenum(imatch))-1 == s.Tileid);
                    if ~isempty(tile)
                        clickOnTile(tile);
                    end
                    
                % Not found
                else
                    textcolor = 'red';
                    stats     = 'not found';
                end
            end
            set(h.PostcodeMarker,'XData',xy(1,1),'YData',xy(1,2))
            set(obj,'ForegroundColor',textcolor);
            updatePcodeinfo(stats);
        elseif any(obj.ForegroundColor ~= 0.2)
            obj.ForegroundColor = repmat(0.2, 1, 3);
        end
        drawnow
    end
    function updatePcodeinfo(stats)
        if any(strcmpi(stats,{'invalid','not found'}))
            hh = h.Pcodeinfopanel.BodyPcode; set(hh, 'string',sprintf('%s%s', hh.Tag, stats))
            hh = h.Pcodeinfopanel.BodyBetween; set(hh, 'string',sprintf('%s', ''))
            hh = h.Pcodeinfopanel.BodyNdeals;  set(hh, 'string',sprintf('%s', ''))
            hh = h.Pcodeinfopanel.BodyPerfree; set(hh, 'string',sprintf('%s', ''))
            hh = h.Pcodeinfopanel.BodyPernew;  set(hh, 'string',sprintf('%s', ''))
            hh = h.Pcodeinfopanel.BodyPrice;   set(hh, 'string',sprintf('%s', ''))
        else
            stats.Trdate.Format = 'MMM yy';
            dtrange = [char(min(stats.Trdate)), ' - ', char(max(stats.Trdate))];
            hh = h.Pcodeinfopanel.BodyPcode;   set(hh, 'string',sprintf('%s%s', hh.Tag, stats.Postcode(1,:)))
            hh = h.Pcodeinfopanel.BodyBetween; set(hh, 'string',sprintf('%s%s', hh.Tag, dtrange))
            hh = h.Pcodeinfopanel.BodyNdeals;  set(hh, 'string',sprintf('%s%d', hh.Tag, size(stats,1)))
            hh = h.Pcodeinfopanel.BodyPerfree; set(hh, 'string',sprintf('%s%s', hh.Tag, s.fmt(mean(stats.Freeorlease)*100)))
            hh = h.Pcodeinfopanel.BodyPernew;  set(hh, 'string',sprintf('%s%s', hh.Tag, s.fmt(mean(stats.Newbuild)*100)))
            hh = h.Pcodeinfopanel.BodyPrice;   set(hh, 'string',sprintf('%s%s', hh.Tag, s.fmt(mean(double(stats.Price)))))
        end
    end
end