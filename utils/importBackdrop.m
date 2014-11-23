function s = importBackdrop(s)
try
    s.backdrop = imread(fullfile('data','backdrop.tif'));
catch
    % Read backdrop raster image (1px = 100m)
    rastermap  = fullfile(s.path2proj, 'data','minisc_gb','data','RGB_TIF_compressed','MiniScale_(relief1)_R16.tif');
    info       = imfinfo(rastermap);
    s.backdrop = imread(rastermap, 'PixelRegion',{info.Height-[s.bbox(2,2) s.bbox(1,2)],s.bbox(1:2,1)});
    imwrite(s.backdrop, fullfile('data','backdrop.tif'));
end
end