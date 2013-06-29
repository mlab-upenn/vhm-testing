function [xmlStruct] = addTemplate(template, xmlStruct, varargin)
%addTemplate helps to properly add a template from a UPPAAL model into
%another UPPAAL model structure
%   template is a structure containing the given fields:
%       name: a structure containing the fields 
%              x: a double describing the x-coordinate when graphically
%                constructed
%              y: a double describing the y-coordinate when graphically
%                constructed
%              text: char array of the name.    
%       parameter: an mx3 cell array containing input parameters       
%       declaration: an mx3 cell array containing variables
%       location: a struct array with structures that contain the fields:
%                x: a double describing the x-coordinate when graphically
%                constructed
%                y: a double describing the y-coordinate when graphically
%                constructed
%                id: a char array describing a unique id number
%                name: a struct with fields x,y, and text
%                label: a struct with fields
%                       x: a double describing the x-coordinate when graphically
%                           constructed.
%                       y: a double describing the y-coordinate when graphically
%                           constructed.            
%                       committed: 'yes' or 'no' depending on if the location is committed                  
%       transition: a cell array of structures, which each structure 
%                   containing the fields: 
%                   source: char array of a unique id number representing a location
%                   target: char array of a unique id number representing a location
%                   label: a structure array with structure(s) containing fields:
%                           x: a double describing the x-coordinate when graphically
%                               constructed
%                           y: a double describing the y-coordinate when graphically
%                               constructed        
%                           kind: char array describing the location type.
%                               i.e. 'synchronisation'
%                   nail: a structure array with structure(s) containing fields:
%                           x: a double describing the x-coordinate when graphically
%                               constructed
%                           y: a double describing the y-coordinate when graphically
%                               constructed                       
%
%   xmlStruct is the structure that will be adding template into its
%           template array.
idNum = findGreatestId(xmlStruct);
template = fixLocationIds(template,idNum);
xmlStruct = addToSystem(xmlStruct,template);

    function id = findGreatestId(struct)
        id = 0;
        for t = 1:length(struct.template)
            for l = 1:length(struct.template{t}.location)
                idVal = struct.template{t}.location{l}.id;
                %remove 'id' from the name and convert to double
                idVal = str2num(idVal(strfind(idVal,'id')+2:end));
                if idVal > id
                    id = idVal;
                end
            end
        end
    end
    %helps to adjust the id values for each location of the new template.
    %(each location in a UPPAAL xml file has a unique id)
    function [template startingIDNum] = fixLocationIds(template,startingIDNum)
        idLocator = cell(2,length(template.location));
        for l = 1:length(template.location)
            %store previous id number to adjust the transitions
            idLocator{1,l} = template.location{l}.id;
            startingIDNum = startingIDNum + 1;
            idLocator{2,l} = ['id',num2str(startingIDNum)];
            %change the id number
            template.location{l}.id = idLocator{2,l};
            for k = 1:length(template.init)
                if strcmp(template.init{k},idLocator{1,l})
                    template.init{k} = idLocator{2,l};
                end
            end
        end
        %adjust the id numbers of the source and target of the transitions
        for t = 1:length(template.transition)
            template.transition{t}.source = {convertid(template.transition{t}.source,idLocator)};
            template.transition{t}.target = {convertid(template.transition{t}.target,idLocator)};
        end
        
        function newId = convertid(previd,idDictionary)
            totIds = length(idDictionary);
            for i = 1:totIds
                if strcmp(idDictionary{1,i},previd)
                    newId = idDictionary{2,i};
                    break;
                end
            end
        end  
    end

    function struct = addToSystem(struct,template)
       oldTemps = struct.template;
       templates = {oldTemps{1:end},template};
       struct.template = templates;
       sysProcess.function = template.name{1}.text;
       sysProcess.name = ['P',sysProcess.function];
       sysProcess.arguments = template.parameter{1}(:,3)';
       struct.system.process = [struct.system.process(1:end), sysProcess];
       struct.system.system.processes = {struct.system.system.processes{1:end} ,sysProcess.name};
    end



end

