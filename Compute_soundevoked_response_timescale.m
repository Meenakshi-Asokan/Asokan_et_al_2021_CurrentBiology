close all
clearvars;
data_dir = 'F:\EPHYS\Curr Bio\Dataset\Figure_1';
load(fullfile(data_dir,'noiseburst.mat'));
%%
num_regions = length(noiseburst);
sm = 5;
tau_single = cell(1,num_regions);
tau_final = cell(1,num_regions);
for r_num = 1:num_regions
    all_rasters = noiseburst(r_num).raster;
    for i = 1:size(all_rasters,3)
        raster = all_rasters(:,:,i);
        sm_resp = smoothdata(mean(raster,1),'gaussian',sm);
        [c,lags] = xcorr(sm_resp,'coeff');
        x = lags((length(lags)+1)/2:end);
        y = c((length(lags)+1)/2:end);
        %Single exponential fit
        options = fitoptions('exp1');
        options.StartPoint = [1 -0.5];
        options.Upper = [1 0];
        options.Lower = [1 -Inf];
        [curve,gof] = fit(x',y','exp1',options);
        tau_single{r_num}(i) = -1/(curve.b);
        %Double exponential fit if goodness of fit is low
        if (gof.adjrsquare<0.75)
            options = fitoptions('exp2');
            options.StartPoint = [1 -0.5 0.5 -0.3];
            options.Upper = [Inf 0 Inf -0.01];
            [curve,gof] = fit(x',y','exp2',options);
            tau1 = -1/(curve.b);
            tau2 = -1/(curve.d);
            tau_final{r_num}(i) = (curve.a*tau1+curve.c*tau2)/(curve.a+curve.c);
            if (tau_final{r_num}(i)>100)
                tau_final{r_num}(i) = tau_single{r_num}(i);
            end
        else
            tau_final{r_num}(i) = tau_single{r_num}(i);
        end
    end
    r_num
end
%%
figure();
my_boxplot(tau_final);
box off
xticklabels({'IC','MGB','A1'});
ylabel('Neural timescale, tau (ms)');
set(gca,'fontsize',12);