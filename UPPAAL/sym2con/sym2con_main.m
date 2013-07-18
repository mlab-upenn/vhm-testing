
int main(int argc, char** argv)
{

  if (argc == 1) {
    cout << "No arguments specified. Use -h to obtain a list of options" << endl;
    return 1;
  }

  Options* options = loadOptions (argc,argv);  
  bool ready = loadRoutine (options);   

  LTA::Lta* l = createLTA (options);    
  %{
                                         LTA::Lta* createLTA(Options* o) {
                                            XMLLoader loader (o->zeroRep); //after loadOption zeroRep = "sys.t(0)";
                                            LTA::Lta* lta = loader.generateLTA (o->modelpath,&doc,o->clockIndex);
                                            cout << "LTA created" << endl;
                                            return lta;
                                         }
                                         %}
  cout << "Trace loaded contains " << l->getNumberOfLocations() << " states." << endl;
  Result* res;
  if (ready && l!= 0)
    {
      res = solve_plug (l,options,cin,cout); 
                                %{
                                        solve_func
                                              
                                              %}
      cout.flush ();
      if (res->hasResult ())
	{

	  if (options->saveRes)
	    {
	      saveRes (l,res,options); /*
                                    void saveRes (LTA::Lta* lta,  Result* res,Options* options){
                                        if (doc!=0){
                                            map<string,xmlNodePtr> theMap;
                                            %parse through document to find all the transitions
                                            getTrans (theMap,xmlDocGetRootElement(doc));
                                                            %{
                                                            void getTrans ( map<string,xmlNodePtr>& theMap, xmlNodePtr  cur2) {
                                                                    xmlNodePtr cur = cur2->xmlChildrenNode;
                                                                    while (cur!=0) {
                                                                          if (!xmlStrcmp (cur->name, (const xmlChar*)"transition")) {
                                                                            xmlChar* from = xmlGetProp (cur,(const xmlChar*) "from");
                                                                            if (from != 0) {
                                                                                string strFrom ((const char*) from);
                                                                                theMap[strFrom] = cur;
                                                                            }
                                                                        }
                                                                        else {
                                                                            getTrans (theMap,cur);
                                                                        }
                                                                        cur = cur->next;
                                                                    }
                                                                }
                                                             %}                                                                        

                                            LTA::LtaIterator* iter = lta->getIterator ();
                                                            /*return new LTA::LtaIterator (firstLocation);;
                                    
                                            ostringstream ostream;
                                            if (!options->floating)
                                                res->outputAlternateSimp (ostream);
                                            else
                                                res->outputDoubleSimp (ostream);
                                            string str = ostream.str ();
                                            istringstream istr (str);
                                            if (iter->hasSomething ()) {
                                                do  {
                                                    string buf;
                                                    istr >> buf;
                                                    if (iter->getEdge() != 0)
                                                        xmlNewProp (theMap[iter->getEdge () ->getId ()],(xmlChar*)"delay",(xmlChar*)buf.c_str ());
                                                                        /*
                                    
                                                    } while (iter->move ());
                                            }
                                        }
                                        else {
                                            cout << "Doc is not set" << endl;
                                        }
                                        xmlSaveCtxtPtr ctxt = xmlSaveToFilename (options->saveResTo.c_str (),NULL, 1);
                                        xmlSaveDoc (ctxt,doc);
                                        xmlSaveClose (ctxt);
                                        //xmlFree (ctxt);
                                        }
                                    */
	    }
	  if (!options->quiet){
	    if (!options->floating)
	      {
		if (options->entry)
		  {
		    res->outputAlternateEntry (cout);

		  }
		else
		  {
		    res->outputAlternateDelay (cout);
		  }
	      }
	    else
	      {
		if (options->entry)
		  {
		    res->outputDoubleEntry (cout);
		  }
		else
		  {
		    res->outputDoubleDelay (cout);
		  }
	      }
	    if (options->time)
	      res->outputTiming (cout);
	  }
	}

      delete res;
    }
  if (l!=0)
     delete l;
  delete options;
  if (doc!=0)
    xmlFreeDoc (doc); //remove xml memory

  unloadRoutine ();

  return 0;
}
