function [] = writeUPPAAL(filename, struct)
%writeUPPAAL uses a UPPAAL structure made from readUPPAAL and writes it
%into an UPPAAL xml file format.
%
% filename is a string of the name of the file to be written
%
%   struct is the UPPAAL structure generated from readUPPAAL


%% Constants
%% Main function
docNode = com.mathworks.xml.XMLUtils.createDocument('nta','nta','-//Uppaal Team//DTD Flat System 1.1//EN','http://www.it.uu.se/research/group/darts/uppaal/flat-1_1.dtd');
docNode.setXmlVersion('1.0');
docNode.setXmlEncoding('utf-8');
%commentNode = docNode.createComment();
%docNode.appendChild(commentNode);
declaration = struct.declaration;
declaration_node = makeDeclarationNode(declaration);
docNode.getDocumentElement.appendChild(declaration_node);
    
tottemps = length(struct.template);
%name, parameter, declaration, location, init, transition
for t = 1:tottemps
    template_node = docNode.createElement('template');
    totName = length(struct.template{t}.name);
    %name nodes
    if totName ~=0 
        for n = 1:totName
            name = struct.template{t}.name{n};
            nameNode = makeNameNode(name);
            template_node.appendChild(nameNode);
        end
    else
        name.x = '0';
        name.y = '0';
        name.text = 'location';
        nameNode = makeNameNode(name);
        template_node.appendChild(nameNode);
    end
    %parameter nodes
    totParam = length(struct.template{t}.parameter);
    if totParam ~= 0
        for p = 1:totParam
            parameter = struct.template{t}.parameter{p};
            parameterNode = makeParameterNode(parameter);
            template_node.appendChild(parameterNode);
        end
    else
        parameter = {'' '' ''};
        parameterNode = makeParameterNode(parameter);
        template_node.appendChilde(parameterNode);
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
    system_node = makeSystemNode(struct.system(S));
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
            nameNode.setAttribute('x', '0');
        end
        if ~isempty(name.y)
            nameNode.setAttribute('y', num2str(name.y));
        else
            nameNode.setAttribute('y', '0');
        end
        nameNode.setTextContent(name.text);
    end

    function parameterNode = makeParameterNode(parameter)
        parameterNode = docNode.createElement('parameter');
        if ~isempty(parameter)
            total = size(parameter);
            total = total(1);
            parameters = '';
            for par = 1:total-1
                parameters = [parameters,parameter{par,1},' ',parameter{par,2},parameter{par,3},','];
            end
                parameters =[parameters,parameter{end,1},' ',parameter{end,2},parameter{end,3}];
            parameterNode.setTextContent(parameters);
            %parameterNode.setTextContent(parameter);
        end
    end
    %TODO: deal with values containing arrays
    function declarationNode = makeDeclarationNode(declaration)
        declarationNode = docNode.createElement('declaration');
        if ~isempty(declaration)
   %         declarationNode.setTextContent(declaration);
            total = size(declaration);
            total = total(1);
            declarations = '';
            for dec = 1:total
                declarations = [declarations,declaration{dec,1},' ',addCommas(declaration{dec,2})];
                if strcmp(declaration(dec,1),'clock') || length(declaration{dec,2}) > 1
                    declarations = sprintf([declarations,';\n']);
                else
                    declarations = [declarations,'=',num2str(declaration{dec,3}),';'];
                    declarations = sprintf([declarations,'\n']);
                end
            end
            declarationNode.setTextContent(declarations);
        end
    end
    
    function systemNode = makeSystemNode(system)
        systemNode = docNode.createElement('system');
        variable = system.variables;
        process = system.process;
        systems = system.system;
        if ~isempty(system)
            variableText = sprintf('//variables\n');
            for var = 1:size(variable,1)
                variableText = [variableText,variable{var,1},' ',addCommas(variable{var,2})];
                if strcmp(variable(var,1),'clock') || iscell(variable{var,2})
                    variableText
                    variableText = sprintf([variableText,';\n']);
                else
                    variableText = [variableText,'=',num2str(variable{var,3}),';'];
                    variableText = sprintf([variableText,'\n']);
                end
            end
            processes = sprintf('//processes\n');
            for pro = 1:length(process)
                processes = [processes,process(pro).name,'=',process(pro).function,'('];
                arguments = '';
                totalArgs = length(process(pro).arguments);
                for arg = 1:totalArgs-1
                    argument = process(pro).arguments{arg};
                    arguments = [arguments,argument,','];
                end
                arguments = [arguments,process(pro).arguments{totalArgs}];
                processes = sprintf([processes,arguments,');\n']);
            end
            systemText = sprintf('//systems\n');
            for sys = 1:length(systems)
                systemText = sprintf([systemText,'//',systems(sys).name,'\n']);
                processText = '';
                systemText = [systemText,'system '];
                totalProcesses = length(systems(sys).processes);
                for prt = 1: totalProcesses-1
                    processText = [processText,systems(sys).processes{prt},','];
                end
                processText = [processText,systems(sys).processes{totalProcesses}];
                systemText = sprintf([systemText,processText,';\n']);
            end
            systemNodeText = [variableText,processes,systemText];
            systemNode.setTextContent(systemNodeText);
        end
    end

    function variable = addCommas(variables)
            if iscell(variables)
                var = '';
                for y = 1:length(variables)-1
                    var = [var,variables{y},','];
                end
                    var = [var,variables{end}];
                    variable = var;
            else
                variable = variables;
            end
    end
    function value = getValues(values)
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
            locationNode.setAttribute('y', '0');
        end  
        %x
        if ~isempty(location.x)
            locationNode.setAttribute('x', num2str(location.x));
        else
            locationNode.setAttribute('x', '0');
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
            labelNode.setAttribute('y', '0');
        end
        if ~isempty(label.x)
            labelNode.setAttribute('x', num2str(label.x));
        else
            labelNode.setAttribute('x', '0');
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
            nailNode.setAttribute('y', '0');
        end 
        if ~isempty(nail.x)
            nailNode.setAttribute('x', num2str(nail.x));
        else
            nailNode.setAttribute('x', '0');
        end
    end

    function initNode = makeInitNode(init)
        initNode = docNode.createElement('init');
        initNode.setAttribute('ref', init);
    end

end

