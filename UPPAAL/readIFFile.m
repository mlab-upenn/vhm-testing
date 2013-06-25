function [ifStruct] = readIFFile(fileName)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
fileId = fopen(fileName);
clockCount = 0;
variableCount = 0;
while ~feof(fileId)
    section = fgetl(fileId);
    switch section
        case 'layout'
            line = fgetl(fileId);
            while ~isspace(line) || ~isempty(line)
                if regexp(line,'[0-9]+:clock:[0-9]+:[a-z]+')
                    str = strsplit(line,':');
                    index = str2num(str{1});
                    number = str2num(str{3});
                    name = str{4};
                
                    cell.type = 'CLOCK';
                    cell.index = index;
                    cell.number = number;
                    cell.name = name;
                    clockCount = clockCount + 1;
                elseif regexp(line,'[0-9]+:const:[0-9]+')
                    str = strsplit(line,':');
                    index = str2num(str{1});
                    value = str2num(str{3});
                    
                    cell.type = 'CONST'
                    cell.index = index;
                    cell.number = value;
                elseif regexp(line,'[0-9]+:var:[0-9]+:[0-9]+:[0-9]+:[0-9]+:[a-z]+')
                    str = strsplit(line,':');
                    index = str2num(str{1});
                    min = str2num(str{3});
                    max = str2num(str{4});
                    init = str2num(str{5});
                    number = str2num(str{6});
                    name = str2num(str{7});
                    
                    cell.index = index;
                    cell.min = min;
                    cell.max = max;
                    cell.init = init;
                    cell.number = number;
                    cell.name = name;
                    variableCount = variableCount + 1;
                elseif regexp(line,'[0-9]+:meta:[0-9]+:[0-9]+:[0-9]+:[0-9]+:[a-z]+')
                    str = strsplit(line,':');
                    index = str2num(str{1});
                    min = str2num(str{3});
                    max = str2num(str{4});
                    init = str2num(str{5});
                    number = str2num(str{6});
                    name = str2num(str{7});
                    
                    cell.index = index;
                    cell.min = min;
                    cell.max = max;
                    cell.init = init;
                    cell.number = number;
                    cell.name = name;
                    variableCount = variableCount + 1;
                elseif regexp(line,'[0-9]+:location::[a-z]+')
                    str = strsplit(line,':');
                    index = str2num(str{1});
                    name = str2num(str{4});
                    
                    cell.index = index;
                    cell.type = 'LOCATION';
                    cell.flags = 'NONE';
                    cell.name = name;
                    
                elseif regexp(line,'[0-9]+:location:committed:[a-z]+')
                    str = strsplit(line,':');
                    index = str2num(str{1});
                    name = str2num(str{4});
                    
                    cell.index = index;
                    cell.type = 'LOCATION';
                    cell.flags = 'COMMITTED';
                    cell.name = name;
                elseif regexp(line,'[0-9]+:location:urgent:[a-z]+')
                    str = strsplit(line,':');
                    index = str2num(str{1});
                    name = str2num(str{4});
                    
                    cell.index = index;
                    cell.type = 'LOCATION';
                    cell.flags = 'URGENT';
                    cell.name = name;
                elseif regexp(line,'[0-9]+:static:[0-9]+:[0-9]+:[a-z]+')
                    str = strsplit(line,':');
                    index = str2num(str{1});
                    min =str2num(str{3});
                    max = str2num(str{4});
                    name = str2num(str{5});
                    
                    cell.index = index;
                    cell.min = min;
                    cell.max = max;
                    cell.name = name;
                end
            end
        case 'instructions'
        case 'processes'
        case 'locations'
        case 'edges'
        case 'expressions'
    end
end

end

