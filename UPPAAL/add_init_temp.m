ttt=readUPPAAL('PM_new_edge.xml');
aaa=readUPPAAL('test_init.xml');
 ttt.template{1,end+1}=aaa.template{1,end};
  ttt.system.process(1,end+1)=aaa.system.process(1,end);
  ttt.declaration{21,2}{1,end+1}='INTR';
  ttt.declaration(end+1,:)={'int','seq',2};
  writeUPPAAL('ttt.xml',ttt);