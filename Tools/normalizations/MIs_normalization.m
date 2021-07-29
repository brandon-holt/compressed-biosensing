function MIs = normalize_MIs(MIs)

ind = find(MIs<1e-12);
normalization = repmat(diag(MIs),1,size(MIs,1)) + repmat(diag(MIs)',size(MIs,1),1);
MIs = 2*MIs./normalization;
MIs = MIs - diag(diag(MIs));
MIs(ind) = 0;