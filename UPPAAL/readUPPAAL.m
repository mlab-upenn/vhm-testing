function [theStruct] = readUPPAAL(filename)
%readUPPAAL reads in a UPPAAL-formatted .xml file and outputs a structure
%   containing data from the .xml file.
%   filename is the name of the file i.e. 'uppaalfile.xml'
%   theStruct has the contents of the file in a structure-format.
try
   doc = xmlread(filename);
catch err
   error(getReport(err, 'extended'));
end

% Recurse over child nodes. This could run into problems 
% with very deeply nested trees.
try
    tree = doc.getDocumentElement;
    theStruct = makeStruct(tree);
catch err
    error(getReport(err, 'extended'));
end

    function theStruct = makeStruct(theNode)
        % Recurse over node children.
        if theNode.hasChildNodes
            childNodes = theNode.getChildNodes;
            numChildNodes = childNodes.getLength;
            totDec = 0;
            totTemp = 0;
            totSys = 0;
            for count = 1:numChildNodes
                theElement = childNodes.item(count-1);
                elementName = char(theElement.getNodeName);
                switch elementName
                    case 'template'
                        totTemp = totTemp + 1;
                end
            end
            theStruct = struct('template',cell(1));
                                                           
            templateCell = cell(1,totTemp);
            theStruct.template = templateCell;
            
            totDec = 1;
            totTemp = 1;
            totSys = 1;
            for count = 1:numChildNodes
                theChild = childNodes.item(count-1);
                childName = char(theChild.getNodeName);
                switch childName
                    case 'template'
                        theStruct.template{totTemp} = makeStructFromTemplate(theChild);
                        totTemp = totTemp + 1;
                    case 'system'
                        theStruct.system = makeSystemStruct(char(theChild.getTextContent)); %char(theChild.getTextContent);
                        totSys = totSys + 1;
                    case 'declaration'
                        theStruct.declaration = makeDeclarationCell(char(theChild.getTextContent)); % char(theChild.getTextContent);
                        totDec = totDec + 1;
               end
            end
        end
    end

    function templateStruct = makeStructFromTemplate(template)
        elements = template.getChildNodes;
        totalElements = elements.getLength;
        totalNames = 0;
        totalParameters = 0;
        totalDeclarations = 0;
        totalLocations = 0;
        totalTransitions = 0;
        totalInit = 0;
        % preallocate
        for y = 1:totalElements
            theElement = elements.item(y-1);
            elementName = char(theElement.getNodeName);
            switch elementName
                case 'name'
                    totalNames = totalNames + 1;
                case 'parameter'
                    totalParameters = totalParameters + 1;
                case 'declaration'
                    totalDeclarations = totalDeclarations + 1;
                case 'location'
                    totalLocations = totalLocations + 1;
                case 'transition'
                    totalTransitions = totalTransitions + 1;
                case 'init'
                    totalInit = totalInit + 1;
            end
        end
        templateStruct = struct('name',cell(1),...
                                'parameter', cell(1),...
                                'declaration', cell(1),...
                                'location', cell(1),...
                                'init',cell(1),...
                                'transition', cell(1));
                            
        nameCell = cell(1,totalNames);
        parameterCell =cell(1,totalParameters);
        declarationCell = cell(1,totalDeclarations);
        locationCell = cell(1,totalLocations);
        transitionCell = cell(1,totalTransitions);
        initCell = cell(1,totalInit);
        
        templateStruct.name = nameCell;
        templateStruct.parameter = parameterCell;
        templateStruct.declaration = declarationCell;
        templateStruct.location = locationCell;
        templateStruct.transition = transitionCell;
        templateStruct.init = initCell;
        
        totalNames = 1;
        totalParameters = 1;
        totalDeclarations = 1;
        totalLocations = 1;
        totalTransitions = 1;
        totalInit = 1;
        for y = 1:totalElements
            theElement = elements.item(y-1);
            elementName = char(theElement.getNodeName);
            switch elementName
                case 'name'
                    templateStruct.name{totalNames} = makeNameStruct(theElement);
                    totalNames = totalNames + 1;
                case 'parameter'
                    templateStruct.parameter{totalParameters} = makeParameterCell(char(theElement.getTextContent));
                    totalParameters = totalParameters + 1;
                case 'declaration'
                    templateStruct.declaration{totalDeclarations} = makeDeclarationCell(char(theElement.getTextContent));
                    totalDeclarations = totalDeclarations + 1;
                case 'location'
                    templateStruct.location{totalLocations} = makeLocationStruct(theElement);
                    totalLocations = totalLocations + 1;
                case 'transition'
                    templateStruct.transition{totalTransitions} = makeTransitionStruct(theElement);
                    totalTransitions = totalTransitions + 1;
                case 'init'
                    templateStruct.init{totalInit} = char(theElement.getAttribute('ref'));
                    totalInit = totalInit + 1;
            end
        end
    end


