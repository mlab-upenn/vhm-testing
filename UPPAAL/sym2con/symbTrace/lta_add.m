function [lta] = lta_add(e,n,lta)
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here
  e->setNextLocation (n);
  e->setPrev (curLocation);
  if (e->isLoopTrans())
    n->setBackLoop (e);
  else 
    n->setBack (e);
  curLocation->setEdge (e);
  curLocation = n;
  numOfLocations++;



end

