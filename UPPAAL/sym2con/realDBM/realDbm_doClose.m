function [theDBM] = realDbm_doClose(theDBM)
%UNTITLED16 Summary of this function goes here
%   Detailed explanation goes here
%Foyd_Warshall shortest path algorithm
%void DBM::doClose () {
  int i;
  int j;
  int k;
  %Bound 
  zeroB = realBound(0,false);
  numVars = theDBM.numVars;
  for k =0:numVars
    for i =0:numVars
       for j = 0:numVars
            if i~= j
                %Bound
                orig = theDBM(i,j);
                %Bound 
                sum =  theDBM(i,k) + theDBM(k,j);
                if (sum < orig) 
                    theDBM(i,j) = sum;
                end
            end
       end
    end
  end
end

