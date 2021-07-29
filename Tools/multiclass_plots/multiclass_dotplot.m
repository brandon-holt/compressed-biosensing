function multiclass_dotplot(data,labels,dims,plotlabels)
% multiclass_pcaplot(data,labels,dims,plotlabels)
% each column is a point

if ~exist('dims') || isempty(dims) || min(dims)<1 || max(dims)>size(data,2)
    dims = [1,2];
end
if ~exist('plotlabels')
    plotlabels = 'o^d*p+x<>';
end


if ~exist('labels') || isempty(labels)
    plot(coeff(1,:),coeff(2,:),'.')
elseif ~isempty(labels)
    if ~isnumeric(labels)
        [~,~,labels] = unique(labels);
    end
    if ~isempty('plotlabels'), plotlabels = 'o^d*p+x<>'; end
    possible_labels = unique(labels);
    for i=1:length(possible_labels)
        cl = mod(i,length(plotlabels));
        if cl==0, cl = length(plotlabels); end
        ind = ismember(labels,possible_labels(i));
        plot(data(dims(1),ind),data(dims(2),ind),plotlabels(cl));
        if i==1, hold on; end
    end
    hold off;
end

return





