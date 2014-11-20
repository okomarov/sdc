function varargout = plotBoundaries(filename, varargin)

% Parse optional inputs with defaults
persistent ip
if isempty(ip)
    ip = inputParser;
    ip.FunctionName = mfilename;
    ip.addOptional('bbox'  ,[4299.36,921.69; 6289.99,2806.05],@(x) isnumeric(x) && isequal(size(x), [2,2]));
    ip.addOptional('center',[5296.12,1806.25]                ,@(x) isnumeric(x) && numel(x)== 2);
    ip.addOptional('radius',1000                             ,@(x) isnumeric(x) && isscalar(x));
    ip.addOptional('theta' ,(0:0.01:2*pi)'                   ,@(x) isnumeric(x) && isvector(x));
    ip.addOptional('circ'  ,[]                               ,@isnumeric);
    ip.addOptional('cdata' ,[]                               ,@isnumeric);
end
parse(ip,varargin{:})
bbox   = ip.Results.bbox;
center = ip.Results.center;
radius = ip.Results.radius;
theta  = ip.Results.theta;
cdata  = ip.Results.cdata;
% Exclude if outside and grey out if partially filled, i.e. intersecting
if isempty(ip.Results.circ)
    circ = [center(1) + radius.*cos(theta), center(2) + radius.*sin(theta)];
else
    circ = ip.Results.circ;
end

% Shape structure supplied
if isstruct(filename) && isfield(filename,'Geometry')
    Bnd = filename;
    
% Import file    
else
    path2proj = fileparts(filename);
    if isempty(path2proj)
        % Assume we are in the projects folder
        filename = fullfile('data','bdline_essh_gb','Data', filename);
    end
    % info = shapeinfo(filename);
    Bnd = shaperead(filename,'boundingbox',bbox*100);
end

% Partial if polygon intersects circle
nBnd  = numel(Bnd);
ipart = false(nBnd,1);
pop   = zeros(nBnd,2);
for ii = 1:nBnd
    Bnd(ii).X = Bnd(ii).X/100;
    Bnd(ii).Y = Bnd(ii).Y/100;
    ipart(ii) = any(inpolygon(circ(:,1),circ(:,2), Bnd(ii).X, Bnd(ii).Y));
    pop(ii,:) = [Bnd(ii).X(1), Bnd(ii).Y(1)];
end
Bndpart = Bnd(ipart);

% Empty if any point of the boundary not in circle
iempty = ~inpolygon(pop(:,1),pop(:,2), circ(:,1),circ(:,2));

% Drop
idrop      = iempty | ipart;
Bnd(idrop) = [];

% Plot
h = NaN(2,1);
if ~isempty(Bnd)
    h(1) = mapshow(Bnd,'FaceColor','None','EdgeColor',[0.9880, 0.8066, 0.1794],'LineWidth',1);
end
if ~isempty(Bndpart)
    h(2) = mapshow(Bndpart,'FaceColor','None','EdgeColor','k','LineWidth',1);
end

if ~isempty(cdata)
    cdata  = cdata(~idrop);
    isdata = cdata ~= 0;
    minval = min(cdata(isdata));
    cmap   = parula;
    [a,~,bin] = histcounts(cdata, linspace(minval, max(cdata),size(cmap,1)+1));
    ph = get(h(1),'Children');
    npatches = numel(ph);
    cdata = zeros(npatches,3);
    cdata(isdata,:) = cmap(bin(isdata),:);
    for ii = 1:npatches
        if isdata(ii)
            set(ph(ii),'FaceAlpha',0.5,'FaceColor',cdata(ii,:));
        end
    end
   
end

if nargout == 1
    varargout{1} = h; 
end
if nargout == 2
    varargout{1} = struct('Bnd',Bnd,'Bndpart',Bndpart,'Center',center,'Radius',radius,'Circle',circ); 
end
end
