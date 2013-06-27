function position = findByIndex(array,index)
        for i = 1:length(array)
            if array{i}.index == index
                position = i;
                break;
            end
        end
end 