void loadIF(FILE *file)
{
    char str[255];
    char section[16];
    char name[32];
    int index;

    while (fscanf(file, "%15s\n", section) == 1)
    {
        if (strcmp(section, "layout") == 0)
        {
            while (read(file, str, 255) && !isspace(str[0]))
            {
                char s[5];
                cell_t cell;
                
                if (sscanf(str, "%d:clock:%d:%31s", &index, 
                           &cell.clock.nr, name) == 3)
                {
                    cell.type = CLOCK;
                    cell.name = name;
                    clocks.push_back(name);
                    clockCount++;
                }
                else if (sscanf(str, "%d:const:%d", &index, 
                                &cell.value) == 2)
                {
                    cell.type = CONST;
                }
                else if (sscanf(str, "%d:var:%d:%d:%d:%d:%31s", &index, 
                                &cell.var.min, &cell.var.max, &cell.var.init, 
                                &cell.var.nr, name) == 6)
                {
                    cell.type = VAR;
                    cell.name = name;
                    variables.push_back(name);
                    variableCount++;
                }
                else if (sscanf(str, "%d:meta:%d:%d:%d:%d:%31s", &index,
                                &cell.meta.min, &cell.meta.max, &cell.meta.init,
                                &cell.meta.nr, name) == 6)
                {
                    cell.type = META;
                    cell.name = name;
                    variables.push_back(name);
                    variableCount++;
                }
                else if (sscanf(str, "%d:location::%31s", &index, name) == 2)
                {
                    cell.type = LOCATION;
                    cell.location.flags = NONE;
                    cell.name = name;
                }
                else if (sscanf(str, "%d:location:committed:%31s", &index, name) == 2)
                {
                    cell.type = LOCATION;
                    cell.location.flags = COMMITTED;
                    cell.name = name;
                }
                else if (sscanf(str, "%d:location:urgent:%31s", &index, name) == 2)
                {
                    cell.type = LOCATION;
                    cell.location.flags = URGENT;
                    cell.name = name;
                }
                else if (sscanf(str, "%d:static:%d:%d:%31s", &index,
                                &cell.fixed.min, &cell.fixed.max, 
                                name) == 4)
                {
                    cell.type = FIXED;
                    cell.name = name;
                }
                else if (sscanf(str, "%d:%5s", &index, s) == 2
                         && strcmp(s, "cost") == 0)
                {
                    cell.type = COST;
                }
                else 
                {
                    throw invalid_format(str);
                }

                layout.push_back(cell);
            }
        }
        else if (strcmp(section, "instructions") == 0)
        {
            while (read(file, str, 255) && !isspace(str[0]))
            {
                int address;
                int values[4];
                int cnt = sscanf(
                    str, "%d:%d%d%d%d", &address, 
                    values + 0, values + 1, values + 2, values + 4);
                if (cnt < 2)
                {
                    throw invalid_format("In instruction section");
                }

                for (int i = 0; i < cnt; i++)
                {
                    instructions.push_back(values[i]);
                }
            }
        }
        else if (strcmp(section, "processes") == 0)
        {
            while (read(file, str, 255) && !isspace(str[0]))
            {
                process_t process;
                if (sscanf(str, "%d:%d:%31s", 
                           &index, &process.initial, name) != 3)
                {
                    throw invalid_format("In process section");
                }
                process.name = name;
                processes.push_back(process);
                processCount++;
            }
        }
        else if (strcmp(section, "locations") == 0)
        {
            while (read(file, str, 255) && !isspace(str[0]))
            {
                int index;
                int process;
                int invariant;

                if (sscanf(str, "%d:%d:%d", &index, &process, &invariant) != 3)
                {
                    throw invalid_format("In location section");
                }

                layout[index].location.process = process;
                layout[index].location.invariant = invariant;
                processes[process].locations.push_back(index);
            }
        }
        else if (strcmp(section, "edges") == 0)
        {
            while (read(file, str, 255) && !isspace(str[0]))
            {
                edge_t edge;

                if (sscanf(str, "%d:%d:%d:%d:%d:%d", &edge.process, 
                           &edge.source, &edge.target,
                           &edge.guard, &edge.sync, &edge.update) != 6)
                {
                    throw invalid_format("In edge section");
                }                

                processes[edge.process].edges.push_back(edges.size());
                edges.push_back(edge);
            }
        }
        else if (strcmp(section, "expressions") == 0)
        {
            while (read(file, str, 255) && !isspace(str[0]))
            {
                if (sscanf(str, "%d", &index) != 1)
                {
                    throw invalid_format("In expression section");
                }                    
                
                /* Find expression string (after the third colon).
                 */
                char *s = str;
                int cnt = 3;
                while (cnt && *s)
                {
                    cnt -= (*s == ':');
                    s++;
                }
                if (cnt)
                {
                    throw invalid_format("In expression section");
                }

                /* Trim white space. 
                 */
                while (*s && isspace(*s)) 
                {
                    s++;
                }
                char *t = s + strlen(s) - 1;
                while (t >= s && isspace(*t)) 
                {
                    t--;
                }
                t[1] = '\0';

                expressions[index] = s;
            }
        }
        else 
        {
            throw invalid_format("Unknown section");
        }
    }  
};