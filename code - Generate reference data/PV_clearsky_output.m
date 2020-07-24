%function that generate clear sky PV output profile for the PV plant.
function  [P_output, P_curtail] = PV_clearsky_output(x,y,SurfTilt,SurfAz,eff,iPlant,year,GMT,Pdc,Pac)

% iPlant = 295;
% year = 2017;
% GMT = 10;
% Pdc = 70;
% Pac = 53;

Albedo = 0.15;
alpha = -3.56;
beta = -0.075;
delta_T = 3;
gamma = -0.00436;

load(['F:\Clear Sky Analysis\fitting_295_v5\Weather_' num2str(year) '_' num2str(iPlant)])
load(['F:\Satellite Data\Satellite MAT\Gridded_' num2str(iPlant) '_UT.mat'], 'NearestPoint')
        Lat = NearestPoint.Lat;
        Long = NearestPoint.Long;
        Alt = NearestPoint.Alt;       
 Location = pvl_makelocationstruct(Lat, Long, Alt);

Weather = eval(['Weather_' num2str(year) '_' num2str(iPlant)]);
TimeDay = [timeofday(datetime(year,1,1,0,0,3)):seconds(4):timeofday(datetime(year,1,1,23,59,59))]';
DayOfYear = [datetime(year,1,1):days(1):datetime(year,12,31)]';

y = y';

P_output = zeros([length(y),length(x)]);


for i = 1:length(x)
  x1 =   x(i)*ones([length(y),1]);
TimeStamp = DayOfYear(x1) + TimeDay(y);
TimeNum = datenum(TimeStamp(:));

Time = pvl_maketimestruct(TimeNum, GMT);
[SunAz, SunEl, ~, ~]= pvl_ephemeris(Time, Location);
[ClearSkyGHI, ClearSkyDNI, ClearSkyDHI]= pvl_clearsky_ineichen(Time, Location);
 SunZen = 90 - SunEl;

WeatherTime = Weather.TimeStamp(:);
Wind = Weather.Wind(ismember(WeatherTime,TimeStamp),1);
Tamb = Weather.Temperature(ismember(WeatherTime,TimeStamp),1);
 

GHI = ClearSkyGHI;
DNI = ClearSkyDNI;
DHI = ClearSkyDHI;

GHI(isnan(GHI)) = 0; DNI(isnan(DNI)) = 0; DHI(isnan(DHI)) = 0;

AOI = pvl_getaoi(SurfTilt, SurfAz, SunZen, SunAz);
GR = pvl_grounddiffuse(SurfTilt,GHI,Albedo);
AM = pvl_relativeairmass(SunZen);
Ea = pvl_extraradiation_m(x(i));
 
 SkyDiffuse = pvl_perez(SurfTilt, SurfAz, DHI, DNI, Ea, SunZen, SunAz, AM);
 Beam = DNI.*(cos(deg2rad(AOI)));
 Beam(Beam < 0) = 0;

 POA = Beam + GR + SkyDiffuse;
 
 Tc = POA.*exp(alpha + beta.*Wind) + Tamb + POA./1000.*delta_T;
 Pmp = POA./1000 .* Pdc .* (1+ gamma.*(Tc-25));
 
 P_output(:,i) = Pmp.*eff;
end
P_curtail = P_output;
P_curtail(P_output >= Pac) = Pac;
end