%% SubFunctions
    %type, name, value
    %TODO: deal with these cases:
    %           int[0,1]
    %           int/bool a, b[2][2];
    %           int b[2][3] = {{1,2,3},{4,5,6}};
    %           int b[5];
    %           urgent chan a, b[2];
    %           broadcast chan c;
    %           const k[3]{1,2,3};
    %           meta int/bool/arrays
    function declarationCell = makeDeclarationCell(declaration)
        %first separate by line
        splitLines = strsplit_re(declaration,'\n');
        %count number of variables to store to preallocate declarationCell
        semicolons = 0;
        for l = 1:length(splitLines)
            line = splitLines{l};
            %if the line wasn't commented out
            if isempty(strfind(line,'//'))
                stuff =  strfind(line,';');
                semicolons = semicolons + length(strfind(line,';'));
            end
        end
        
        %preallocate declarationCell
        declarationCell = cell(semicolons,3);
        %counter
        d = 1;
        for l = 1:length(splitLines)
            line = splitLines{l};
            purewhiteSpace = sum(isspace(line))/length(line);
            if strcmp(line,'') || isempty(line) || purewhiteSpace == 1
                continue
            end
            %if the line wasn't commented out
            if isempty(strfind(line,'//'))
                %if more than one variable is on this line
                values = findNameValueVariable(line);
                totValues = size(values,1);
                for t = 1:totValues
                    declarationCell(d,:) = values(t,:);
                    d = d+1;
                end 
            end
        end
    end
    function systemStruct = makeSystemStruct(system)
        %first separate by line
        splitLines = strsplit_re(system,'\n');
        %count number of variables to store to preallocate systemStruct and
        %cells
        totSys = 0;
        totProc = 0;
        for l = 1:length(splitLines)
            line = splitLines{l};
            %if the line wasn't commented out
            if isempty(strfind(line,'//'))
                if length(strfind(line,';')) > 1
                    line = strsplit(line,';');
                    line = line(1:end-1);
                    for m = 1:length(line)
                        if length(strfind(line{m},'=')) >= 1
                            totProc = totProc + 1;
                        elseif length(strfind(line{m},'system ')) >=1
                            totSys = totSys + 1;
                        end
                    end
                else
                    if length(strfind(line,'=')) >= 1
                        totProc = totProc + 1;
                    elseif length(strfind(line,'system ')) >=1
                        totSys = totSys + 1;
                    end
                end
            end
        end
        %preallocate struct and cells
        systemStruct = struct('variables',cell(1),...
                              'process',cell(1),...
                              'system',cell(1));
        process = struct('name',cell(1),...
                         'function',cell(1),...
                           'arguments',cell(1)); %struct with name of process, and input arguments
        system = struct('name',cell(1),...
                        'processes',cell(1));
        s = 1;
        p = 1;
        v = 1;
        for l = 1:length(splitLines)
            line = splitLines{l};
            purewhiteSpace = sum(isspace(line))/length(line);
            if strcmp(line,'') || isempty(line) || purewhiteSpace == 1
                continue
            end
            %if the line wasn't commented out
            if isempty(strfind(line,'//'))
                if length(strfind(line,';')) > 1
                    line = strsplit(line,';');
                    line = line(1:end-1);
                    for m = 1:length(line);
                        ifVar = strsplit_re(line{m},'\s+');
                        varType = {'bool' 'int' 'chan' 'clock' 'const' 'meta' 'broadcast' 'urgent'};
                        if ~isempty(find(ismember(ifVar,varType), 1))
                            vars = findNameValueVariable(line{m});
                            for va = 1:size(vars,1)
                                systemStruct.variables(v,:) = vars(va); 
                                v = v+1;
                            end
                        elseif length(strfind(line{m},'=')) >= 1
                            line{m} = line{m}(~isspace(line{m}));
                            newline = strsplit(line{m},'=');
                            processName = newline{1};
                            theRest = newline{2};
                            theRest = strsplit(theRest,'(');
                            funct = theRest{1};
                            theRest = theRest{2};
                            theRest = theRest(1:strfind(theRest,')')-1);
                            arguments = strsplit(theRest,',');
                            process(p).name = processName;
                            process(p).function = funct;
                            process(p).arguments = arguments;
                            p = p+1;
                        elseif length(strfind(line{m},'system ')) >=1
                            line = line(1:strfind(line,';')-1);
                            line = strsplit(line,' ');
                            line = [line{2:end}];
                            processes = strsplit(line,',');
                            system(s).processes = processes;
                            s = s+1;
                        end
                    end
                else
                    ifVar = strsplit_re(line,'\s+');
                    varType = {'bool' 'int' 'chan' 'clock' 'const' 'meta' 'broadcast' 'urgent'};
                    if ~isempty(find(ismember(ifVar,varType), 1))
                        vars = findNameValueVariable(line);
                        for va = 1:size(vars,1)
                            systemStruct.variables(v,:) = vars(va,:);
                            v = v+1;
                        end
                    elseif length(strfind(line,'=')) >= 1
                        line = line(1:strfind(line,';')-1);
                        line = line(~isspace(line));
                        line = strsplit(line,'=');
                        processName = line{1};
                        theRest = line{2};
                        theRest = strsplit(theRest,'(');
                        funct = theRest{1};
                        theRest = theRest{2};
                        theRest = theRest(1:strfind(theRest,')')-1);
                        arguments = strsplit(theRest,',');
                        process(p).name = processName;
                        process(p).function = funct;
                        process(p).arguments = arguments;
                        p = p+1;
                    elseif length(strfind(line,'system ')) >=1
                        line = line(1:strfind(line,';')-1);
                        line = strsplit(line,' ');
                        line = [line{2:end}];
                        processes = strsplit(line,',');
                        system(s).processes = processes;
                        s = s+1;
                    end
                end
            end          
        end
        systemStruct.process = process;
        systemStruct.system = system;
    end
    function values = findNameValueVariable(line)
            %if more than one variable is on this line
            if length(strfind(line,';')) > 1
                variables = strsplit(line,';');
                variables = variables(1,1:end-1);
                values = cell(length(variables),3);
            else
                variables = cell(1,1);
                variables{1} = line(1:strfind(line,';')-1);
                values = cell(1,3);
            end
            for v = 1:length(variables)
                value = strsplit_re(variables{v},'\s+');
                variableType = value{1};
                switch variableType
                    case {'broadcast','meta','urgent','const'}
                        variableType = [value{1},' ',value{2}];
                        theRest = strcat(value{3:end});
                    otherwise
                        theRest = strcat(value{2:end});
                end
                name = '';
                value = 0;
                %TODO:Take multiple different variabletypes into
                %account
                 rangedVariable ='[a-z_]+\[[0-9]+\,[0-9]+\]';
           %      arrayAllocate = '\[[0-9]+\]\[[0-9]+\]';
                if sum(strcmp(variableType,{'int', 'bool','meta int','meta bool','const int','const bool'}))>=1
                    %remove whitespace
                    theRest = theRest(~isspace(theRest));
                    theRest = strsplit(theRest,'=');
                    %TODO: deal with arrays.
                    if length(strfind(theRest{1}, '[')) >=1
                        array = makeArray(theRest);
                        name = array{1};
                        value = array{2};
                    else
                        name = theRest{1};
                        value = 0;
                        if length(theRest) > 1
                            value = theRest{2};
                        end
                        isDigit = sum(isstrprop(value,'digit'))/length(value);
                        if isDigit == 1
                            value = str2num(value);
                        else
                            switch value
                                case 'false'
                                    value = 0;
                                case 'true'
                                    value = 1;
                            end
                        end
                        vars = strsplit(name,',');
                        if length(vars) > 1
                            name = vars;
                        end
                    end
                elseif sum(strcmp(variableType,{'clock','broadcast chan','chan','urgent chan'}))>=1
                        name = theRest;
                        names = strsplit(name,',');
                        if length(names)> 1
                            name = names;
                        end
                elseif regexp(variableType,rangedVariable)
                     
                end   
                values(v,:) = {variableType, name, value};
            end
    end

    function array = makeArray(theRest)
        name = strsplit(theRest{1},'[');
        name = name{1};
        dimension = length(name)-1;
        zero = 'zeros(';
        dim = zeros(1,dimension);
        for a = 1:dimension-1
            zero = [zero,name{a}(1:end-1),','];
            dim(a) = num2str(name{a}(1:end-1));
        end
        zero = [zero,name{dimension}(1:end-1),')'];
        value = eval(zero);%dim =zeros(a,b,c,etc..)
        if length(theRest) >1
            alloc = theRest{2};
            alloc = alloc(~isspace(alloc));
            value = eval(alloc);
            value = value';
        end
        array = {name, value};
    end
