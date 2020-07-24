% Exclude the small variability range and to find the extend of the
% exclusion to generate best fit q-exponential distribution to the measured
% 4-second data.

iPlant = 299;
year = 2017;

filename1 = ['F:\Variability Modelling - v9\bin_clearsky_index_' num2str(year) '_' num2str(iPlant)];
load('BIN_INDEX')

bin_index = eval(['BIN_INDEX_exist_' num2str(iPlant)]);
mat1 = NaN([length(BIN_INDEX),6]);
T2 = array2table(mat1,'VariableNames',{'GHI','DNI','KSI','KSI_percent','Divider1','Divider2'});

thre = 0.015;
tlag = 1;
edge = [0:0.005:1];


binwidth = edge(2) - edge(1);

t = 0;
for j = 1:length(BIN_INDEX)
    j
    if ~ismember(j,bin_index)
        continue
    else
numGHI = BIN_INDEX(j,1); numDNI = BIN_INDEX(j,2);

parname1 = ['bin_clearsky_*_' num2str(numGHI) '_' num2str(numDNI)];
load(filename1,parname1)
a = who(parname1);
data_array = eval(a{:});
x_cell = cell([height(data_array),1]);
y_cell = cell([height(data_array),1]);
for i = 1:height(data_array)
    t = t+1;
    x_cell{t,1} =  data_array.ClearSkyIdxOutput{i}(1:end-tlag);
    y_cell{t,1} =  data_array.ClearSkyIdxOutput{i}(1+tlag:end);
end

x1 = vertcat(x_cell{:});
y1 = vertcat(y_cell{:});
diff_data = (y1-x1);
diff_data = abs(diff_data);
zero_data = diff_data(diff_data < thre);

dvec = 1:500;
T1 = array2table(zeros([500,2]),'VariableNames',{'KSI','KSI_percent'});
for d = 1:length(dvec)
diff_data = [diff_data(diff_data >= thre); zero_data(1:round(length(zero_data)/dvec(d)))];
diff_data1 = diff_data;

f1 = figure;
h1 = histogram(diff_data,edge,'Normalization','pdf');
std_diff = std(diff_data,'omitnan');
x2 = ((edge(1:end-1) + edge(2:end))/2);%./std_diff;
x2_1 = x2';
y2_prob = h1.BinCounts./length(diff_data);
y2_prob = y2_prob';
y2 = h1.BinCounts./(length(diff_data).*binwidth);
y2_1 = y2';
close(f1)

xmean = mean(diff_data1);
s2 = sum((diff_data1).^2)/length(diff_data1);

s4 = sum((diff_data1).^4)/length(diff_data1);

f = s4/(s2^2);
syms x
q_vec = vpasolve(6*(-4*x^3 + 17*x^2 - 20*x +6)/((x-2)*(4*x-5)*(5*x-6)) == f, x); %wikipedia
q = double(q_vec(2));
syms y
beta_vec = vpasolve((q - 2)/((2*q-3)^2 * (3*q-4) *y^2) == s2, y);
beta1 = double(beta_vec(beta_vec >0));
pdf_diff = (((2-q)*beta1)*(1 - beta1*(1-q)*abs(x2)).^(1/(1-q)));

  cdf1 = cumsum(y2_prob(1:end))';
  qq = 1/(2-q);

y3_prob = pdf_diff.*binwidth;
cdf2 = cumsum(y3_prob(1:end));
x3 = x2(1:end);

alpha_critical = 1.63/sqrt(length(diff_data1)*(edge(end) - edge(1)));
KSI = sum(abs(cdf1(2:end) - cdf2(2:end)).*binwidth);
KSI_percent = KSI/alpha_critical;

