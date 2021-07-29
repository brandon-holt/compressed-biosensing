function [result] = generate_ROC_three(good1,good2,bad1,bad2,ctrl, make_plots)
    sigma = 0.1; % increase to > 0.6 to tease apart feature importance more effectively in contrl group
    ctrl1 = [];
    for i = 1:10
       ctrl1 = [ctrl1 normrnd(1, sigma, length(ctrl), 1) .* ctrl(:,1)];
    end
    ctrl2 = [];
    for i = 1:10
       ctrl2 = [ctrl2 normrnd(1, sigma, length(ctrl), 1) .* ctrl(:,2)];
    end
    label = [ones(1,width(ctrl1)),2*ones(1,width(ctrl2))];
    X = [ctrl1,ctrl2];
    [~, ~, confusion_table1, cv_pred_Y, cv_pred_prob] = random_forest_multiclass_treebagger(X',label)
    [FP1,TP1,T1,auc1] = perfcurve(label,cv_pred_prob(:,2),2)
    if make_plots
        figure()
        plot(FP1,TP1)
        hold on 
    end

    label = [ones(1,length(good1)),2*ones(1,length(good2))];
    X = [good1,good2];
    [~, ~, confusion_table1, cv_pred_Y, cv_pred_prob] = random_forest_multiclass_treebagger(X',label);
    [FP2,TP2,T2,auc2] = perfcurve(label,cv_pred_prob(:,2),2);
    good_auc = auc2
    if make_plots
        plot(FP2,TP2)
    end
    
    label = [ones(1,length(bad1)),2*ones(1,length(bad2))];
    X = [bad1,bad2];
    [~, ~, confusion_table1, cv_pred_Y, cv_pred_prob] = random_forest_multiclass_treebagger(X',label);
    [FP3,TP3,T3,auc3] = perfcurve(label,cv_pred_prob(:,2),2);
    bad_auc = auc3
    if make_plots
        plot(FP3,TP3)
        legend('ctrl', 'good', 'bad')
        xlim([-0.1, 1.1])
        ylim([-0.1, 1.1])
    end
    
    

    
    result{1} = FP1;
    result{2} = TP1;
    result{3} = FP2;
    result{4} = TP2;
    result{5} = FP3;
    result{6} = TP3;
end