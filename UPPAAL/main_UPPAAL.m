%main IF/xtr file.

ifFile = 'model.if';
xtrFile = 'test.xtr';
stateTransStruct = struct('states',cell(1));
ifStruct = readIFFile(ifFile);

fid = fopen(xtrFile);

processCount = length(ifStruct.processes);
variableCount = length(ifStruct.layout.variables);
clockCount = length(ifStruct.layout.clocks);
stateCount = 1;
model = {};

while ~feof(fid)
    [xtrStateStruct xtrTransStruct] = makeStateTransStruct(fid,processCount,variableCount,clockCount);
    if feof(fid) || isempty(xtrStateStruct)
        break;
    end
    for i = 1:processCount
        model{stateCount}.state.process{i}.name = ifStruct.processes{i}.name;
        location = ifStruct.processes{i}.locations;
        location = location{xtrStateStruct.locations(i) + 1};
        model{stateCount}.state.process{i}.location = location;
    end
        model{stateCount}.state.dbm = xtrStateStruct.dbm;
    %iterate
    for j = 1:processCount
        transition = xtrTransStruct.edges(j)
        model{stateCount}.transition.process{j} = {};
        if transition ~= 0
            model{stateCount}.transition.process{j}.name = ifStruct.processes{j}.name;
            model{stateCount}.transition.process{j}.edge = ifStruct.processes{j}.edges{transition};    
        end
    end
    stateCount = stateCount + 1;
end
