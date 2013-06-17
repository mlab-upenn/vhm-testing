function [theStruct] = readUPPAAL(filename)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
try
   doc = xmlread(filename);
catch
   error('Failed to read XML file %s.',filename);
end

% Recurse over child nodes. This could run into problems 
% with very deeply nested trees.
try
    tree = doc.getDocumentElement;
    dec = tree.getChildNodes;
    declaration = tree.item(0).getTextContent;
    templates = parseChildNodes(tree);
    theStruct = {declaration, templates};
    %{
    numNodes = tree.getLength;
    for c = 1:numNodes
        node = tree.item(c-1);
        if strcmp(node.getNodeName,'declaration')
            declaration = node.item(0);
        else
            template = node.getChildNodes;
            numElements = template.getLength;
            for 
        end
        
    end
    theStruct = parseChildNodes(tree);
    %}
catch
    error('Unable to parse XML file %s.',filename);
end


    % ----- Local function PARSECHILDNODES -----
    function children = parseChildNodes(theNode)
        % Recurse over node children.
        children = [];
        if theNode.hasChildNodes
            childNodes = theNode.getChildNodes;
            numChildNodes = childNodes.getLength;
            allocCell = cell(1, numChildNodes);

            children = struct(             ...
            'Name', allocCell, 'Attributes', allocCell,    ...
            'Data', allocCell, 'Children', allocCell);

            for count = 1:numChildNodes
                theChild = childNodes.item(count);
                children(count) = makeStructFromTemplate(theChild);
                
            end
        end
    end

    function templateStruct = makeStructFromTemplate(template)
        elements = template.getChildNodes;
        totalElements = elements.getLength
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
        templateStruct = struct('name',cell(1,totalNames),...
                                'parameter', cell(1,totalParameters),...
                                'declaration', cell(1,totalDeclarations),...
                                'location', cell(1,totalLocations),...
                                'transition', cell(1,totalTransitions));
        
        for y = 1:totalElements
            theElement = elements.item(y-1);
            elementName = char(theElement.getNodeName);
            switch elementName
                case 'name'
                    templateStruct.name{totalNames} = makeNameStruct(theElement);
                    totalNames = totalNames - 1;
                case 'parameter'
                    templateStruct.parameter{totalParameters} = makeParameterStruct(theElement);
                    totalParameters = totalParameters - 1;
                case 'declaration'
                    templateStruct.declaration{totalDeclarations} = makeDeclarationStruct(theElement);
                    totalDeclarations = totalDeclarations - 1;
                case 'location'
                    templateStruct.location{totalLocations} = makeLocationStruct(theElement);
                    totalLocations = totalLocations - 1;
                case 'transition'
                    templateStruct.transition{totalTransitions} = makeTransitionStruct(theElement);
                    totalTransitions = totalTransitions - 1;
                case 'init'
            end
        end
    end
    
    function locationStruct = makeLocationStruct(location)
        elements =transition.getChildNodes;
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
                    committed = 'yes'
            end
        end
        locationStruct = struct('x', location.getAttribute('x'),...
                                'y', location.getAttribute('y'),...
                                'id', location.getAttribute('id'),...
                                'name', cell(1,totalNames),...
                                'label', cell(1,totalLabels),...
                                'committed', committed);
        for l = 1:totalElements
            theElement = elements.item(l-1);
            elementName = char(theElement.getNodeName);

            switch elementName
                case 'name'
                    locationStruct.name{totalNames} = makeNameStruct(theElement);
                    totalNames = totalNames - 1;
                case 'label'
                    locationStruct.label{totalLabels} = makeLabelStruct(theElement);
                    totalLabels = totalLabels - 1;
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
        transitionStruct = struct('source', cell(1,totalSourceRef),...
                                  'target', cell(1,totalTargetRef),...
                                  'label', cell(1,totalLabels),...
                                  'nail', cell(1,totalNails));
        for e = 1:totalElements
            theElement = elements.item(e-1);
            elementName = char(theElement.getNodeName);
            switch elementName
                case 'source'
                    totalSourceRef = totalSourceRef - 1;
                case 'target'
                    totalTargetRef = totalTargetRef - 1;
                case 'label'
                    totalLabels = totalLabels - 1;
                case 'nail'
                    totalNails = totalNails + 1;
            end
        end
    end

    function labelStruct = makeLabelStruct(label)
    end

    function nameStruct = makeNameStruct(name)
    end
    
    function parameterStruct = makeParameterStruct(parameter)
    end


%{

    % ----- Local function MAKESTRUCTFROMNODE -----
    function nodeStruct = makeStructFromNode(theNode)
    % Create structure of node info.

    nodeStruct = struct(                        ...
    'Name', char(theNode.getNodeName),       ...
    'Attributes', parseAttributes(theNode),  ...
    'Data', '',                              ...
    'Children', parseChildNodes(theNode));

    if any(strcmp(methods(theNode), 'getData'))
        nodeStruct.Data = char(theNode.getData); 
    else
        nodeStruct.Data = '';
    end
%}
    % ----- Local function PARSEATTRIBUTES -----
    function attributes = parseAttributes(theNode)
    % Create attributes structure.

    attributes = [];
    if theNode.hasAttributes
        theAttributes = theNode.getAttributes;
        numAttributes = theAttributes.getLength;
        allocCell = cell(1, numAttributes);
        attributes = struct('Name', allocCell, 'Value', ...
                       allocCell);

   for count = 1:numAttributes
      attrib = theAttributes.item(count-1);
      attributes(count).Name = char(attrib.getName);
      attributes(count).Value = char(attrib.getValue);
   end
end
theStruct = {declaration, templates}
end

