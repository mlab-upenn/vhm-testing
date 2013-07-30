classdef dumbResult
    %UNTITLED16 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        delays; %vector<mpq_class> 
        hasRes; %bool
    end
    
    methods
        function obj = DumbResult(d) 
            if nargin >=1
                obj.hasRes = true;
                obj.delays = d;
            else
                obj.hasRes = false;
           end
        end
        
        function hasRes = hasResult(obj)
            hasRes = obj.hasRes;
        end
        
        function outputDoubleEntry(obj)
            entry =0;
            i = 1;
            for it = 1:length(obj.delays)
                disp([num2str(i),' Entry: ', num2str(entry)]);
                entry = entry + it;
                i = i+1;
            end
        end
        
        function outputDoubleDelay(obj)
            disp('Output floating delay')
            i = 1;
            for it=1:length(obj.delays)
                disp([num2str(i),' Delay: ', num2str(it)])
                i = i+1;
            end
        end
        
        function outputAlternateEntry(obj)
            %vector<mpq_class>::iterator it;
            entry = 0;
            i =1;
            for it =1:length(obj.delays)
                disp([num2str(i),' Entry: ', num2str(entry)]);
                entry = entry + it;
                i = i+1;
            end
        end
        
        function outputAlternateDelay(obj)
            %vector<mpq_class>::iterator it;
            i = 1;
            for it =1:length(obj.delays)
                disp([num2str(i),' Delay: ',num2str(it)])
                i = i+1;
            end
        end
        
        %{
        function outputTiming(obj)
        end
        %}
        
        function outputDoubleSimp(obj)
            %vector<mpq_class>::iterator it;
            for it =1:length(obj.delays)
                disp([num2str(it), ' ']);
            end 
        end
        
        function outputAlternateSimp(obj)
            for it =1:length(obj.delays)
                disp([ num2str(it),' '])
            end
        end
        
    end
end

