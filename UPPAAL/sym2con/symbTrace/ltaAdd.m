function [lta] = ltaAdd(lta,edge,location)
%UNTITLED14 Summary of this function goes here
%   Detailed explanation goes here
  edge.setNextLocation(location);
  edge.setPrev(lta.curLocation);
  if edge.isLoopTrans()
    location.setBackLoop(edge);
  else 
    location.setBack(edge);
  lta.curLocation.setEdge(edge);
  lta.curLocation = location;
  lta.numOfLocations = lta.numOfLocations + 1;

end

