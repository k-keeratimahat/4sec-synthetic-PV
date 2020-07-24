%% scaling the distribution for each bin number.
iPlant = 299;
year = 2017;
testPlant = 299;
testyear = 2017;
n = 69.5/69.5; % DC capacity of testPlant divided by DC capacity of iPlant(reference plant)

filename1 = ['bin_dist_param_' num2str(year) '_' num2str(iPlant)];
parname1 = filename1;
load(filename1,parname1);
T1 = eval(parname1);

load('BIN_INDEX')

bin_index1 = eval(['BIN_INDEX_exist_' num2str(iPlant)]);

thre = 0.015;
nq_ref = 2;

mat1 = NaN([length(bin_index1),6]);
T2 = array2table([bin_index1, BIN_INDEX(bin_index1,:), mat1],'VariableNames',...
    {'BIN_INDEX','GHI','DNI','s2','s4','f','q','beta1','pzero'});
t = 0;
for j = 1:length(BIN_INDEX)
    j
   
numGHI = BIN_INDEX(j,1); numDNI = BIN_INDEX(j,2);
if ~ismember(j,T1.BIN_INDEX)
    continue
else
    t = t+1;
bindex = ismember(T1.BIN_INDEX,j);
zero_frac = T1.pzero(bindex);
zero_data = T1.zero_data{bindex};
s2new =  T1.s2(bindex)/n;

f = T1.s4(bindex)/(s2new^2);

syms x
q_vec = vpasolve(6*(-4*x^3 + 17*x^2 - 20*x +6)/((x-2)*(4*x-5)*(5*x-6)) == f, x); %wikipedia
q = double(q_vec(nq_ref));
syms y
beta_vec = vpasolve((q - 2)/((2*q-3)^2 * (3*q-4) *y^2) == s2new, y);
beta1 = double(beta_vec(beta_vec >0));

syms z
q_2 = 1/(2-q);
cdf3(z) = (1-beta1*(1-q_2)*z/q_2).^(1/(1-q_2));
        g = finverse(cdf3);
        tic
        dist1 = eval(g(rand(50000,1)));
        dist2 = eval(g(rand(50000,1)));
        toc
        dist_pool = [dist1; -dist2];
        dist_pool_2 = dist_pool(abs(dist_pool) >= thre);
        num_zero = zero_frac*(length(dist_pool_2)/(1-zero_frac));
        zero_add = zero_data(randi(length(zero_data),[round(num_zero),1]));
        dist_full = [zero_add;dist_pool_2];
        
parname2 =  ['bin_pool_' num2str(j) '_' num2str(numGHI) '_' num2str(numDNI)];
assignin('base',parname2,dist_full);
filename2 = ['bin_dist_pool_' num2str(year) '_' num2str(iPlant) '_' num2str(testPlant) '.mat'];
if exist(filename2)
    save(filename2,parname2,'-append');
else
    save(filename2,parname2);
end

T2.s2(t) = s2new;
T2.s4(t) = T1.s4(bindex);
T2.f(t) = f;
T2.q(t) = q;
T2.beta1(t) = beta1;
T2.pzero(t) = length(dist_full(abs(dist_full) < thre))/length(dist_full);
clear('bin_pool_*')
end
end
parname3 = ['bin_dist_param_' num2str(year) '_' num2str(iPlant) '_' num2str(testPlant)];
assignin('base',parname3,T2)
save(parname3,parname3)
