function [h,idrop, ipart] = plotBoundaries(Bnd, varargin)

% Parse optional inputs with defaults
persistent ip
if isempty(ip)
    ip = inputParser;
    ip.FunctionName = mfilename;
    ip.addOptional('center' ,[5296.12,1806.25]                ,@(x) isnumeric(x) && numel(x)== 2);
    ip.addOptional('radius' ,1000                             ,@(x) isnumeric(x) && isscalar(x));
    ip.addOptional('theta'  ,(0:0.01:2*pi)'                   ,@(x) isnumeric(x) && isvector(x));
    ip.addOptional('circ'   ,[]                               ,@isnumeric);
    ip.addOptional('cdata'  ,[]                               ,@isnumeric);
    ip.addOptional('handles',[]                               ,@isstruct);
end
parse(ip,varargin{:})
center = ip.Results.center;
radius = ip.Results.radius;
theta  = ip.Results.theta;
cdata  = ip.Results.cdata;
h      = ip.Results.handles;
% Exclude if outside and grey out if partially filled, i.e. intersecting
if isempty(ip.Results.circ)
    circ = [center(1) + radius.*cos(theta), center(2) + radius.*sin(theta)];
else
    circ = ip.Results.circ;
end

% Shape structure supplied
if ~istable(Bnd)
    error('plotBoundaries:invalidBnd','Invalid BND. Import boundaries first.')
end

% Partial if polygon intersects circle
nBnd  = size(Bnd,1);
ipart = false(nBnd,1);
pop   = zeros(nBnd,2);
bndx  = Bnd.X;
bndy  = Bnd.Y;
for ii = 1:nBnd
    bndx{ii}  = bndx{ii}/100;
    bndy{ii}  = bndy{ii}/100;
    ipart(ii) = any(inpolygon(circ(:,1),circ(:,2), bndx{ii}, bndy{ii}));
    pop(ii,:) = [bndx{ii}(1), bndy{ii}(1)];
end

% Separate from partial and empty (if a point of the boundary not in circle)
iempty = ~inpolygon(pop(:,1),pop(:,2), circ(:,1),circ(:,2));
idrop  = iempty | ipart;

% Plot
[h.Boundaries,h.Tiles] = plotHelper(bndx,bndy,cdata,~idrop);
h.Excluded             = plotHelper(bndx,bndy,[]   , ipart);
end

function [hbound,htiles] = plotHelper(bndx, bndy, cdata, idx)

% number of patches
id       = uint16(find(idx));
npatches = numel(id);
bndx     = bndx(idx);
bndy     = bndy(idx);

% Plot contour line
x      = cell2mat(bndx');
y      = cell2mat(bndy');
hbound = line(x,y,'LineWidth',1,'Visible','off');

% Plot tile with CData
if ~isempty(cdata)
    cdata           = cdata(idx);
    [cdata, isdata] = indexcdata(cdata);
    htiles = hggroup('Tag','colored','Visible','off');
    for ii = 1:npatches
        if isdata(ii)
            x = bndx{ii}(1:end-1);
            y = bndy{ii}(1:end-1);
            patch(x,y,ones(1,numel(x)),'Parent',htiles,...
                  'FaceColor',cdata(ii,:),'FaceAlpha',0.5,'EdgeColor','none','UserData',id(ii));
        end
    end
end
end


