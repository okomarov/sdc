function [idx,pos] = mapPostcode(pricePcd, metaPcd1, metaPcd2) 
[idx1, pos1] = ismember(pricePcd, metaPcd1,'rows');
[idx2, pos2] = ismember(pricePcd, metaPcd2,'rows');
idx          = idx1 | idx2;
pos          = uint32(pos1);
pos(idx1)    = pos1(idx1);
pos(idx2)    = pos2(idx2);
end