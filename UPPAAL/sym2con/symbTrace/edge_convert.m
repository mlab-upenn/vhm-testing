 function buf = edge_convert(s,index)
      %const string& s, map<string,int> index
        vector<int> buf;
        istringstream str(s);
        string buffer;
        while (std::getline(str, buffer, ','))
            %cout << "Converting: " << "," << buffer << "," <<endl;
            if (buffer~= '')
                buf = [buff index(buffer)];
            end
        end

  end