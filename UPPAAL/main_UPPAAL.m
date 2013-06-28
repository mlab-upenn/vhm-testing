%main IF/xtr file.

%this script produces an array of structures that represents each state
%taken in the symbolic model
%model{n} represents the state of the model during the nth iteration
%each model contains two structures, state and transition. 
%model{n}.state contains data on the location of each process and the dbm.
% model{n}.state.dbm contains the dbm structures of each cell which store
%   the value and determine if the set value is strictly defined (dm.strict =
%   0 if not strict, 1 if strict)
%   model{n}.state.dbmVals presents a matrix of the values of the dbm only.  


% model{n}.transition contains data on if any transition in each process
%   will occur afterwards.
%   model{n}.transition.process{p} will show if process{p} will change to
%   another location using process{p}.edge (i.e.
%   model{n}.transition.process{p}.edge will show with edge was use for the
%   transition. if model{n}.transition.process{p} is empty, not transition was
%   made.
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
        
        
        [m n] = size(xtrStateStruct.dbm);
        dbmat = zeros(m,n);
        for r= 1:m
            for c = 1:n
                dbmat(r,c) = xtrStateStruct.dbm{r,c}.value;
            end
        end
        model{stateCount}.state.dbmVals = dbmat;
        
    %iterate
    for j = 1:processCount
        transition = xtrTransStruct.edges(j);
        model{stateCount}.transition.process{j} = {};
        if transition ~= 0
            model{stateCount}.transition.process{j}.name = ifStruct.processes{j}.name;
            model{stateCount}.transition.process{j}.edge = ifStruct.processes{j}.edges{transition};    
        end
    end
    stateCount = stateCount + 1;
end
