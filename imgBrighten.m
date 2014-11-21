function img = imgBrighten(img, val)
img = img*(1-val) + 255*val;
end
