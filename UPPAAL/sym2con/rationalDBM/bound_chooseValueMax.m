function [mpq_class] = bound_chooseValueMax(upper,lower,epsilon)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%mpq_class Bound::chooseValueMax (const Bound& upper, const Bound& lower, const mpq_class& epsilon) {
    if (upper.unbound)
        disp('chooseValueMax was called with an upper infinity bound. THis should not happen...')
        disp('uses chooseValueMin instead');
        mpq_class = bound_chooseValueMin (upper,lower,epsilon);
    elseif (upper.strict)
      %cerr << "chose " <<  upper.getBound ()-epsilon << endl;
      mpq_class = upper.bound - epsilon;
      return 
    else 
      %cerr << "chose " <<  upper.getBound () << endl;
      mpq_class = upper.bound;
      return
    end
end

