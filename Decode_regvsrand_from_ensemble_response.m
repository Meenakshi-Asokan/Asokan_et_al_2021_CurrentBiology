%Still needs to commented and cleaned-up (add x,y labels, legends, etc.)
close all
clearvars

data_dir = 'F:\EPHYS\Curr Bio\Dataset\Figure_2';
load(fullfile(data_dir,'ensembles_regrand.mat'));

sess = 3;
n_cyc = 4;
num_frames = 25;
sm = 5;
bin_size = 1;
r_num = 1;%IC
% r_num = 2;%MGB
% r_num = 3;%A1

ens_compr_reg = [];
ens_compr_rand = [];
num_units = size(ensembles_regrand(r_num).raster_reg{sess},3);

%Pre-processing prior to dimensionality reduction to capture shared
%variance and not the stochastic fluctuations inherent to each neuron
for clu = 1:num_units
raster_reg = ensembles_regrand(r_num).raster_reg{sess}(:,:,clu);
raster_rand = ensembles_regrand(r_num).raster_rand{sess}(:,:,clu);
%Average response across every 4 (n_cyc) bursts
tmp = [];
k = 1;
for i = 1:n_cyc:size(raster_reg,1)
    tmp(k,:) = sum(raster_reg(i:i+n_cyc-1,:),1);
    k = k+1;
end
raster_reg = tmp;

tmp = [];
k = 1;
for i = 1:n_cyc:size(raster_rand,1)
    tmp(k,:) = sum(raster_rand(i:i+n_cyc-1,:),1);
    k = k+1;
end
raster_rand = tmp;
%Bin spikes over a chosen window (here we keep bin_size = 1ms) & smooth
compr_reg = [];
compr_reg_sm = [];
compr_rand = [];
compr_rand_sm = [];
for i = 1:size(raster_reg,1)
    for j = 1:size(raster_reg,2)/bin_size
        compr_reg(i,j) = sum(raster_reg(i,(j-1)*bin_size+(1:bin_size)));
        compr_rand(i,j) = sum(raster_rand(i,(j-1)*bin_size+(1:bin_size)));
    end
    compr_reg_sm(i,:) = smoothdata(compr_reg(i,:),'gaussian',sm);
    compr_rand_sm(i,:) = smoothdata(compr_rand(i,:),'gaussian',sm);
end

temp = compr_reg_sm';
ens_compr_reg(clu,:) = temp(:);
temp = compr_rand_sm';
ens_compr_rand(clu,:) = temp(:);
end

%Dimensionality red - PCA
data = [ens_compr_reg ens_compr_rand];
[Zproj,num_proj] = myfunc_pca(data);

bins = size(compr_reg,2);
X_all = [];

for proj = 1:num_proj
    Z_p = Zproj(proj,:);
    Z_p_split = [];
    for i = 1:length(Z_p)/bins
        Z_p_split(i,:) = Z_p((i-1)*bins+(1:bins));
    end
    X_all = [X_all Z_p_split];
end

%Decoder - SVM
Y_all = [zeros(size(compr_reg,1),1);ones(size(compr_reg,1),1)];
regvsrand = [];
regvsrand_shuffle = [];
n_iter = 100;
for iter = 1:n_iter
folds = 10;%10 fold crossvalidation with random partitions each iteration
label = myfunc_svm(X_all,Y_all,folds);
regvsrand(:,iter) = label;
% iter
end

%control - shuffled data
n_shuff = 100;
for shuff = 1:n_shuff
X_all_shuffle = X_all(randperm(size(X_all,1)),:);%different random shuffle each iteration
label = myfunc_svm(X_all_shuffle,Y_all,folds);
regvsrand_shuffle(:,shuff) = label;
% shuff
end

y = mean(regvsrand,2);
x = 1:length(y);

y_shuff = mean(regvsrand_shuffle,2);
x_shuff = 1:length(y_shuff);

