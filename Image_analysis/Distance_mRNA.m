
mRNA_loc=[mRNAThunderSTORM(:,3),mRNAThunderSTORM(:,4)]; 
CAAX_loc=[CAAXThunderSTORM(:,3),CAAXThunderSTORM(:,4)];

% rng('default') % For reproducibility
% D = pdist2(CAAX_loc,mRNA_loc);
% min_d=min(D);

[Distance,I] = pdist2(CAAX_loc,mRNA_loc,'euclidean','Smallest',1);  % Distance of each mRNA to the CAAX

figure(1)
histogram(Distance,10);
xlabel('distance of mRNA to CAAX(nm)');
ylabel('Count');