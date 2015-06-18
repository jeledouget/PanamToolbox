function map = panam_struct2Map(struct )

map = containers.Map;
f = fieldnames(struct);

for ii = 1:length(f)
    map(f{ii}) = struct.(f{ii});
end

end

