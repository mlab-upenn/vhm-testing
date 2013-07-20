function [ mpq_class ] = bound_chooseValueBetween(upper,lower,epsilon)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

    %cerr << "CHoose value: " << upper << " -  " << lower << endl;
%(const Bound& upper, const Bound& lower, const mpq_class& epsilon)
    if upper.unbound && lower.unbound
        disp('Strange: chooseValueBetween was called with two infinity bounds...')
        disp('Returning zero')
        mpq_class = 0;
        return
    elseif upper.unbound
        mpq_class = bound_chooseValueMin(upper,lower,epsilon);
        return 
    elseif lower.unbound
        mpq_class = bound_chooseValueMax(upper,lower,epsilon);
        return 
    elseif ~lower.strict
      %cerr << "chose " << -1*lower.getBound () << endl << "lower";;
      mpq_class = -1*lower.bound;
      return
    elseif ~upper.strict
      %cerr << "chose " << lower.getBound ()<<endl<<"upper";
      mpq_class = upper.bound;
      return
    else 
      %cerr << "Choosing value between" << endl;
      mpq_class = (upper.bound - lower.bound)/2;
      return 
    end
end

