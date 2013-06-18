function [] = writeUPPAAL(filename, struct)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%% Constants
%% Main function
docNode = com.mathworks.xml.XMLUtils.createDocument('nta','nta','-//Uppaal Team//DTD Flat System 1.1//EN','http://www.it.uu.se/research/group/darts/uppaal/flat-1_1.dtd');
docNode.setXmlVersion('1.0');
docNode.setXmlEncoding('utf-8');
%commentNode = docNode.createComment();
%docNode.appendChild(commentNode);
totdec = length(struct.declaration);
for d = 1:totdec
    declaration_node = docNode.createElement('declaration');
    declaration_node.setTextContent(struct.declaration{d});
    docNode.getDocumentElement.appendChild(declaration_node);
end

tottemps = length(struct.template);
%name, parameter, declaration, location, init, transition
for t = 1:tottemps
    template_node = docNode.createElement('template');
    totName = length(struct.template{t}.name);
    %name nodes
    for n = 1:totName
        name = struct.template{t}.name{n};
        nameNode = makeNameNode(name);
        template_node.appendChild(nameNode);
    end
    %parameter nodes
    totParam = length(struct.template{t}.parameter);
    for p = 1:totParam
        parameter = struct.template{t}.parameter{p};
        parameterNode = makeParameterNode(parameter);
        template_node.appendChild(parameterNode);
    end
    %declaration nodes
    totDec = length(struct.template{t}.declaration);
    for d = 1:totDec
        declaration = struct.template{t}.declaration{d};
        declarationNode = makeDeclarationNode(declaration);
        template_node.appendChild(declarationNode);
    end
    %location nodes
    totLoc = length(struct.template{t}.location);
    for l = 1:totLoc
        location = struct.template{t}.location{l};
        locationNode = makeLocationNode(location);
        template_node.appendChild(locationNode);   
        %see if init
        init = struct.template{t}.init;
        if strcmp(location.id, init)
            initNode = makeInitNode(init);
            template_node.appendChild(initNode);
        end
    end
    %transition nodes
    totTrans = length(struct.template{t}.transition);
    for T = 1:totTrans
        transition = struct.template{t}.transition{T};
        transitionNode = makeTransitionNode(transition);
        template_node.appendChild(transitionNode);
    end
    docNode.getDocumentElement.appendChild(template_node);
end

totsys = length(struct.system);
for S = 1:totsys
    system_node = docNode.createElement('system');
    system_node.setTextContent(struct.system{S});
    docNode.getDocumentElement.appendChild(system_node);
end

if nargin == 2
    xmlwrite(filename, docNode)
elseif nargin == 1
    xmlwrite(docNode)
end


%% function list
    function nameNode = makeNameNode(name)
        nameNode = docNode.createElement('name');
        if ~isempty(name.x)
            nameNode.setAttribute('x', num2str(name.x));
        else
            nameNode.setAttribute('x', 0);
        end
        if ~isempty(name.y)
            nameNode.setAttribute('y', num2str(name.y));
        else
            nameNode.setAttribute('y', 0);
        end
        nameNode.setTextContent(name.text);
    end

    function parameterNode = makeParameterNode(parameter)
        parameterNode = docNode.createElement('parameter');
        if ~isempty(parameter)
            parameterNode.setTextContent(parameter);
        end
    end

    function declarationNode = makeDeclarationNode(declaration)
        declarationNode = docNode.createElement('declaration');
        if ~isempty(declaration)
            declarationNode.setTextContent(declaration);
        end
    end

    function locationNode = makeLocationNode(location)
        locationNode = docNode.createElement('location');
        %names
        totNa = length(location.name);
        for N = 1:totNa
            nam = location.name{N};
            if ~isempty(nam)
                locationNode.appendChild(makeNameNode(nam));
            end
        end
        %labels
        totLa = length(location.label);
        for L = 1:totLa
            lab = location.label{L};
            if ~isempty(lab)
                locationNode.appendChild(makeLabelNode(lab));
            end
        end
        %committed?
        if strcmp(location.committed,'yes')
            locationNode.appendChild(docNode.createElement('committed'));
        end
        %y
        if ~isempty(location.y)
            locationNode.setAttribute('y', num2str(location.y));
        else
            locationNode.setAttribute('y', 0);
        end  
        %x
        if ~isempty(location.x)
            locationNode.setAttribute('x', num2str(location.x));
        else
            locationNode.setAttribute('x', 0);
        end
        %id
        if ~isempty(location.id)
            locationNode.setAttribute('id', location.id);
        end 
    end
    function transitionNode = makeTransitionNode(transition)
        transitionNode = docNode.createElement('transition');
        %source
        totSource = length(transition.source);
        for s = 1:totSource
            source = transition.source{s};
            if ~isempty(source)
                transitionNode.appendChild(makeSourceNode(source));
            end
        end
        %target
        totTarget = length(transition.target);
        for a = 1:totTarget
            target = transition.target{a};
            if ~isempty(target)
                transitionNode.appendChild(makeTargetNode(target));
            end
        end
        %label
        totL = length(transition.label);
        for b = 1:totL
            labe = transition.label{b};
            if ~isempty(labe)
                transitionNode.appendChild(makeLabelNode(labe));
            end
        end
        %nail
        totNail = length(transition.nail);
        for na = 1:totNail
            nail = transition.nail{na};
            if ~isempty(nail)
                transitionNode.appendChild(makeNailNode(nail));
            end
        end
    end
    function labelNode = makeLabelNode(label)
        labelNode = docNode.createElement('label');
        if ~isempty(label.y)
            labelNode.setAttribute('y', num2str(label.y));
        else
            labelNode.setAttribute('y', 0);
        end
        if ~isempty(label.x)
            labelNode.setAttribute('x', num2str(label.x));
        else
            labelNode.setAttribute('x', 0);
        end  
        if ~isempty(label.kind)
            labelNode.setAttribute('kind',label.kind);
        end
        if ~isempty(label.text)
            labelNode.setTextContent(label.text);
        end
    end

    function sourceNode = makeSourceNode(source)
        sourceNode = docNode.createElement('source');
        sourceNode.setAttribute('ref', source);
    end

    function targetNode = makeTargetNode(target)
        targetNode = docNode.createElement('target');
        targetNode.setAttribute('ref', target);
    end

    function nailNode = makeNailNode(nail)
        nailNode = docNode.createElement('nail');
        if ~isempty(nail.y)
            nailNode.setAttribute('y', num2str(nail.y));
        else
            nailNode.setAttribute('y', 0);
        end 
        if ~isempty(nail.x)
            nailNode.setAttribute('x', num2str(nail.x));
        else
            nailNode.setAttribute('x', 0);
        end
    end

    function initNode = makeInitNode(init)
        initNode = docNode.createElement('init');
        initNode.setAttribute('ref', init);
    end

end

