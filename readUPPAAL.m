function [theStruct] = readUPPAAL(filename)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
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
                    case 'declaration'
                        totDec = totDec + 1;
                    case 'template'
                        totTemp = totTemp + 1;
                    case 'system'
                        totSys = totSys + 1;
                end
            end
            theStruct = struct('declaration',cell(1),...
                               'template',cell(1),...
                               'system',cell(1));
                           
            declarationCell = cell(1,totDec);
            templateCell = cell(1,totTemp);
            systemCell = cell(1,totSys);
            
            theStruct.declaration = declarationCell;
            theStruct.template = templateCell;
            theStruct.system = systemCell;
            
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
                        theStruct.system{totSys} = char(theChild.getTextContent);
                        totSys = totSys + 1;
                    case 'declaration'
                        theStruct.declaration{totDec} = char(theChild.getTextContent);
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
                    templateStruct.parameter{totalParameters} = char(theElement.getTextContent);
                    totalParameters = totalParameters + 1;
                case 'declaration'
                    templateStruct.declaration{totalDeclarations} = char(theElement.getTextContent);
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