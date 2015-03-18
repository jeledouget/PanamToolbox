function panam_coherenceVisu( inputStruct )
%PANAM_COHERENCEVISU visualize coherence structure

coh = inputStruct.coherence;
n  = size(coh.labelcmb,1);
nH = ceil(sqrt(n));
nV = ceil(n/nH);

m = max(max(coh.cohspctrm));

figure;
for ii = 1:n
    subplot(nH,nV,ii)
    plot(coh.freq,coh.cohspctrm(ii,:));
    title([strrep(coh.labelcmb{ii,1},'_','') '  -  ' strrep(coh.labelcmb{ii,2},'_','')]);
    ax = axis;
    axis([ax(1) ax(2) 0 m]);
end



end

