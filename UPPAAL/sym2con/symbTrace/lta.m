function [lta] = lta(location,clock_cell)
%lta creates an lta struct
%   Detailed explanation goes here
    lta.firstLocation = location;
    lta.curLocation = location;
    lta.numOfLocations =1;
    lta.clocks = clock_cell;

end

%{
 class LtaIterator {
  private:
    const Location* cur;
  public:
    LtaIterator (Location*);
    bool move();
    const Location* getLocation ();
    const Edge* getEdge ();
    bool hasSomething ();
  };

  class Lta {
  private:
    Location* firstLocation;
    Location* curLocation;
    Location* loopStartLocation;
    unsigned numOfLocations;
    vector<string>* clocks;
  public:
    Lta (Location*,vector<string>*);
    ~Lta ();
    void add (Edge*, Location*);
    void setLoopStartLocation(Location* loc) { loopStartLocation = loc; }
    unsigned int getNumberOfLocations ();
    unsigned int getNumberOfClocks ();
    vector<string>* getClockNames ();
    LtaIterator* getIterator ();
    LtaIterator* getLoopIterator();
    Location* getFirst () {return firstLocation;}
    void makeBackLinks ();
  };
%}