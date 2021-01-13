close all
clearvars;
data_dir = 'F:\EPHYS\Curr Bio\Dataset\Figure_1';
load(fullfile(data_dir,'noiseburst_ex.mat'));
num_regions = length(noiseburst_examples);
sm = 5;
for r_num = 1:num_regions
    if (r_num ==1)
    color = 'r';
    elseif (r_num ==2)
    color = [0,0.5,0];
    else
    color = 'b';
    end
    raster = noiseburst_examples(r_num).raster;
    figure(1);
    subplot(1,4,r_num);
    L = logical(raster);
    MarkerFormat.Color = color;
    plotSpikeRaster(L,'PlotType','scatter','MarkerFormat',MarkerFormat);
    box off
    xlabel('Time wrt sound onset (ms)');
    ylabel('Trial number');
    set(gca,'fontsize',12);
    
    [tau_single, tau_final, curve] = myfunc_calculate_tau(raster,sm);
    subplot(1,4,4);
    sm_resp = smoothdata(mean(raster,1),'gaussian',sm);
    [c,lags] = xcorr(sm_resp,'coeff');
    x = lags((length(lags)+1)/2:end);
    y = c((length(lags)+1)/2:end);
    plot(x,y,'color',color,'LineStyle','--');
    hold on
    plot(curve,'k');
    hold on
    box off
    xlabel('Time lag (ms)');
    ylabel('Autocorrelation');
    set(gca,'fontsize',12);
end
%%
load(fullfile(data_dir,'noiseburst.mat'));
num_regions = length(noiseburst);
sm = 5;
tau_single = cell(1,num_regions);
tau_final = cell(1,num_regions);
for r_num = 1:num_regions
    all_rasters = noiseburst(r_num).raster;
    for i = 1:size(all_rasters,3)
        raster = all_rasters(:,:,i);
        [tau_single{r_num}(i), tau_final{r_num}(i), curve] = myfunc_calculate_tau(raster,sm);
    end
    r_num
end

figure();
myfunc_boxplot(tau_final);
box off
xticklabels({'IC','MGB','A1'});
ylabel('Neural timescale, tau (ms)');
set(gca,'fontsize',12);