T1.KSI(d) = KSI;
T1.KSI_percent(d) = KSI_percent;
end
parname2 = ['divider_' num2str(iPlant) '_' num2str(numGHI) '_' num2str(numDNI)];
foldername2 = ['divider_simulation_299_q2'];
assignin('base',parname2,T1);
save([foldername2 '\' parname2],parname2);

[minKSI,minI] = min(T1.KSI);
[minKSIpercent,minIpercent] = min(T1.KSI_percent);

T2.GHI(j) = numGHI; T2.DNI(j) = numDNI;
T2.KSI(j) = minKSI; T2.KSI_percent(j) = minKSIpercent;
T2.Divider1(j) = minI(1); T2.Divider2(j) = minIpercent(1);
    end
end
T2(isnan(T2.GHI),:) = [];

parname3 = ['divider_' num2str(iPlant)];
assignin('base',parname3,T2);
save(parname3,parname3);
%%
% generate q parameters from the original/measured distribution
% use the output file the previous section
iPlant = 299;
year = 2017;

filename1 = ['F:\Variability Modelling - v9\bin_clearsky_index_' num2str(year) '_' num2str(iPlant)];
load('BIN_INDEX')
filename2 = ['divider_' num2str(iPlant) '_q' num2str(nq)];
parname2 = ['divider_' num2str(iPlant)];
load(filename2,parname2)
D1 = eval(parname2);
bin_index = eval(['BIN_INDEX_exist_' num2str(iPlant)]);
mat1 = NaN([length(bin_index),8]);
T1 = array2table([bin_index, BIN_INDEX(bin_index,:), mat1],'VariableNames',...
    {'BIN_INDEX','GHI','DNI','s2','s4','f','q','beta1','pzero','KSI','KSI_percent'});
cell1 = cell([length(bin_index),1]);
T2 = [T1, cell2table(cell1,'VariableNames',{'zero_data'})];

thre = 0.015;
tlag = 1;
edge = [0:0.005:1];
nq = 2;

binwidth = edge(2) - edge(1);

for BI = 1:length(bin_index)
    BI

parname1 = ['*_' num2str(bin_index(BI)) '_*_*'];
load(filename1,parname1)
a = who(parname1);
data_array = eval(a{:});
x_cell = cell([height(data_array),1]);
y_cell = cell([height(data_array),1]);
t = 0;
for i = 1:height(data_array)
    t = t+1;
    x_cell{t,1} =  data_array.ClearSkyIdxOutput{i}(1:end-tlag);
    y_cell{t,1} =  data_array.ClearSkyIdxOutput{i}(1+tlag:end);
end

x1 = vertcat(x_cell{:});
y1 = vertcat(y_cell{:});
diff_data = (y1-x1);
zero_data_posneg = diff_data(abs(diff_data) < thre);
diff_data = abs(diff_data);
zero_data = diff_data(diff_data < thre);
percent_zero = length(zero_data)/length(diff_data);
diff_data = [diff_data(diff_data >= thre); zero_data(1:round(length(zero_data)/D1.Divider1(BI)))];
diff_data1 = diff_data;

f1 = figure;
h1 = histogram(diff_data,edge,'Normalization','pdf');
x2 = ((edge(1:end-1) + edge(2:end))/2);
x2_1 = x2';
y2_prob = h1.BinCounts./length(diff_data);
y2_prob = y2_prob';
y2 = h1.BinCounts./(length(diff_data).*binwidth);
y2_1 = y2';
close(f1)

s2 = sum((diff_data1).^2)/length(diff_data1);

s4 = sum((diff_data1).^4)/length(diff_data1);

f = s4/(s2^2);
syms x
q_vec = vpasolve(6*(-4*x^3 + 17*x^2 - 20*x +6)/((x-2)*(4*x-5)*(5*x-6)) == f, x); %wikipedia
q = double(q_vec(nq));
syms y
beta_vec = vpasolve((q - 2)/((2*q-3)^2 * (3*q-4) *y^2) == s2, y);
beta1 = double(beta_vec(beta_vec >0));
pdf_diff = (((2-q)*beta1)*(1 - beta1*(1-q)*abs(x2)).^(1/(1-q)));

  cdf1 = cumsum(y2_prob(1:end))';
y3_prob = pdf_diff.*binwidth;
cdf2 = cumsum(y3_prob(1:end));


alpha_critical = 1.63/sqrt(length(diff_data1)*(edge(end) - edge(1)));
KSI = sum(abs(cdf1(2:end) - cdf2(2:end)).*binwidth);
KSI_percent = KSI/alpha_critical;

T2.KSI(BI) = KSI;
T2.KSI_percent(BI) = KSI_percent;
T2.s2(BI) = s2;
T2.s4(BI) = s4;
T2.f(BI) = f;
T2.q(BI) = q;
T2.beta1(BI) = beta1;
T2.pzero(BI) = percent_zero;
T2.zero_data{BI} = zero_data_posneg;
end
parname2 = ['bin_dist_param_' num2str(year) '_' num2str(iPlant)];
assignin('base',parname2,T2);
save(parname2,parname2);
