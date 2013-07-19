function [dbm_t] = CreateEntryTimeConstraints()
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here
{
  clock_t start;
  if (doTime)
    start = clock ();
  //Create and initiliaze the dbm
  int dim = lta->getNumberOfLocations();
  entryTimeDBM = dbm_t(dim);
  raw_t* rawdbm= entryTimeDBM.getDBM ();
  dbm_init (rawdbm,dim);

  LtaIterator *ltaIterator = lta->getIterator();

  cindex_t n = lta->getNumberOfLocations();
  const list<dc_t*> *invariant, *guard;
  const Location* loc;

  for (cindex_t i=0; i<n; i++)
    {
      loc = ltaIterator->getLocation();
      invariant = loc->getInvariant();
      CreateConstraint(rawdbm, dim, invariant, i, false);
      ltaIterator->move();
    }

  ltaIterator = lta->getIterator();
  for (cindex_t i=0; i<n-1; i++)
    {
      loc = ltaIterator->getLocation();
      DBM(i, i+1) = dbm_bound2raw(0, dbm_WEAK);

      guard = loc->getEdge()->getGuard();
      CreateConstraint(rawdbm, dim, guard, i, true);

      invariant = loc->getInvariant();
      CreateConstraint(rawdbm, dim, invariant, i, true);

      ltaIterator->move();
    }

  if (doTime) {
    keep.createConstraint = (double)(clock()-start)/CLOCKS_PER_SEC;
    start = clock ();
  }

    dbm_close (rawdbm,dim);
    if (doTime) {
       keep.closeDBM = (double)(clock()-start)/CLOCKS_PER_SEC;
    }
    delete ltaIterator;
    return entryTimeDBM;

end

