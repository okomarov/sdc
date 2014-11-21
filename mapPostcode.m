function [idx,pos] = mapPostcode(pricePcd, metaPcd1, metaPcd2)
ipcd = sum(~isspace(pricePcd),2) < 7;
sz   = size(ipcd);
[idx1, pos1] = ismember(pricePcd( ipcd,:), metaPcd1,'rows');
[idx2, pos2] = ismember(pricePcd(~ipcd,:), metaPcd2,'rows');
pos          = zeros(sz,'uint32');
pos( ipcd)   = pos1;
pos(~ipcd)   = pos2;
idx          = false(sz);
idx( ipcd)   = idx1;
idx(~ipcd)   = idx2;
end