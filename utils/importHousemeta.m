function hmeta = importHousemeta(path2proj)

% Try to load dataset
datadir = fullfile(path2proj, 'data');
try 
    load(fullfile(datadir,'hmeta'));
    
% Import ex-novo   
catch
    
    % Unzip house prices
    filename = fullfile(datadir,'london2009-2014-house-prices','NPSL_London100km.csv');
    if ~exist(filename,'file')
        zipfile = fullfile(datadir,'raw','london2009-2014-house-prices.zip');
        unzip(zipfile,datadir);
    end
    
    % Import house prices
    fmt      = '%s%s%u32%u32%u8%u32%u32%9c%9c%9c%9c%9c%9c%9c%9c%2c%9c%f%f%f';
    hmeta    = readtable(filename, 'Format',fmt, 'Delimiter',',');
    
    % Manipulate
    hmeta.Pcd  = char(hmeta.Pcd);
    hmeta.Pcd2 = char(hmeta.Pcd2);
    
    % Give some descriptions
    hmeta.Properties.VariableDescriptions = ...
        {'Postcode 7-char', 'Postcode 8char (one blank in middle)',...
        'Date of introduction', 'Date of termination','Is large user',...
        'Easting to 1m', 'Northing to 1m', 'County', ...
        'Local authority district (LAD)/unitary authority (UA)/ metropolitan district (MD)/ London borough (LB)/ council area (CA)/district council area (DCA)',...
        'Administrative/electoral area',...
        'Strategic health authority (SHA)/ health board (HB)/ health authority (HA)/ health & social care board (HSCB)',...
        'Country','Lower layer super output area (LSOA)','Middle layer super output area (MSOA)',...
        '2011 Census output area (GB)/ small area (NI)','2011 Census rural-urban classification',...
        '2011 Census workplace zone','','',''};
    
    % Drop variables
    hmeta(:,{'Dointr','Doterm','Usertype','Cty','Laua','Hlthau','Ctry','Lsoa11','Msoa11','Oa11','Ru11Ind','Wz11','Latitude','Longitude'}) = [];
    
    % Save
    save(fullfile(path2proj, 'data', 'hmeta'),'hmeta','-v7.3')
end
end