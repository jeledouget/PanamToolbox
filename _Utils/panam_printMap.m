function panam_printMap( map )
%CONTAINERPRINT Summary of this function goes here
%   Detailed explanation goes here

for key = map.keys
    key = key{1};  %#ok<FXSET>
    if isnumeric(key)
        fprintf('\n%s : \n', num2str(key));
    else
        fprintf('\n%s : \n', key);
    end
    
    value = map(key);
    if isnumeric(value)
        if length(value) <= 50
            fprintf('%4.2g,',value(1:end-1));
            fprintf('%4.2g\n ',value(end));
        else
            fprintf('%4.2g,',value(1:49));
            fprintf('%4.2g...\n ',value(50));
        end
    else
        % make it a cell
        if ~iscell(value)
            value = {value};
        end
        if length(value) <=50
            try
                disp(value{1:end});
            catch
                disp(value(1:end));
            end
            fprintf('\n');
        else
            try
                disp(value{1:50});
            catch
                disp(value(1:50));
            end
            fprintf('\n');
        end
    end
    
end

