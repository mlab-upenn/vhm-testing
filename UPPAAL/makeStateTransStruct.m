function [stateStruct, transitionStruct] = makeStateTransStruct(fileId,processCount,variableCount,clockCount)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%allocate
%% Make State Struct
locations = zeros(processCount,1);
variables = zeros(variableCount,1);
dbm = cell(clockCount,clockCount);
               
s = size(dbm);
for row = 1:s(1)
    for column = 1:s(2)
        if row == column
            bound_t.value = 0;
            bound_t.strict = 0;
            dbm{row,column} = bound_t;
        elseif row == 1
            bound_t.value = 0;
            bound_t.strict = 0;
            dbm{row,column} = bound_t;
        else
            bound_t.value = Inf;
            bound_t.strict = 1;
            dbm{row,column} = bound_t;
        end  
    end
end
%i.e. if dbm is 3x3
%dbm =  0   0   0
%      Inf  0  Inf
%      Inf Inf  0

locations = fscanf(fileId,'%d');

fscanf(fileId,'.');

dbm = fscanf(fileId,'%d\n%d\n%d\n.');
for d = 1:3:length(dbm)
    sample = dbm(d:d+2);
    r = sample(1) + 1;
    c = sample(2) + 1;
    bnd = sample(3);
    bound_t.value = bitshift(bnd,-1);
    bount_t.strict = bitand(bnd,1);
    dbm{r,c} = bound_t;
end

fscanf(fileId,'.');

variables = fscanf(fileId,'%d');



stateStruct.locations = locations;
stateStruct.variables = variables;
stateStruct.dbm = dbm;

fscanf(fileId,'.');
%% Make transition Struct
edges = zeros(processCount,1);

prevPos = ftell(fileId);
[data, pos] = textscan(fileId,'%d %d\n','EndOfLine','\n','whitespace', ' ');
if isempty(data{2})
    fseek(fileId,prevPos-pos,'cof')
else
    fseek(fileId,prevPos-pos,'cof')
    data = fscanf(fileId,'%d %d\n',[2,Inf]);
    data = data';
    totTrans = size(data,1);

    for e = 1:totTrans
        process = data(e,1);
        edge = data(e,2);
        edges(process) = edge;
    end
end
transitionStruct.edges = edges;
end