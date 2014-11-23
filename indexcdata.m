function [cdata, isdata] = indexcdata(cdata)
isdata          = cdata ~= 0;
cmap            = jet(15);
edges           = prctile(cdata(isdata), [0,5,10:10:80,85:5:95,99,99.5,100]);
%     minval = min(cdata(isdata));
%     edges = linspace(minval, max(cdata),size(cmap,1)+1);
[counts,a,bin]  = histcounts(cdata(isdata), edges);
cdata           = zeros(size(cdata,1),3);
cdata(isdata,:) = cmap(bin,:);
end