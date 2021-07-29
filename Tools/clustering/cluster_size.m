function s = cluster_size(idx)

idx = idx(:);
tmp  = sort(idx); 
tmp(tmp==0)=[];
tmp = find(tmp~=[tmp(2:end);-1]);
s = tmp - [0;tmp(1:end-1)];
[aa,bb,cc] = mytable(s);


