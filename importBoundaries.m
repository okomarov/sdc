function boundaries = importBoundaries(filename, varargin)

persistent ip
if isempty(ip)
    ip = inputParser;
    ip.FunctionName = mfilename;
    ip.addOptional('bbox'  ,[429936,92169; 628999,280605],@(x) isnumeric(x) && isequal(size(x), [2,2]));
end
parse(ip,varargin{:})
bbox = ip.Results.bbox;

% Load
try
    [~,matfile] = fileparts(filename);
    load(fullfile('data',matfile));
    
catch
    
    % Import simplified boundaries at 5% from mapshaper with Visvalingam/effective area algo
    try
        simplefile     = fullfile('data','bdline_simplified', filename);
        boundaries   = shaperead(simplefile);
        boundaries   = struct2table(boundaries);
        [~,simplefile] = fileparts(simplefile);
        save(fullfile('data',simplefile), 'boundaries');
        
    % Import Ordnance Survey bdlines with bbox
    catch
        
        % info = shapeinfo(filename);
        filename   = fullfile('data','bdline_essh_gb','Data', filename);
        boundaries = shaperead(filename,'boundingbox',bbox);
        % Save
        [~,filename] = fileparts(filename);
        shapewrite(boundaries,fullfile('data','bdline_simplified','tosimplify',filename))
        fprintf(['Simplify <a href="matlab:winopen(''./data/bdline_simplified/tosimplify'')">%s</a>',...
                 ' with <a href="matlab:web(''http://www.mapshaper.org/'',''-browser'')">mapshaper</a>\n'],filename)
    end
end
end
