close all;
clear;
clc;
load Medtronic_tests/medtronic_tests_1-75.mat
load edge_cov.mat
load pm_New_George.mat
load initializer.mat

index = [1:29, 31:34, 36:39, 40:43, 45:75]; %45:75; %[9,15,20,22,23,25,27,31,33,34,37,38,40,41,43];% %, 45:75]; 
files = cell(length(index),1);
for i = 1:length(index)
    number = index(i);
    fileName = strcat('test_File_', num2str(number));
    file = eval(fileName);
    pace_test = pace_param;
   % files{i} = file;
   switch number
        case {34, 51}
            pace_test.PVVRP = 300;
        case {40}
            pace_test.TURI = 750;
        case {50, 56}
            pace_test.PAARP = 150;
            pace_test.TAVI = 150;
        case {53}
            pace_test.PAARP = 300;
            pace_test.TAVI = 300;
        case {54, 55}
            pace_test.TURI = 500;
            pace_test.PAARP = 80;
            pace_test.TAVI = 80;
            pace_test.VSP_thresh = 80;
            pace_test.TLRI = 600;
        case {57, 58, 59, 61, 62, 64, 65, 66, 67, 70}
            pace_test.TAVI = 200;
            pace_test.PAARP = 200;
        case {60, 63}
            pace_test.TAVI = 150;
            pace_test.PAARP = 150;
            pace_test.TURI = 666;
        case {68, 72}
            pace_test.TAVI = 120;
            pace_test.PAARP = 120;
            pace_test.TURI = 666;
        case {69}
            pace_test.TAVI = 120;
            pace_test.PAARP = 120;
            pace_test.TURI = 545;
        case {71}
            pace_test.TAVI = 200;
            pace_test.PAARP = 200;
            pace_test.TURI = 500; 
        case {73}
            pace_test.TAVI = 200;
            pace_test.PAARP = 200;
            pace_test.TURI = 750;
        case {74, 75}
            pace_test.TAVI = 200;
            pace_test.PAARP = 200;
            pace_test.PVARP = 500;
            pace_test.PVARP_def = 500;
            pace_test.PVVRP = 500;
            pace_test.TURI = 750;   
    end
    disp(num2str(index(i)));
    pacemaker_tester(file,initializer,pace_test,'tolerances',[5,5],'plot','signals','seePaceSense',1,'allowOffset', 1)
end

