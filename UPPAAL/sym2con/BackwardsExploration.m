function [concretization] =  BackwardsExploration(trace)
%BackwardsExploration is Algorithm 3 in Concrete delays for Symbolic Traces (page 56)
 
n = length(trace);
[inconsistent vPrime(n)] = FindPoint(trace.D(n));
 
 if inconsistent
    concretization = 0;
    disp('trace is not consistent');
    return
 end
 
 
 v(n) = FindPoint();
 
 
 for  i = n:2
    vPrime(i) = FindPoint(); %vi? =FINDPOINT(preaction(Di,gi,ri,{vi+1}));
    v(i) = FindPoint(); %vi=FINDPOINT(pretime(Di ? (Di?1 ? gi?1)ri?1=0, {vi?}) ) ;
    %Set di such that vi+di =vi?;
 end
 %v1? = FINDPOINT(preaction(D1, g1, r1, {v2})) ;
 %v1 = FINDPOINT(pretime(D1, {v1? })) ;
 %Set d1 such that v1?=v1+d1;
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
l is the name of the state of the timed automata
v is the valuation of the clock (i.e.v(A_timer) = 500, v(V_timer) = 200)
d is the delay
r is the reset
g is difference constraints

r=0 is a reset operator that resets each valuation by r
    (v+d)(x) = v(x) + d if x~=0, v(x) if x = 0
    v(r=0)(x) = 0 if x is an element of r, v(x)  if x is not an element of
    r
%}
function v = pretime(Pi1,Pi2)
   
%pretime(?,?') = {v|v?? and there exists d?R?0 such that (v+d)??'}
end

function preaction(Pi1,g,r,Pi2)

%preaction(?,g,r,?') = {v|v?? s.t. v = g and v(r=0)??'}
end
%{
? is the set of valuations over C


%}