function [stateStruct, transitionStruct] = makeStateTransStruct(fileId,processCount,variableCount,clockCount)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%allocate
%% Make State Struct
locations = zeros(processCount,1);
variables = zeros(variableCount,1);
dbm = cell(clockCount,clockCount);

prevPos = ftell(fileId);
[a pos] = textscan(fileId,'%c\n','EndOfLine','\n');
if length(a{1}) >1
    a{1} = a{1}(2);
end
%check if end of file
if ~strcmp(a{1},'.')
    fseek(fileId,prevPos-pos,'cof');

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

    difboundM = fscanf(fileId,'%d\n%d\n%d\n.');
    for d = 1:3:length(difboundM)
        sample = difboundM(d:d+2);
        r = sample(1) + 1;
        c = sample(2) + 1;
        bnd = sample(3);
        bound_t.value = bitshift(bnd,-1);
        bound_t.strict = bitand(s2u(bnd),1);
        dbm{r,c} = bound_t;
    end

    fscanf(fileId,'.');

    variables = fscanf(fileId,'%d');



    stateStruct.locations = locations;
    stateStruct.variables = variables;
    stateStruct.dbm = dbm;

    textscan(fileId,'.');
    %% Make transition Struct
    edges = zeros(processCount,1);

    prevPos = ftell(fileId);
    [data, pos] = textscan(fileId,'%d %d\n','EndOfLine','\n','whitespace', ' ');
    if isempty(data{2})
        fseek(fileId,prevPos-pos,'cof');
    else
        fseek(fileId,prevPos-pos,'cof');
        fscanf(fileId,'.');
        data = fscanf(fileId,'%d %d\n',[2,Inf]);
        data = data';
        totTrans = size(data,1);

        for e = 1:totTrans
            process = data(e,1);
            edge = data(e,2);
            edges(process+1) = edge;
        end
        fscanf(fileId,'.');
    end
    transitionStruct.edges = edges;
else
    stateStruct = {};
    transitionStruct = {};
end

function y = s2u(x)
    x = int16(x);
    if x < 0
        y = uint16(double(x) + 65536);
    else
        y = uint16(x);
    end
end
end