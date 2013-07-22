function dbm = edge_createDBM(dc_t_list,dbm,cindex)
    %void createDBM (list<dc_t*>*g, DBM& dbm,map<string,int> cindex) {
    dbm = DBM(size(cindex));
    for it =1:length(dc_t_list)
        comp = dc_t_list{it}.op;
        x = cindex((dc_t_list{it}.clockX);
        y = cindex(dc_t_list{it}.clockY);
        bound = dc_t_list{it}.bound;
        if strcmp(comp,'lt')
            dbm = constrain(x,y,createBound(bound,true),dbm);
        elseif strcmp(comp,'leq')
            dbm = constrain (x,y,createBound(bound,false),dbm);
        else 
            dbm = constrain(x,y,createBound(bound,false),dbm);
            dbm = constrain(y,x,createBound(-1*bound,false),dbm);
        end
    end
    dbm.close ();
end