%pace_test = pace_param;
%pacemaker_tester(test_File_9,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_9_results.txt')
%pacemaker_tester(test_File_15,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_15_results.txt')
%pacemaker_tester(test_File_20,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'output','test_File_20_results.txt')
%pacemaker_tester(test_File_22,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_22_results.txt')
%pacemaker_tester(test_File_23,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1, 'output','test_File_23_results.txt')
%pacemaker_tester(test_File_25,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_25_results.txt')
%pacemaker_tester(test_File_27,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_27_results.txt')
%pacemaker_tester(test_File_31,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_31_results.txt')
%pacemaker_tester(test_File_33,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_33_results.txt')
%{
pace_test = pace_param;
pace_test.PVVRP = 300;
pacemaker_tester(test_File_34,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_34_results.txt')
%}
%{
pace_test = pace_param;
pacemaker_tester(test_File_37,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_37_results.txt')
pacemaker_tester(test_File_38,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_38_results.txt')
%}
%{
pace_test.TURI = 750;
pacemaker_tester(test_File_40,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_40_results.txt')
%}
%{
pace_test = pace_param;
pacemaker_tester(test_File_41,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_41_results.txt')
pacemaker_tester(test_File_43,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_43_results.txt')
pacemaker_tester(test_File_45,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_45_results.txt')
%}
%{
pace_test = pace_param;
pace_test.PAARP = 150;
pace_test.TAVI = 150;
pacemaker_tester(test_File_50,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_50_results.txt')
%}
%{
pace_test = pace_param;
pace_test.PVVRP = 300;
pacemaker_tester(test_File_51,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_51_results.txt')
%}
%{
pace_test.PAARP = 300;
pace_test.TAVI = 300;
pacemaker_tester(test_File_53,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_53_results.txt')
%}
%{
pace_test = pace_param;
pace_test.TURI = 500;
pace_test.PAARP = 80;
pace_test.TAVI = 80;
pace_test.VSP_thresh = 80;
pace_test.TLRI = 600;
pacemaker_tester(test_File_54,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_54_results.txt')
pacemaker_tester(test_File_55,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_55_results.txt')
%}
%{
pace_test = pace_param;
pace_test.PAARP = 150;
pace_test.TAVI = 150;
pacemaker_tester(test_File_56,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_56_results.txt')
%}
%{
pace_test = pace_param;
pace_test.TAVI = 200;
pace_test.PAARP = 200;
pacemaker_tester(test_File_57,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_57_results.txt')
%pacemaker_tester(test_File_58,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_58_results.txt')
%}
%{
pace_test = pace_param;
pace_test.TAVI = 150;
pace_test.PAARP = 150;
pace_test.TURI = 666;
pacemaker_tester(test_File_60,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_60_results.txt')
%}
%{
pace_test = pace_param;
pace_test.TAVI = 200;
pace_test.PAARP = 200;
pacemaker_tester(test_File_61,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_61_results.txt')
%}
%{
pace_test = pace_param;
pace_test.TAVI = 150;
pace_test.PAARP = 150;
pace_test.TURI = 666;
pacemaker_tester(test_File_63,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_63_results.txt')
%}
%{
pace_test = pace_param;
pace_test.TAVI = 200;
pace_test.PAARP = 200;
pacemaker_tester(test_File_64,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_64_results.txt')
pacemaker_tester(test_File_65,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_65_results.txt')
pacemaker_tester(test_File_66,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_66_results.txt')
pacemaker_tester(test_File_67,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_67_results.txt')
%}
%{
pace_test = pace_param;
pace_test.TAVI = 120;
pace_test.PAARP = 120;
pace_test.TURI = 666;
pacemaker_tester(test_File_68,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_68_results.txt')
%}
%{
pace_test = pace_param;
pace_test.TAVI = 120;
pace_test.PAARP = 120;
pace_test.TURI = 545;
pacemaker_tester(test_File_69,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_69_results.txt')
%}
%{
pace_test = pace_param;
pace_test.TAVI = 200;
pace_test.PAARP = 200;
pace_test.TURI = 500; 
pacemaker_tester(test_File_71,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_71_results.txt')            
%}
%{
pace_test = pace_param;
pace_test.TAVI = 120;
pace_test.PAARP = 120;
pace_test.TURI = 666;
pacemaker_tester(test_File_72,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_72_results.txt')
%}
%{
pace_test = pace_param;
pace_test.TAVI = 200;
pace_test.PAARP = 200;
pace_test.TURI = 750;
pacemaker_tester(test_File_73,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_73_results.txt')
%}
%{
pace_test = pace_param;
pace_test.TAVI = 200;
pace_test.PAARP = 200;
pace_test.PVARP = 500;
pace_test.PVARP_def = 500;
pace_test.PVVRP = 500;
pace_test.TURI = 750; 
pacemaker_tester(test_File_74,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_74_results.txt')
pacemaker_tester(test_File_75,initializer,pace_test,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_75_results.txt')
%}
%{
pace_param.TURI = 750;
pacemaker_tester(test_File_40,initializer,pace_param,'plot','signals','tolerances',[5,5],'allowOffset', 1,'seePaceSense',1,'output','test_File_40_results.txt')
%}
%Tests that have issues:
%9,15,20,22,23,25,27,31,33,34,37,38,40,
%41,43,45,50,51,53,54,55,56,57,58,60,61,63,64,65,66,67,68,69,72,73,74,75