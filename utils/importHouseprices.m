function hprices = importHouseprices(path2proj)

% Try to load dataset
datadir = fullfile(path2proj, 'data');
try 
    load(fullfile(datadir,'hprices'));
    
% Import ex-novo   
catch
    % Unzip house prices
    filename = fullfile(datadir,'london2009-2014-house-prices','Houseprice_2009_100km_London.csv');
    if ~exist(filename,'file')
        zipfile = fullfile(datadir,'raw','london2009-2014-house-prices.zip');
        unzip(zipfile,datadir);
    end
    
    % Import house prices
    fmt      = '%s%{yyyy-MM-dd HH:mm}D%s%c%c%c%*d%*s%s%s%9c%f%f';
    hprices  = readtable(filename, 'Format',fmt, 'Delimiter',',');
    
    % Manipulate
    g                = @(x) char(strrep(x,'_',''))';
    f                = @(x) textscan([x; repmat(' ',1,size(x,2))], sprintf('%%%du32',size(x,1)+1));
    
    tmp              = g(hprices.Price);
    tmp              = f(tmp);
    hprices.Price    = tmp{1};
    
    tmp              = g(hprices.Oseast1M);
    tmp              = f(tmp);
    hprices.Oseast1M = tmp{1};
    
    tmp              = g(hprices.Osnrth1M);
    tmp              = f(tmp);
    hprices.Osnrth1M = tmp{1};
    
    hprices.Trdate.Format = 'yyyy-MM-dd';
    
    hprices.Freeorlease = hprices.Freeorlease == 'F';
    hprices.Newbuild    = hprices.Newbuild == 'N';
    hprices.Postcode    = char(hprices.Postcode);
    
    % Drop variables
    hprices(:,{'Oa11','Latitude','Longitude'}) = [];
    
    % Save
    save(fullfile(path2proj, 'data', 'hprices'),'hprices','-v7.3')
end
end