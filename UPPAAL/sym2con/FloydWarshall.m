function [shortDbm] = FloydWarshall(dbm)
%FloydWarshall is the all-pairs shortest path algorithm presented in
%Algorithm 1 of the the Concrete Traces for Symbolic traces. (See pg 24)
%   dbm is a difference bound matrix.

shortDbm = dbm;
n = size(dbm,1);

for k = 1:n
    for i = 1:n
        for j = 1:n
            shortDbm(i,j) = min(shortDbm(i,k) + shortDbm(k,j),shortDbm(i,j));
        end
    end
end

end

