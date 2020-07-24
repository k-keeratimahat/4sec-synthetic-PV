% build struct array which includes the measured PV output from the
% reference PV plant, calculated clear sky PV output and clear sky PV
% output index.

%% input parameters. These can be changed by the user depending on parameter of the reference plant.
iPlant = 295;
year = 2017;

parname1 = ['daily_' num2str(year) '_' num2str(iPlant)]; %measured PV output
load(['F:\Clear Sky Analysis\' parname1]);
daily_ST = eval(parname1);

load(['F:\Clear Sky Analysis\fitting_295_v5\' 'fit_'  num2str(year) '_' num2str(iPlant)]); %parameter such as tilt angle, azimuth, efficiency.
DayNumber = vertcat(daily_ST(:).DayNumber);

SurfTilt = fitresult.SurfTilt;
SurfAz = fitresult.SurfAz;
eff = fitresult.eff;

%% calculation.
TimeDay = [timeofday(datetime(year,1,1,0,0,3)):seconds(4):timeofday(datetime(year,1,1,23,59,59))]';
DayOfYear = [datetime(year,1,1):days(1):datetime(year,12,31)]';

%function that generate clear sky PV output profile for the PV plant.
[P_output, P_curtail] = PV_clearsky_output(DayNumber,1:length(TimeDay),SurfTilt,SurfAz,eff,iPlant,year,GMT,Pdc,Pac)

for dd = 1:length(DayNumber)
    dd
    ST1(dd).DayNumber = DayNumber(dd);
    ST1(dd).TimeStamp = daily_ST(dd).TimeStamp;
    ST1(dd).Data = daily_ST(dd).Data;
    dd_vec = dd.*ones([length(TimeDay),1]);
    ST1(dd).TimeStamp1 = DayOfYear(dd_vec) + TimeDay;
    
    Data1 = zeros([length(TimeDay),1]);
    Data1(ismember(ST1(dd).TimeStamp1,ST1(dd).TimeStamp),1) = daily_ST(dd).Data;
    ST1(dd).Data1 = Data1;
    ST1(dd).Modelled = P_output(:,dd);
    ST1(dd).Modelled_curtail = P_curtail(:,dd);
    ST1(dd).csIndex_Data = ST1(dd).Data1./P_curtail(:,dd);
    
     difference = ST1(dd).Data1 -P_curtail(:,dd);
    MBE = sum(difference)/length(ST1(dd).Data);
    RMSE = sqrt(sum(difference.^2)/length(ST1(dd).Data));
    ST1(dd).csIndex = mean(ST1(dd).csIndex_Data(~isinf(ST1(dd).csIndex_Data)),'omitnan');
    ST1(dd).MBE = MBE;
    ST1(dd).RMSE = RMSE;
    
end

parname2 = ['fitresult_final_'  num2str(year) '_' num2str(iPlant)] ;
assignin('base',parname2,ST1)