%TODO:Add a parameter cell function
    function parameterCell = makeParameterCell(parameter)
        splitParams = strsplit(parameter,',');
        %preallocate parameterCell
        parameterCell = cell(length(splitParams),3);
        for p = 1:length(splitParams)
            param = splitParams{p};
            param = strsplit_re(param,'\s+');
            variable = param{length(param)};
            variableType = param(1:end-1);
            pointOrMem = '';
            %if a memory address
            if length(strfind(variable,'&')) >= 1
                pointOrMem = '&';
                variable = variable(strfind(variable,'&')+1:end);
            end
            if length(variableType) > 1
                varType = '';
                for v = 1:length(variableType)-1
                    varType = [varType, variableType{v}, ' '];
                end
                varType = [varType, variableType{length(variableType)}];
            else
                varType = variableType{1};
            end
            parameterCell(p,:) = {varType, pointOrMem, variable};
        end
    end
    function locationStruct = makeLocationStruct(location)
        elements =location.getChildNodes;
        totalElements = elements.getLength;
        totalNames = 0;
        totalLabels = 0;
        committed = 'no';
        for l = 1:totalElements
            theElement = elements.item(l-1);
            elementName = char(theElement.getNodeName);

            switch elementName
                case 'name'
                    totalNames = totalNames + 1;
                case 'label'
                    totalLabels = totalLabels + 1;
                case 'committed'
                    committed = 'yes';
            end
        end
        locationStruct = struct('x', str2num(location.getAttribute('x')),...
                                'y', str2num(location.getAttribute('y')),...
                                'id',char(location.getAttribute('id')),...
                                'name', cell(1),...
                                'label', cell(1),...
                                'committed', committed);
        nameCell = cell(1,totalNames);
        labelCell = cell(1,totalLabels);
        
        locationStruct.name = nameCell;
        locationStruct.label = labelCell;
        
        totalNames = 1;
        totalLabels = 1;
        for l = 1:totalElements
            theElement = elements.item(l-1);
            elementName = char(theElement.getNodeName);

            switch elementName
                case 'name'
                    locationStruct.name{totalNames} = makeNameStruct(theElement);
                    totalNames = totalNames + 1;
                case 'label'
                    locationStruct.label{totalLabels} = makeLabelStruct(theElement);
                    totalLabels = totalLabels + 1;
            end
        end
    end

    function transitionStruct = makeTransitionStruct(transition)
        elements = transition.getChildNodes;
        totalElements = elements.getLength;
        totalSourceRef = 0;
        totalTargetRef = 0;
        totalLabels = 0;
        totalNails = 0;
        for e = 1:totalElements
            theElement = elements.item(e-1);
            elementName = char(theElement.getNodeName);
            switch elementName
                case 'source'
                    totalSourceRef = totalSourceRef + 1;
                case 'target'
                    totalTargetRef = totalTargetRef + 1;
                case 'label'
                    totalLabels = totalLabels + 1;
                case 'nail'
                    totalNails = totalNails + 1;
            end
        end
        transitionStruct = struct('source', cell(1),...
                                  'target', cell(1),...
                                  'label', cell(1),...
                                  'nail', cell(1));
                              
        sourceCell = cell(1,totalSourceRef);
        targetCell = cell(1,totalTargetRef);
        labelCell = cell(1,totalLabels);
        nailCell = cell(1,totalNails);
        
        transitionStruct.source = sourceCell;
        transitionStruct.target = targetCell;
        transitionStruct.label = labelCell;
        transitionStruct.nail = nailCell;
        
        totalSourceRef = 1;
        totalTargetRef = 1;
        totalLabels = 1;
        totalNails = 1;
        for e = 1:totalElements
            theElement = elements.item(e-1);
            elementName = char(theElement.getNodeName);
            switch elementName
                case 'source'
                    transitionStruct.source{totalTargetRef} = char(theElement.getAttribute('ref'));
                    totalSourceRef = totalSourceRef + 1;
                case 'target'
                    transitionStruct.target{totalTargetRef} = char(theElement.getAttribute('ref'));
                    totalTargetRef = totalTargetRef + 1;
                case 'label'
                    transitionStruct.label{totalLabels} = makeLabelStruct(theElement);
                    totalLabels = totalLabels + 1;
                case 'nail'
                    transitionStruct.nail{totalNails} = makeNailStruct(theElement);
                    totalNails = totalNails + 1;
            end
        end
    end

    function labelStruct = makeLabelStruct(label)
        labelStruct = struct('x',str2num(label.getAttribute('x')),...
                             'y',str2num(label.getAttribute('y')),...
                             'kind',char(label.getAttribute('kind')),...
                             'text', char(label.getTextContent));
    end
    function nailStruct = makeNailStruct(nail)
        nailStruct = struct('x',str2num(nail.getAttribute('x')),...
                            'y',str2num(nail.getAttribute('y')));
    end
    function nameStruct = makeNameStruct(name)
        nameStruct = struct('x',str2num(name.getAttribute('x')),...
                             'y',str2num(name.getAttribute('y')),...
                             'text', char(name.getTextContent));
    end
end