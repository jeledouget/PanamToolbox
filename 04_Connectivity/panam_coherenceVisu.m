function panam_coherenceVisu( inputStruct )
%PANAM_COHERENCEVISU visualize coherence structure

coh = inputStruct.coherence;
n  = size(coh.labelcmb,1);
if n < 10
    nH = 3;
    nV = 3;
elseif n < 17
    nH = 4
    nV = 4;
else
    nH = 5;
    nV = 5;
end

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

