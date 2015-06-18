function struct = panam_map2Struct(map)
%PANAM_MAP2STRUCT Summary of this function goes here
%   Detailed explanation goes here

k = map.keys;

for ii = 1:length(k)
    struct.(k{ii})= map(k{ii});
end
    
end

