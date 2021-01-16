function actual_vs_classified = myfunc_psth_decoder(raster)
%INPUT: raster - 3d matrix where the 1st dimension - various repetitions, 2nd
%dimension - time, 3rd dimension - different conditions/stimulus

    %creating the template for each condition
    n_inner = size(raster,3);
    n_reps = size(raster,1);
    template = [];
    for inn = 1:n_inner
        template(inn,:) = mean(raster(:,:,inn),1);
    end

    %testing stage of the psth decoder
    %Leave one out cross validation
    min_euc = zeros(n_inner,n_reps);
    for i = 1:n_inner
        sub_master_raster = raster(:,:,i);
        for j = 1:size(sub_master_raster,1)
            test_vector = sub_master_raster(j,:);
            euc_dist = [];
            for temp = 1:size(template,1)
                if(temp == i)
                    train_vector = ((template(temp,:)*n_reps)-test_vector)/(n_reps-1);
                else
                    train_vector = template(temp,:);
                end
                euc_dist(temp) = sqrt(sum((test_vector - train_vector).^2));
            end
            tmp = find(euc_dist == min(euc_dist));
            %When multiple conditions have the min euclidean distance:
%             min_euc(i,j) = tmp(1);%this could create a bias(?)
            if (length(tmp)==1)
                min_euc(i,j) = tmp;
            else
                min_euc(i,j) = tmp(randi(length(tmp)));
            end
        end
    end
    
    %creating the confusion matrix
    actual_vs_classified = zeros(n_inner,n_inner);
    for i = 1:n_inner
        for j = 1:n_inner
        actual_vs_classified(i,j) = length(find(min_euc(i,:)==j))/n_reps;
        end
    end
    actual_vs_classified = flipud(actual_vs_classified);
    
    figure();
%     CT=cbrewer('seq', 'Blues', n_reps);%or reds or greens
%     colormap(flipud(CT));
    colormap(hot);
    imagesc(actual_vs_classified);
%     set(gca,'xtick',2:2:20);
%     set(gca,'xticklabel',{'1', '2','4','8','16','32','64','128','256','512'});
%     set(gca,'ytick',2:2:20);
%     set(gca,'yticklabel',{'512','256','128','64','32','16','8','4','2','1'});
    caxis([0 1])
    colorbar();
    decoder_accuracy = diag(flipud(actual_vs_classified));
    
        
%     figure();
%     plot(decoder_accuracy,'LineWidth',2,'color','k');
%     set(gca,'xtick',1:20);
%     set(gca,'xticklabel',{'0', '1', '1.4', '2','2.8','4','5.7','8','11.3','16','22.6','32','45.3','64','90.5','128','181','256','362','512'});
%     xlabel('Delay between the two bursts');
%     title('Probability of correct decoding');
%     box off

end