% bin variability of clear sky PV output index according to hourly
% irradiance data
iPlant = 299;
year = 2017;
cap = 56; % plant AC capacity
% both adjusted clear sky
load('BIN_INDEX')
parname1 = ['Year_SAT_' num2str(year) '_' num2str(iPlant)]; %hourly irradiance data with calculated bin numbers
filename1 = ['F:\Variability Modelling - v9\' parname1];
load(filename1,parname1)
SAT_data = eval(parname1);

filename2 = ['F:\Variability Modelling - v6\' 'Hourly_fitresult_adjust_' num2str(iPlant)]; %4 seconds training data
matObj = matfile([filename2 '.mat']);

TimeStamp = SAT_data.TimeStamp;
ClearIdxGHI = SAT_data.ClearSkyIdxGHI_Adj;
ClearIdxDNI = SAT_data.ClearSkyIdxDNI_Adj;
GHI = SAT_data.GHI;
DNI = SAT_data.DNI;

T1 = TimeStamp;
T1.Hour = 0; T1.Minute = 0; T1.Second = 0;
T2 = unique(T1);

ClearNumGHI = SAT_data.ClearNumGHI_Adj;
ClearNumDNI = SAT_data.ClearNumDNI_Adj;

for i = 1:length(BIN_INDEX)
    i
    row_idx = ClearNumGHI == BIN_INDEX(i,1) & ClearNumDNI == BIN_INDEX(i,2);
    if sum(row_idx) == 0
        continue
    else
        TimeStamp1 = TimeStamp(row_idx);
        day_of_year = day(TimeStamp1,'dayofyear');
        T3 = TimeStamp1;
        T3.Hour = 0;
        T3.Minute = 0;
        T3.Second = 0;
        T4 = unique(T3);

        day_number = unique(day_of_year);
        
        ClearIdxGHI1 = ClearIdxGHI(row_idx);
        ClearIdxDNI1 = ClearIdxDNI(row_idx);
        GHI1 = GHI(row_idx);
        DNI1 = DNI(row_idx);
    end
    
    struct_array = table(day_of_year,TimeStamp1,ClearIdxGHI1,ClearIdxDNI1,GHI1,DNI1,'VariableNames',...
                    {'DayNumber','TimeStamp','ClearSkyIdxGHI','ClearSkyIdxDNI','GHI','DNI'});
                
    cell_array = cell([length(TimeStamp1) 1]);
    cell_array2 = cell([length(TimeStamp1) 1]);
    t = 0;
    for j = 1:length(day_number)
        a = who(matObj,['*_' num2str(day_number(j))]);
        load(filename2,a{:})
    fit_data = eval(a{:});
    
        h1 = TimeStamp1(TimeStamp1.Month == T4(j).Month & TimeStamp1.Day == T4(j).Day);
        h2 = h1.Hour;
        h3 = fit_data.HourNumber;
        h4 = find(ismember(h3,h2));
        
        for s = 1:length(h2)
            t = t+1;
            if ismember(h2(s),h3)
                s1 = find(h3 == h2(s));
                if prctile(fit_data.Data{s1},50)>= cap
                    cell_array2{t,1} = fit_data.ClearSkyOutputIdxAdj{s1};
                else
                cell_array{t,1} = fit_data.ClearSkyOutputIdxAdj{s1};
                end
            else
                cell_array{t,1}= [];
            end
        end
        
     end
     
    TABLE1 = table(cell_array,'VariableNames',{'ClearSkyIdxOutput'});
    TABLE2 = table(cell_array2,'VariableNames',{'ClearSkyIdxCurtailed'});
    table_array = [struct_array TABLE1 TABLE2];
    b = cellfun(@isempty,cell_array);
    b2 = cellfun(@isempty,cell_array2);
    b3 = b & b2;
    table_array(b3,:) = [];
    
    if isempty(table_array)
        clear('struct_array')
        clear('Hourly_fit*')
        clear('cell_array')
        clear('cell_array2')
    else
    parname_save1 = ['bin_clearsky_index_' num2str(i) '_' num2str(BIN_INDEX(i,1)) '_' num2str(BIN_INDEX(i,2))];
    assignin('base',parname_save1,table_array);
    clear('struct_array')
    clear('Hourly_fit*')
    clear('cell_array')
    
    filesave1 = ['F:\Variability Modelling - v9\' 'bin_clearsky_index_' num2str(year) '_' num2str(iPlant) '.mat'];
    if exist(filesave1)
        save(filesave1,parname_save1,'-append')
    else
        save(filesave1,parname_save1)
    end
    clear('bin_clearsky*')
    end
    
end

%% Looking for days with problems (e.g. operational problems)
filename1 = 'bin_clearsky_index_2016_277.mat';
load(filename1)
load('BIN_INDEX')
filename_save = 'FlagDayNumber_2016_277';
bin_exist = BIN_INDEX_exist_277;

for i = 1:length(bin_exist)
    i
    a = who(['*index_' num2str(bin_exist(i)) '_*']);
data_array = eval(a{:});
ClearSkyIdxOutput = data_array.ClearSkyIdxOutput;
b = cellfun(@max, ClearSkyIdxOutput,'UniformOutput',false);
b2 = cellfun(@isempty, data_array.ClearSkyIdxCurtailed,'UniformOutput',false);
thre = (round(mean(BIN_INDEX(bin_exist(i),:))) - 1)*0.1 - 0.2;
b1 = unique(data_array.DayNumber(vertcat(b{:}) < thre & vertcat(b2{:})));
if isempty(b1)
    continue
else
    
parname_save = ['FlagDayNumber_' num2str(bin_exist(i))];
assignin('base',parname_save,b1)
if exist(filename_save)
        save(filename_save,parname_save,'-append')
    else
        save(filename_save,parname_save)
    end
end
end

%% find common day numbers with problems
filename1 = 'FlagDayNumber_2017_299.mat';
matObj = matfile(filename1);
a = who(matObj);
load(filename1)
FlagDay = eval(a{1});

for i = 2:length(a)
    FlagDay2 = eval(a{i});
    FlagDay = [FlagDay; FlagDay2];
end

FlagDayNumber = unique(FlagDay);

%% exclude days with problem
load('FlagDayNumber_2017_299','FlagDayNumber')
% load('BIN_INDEX')

filename1 = ['F:\Variability Modelling - v9\' 'bin_clearsky_index_2017_299_1.mat'];
load(filename1)

bin_exist = BIN_INDEX_exist_299;
for i = 1:length(bin_exist)
    i
    a = who(['*index_' num2str(bin_exist(i)) '_*']);
data_array = eval(a{:});
row_idx = ismember(data_array.DayNumber,FlagDayNumber);
data_array(row_idx,:) = [];
if isempty(data_array)
    continue
else
assignin('base',a{:},data_array)
filename_save = ['F:\Variability Modelling - v9\' 'bin_clearsky_index_2017_299.mat'];
if exist(filename_save)
        save(filename_save,a{:},'-append')
    else
        save(filename_save,a{:})
end
end
end

%%
% assing the clear sky index bin that has intervals less than 10 to another
% bin.
iPlant1 = 299;
year1 = 2017;
filename1 = ['F:\Variability Modelling - v9\bin_clearsky_index_' num2str(year1) '_' num2str(iPlant1) '_2'];
load('BIN_INDEX_v1',['BIN_INDEX_exist_' num2str(iPlant1)],'BIN_INDEX')
load(filename1)
bin_index1 = eval(['BIN_INDEX_exist_' num2str(iPlant1)]);
b1 = BIN_INDEX(bin_index1,:);
ncell = cell([40,2]);
nrows = NaN([40,2]);
T1 = [cell2table(ncell),array2table(nrows)];
i = 0;
for j = 1:length(b1(:,1))
    j
numGHI = b1(j,1); numDNI = b1(j,2);

parname1 = ['bin_clearsky_index_' num2str(bin_index1(j)) '_' num2str(numGHI) '_' num2str(numDNI)];

data_array = eval(parname1);

if height(data_array) >= 10
    continue
else
    c = sscanf(parname1,'bin_clearsky_index_%d_%d_%d');
            Bg = numGHI;
            Bd = numDNI;
            t = 0;
            a2 = [];
            while isempty(a2)
                t = t+1;
                Bg1 = Bg+t;
                a2 = who(['bin_clearsky_*_' num2str(Bg1) '_'  num2str(Bd)]);
                if isempty(a2)
                    Bg1 = Bg-t;
                a2 = who(['bin_clearsky_*_' num2str(Bg1) '_'  num2str(Bd)]);
                end
                    if isempty(a2)
                       Bd1 = Bd+t;
                a2 = who(['bin_clearsky_*_' num2str(Bg) '_'  num2str(Bd1)]);
                    end
                    if isempty(a2)
                           Bd1 = Bd-t;
                    a2 = who(['bin_clearsky_*_' num2str(Bg) '_'  num2str(Bd1)]);
                    end
                    if isempty(a2)
                        Bg1 = Bg+t;
                         Bd1 = Bd+t;
                         a2 = who(['bin_clearsky_*_' num2str(Bg1) '_'  num2str(Bd1)]);
                    end
                     if isempty(a2)
                        Bg1 = Bg-t;
                         Bd1 = Bd-t;
                         a2 = who(['bin_clearsky_*_' num2str(Bg1) '_'  num2str(Bd1)]);
                     end
                     if ~isempty(a2)
                     break
                     end  
            end
            i = i+1;
            ref_array = eval(a2{:});
            new_array = [ref_array;data_array];
            T1.ncell1{i} = parname1;
            T1.ncell2{i} = a2{:};
            T1.nrows1(i) = height(new_array);
            T1.nrows2(i) = c(1);
            clear(parname1)
end
T1(isnan(T1.nrows1),:) = [];
end

bin_index2 = bin_index1(~ismember(bin_index1,T1.nrows2));
clear(['BIN_INDEX_exist_' num2str(iPlant1)])
assignin('base',['BIN_INDEX_exist_' num2str(iPlant1)],bin_index2);
save('BIN_INDEX',['BIN_INDEX_exist_' num2str(iPlant1)],'-append')