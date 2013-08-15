function [concretization] =  BackwardsExploration(trace)
%BackwardsExploration is Algorithm 3 in Concrete delays for Symbolic Traces (page 56)
 
n = length(trace);
[inconsistent vPrime(n)] = FindPoint(trace.D(n));
 
 if inconsistent
    concretization = 0;
    disp('trace is not consistent');
    return
 end
 
 %vn=FINDPOINT(pretime(Dn ? (Dn?1 ? gn?1)rn?1=0, {vn? }) ) ;
 
 input1 = intersection(trace.D(n),intersection(trace.D(n-1),trace.g(n-1)));
 pTime = pretime(input1, vPrime(n));
 [inconsistent v(n)] = FindPoint(pTime);
 if inconsistent
    concretization = 0;
    disp('pTime is not consistent');
    return
 end 
 
 d(n) = vPrime(n)-v(n);
 %Set dn such that vn? =vn +dn;
 
 
 for  i = n-1:-1:2
    %vi? =FINDPOINT(preaction(Di,gi,ri,{vi+1}));
    pAction = preaction(trace.D(i),trace.g(i),trace.r(i),v(i+1));
    vPrime(i) = FindPoint(pAction); 
    %vi=FINDPOINT(pretime(Di ? (Di?1 ? gi?1)ri?1=0, {vi?}) ) ;
    prTime = pretime(intersection(trace.D(i),intersection(trace.D(i-1),trace.g(i-1))),vPrime(i));
    v(i) = FindPoint(prTime); 
    %Set di such that vi+di =vi?;
    d(i) = v(i)-vPrime(i);
 end
 %v1? = FINDPOINT(preaction(D1, g1, r1, {v2})) ;
 prAction = preaction(trace.D(1),trace.g(1),trace.r(1),v(2));
 vPrime(1) = FindPoint(prAction);
 
 %v1 = FINDPOINT(pretime(D1, {v1? })) ;
 preTime = pretime(trace.D(1),vPrime(1));
 v(1) = FindPoint(preTime);

 %Set d1 such that v1?=v1+d1;
 d(1) = vPrime(1)-v(1);
 
 concretization.l = trace.l;
 concretization.v = v;
 concretization.d = d;
end

%{
Input:A post-stable symbolic trace ?=?l1,D1? ? ...
 ?? g1 ,r1 gn?1 ,rn?1 ? ?ln,Dn?
Output: A concretization of ?
1 vn? = FINDPOINT(Dn);
2 vn=FINDPOINT(pretime(Dn ? (Dn?1 ? gn?1)rn?1=0, {vn? }) ) ;
3 Setdn suchthatvn? =vn +dn;
4 fori=n?1to2do
5 vi? =FINDPOINT(preaction(Di,gi,ri,{vi+1}));
6 vi=FINDPOINT(pretime(Di ? (Di?1 ? gi?1)ri?1=0, {vi?}) ) ;
7 Setdi suchthatvi +di =vi?;
8 end
9 v1? = FINDPOINT(preaction(D1, g1, r1, {v2})) ;
10 v1 = FINDPOINT(pretime(D1, {v1? })) ;
11 Setd1 suchthatv1? =v1 +d1;
12 return (l1, v1, d1), . . . , (ln, vn, dn)
%}
%{
Terminology
l is the name of the state (or location) of the timed automata.
v is the valuation of the clock (i.e.v(A_timer) = 500, v(V_timer) = 200)
d is the delay in clock time between each state
r is the reset i.e. y(r=0) means to reset y
g is difference constraints (i.e. x >=2)

r=0 is a reset operator that resets each valuation by r
    (v+d)(x) = v(x) + d if x~=0, v(x) if x = 0
    v(r=0)(x) = 0 if x is an element of r, v(x)  if x is not an element of
    r
%}
function v = pretime(Pi1,Pi2)
   
%pretime(?,?') = {v|v?? and there exists d?R?0 such that (v+d)??'}
end

function v = preaction(Pi1,g,r,Pi2)

%preaction(?,g,r,?') = {v|v?? s.t. v = g and v(r=0)??'}
end
%{
? is the set of valuations over C
%}

function d = intersection(d1,d2)
    d = d1.*(d1==d2);
end