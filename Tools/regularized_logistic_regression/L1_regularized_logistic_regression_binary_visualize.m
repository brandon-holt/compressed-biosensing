h = figure(101);
subplot(2,2,1)
[~,t] = min(abs(roc_t-0.5));
hold off; plot(roc_x,roc_y,'-b','linewidth',3); line([0,1],[0,1]); 
hold on;  plot(roc_x(t),roc_y(t),'og','linewidth',5);
xlabel('False Positive Rate'); ylabel('True Positive Rate')
title(num2str([accuracy, auc, mcorr],'acc=%1.2f, auc=%1.2f, mcc=%1.2f'))
subplot(2,2,3)
heatmap(confusion_table,'ColorbarVisible','off');
h = subplot(2,2,[2 4]);
[~,I] = sort(selected_weights);
barh(selected_weights(I));
set(h,'ytick',1:length(selected_features),'yticklabel',selected_features(I));
