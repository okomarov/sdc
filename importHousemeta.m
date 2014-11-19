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
    
    % Save
    save(fullfile(path2proj, 'data', 'hmeta'),'hmeta','-v7.3')
end
end