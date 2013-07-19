function [edge] = edge(r,dc_t_list,location,id,cindex_map)
%UNTITLED15 Summary of this function goes here
%   Detailed explanation goes here
%const string& r, list<dc_t*>*g  , Location* n,string i, map<string, int> cindex)
  edge.nextLocation = location;
  edge.constraints = dc_t_list;
  edge.id = id;
  createDBM (constraints,dbm, cindex_map);
  edge.isLoop = false;
  edge.resetVector = convert(r, cindex_map);

  
  function buf = convert(s,index)
      %const string& s, map<string,int> index
        vector<int> buf;
        istringstream str(s);
        string buffer;
        while (std::getline(str, buffer, ','))
            %cout << "Converting: " << "," << buffer << "," <<endl;
            if (buffer~= '')
                buf.push_back (index[buffer]);
            end
        end
        return buf;
  end
  
    function createDBM(dc_t_list,dbm,cindex)
        %void createDBM (list<dc_t*>*g, DBM& dbm,map<string,int> cindex) {
        dbm = DBM(size(cindex));
        for it =1:length(dc_t_list)
            comp = dc_t_list{it}.op;
            x = cindex((dc_t_list{it}.clockX];
            y = cindex(dc_t_list{it}.clockY);
            bound = dc_t_list{it}.bound;
            if strcmp(comp,'lt')
                dbm.constrain(x,y,Bound(mpq_class(bound),true));
            elseif strcmp(comp,'leq')
                dbm.constrain (x,y,Bound (mpq_class(bound),false));
            else 
                dbm.constrain(x,y,Bound (mpq_class(bound),false));
                dbm.constrain(y,x,Bound (mpq_class(-1*bound),false));
            end
        end
        dbm.close ();
    end
%{

#include <list>
#include "symbTrace/DCConstraint.hpp"


#include "rationalDBM/dbm.hpp"
using std::map;
using std::string;
using std::list;
using namespace newdbm;


namespace LTA {
  class Location;
  class Edge {
  private:
    string reset;
    list<dc_t*>* constraints;
    vector<int> resetVector;
    DBM dbm;
    Location* nextLocation;
    string id;
    bool isLoop;
    Location* prev;
  public:
    Edge (const string&, list<dc_t*>* , Location*,string, map<string,int>);
    Edge (const string&,  list<dc_t*>* ,string, map<string,int>);
    ~Edge ();

    void setLoop ();
    void setNextLocation (Location*);
    Location* getNextLocation ();
    const Location* getNextLocation () const;
    const string& getReset () const ;

    const vector<int>& getResetVector() const;

    const list<dc_t*>* getGuard () const ;
    string getGuardText () const;
    string getId () const ;
    const DBM& getDBM () const ;
    void setPrev(Location*);
    Location* getPrev ();
    bool isLoopTrans ();
  };

}
%}

