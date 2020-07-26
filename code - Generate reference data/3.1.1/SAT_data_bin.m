%% binning satellite data for plant that will be modelled

iPlant = 295; %plant index number
year = 2016; %year of data.

parname1 = ['Daily_Satellite_' num2str(year) '_' num2str(iPlant)];
filename1 = ['F:\Satellite Data\' parname1];
load(filename1,parname1)
SAT_data = eval(parname1);

for dd = 1:length(SAT_data)
    TimeStamp = SAT_data(dd).TimeStamp;
    GHI = SAT_data(dd).GHI;
    DNI = SAT_data(dd).DNI;
    ClearSkyIdxGHI = SAT_data(dd).ClearSkyIdxHourGHI;
    ClearSkyIdxDNI = SAT_data(dd).ClearSkyIdxHourDNI;
    
    ClearNumGHI = round(ClearSkyIdxGHI.*10)+1;
    ClearNumDNI = round(ClearSkyIdxDNI.*10)+1;
    ClearNumGHI(ClearNumGHI >11) = 11; ClearNumDNI(ClearNumDNI > 11) = 11;
    
    HourNumber = TimeStamp.Hour;
    T1 = table(HourNumber,TimeStamp,GHI,DNI,ClearSkyIdxGHI,ClearSkyIdxDNI,ClearNumGHI,ClearNumDNI);
    
    GHI_idx = find(GHI > 0);
    GHI_clearidx = ClearSkyIdxGHI(GHI_idx);
    GHImax = max(GHI_clearidx(3:end-2));
    if GHImax > 0.9
        ClearSkyIdxGHI_Adj = ClearSkyIdxGHI./GHImax ;
    else
        ClearSkyIdxGHI_Adj = ClearSkyIdxGHI;
    end
    
    DNI_idx = find(DNI > 0);
    DNI_clearidx = ClearSkyIdxDNI(DNI_idx);
    DNImax = max(DNI_clearidx(3:end-2));
    if DNImax > 0.9
        ClearSkyIdxDNI_Adj = ClearSkyIdxDNI./DNImax;
    else
        ClearSkyIdxDNI_Adj = ClearSkyIdxDNI;
    end
    ClearNumGHI_Adj = round(ClearSkyIdxGHI_Adj.*10)+1;
    ClearNumDNI_Adj = round(ClearSkyIdxDNI_Adj.*10)+1;
    ClearNumGHI_Adj(ClearNumGHI_Adj >11) = 11; ClearNumDNI_Adj(ClearNumDNI_Adj > 11) = 11;
    
    T2 = table(ClearSkyIdxGHI_Adj,ClearSkyIdxDNI_Adj,ClearNumGHI_Adj,ClearNumDNI_Adj);
    
    T3 = [T1 T2];
    
    mmonth = TimeStamp(5).Month;
    dday = TimeStamp(5).Day;
    
    
    if mmonth <= 9 
        mmn = ['0' num2str(mmonth)];
    else
        mmn = num2str(mmonth);
    end
    
    if dday <=9
        ddy = ['0' num2str(dday)];
    else
        ddy = num2str(dday);
    end
    
    parname_save = ['Hourly_SAT_' num2str(iPlant) '_' num2str(year) mmn ddy '_' num2str(dd)];
    assignin('base',parname_save,T3)
    filename_save = ['F:\Variability Modelling - v6\' 'Hourly_SAT_' num2str(year) '_' num2str(iPlant) '.mat'];
    
    if ~exist(filename_save)
        save(filename_save,parname_save)
    else
        save(filename_save,parname_save,'-append')
    end
    
      clear('T1',parname_save)
end

%% combine into year
iPlant = 299;
year = 2016;
filename1 = ['F:\Variability Modelling - v6\' 'Hourly_SAT_' num2str(year) '_' num2str(iPlant) '.mat'];
matobj = matfile(filename1);
a = who(matobj);
load(filename1);

dd = 1;
a1 = who(['*SAT_*_' num2str(dd)]);
T1 = eval(a1{:});

for i = 2:length(a)
    a1 = who(['*SAT_*_' num2str(i)]);
    T2 = eval(a1{:});
    
    T1 = [T1;T2];
end

parname1 = ['Year_SAT_' num2str(year) '_' num2str(iPlant)];
assignin('base',parname1,T1);
 