function [tau_single, tau_final, curve] = myfunc_calculate_tau(raster,sm)
%inputs: raster
%        sm - smoothing window for psth
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
    tau_single = -1/(curve.b);
    %Double exponential fit if goodness of fit is low
    if (gof.adjrsquare<0.75)
        options = fitoptions('exp2');
        options.StartPoint = [1 -0.5 0.5 -0.3];
        options.Upper = [Inf 0 Inf -0.01];
        [curve,gof] = fit(x',y','exp2',options);
        tau1 = -1/(curve.b);
        tau2 = -1/(curve.d);
        tau_final = (curve.a*tau1+curve.c*tau2)/(curve.a+curve.c);
        if (tau_final>100)%if double exp fit is faulty
            tau_final = tau_single;
        end
    else
        tau_final = tau_single;
    end
    %Verify fits by eye
end