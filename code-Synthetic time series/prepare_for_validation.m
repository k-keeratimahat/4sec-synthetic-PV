% additional step to calculate variabilty and merge daily file into a year
% for validation of the results.

pnum  = [295]; % plant to be modelled
yearnum = [2016]; % year of modelled data
vers = 'v13'; %for directory
mPlant = 309; % reference plant/ reference training data
myear = 2017; %year of the measured reference plant
load('BIN_INDEX')
%%
for p = 1:length(pnum)
    
iPlant = pnum(p);
year = yearnum(p);

foldername = ['Model_' num2str(year) '_' num2str(iPlant) '_' num2str(mPlant)];
mkdir(foldername) %create directory
%%  hourly_model_diff

filename1= ['F:\Variability Modelling - ' vers '\' foldername '\' 'Hourly_model_' num2str(year) '_' num2str(iPlant) '_' num2str(mPlant) '.mat'];
mat1 = matfile(filename1);
a1 = who(mat1);
load(filename1)

filename2 = ['Hourly_input_adjust_' num2str(year) '_' num2str(iPlant) '.mat'];
mat2 = matfile(filename2);
a2 = who(mat2);
load(filename2)

for i = 1:length(a1)
    data_array = eval(a1{i});
    input_array = eval(a2{i});

    T1 = data_array(:,[1 2 7 8 13 14]);
    %HourNumber, TimeStamp, ClearNumGHI,ClearNumDNI, ClearskyIdxOutput,
    %Modelled Output
    diff_array = cellfun(@diff, T1.ModelledOutput,'UniformOutput',0);
    diff_array_cs = cellfun(@diff,input_array.ClearSkyOutputAdj, 'UniformOutput',0);
    
    OutputDiff = diff_array;
    VarIndex = cellfun(@(x,y) sum(sqrt(x.^2 + (4/60)^2))/sum(sqrt(y.^2 + (4/60)^2)),diff_array,diff_array_cs);
    DiffSum = cellfun(@(x) sum(abs(x),'omitnan'),diff_array);
    DiffAvg = cellfun(@(x) mean(abs(x),'omitnan'),diff_array);
    DiffStd = cellfun(@(x) std(abs(x),'omitnan'),diff_array);
    T2 = table(OutputDiff,VarIndex, DiffSum, DiffAvg, DiffStd);
    
   T3 = [T1 T2];

    b = sscanf(a1{i},'Hourly_model_%d_%d_%d');
    parname_save = ['Hourly_model_diff_' num2str(b(1)) '_' num2str(b(2)) '_' num2str(b(3))];
    assignin('base',parname_save,T3)
   
end
clear(a1{:},a2{:}) 

filename_save = ['F:\Variability Modelling - ' vers '\' foldername '\' 'Hourly_model_diff_' num2str(year) '_' num2str(iPlant) '_' num2str(mPlant) '.mat'];
a3 = who('Hourly_model_diff_*');
save(filename_save,a3{:})

clear(a3{:})
%% merge_hourly_result
filename1 = ['F:\Variability Modelling - ' vers '\' foldername '\' 'Hourly_model_' num2str(year) '_' num2str(iPlant) '_' num2str(mPlant) '.mat'];
filename2 = ['Hourly_input_adjust_' num2str(year) '_' num2str(iPlant) '.mat'];

mat1 = matfile(filename1); mat2 = matfile(filename2);
a1 = who(mat1); a2 = who(mat2);

load(filename1,a1{1}); load(filename2,a2{1});
model_array = eval(a1{1}); input_array = eval(a2{1});

T1_col = [2 11 12 15:17]; D1_col = [2 7:9];
T1 = model_array(:,T1_col); D1 = input_array(:,D1_col);

%T1 = TimeStamp, ClearNumGHI, ClearNumDNI, OutputSum, OutputAvg, OutputStd.
%D1 = TimeStamp, DataSum,DataAvg,DataStd.
clear(a1{1},a2{1})

for i = 2:length(a1)
    i
    load(filename1,a1{i}); load(filename2,a2{i});
model_array = eval(a1{i}); input_array = eval(a2{i});
T1 = [T1; model_array(:,T1_col)];
D1 =  [D1; input_array(:,D1_col)];
clear(a1{i},a2{i})

end

 filename_save = ['F:\Variability Modelling - ' vers '\' foldername '\' 'Model_result_' num2str(year) '_' num2str(iPlant) '_' num2str(mPlant) '.mat'];
    if ~exist(filename_save)
        save(filename_save,'D1','T1')
    else
        save(filename_save,'D1','T1','-append')
    end
    
%% merge variability

filename1 = ['F:\Variability Modelling - ' vers '\' foldername '\' 'Hourly_model_diff_' num2str(year) '_' num2str(iPlant) '_' num2str(mPlant) '.mat'];
filename2 = ['Hourly_input_diff_' num2str(year) '_' num2str(iPlant) '.mat'];

mat1 = matfile(filename1); mat2 = matfile(filename2);
a1 = who(mat1); a2 = who(mat2);

load(filename1,a1{1}); load(filename2,a2{1});
model_array = eval(a1{1}); input_array = eval(a2{1});

% T2_col = [2 3 4 8:11]; D2_col = [2 7:10];
T2_col = {'TimeStamp', 'ClearNumGHI','ClearNumDNI','VarIndex','DiffSum','DiffAvg','DiffStd'};
D2_col = {'TimeStamp', 'VarIndex','DiffSum','DiffAvg','DiffStd'};
T2 = model_array(:,T2_col); 
D2 = input_array(:,D2_col); %[2 8:10] [2 5:7]
% T2 = TimeStamp, ClearNumGHI,ClearNumDNI,VarIndex,DiffSum,DiffAvg,DiffStd
% D2 = TimeStamp, VarIndex,DiffSum,DiffAvg,DiffStd
clear(a1{1},a2{1})
for i = 2:length(a1)
    i
    load(filename2,a2{i});input_array = eval(a2{i});
    load(filename1,a1{i}); 
model_array = eval(a1{i}); 
    
T2 = [T2; model_array(:,T2_col)];
D2 =  [D2; input_array(:, D2_col)];
clear(a1{i},a2{i})
end

 filename_save = ['F:\Variability Modelling - ' vers '\' foldername '\' 'Model_result_' num2str(year) '_' num2str(iPlant) '_' num2str(mPlant) '.mat'];
        save(filename_save,'D2','T2','-append')
        clear('D2','T2')

%% stats
KSI_percent = KSI_4sec_diff(iPlant,year,mPlant,vers,foldername);

 [RMSE, NRMSE,MBD] = hourly_result_stat(D1,T1)
 
 filename_save = ['F:\Variability Modelling - ' vers '\' foldername '\' 'Stat_result_' num2str(year) '_' num2str(iPlant) '_' num2str(mPlant)];
 save(filename_save,'RMSE','NRMSE','MBD','KSI_percent')
 
 clear('D1','T1')
end