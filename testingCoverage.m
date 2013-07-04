close all;
clear;
clc;
load Medtronic_tests/medtronic_test_1-75.mat
load edge_cov.mat
load PM_new.mat
load initializer.mat

index = [1:29, 31:34, 36:39, 40:43];%, 45:75]; 
files = cell(length(index),1);
for i = 1:length(index)
    number = index(i);
    fileName = strcat('test_File_', num2str(number));
    file = eval(fileName);
    files{i} = file;
end

pacemaker_tester(files,initializer,pace_param,'plot','signals','tolerances',[5,5],'allowOffset', 1)