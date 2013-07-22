function [edge] = edge(r,dc_t_list,location,id,cindex_map)
%UNTITLED15 Summary of this function goes here
%   Detailed explanation goes here
%const string& r, list<dc_t*>*g  , Location* n,string i, map<string, int> cindex)
  edge.nextLocation = location;
  edge.constraints = dc_t_list;
  edge.id = id;
  createDBM (constraints,dbm, cindex_map);
  edge.isLoop = false;
  edge.resetVector = edge_convert(r, cindex_map);

  
 
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

