function [ifStruct] = readIFFile(fileName)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
fileId = fopen(fileName);
clockCount = 1;
constCount = 1;
variableCount = 1;
metaCount = 1;
locationCount = 1;
fixedCount = 1;
costCount = 1;

layoutCount = 1;
instrCount = 1;
processCount = 1;


expressionCount = 1;
edgeCount = 1;

cellStruct = struct('type',cell(1),...
                    'name',cell(1),...
                    'value','var','meta','clock','location','fixed');

processStruct = struct('initial',cell(1),...
                       'name',cell(1),...
                       'locations',cell(1),...
                       'edges',cell(1));
edgeStruct = struct('process',cell(1),...
                    'source',cell(1),...
                    'target',cell(1),...
                    'guard',cell(1),...
                    'sync',cell(1),...
                    'update',cell(1));
                       
while ~feof(fileId)
    section = fgetl(fileId);
    switch section
        case 'layout'
            line = fgetl(fileId);
            while (sum(~isspace(line))> 0 || ~isempty(line)) && ~feof(fileId)
                if regexp(line,'[0-9]+:clock:-?[0-9]+:[a-zA-Z]+')
                    str = strsplit(line,':');
                    index = str2num(str{1});
                    number = str2num(str{3});
                    name = str{4};
                
                    clock.type = 'CLOCK';
                    clock.index = index;
                    clock.number = number;
                    clock.name = name;
                    ifStruct.layout.clocks{clockCount} = clock;
                    clockCount = clockCount + 1;
                elseif regexp(line,'[0-9]+:const:-?[0-9]+')
                    str = strsplit(line,':');
                    index = str2num(str{1});
                    value = str2num(str{3});
                    
                    const.type = 'CONST';
                    const.index = index;
                    const.number = value;
                    ifStruct.layout.constants{constCount} = const;
                    constCount = constCount + 1;
                elseif regexp(line,'[0-9]+:var:-?[0-9]+:-?[0-9]+:-?[0-9]+:-?[0-9]+:.+')
                    str = strsplit(line,':');
                    index = str2num(str{1});
                    min = str2num(str{3});
                    max = str2num(str{4});
                    init = str2num(str{5});
                    number = str2num(str{6});
                    name = str{7};
                    
                    var.type = 'VAR';
                    var.index = index;
                    var.min = min;
                    var.max = max;
                    var.init = init;
                    var.number = number;
                    var.name = name;
                    ifStruct.layout.variables{variableCount} = var;
                    variableCount = variableCount + 1;
                elseif regexp(line,'[0-9]+:meta:-?[0-9]+:-?[0-9]+:-?[0-9]+:-?[0-9]+:[a-zA-Z]+')
                    str = strsplit(line,':');
                    index = str2num(str{1});
                    min = str2num(str{3});
                    max = str2num(str{4});
                    init = str2num(str{5});
                    number = str2num(str{6});
                    name = str{7};
                    
                    meta.type = 'META';
                    meta.index = index;
                    meta.min = min;
                    meta.max = max;
                    meta.init = init;
                    meta.number = number;
                    meta.name = name;
                    ifStruct.layout.metas{metaCount} = meta; 
                    metaCount = metaCount + 1;
                elseif regexp(line,'[0-9]+:location:[a-zA-Z]*:.+')
                    str = strsplit(line,':');
                    index = str2num(str{1});
                    flag = str{3};
                    name = str{4};
                    
                    location.index = index;
                    location.type = 'LOCATION';
                    switch flag
                        case ''
                            location.flags = 'NONE';
                        case 'committed'
                            location.flags = 'COMMITTED';
                        case 'urgent'
                            location.flags = 'URGENT';
                        otherwise
                            location.flags = 'NONE';
                    end  
                    location.name = name;
                    ifStruct.layout.locations{locationCount} = location;
                    locationCount = locationCount + 1;
                elseif regexp(line,'[0-9]+:static:-?[0-9]+:-?[0-9]+:[a-zA-Z]+')
                    str = strsplit(line,':');
                    index = str2num(str{1});
                    min =str2num(str{3});
                    max = str2num(str{4});
                    name = str2num(str{5});
                    
                    fixed.type = 'FIXED';
                    fixed.index = index;
                    fixed.min = min;
                    fixed.max = max;
                    fixed.name = name;
                    
                    ifStruct.layout.fixed{fixedCount} = fixed;
                    fixedCount = fixedCount + 1;
                elseif regexp(line,'[0-9]+:[a-zA-Z]+')
                    str = strsplit(line,':');
                    index = str2num(str{1});
                    name = str{2};
                    
                    cost.index = index;
                    cost.name = name;
                    cost.type = 'COST';  
                    ifStruct.layout.cost{costCount} = cost;
                    costCount = costCount + 1;
                end
                line = fgetl(fileId);
            end
        case 'instructions'
            line = fgetl(fileId);
            while (sum(~isspace(line))> 0 || ~isempty(line)) && ~feof(fileId)
                if regexp(line, '[0-9]+:\s-?[0-9]+\s-?[0-9]*\s-?[0-9]*\s-?[0-9]*.*')
                    str = sscanf(line,'%d:%d%d%d%d');
                    instructions.address = str(1);
                    instructions.values = str(2:end);
                    ifStruct.instructions{instrCount} = instructions;
                    instrCount = instrCount + 1;
                end
                line = fgetl(fileId);
            end
        case 'processes'
            line = fgetl(fileId);
            while (sum(~isspace(line))> 0 || ~isempty(line)) && ~feof(fileId)
                if regexp(line,'[0-9]+:-?[0-9]+:[a-zA-Z]+')
                    str = strsplit(line,':');
                    index = str2num(str{1});
                    initial = str2num(str{2});
                    name = str{3};
                    
                    process.index = index;
                    process.initial = initial;
                    process.name = name;
                    ifStruct.processes{processCount} = process;
                    ifStruct.processes{processCount}.locations = {};
                    ifStruct.processes{processCount}.edges = {};
                    processCount = processCount + 1;
                end
                line = fgetl(fileId);
            end
        case 'locations'
            line = fgetl(fileId);
            while (sum(~isspace(line))> 0 || ~isempty(line)) && ~feof(fileId)
                if regexp(line, '[0-9]+:-?[0-9]+:-?[0-9]+')
                    str = strsplit(line,':');
                    index = str2num(str{1});
                    process = str2num(str{2});
                    invariant = str2num(str{3});
                    
                    position = findByIndex(ifStruct.layout.locations, index);
                    ifStruct.layout.locations{position}.process = process;
                    ifStruct.layout.locations{position}.invariant = invariant;
                
                    position = findByIndex(ifStruct.processes,process);
                    loc = ifStruct.processes{position}.locations;
                    loc = {loc{1:end} index};
                    ifStruct.processes{position}.locations = loc;
                end
                line = fgetl(fileId);
            end
        case 'edges'
            line = fgetl(fileId);
            while (sum(~isspace(line))> 0 || ~isempty(line)) && ~feof(fileId)
                if regexp(line,'[0-9]+:-?[0-9]+:-?[0-9]+:-?[0-9]+:-?[0-9]+:-?[0-9]+')
                    str = strsplit(line,':');
                    edge.process = str2num(str{1});
                    edge.source = str2num(str{2});
                    edge.target = str2num(str{3});
                    edge.guard = str2num(str{4});
                    edge.sync = str2num(str{5});
                    edge.update = str2num(str{6}); 
                    
                    position = findByIndex(ifStruct.processes,edge.process);
                    ed =  ifStruct.processes{position}.edges;
                    ed = {ed{1:end} edge};
                    ifStruct.processes{position}.edges = ed;
                    ifStruct.edges{edgeCount} = edge;
                    edgeCount = edgeCount + 1;
                end
                line = fgetl(fileId);
            end
        case 'expressions'
            line = fgetl(fileId);
            while (sum(~isspace(line))> 0 || ~isempty(line)) && ~feof(fileId)
                if regexp(line,'[0-9]+:-?[0-9,]*:-?[0-9,]*:.+')
                    str = strsplit(line,':');
                    address = str2num(str{1});
                    reads = str{2};
                    if ~isempty(strfind(reads,','))
                        reads = strsplit(reads,',');
                    end
                    writes = str{3};
                    if ~isempty(strfind(writes,','))
                        writes = strsplit(writes,',');
                    end
                    text = str{4};
                    expression.address = address;
                    expression.reads = reads;
                    expression.writes = writes;
                    expression.text = text;
                    
                    ifStruct.expressions{expressionCount} = expression;
                    expressionCount = expressionCount + 1;
                end  
                line = fgetl(fileId);
            end
    end
end
    function position = findByIndex(array,index)
        for i = 1:length(array)
            if array{i}.index == index
                position = i;
                break;
            end
        end
    end 
end