%sigmoid fit
fixed_params=[NaN, NaN , NaN , 1];%slope kept as a fixed param
fixed_params_shuff=[NaN, NaN , NaN , NaN];
%best guess for initial parameters
init_params_iter = [0,1,30,10];
init_params_shuff = [0,1,30,0];
figure();
subplot(1,2,1);
estimated_params=sigm_fit(x,y,fixed_params,init_params_iter);
box off
ylim([0 1]);
subplot(1,2,2);
estimated_params_shuff=sigm_fit(x_shuff,y_shuff,fixed_params_shuff,init_params_shuff);
box off
ylim([0 1]);

%%
load(fullfile(data_dir,'real_output_allregions.mat'));
load(fullfile(data_dir,'shuff_output_allregions.mat'));

k = 1;
% figure();
estimated_params = cell(1,3);
% figure();
for r_num = 1:3
% r_num = 3;
    iter_data = real_output_allregions{r_num};
    mean_dec_iters = mean(iter_data,3);
    figure();
for i = 1:size(mean_dec_iters,1)
% for i = 1:5
% i = 1;
    x = 1:size(mean_dec_iters,2);
    y = mean_dec_iters(i,:);
%     if (i == 2)
%     subplot(3,1,r_num);
subplot(size(mean_dec_iters,1),1,i);
% subplot(5,3,r_num+(i-1)*3);
% figure();
% plot(x,y,'o');

[estimated_params{r_num}(i,:)]=sigm_fit(x,y,fixed_params,init_params_iter);
box off
% ylim([-0.5 1.5]);
vline(25,'k--');
%     end

end
end

k = 1;
% figure();
estimated_params_shuff = cell(1,3);
for r_num = 1:3
% r_num = 3;
    shuff_data = shuff_output_allregions{r_num};
    mean_dec_iters = mean(shuff_data,3);
    figure();
for i = 1:size(mean_dec_iters,1)
% for i = 1:5
% i = 1;
    x = 1:size(mean_dec_iters,2);
    y = mean_dec_iters(i,:);
subplot(size(mean_dec_iters,1),1,i);
% subplot(5,3,r_num+(i-1)*3);
% figure();
% plot(x,y,'o');

[estimated_params_shuff{r_num}(i,:)]=sigm_fit(x,y,fixed_params_shuff,init_params_shuff);
box off
% ylim([-0.5 1.5]);
vline(25,'k--');


end
end
%%
fsigm = @(param,xval) param(1)+(param(2)-param(1))./(1+10.^((param(3)-xval)*param(4)));
figure();
datamat = [];
datastat = cell(1,3);
S = cell(1,3);
F1 = cell(1,3);
F2 = cell(1,3);
k = 1;
for r_num = 1:3
    subplot(3,1,r_num);
    y = [];
    y_shuff = [];
    for i = 1:length(estimated_params{r_num})
        param = estimated_params{r_num}(i,:);
        param_shuff = estimated_params_shuff{r_num}(i,:);
        x = 1:1:50;
        y(i,:) = fsigm(param,x);
        plot(x,y(i,:),'r');
        hold on
        y_shuff(i,:) = fsigm(param_shuff,x);
        plot(x,y_shuff(i,:),'k');
        box off
        ylim([0 1]);
        datastat{r_num} = [datastat{r_num};y(i,:)';y_shuff(i,:)'];
        S{r_num} = [S{r_num};ones(length([y(i,:) y_shuff(i,:)]),1)*i];
        F1{r_num} = [F1{r_num};(1:length(y(i,:)))';(1:length(y_shuff(i,:)))'];
        F2{r_num} = [F2{r_num};ones(length(y(i,:)),1);zeros(length(y_shuff(i,:)),1)];
        datamat(k,:,1) = y(i,:);
        datamat(k,:,2) = y_shuff(i,:);
        k = k + 1;
    end

            hold on
        vline(25,'k--');
    subplot(3,1,r_num);
            shadedErrorBar(x,mean(y_shuff,1),std(y_shuff,0,1)/sqrt(size(y_shuff,1)),'k');
            hold on
    shadedErrorBar(x,mean(y,1),std(y,0,1)/sqrt(size(y,1)),'r');
        box off
        ylim([0 1]);
        xticks(0:5:50);
        xlim([1 50]);
        hold on
        vline(25,'k--');
%     errorbar(x,mean(y,1),std(y,0,1)/sqrt(size(y,1)),'r');
% set(gca,'fontsize',12);

end