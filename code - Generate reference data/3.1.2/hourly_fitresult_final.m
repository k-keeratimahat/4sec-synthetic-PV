% arrange the clear sky PV output into hourly interval.
iPlant = 295;
year = 2017;
parname1 = ['fitresult_final_' num2str(year) '_' num2str(iPlant)];
filename1 = ['F:\Clear Sky Analysis\fitting_2017_295\' parname1];
load(filename1,parname1);

daily_data = eval(parname1);

for dd = 1:length(daily_data)
    dd
    row_idx = daily_data(dd).Modelled_curtail >0;
    day_timestamp = daily_data(dd).TimeStamp1(row_idx);
    mmonth = unique(day_timestamp.Month);
    dday = unique(day_timestamp.Day);
    hhour = day_timestamp.Hour;
    uni_hhour = unique(hhour);
    %determine the starting hour
    if sum(hhour == uni_hhour(1)) > 225
        h2 = uni_hhour(3:end); %if the first hour has more than 15 minutes
    else
        h2 = uni_hhour(4:end); %if the first hour has datapoints less than 15 minutes
    end
    %determine the ending hour
    if sum(hhour == uni_hhour(end)) > 225
        h2 = h2(1:end-2);
    else
        h2 = h2(1:end-3);
    end    
    
    Data2 = daily_data(dd).Data1;
%     ClearSkyGHI = daily_data(dd).ClearSkyGHI;
    ClearSkyOutput2 = daily_data(dd).Modelled;
    ClearSkyOutputCurtailed2 = daily_data(dd).Modelled_curtail;
    ClearSkyOutputIdx2 = daily_data(dd).csIndex_Data;
    
    HourNumber = h2;
    TimeStamp = cell([length(h2) 1]);
    Data = cell([length(h2) 1]);
    ClearSkyOutput = cell([length(h2) 1]);
    ClearSkyOutputCurtailed = cell([length(h2) 1]);
    ClearSkyOutputIdx = cell([length(h2) 1]);
    
    
    for h1 = 1:length(h2)
        h3 = h2(h1);
        date_idx =  daily_data(dd).TimeStamp1.Hour == h3;
        date1 = daily_data(dd).TimeStamp1(date_idx);
        data1 = Data2(date_idx);
%         ClearSkyGHI1 = ClearSkyGHI(date_idx);
        ClearSkyOutput1 = ClearSkyOutput2(date_idx);
        ClearSkyOutputCurtailed1 = ClearSkyOutputCurtailed2(date_idx);
        ClearSkyOutputIdx1 = ClearSkyOutputIdx2(date_idx);
        
        
        TimeStamp{h1} = date1;
        Data{h1} = data1;
%         struct_daily(h1).ClearSkyGHI = ClearSkyGHI1;
        ClearSkyOutput{h1} = ClearSkyOutput1;
        ClearSkyOutputCurtailed{h1} = ClearSkyOutputCurtailed1;
        ClearSkyOutputIdx{h1} = ClearSkyOutputIdx1;
    end
    
    T1 = table(HourNumber,TimeStamp,Data,ClearSkyOutput,ClearSkyOutputCurtailed,ClearSkyOutputIdx);
    
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
    
    parname_save = ['Hourly_fitresult_' num2str(iPlant) '_' num2str(year) mmn ddy '_' num2str(dd)];
    assignin('base',parname_save,T1)
    filename_save = ['F:\Variability Modelling - v9\' 'Hourly_fitresult_' num2str(iPlant) '.mat']
%     
%     if ~exist(filename_save)
%         save(filename_save,parname_save)
%     else
%         save(filename_save,parname_save,'-append')
%     end
%     
%       clear('struct_daily',parname_save)
end
        
%% adjust clear sky
iPlant = 299;
Pcap = 56;
filename1 = ['Hourly_fitresult_' num2str(iPlant)];
load(filename1)
a = who('Hourly_fitresult_*');

for i = 1:length(a)
    i
    ST = eval(a{i});
        CSoutput = ST.ClearSkyOutputCurtailed;
        CSoutputIdx = ST.ClearSkyOutputIdx;
        
        avgCS = cellfun(@mean, CSoutputIdx,'UniformOutput',0);
        max_avgCS = max(cell2mat(avgCS));

        if max_avgCS >0.9 
            CSoutputAdj = cellfun(@(x) x.*max_avgCS,CSoutput,'UniformOutput',0);
        else
            CSoutputAdj = CSoutput;
        end
         
         for hh = 1:height(ST)
             CSoutputAdj{hh}(CSoutputAdj{hh}>Pcap) = Pcap;
         end
         
       
       ClearSkyOutputIdxAvg= cell2mat(avgCS);
         ClearSkyOutputAdj = CSoutputAdj;
        Data = ST.Data;
        ClearSkyOutputIdxAdj = cellfun(@(x,y) x./y,Data,CSoutputAdj,'UniformOutput',0);
        T2 = table(ClearSkyOutputIdxAvg,ClearSkyOutputAdj,ClearSkyOutputIdxAdj);
        T1= [ST, T2];
 
    assignin('base',a{i},T1)
end        
        