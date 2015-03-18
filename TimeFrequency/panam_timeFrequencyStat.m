function outputStruct = panam_timeFrequencyStat( inputStruct, method)

%PANAM_TIMEFREQUENCYSTAT Perform statistical test activation vs. baseline
%for Processed Time-Frequency Panam structure

nFreq = size(inputStruct.TimeFreqData.powspctrm,3);
nTimes = size(inputStruct.TimeFreqData.powspctrm,4);
nChannels = size(inputStruct.TimeFreqData.powspctrm,2);
avgBL = mean(inputStruct.TimeFreqData.blPowspctrm,4);
hMask = nan(nChannels,nFreq,nTimes);
pMask = nan(nChannels,nFreq,nTimes);

% default
if nargin < 2
    method  = 'ttest_fdr';
end

%% compute
switch method
    case 'ttest_fdr'
        % test : paired ttest on the values of the (t,f) point for the set
        % of trials compared to the time average of the baseline values for
        % the same trials + correction FDR
        for kk = 1:nChannels
            for ii=1:nFreq
                for jj=1:nTimes
                    try
                        [hMask(kk,ii,jj) pMask(kk,ii,jj)] = ttest(squeeze(inputStruct.TimeFreqData.powspctrm(:,kk,ii,jj)), squeeze(avgBL(:,kk,ii)));
                    catch
                        hMask(kk,ii,jj) = nan;
                        pMask(kk,ii,jj) = nan;
                    end
                end
            end
            temp = reshape(pMask(kk,:,:),1,[]);
            temp = sort(temp);
            [~, corr_p] = fdr_bh(temp,0.05);
            hMaskTemp = (pMask(kk,:,:) < corr_p);
            stat.pMask(kk,:,:) = pMask(kk,:,:);
            stat.hMask(kk,:,:) = hMask(kk,:,:);
            stat.hMaskCorr(kk,:,:) = hMaskTemp;
        end
        stat.method = method;
        
    case 'ttest_cluster'
        % test : paired ttest on the values of the (t,f) point for the set
        % of trials compared to the time average of the baseline values for
        % the same trials + correction : cluster
        cfg = [];
        cfg.neighbours = [];
        cfg.correctm = 'cluster';
        cfg.method = 'montecarlo';
        cfg.numrandomization = 500;
        cfg.statistic = 'actvsblT';
        cfg.clusterstatistic = 'maxsum';
        cfg.clusteralpha = 0.05;
        cfg.alpha = 0.05;
        cfg.tail = 0;
        
        dataBL = inputStruct.TimeFreqData;
        dataBL.powspctrm = dataBL.blPowspctrm;
        timeStep = (dataBL.time(end) - dataBL.time(1)) / (length(dataBL.time)-1);
        dataBL.time = timeStep *(0:size(dataBL.powspctrm,4)-1);
        dataTF = inputStruct.TimeFreqData;
        jj = 1;
        nSamplesTotal = size(dataTF.powspctrm,4);
        nSamplesBL = size(dataBL.powspctrm,4);
        sliceTimeIndices = {};
        while jj <= nSamplesTotal - nSamplesBL + 1
            if ~exist('data1')
                data1 = dataTF;
            else
                data1(end+1) = dataTF;
            end
            data1(end).powspctrm = data1(end).powspctrm(:,:,:,jj:jj+nSamplesBL-1);
            sliceTimeIndices{end+1} = jj:jj+nSamplesBL-1;
            data1(end).time = data1(end).time(jj:jj+nSamplesBL-1) - data1(end).time(jj);
            jj = jj + round(nSamplesBL/2);
        end
        nTimesFinal = jj-1;
        
        ntrials = size(dataBL.powspctrm,1);
        design  = zeros(2,2*ntrials);
        design(1,1:ntrials) = 1;
        design(1,ntrials+1:2*ntrials) = 2;
        design(2,1:ntrials) = 1:ntrials;
        design(2,ntrials+1:2*ntrials) = 1:ntrials;
        
        cfg.design   = design;
        cfg.ivar     = 1;
        cfg.uvar     = 2;
        
        for jj = 1:length(data1)
            slice(jj) = ft_freqstatistics(cfg, data1(jj), dataBL);
        end
        
        hMaskTemp = nan(nChannels,length(dataTF.freq), length(dataTF.time), length(data1));
        for kk = 1:nChannels
            for jj = 1:length(data1)
                hMaskTemp(kk,:,sliceTimeIndices{jj},jj) = slice(jj).mask(kk,:,:);
            end
            hMaskTemp = nanmean(hMaskTemp,4);
            hMaskTemp = double(hMaskTemp > 0);
            hMaskTemp(isnan(hMaskTemp)) = nan;
            hMaskCorr(kk,:,:) = hMaskTemp;
        end
        
        stat.pMask = [];
        stat.hMask = [];
        stat.hMaskCorr = hMaskCorr;
        stat.method = method;
        
        
        
    case 'ttest_ZeroLog'
        % test : ttest under the hypothesis the decibel power (compared to
        % baseline) is 0, on the values of the (t,f) point for the set
        % of trials + correction FDR
        dbCorrectedData = panam_baselineCorrection(inputStruct.TimeFreqData,'DB');
        for kk = 1:nChannels
            for ii=1:nFreq
                for jj=1:nTimes
                    try
                        [hMask(kk,ii,jj) pMask(kk,ii,jj)] = ttest(squeeze(dbCorrectedData.powspctrm(:,kk,ii,jj)));
                    catch
                        hMask(kk,ii,jj) = nan;
                        pMask(kk,ii,jj) = nan;
                    end
                end
            end
            temp = reshape(pMask(kk,:,:),1,[]);
            temp = sort(temp);
            [~, corr_p] = fdr_bh(temp,0.05);
            hMaskTemp(kk,:,:) = (pMask(kk,:,:) < corr_p);
        end
        stat.pMask = pMask;
        stat.hMask = hMask;
        stat.hMaskCorr = hMaskTemp;
        stat.method = method;
        
    case 'zscore'
        % test : ttest under the hypothesis the decibel power (compared to
        % baseline) is 0, on the values of the (t,f) point for the set
        % of trials + correction FDR
        zCorrectedData = panam_baselineCorrection(inputStruct.TimeFreqData,'ZSCORE');
        for kk = 1:nChannels
            for ii=1:nFreq
                for jj=1:nTimes
                    try
                        [hMask(kk,ii,jj) pMask(kk,ii,jj)] = ttest(squeeze(zCorrectedData.powspctrm(:,kk,ii,jj)));
                    catch
                        hMask(kk,ii,jj) = nan;
                        pMask(kk,ii,jj) = nan;
                    end
                end
            end
            temp = reshape(pMask(kk,:,:),1,[]);
            temp = sort(temp);
            [~, corr_p] = fdr_bh(temp,0.05);
            hMaskTemp(kk,:,:) = (pMask(kk,:,:) < corr_p);
        end
        stat.pMask = pMask;
        stat.hMask = hMask;
        stat.hMaskCorr = hMaskTemp;
        stat.method = method;
end

outputStruct = inputStruct;
if ~isfield(outputStruct.TimeFreqData,'stat');
    outputStruct.TimeFreqData.stat(1) = stat;
else
    outputStruct.TimeFreqData.stat(end+1) = stat;
end
outputStruct.History{end+1,1} = datestr(clock);
outputStruct.History{end,2} = 'Statistical mask computation with panam_timeFrequencyStat';

end




%% FDR


% fdr_bh() - Executes the Benjamini & Hochberg (1995) and the Benjamini &
%            Yekutieli (2001) procedure for controlling the false discovery
%            rate (FDR) of a family of hypothesis tests. FDR is the expected
%            proportion of rejected hypotheses that are mistakenly rejected
%            (i.e., the null hypothesis is actually true for those tests).
%            FDR is a somewhat less conservative/more powerful method for
%            correcting for multiple comparisons than procedures like Bonferroni
%            correction that provide strong control of the family-wise
%            error rate (i.e., the probability that one or more null
%            hypotheses are mistakenly rejected).
%
% Usage:
%  >> [h, crit_p, adj_p]=fdr_bh(pvals,q,method,report);
%
% Required Input:
%   pvals - A vector or matrix (two dimensions or more) containing the
%           p-value of each individual test in a family of tests.
%
% Optional Inputs:
%   q       - The desired false discovery rate. {default: 0.05}
%   method  - ['pdep' or 'dep'] If 'pdep,' the original Bejnamini & Hochberg
%             FDR procedure is used, which is guaranteed to be accurate if
%             the individual tests are independent or positively dependent
%             (e.g., Gaussian variables that are positively correlated or
%             independent).  If 'dep,' the FDR procedure
%             described in Benjamini & Yekutieli (2001) that is guaranteed
%             to be accurate for any test dependency structure (e.g.,
%             Gaussian variables with any covariance matrix) is used. 'dep'
%             is always appropriate to use but is less powerful than 'pdep.'
%             {default: 'pdep'}
%   report  - ['yes' or 'no'] If 'yes', a brief summary of FDR results are
%             output to the MATLAB command line {default: 'no'}
%
%
% Outputs:
%   h       - A binary vector or matrix of the same size as the input "pvals."
%             If the ith element of h is 1, then the test that produced the
%             ith p-value in pvals is significant (i.e., the null hypothesis
%             of the test is rejected).
%   crit_p  - All uncorrected p-values less than or equal to crit_p are
%             significant (i.e., their null hypotheses are rejected).  If
%             no p-values are significant, crit_p=0.
%   adj_p   - All adjusted p-values less than or equal to q are significant
%             (i.e., their null hypotheses are rejected). Note, adjusted
%             p-values can be greater than 1.
%
%
% References:
%   Benjamini, Y. & Hochberg, Y. (1995) Controlling the false discovery
%     rate: A practical and powerful approach to multiple testing. Journal
%     of the Royal Statistical Society, Series B (Methodological). 57(1),
%     289-300.
%
%   Benjamini, Y. & Yekutieli, D. (2001) The control of the false discovery
%     rate in multiple testing under dependency. The Annals of Statistics.
%     29(4), 1165-1188.
%
% Example:
%   [dummy p_null]=ttest(randn(12,15)); %15 tests where the null hypothesis
%                                       %is true
%   [dummy p_effect]=ttest(randn(12,5)+1); %5 tests where the null
%                                          %hypothesis is false
%   [h crit_p adj_p]=fdr_bh([p_null p_effect],.05,'pdep','yes');
%
%
% For a review on false discovery rate control and other contemporary
% techniques for correcting for multiple comparisons see:
%
%   Groppe, D.M., Urbach, T.P., & Kutas, M. (2011) Mass univariate analysis
% of event-related brain potentials/fields I: A critical tutorial review.
% Psychophysiology, 48(12) pp. 1711-1725, DOI: 10.1111/j.1469-8986.2011.01273.x
% http://www.cogsci.ucsd.edu/~dgroppe/PUBLICATIONS/mass_uni_preprint1.pdf
%
%
% Author:
% David M. Groppe
% Kutaslab
% Dept. of Cognitive Science
% University of California, San Diego
% March 24, 2010

%%%%%%%%%%%%%%%% REVISION LOG %%%%%%%%%%%%%%%%%
%
% 5/7/2010-Added FDR adjusted p-values
% 5/14/2013- D.H.J. Poot, Erasmus MC, improved run-time complexity

function [h crit_p adj_p]=fdr_bh(pvals,q,method,report)

if nargin<1,
    error('You need to provide a vector or matrix of p-values.');
else
    if ~isempty(find(pvals<0,1)),
        error('Some p-values are less than 0.');
    elseif ~isempty(find(pvals>1,1)),
        error('Some p-values are greater than 1.');
    end
end

if nargin<2,
    q=.05;
end

if nargin<3,
    method='pdep';
end

if nargin<4,
    report='no';
end

s=size(pvals);
if (length(s)>2) || s(1)>1,
    [p_sorted, sort_ids]=sort(reshape(pvals,1,prod(s)));
else
    %p-values are already a row vector
    [p_sorted, sort_ids]=sort(pvals);
end
[dummy, unsort_ids]=sort(sort_ids); %indexes to return p_sorted to pvals order
m=length(p_sorted); %number of tests

if strcmpi(method,'pdep'),
    %BH procedure for independence or positive dependence
    thresh=(1:m)*q/m;
    wtd_p=m*p_sorted./(1:m);
    
elseif strcmpi(method,'dep')
    %BH procedure for any dependency structure
    denom=m*sum(1./(1:m));
    thresh=(1:m)*q/denom;
    wtd_p=denom*p_sorted./[1:m];
    %Note, it can produce adjusted p-values greater than 1!
    %compute adjusted p-values
else
    error('Argument ''method'' needs to be ''pdep'' or ''dep''.');
end

if nargout>2,
    %compute adjusted p-values
    adj_p=zeros(1,m)*NaN;
    [wtd_p_sorted, wtd_p_sindex] = sort( wtd_p );
    nextfill = 1;
    for k = 1 : m
        if wtd_p_sindex(k)>=nextfill
            adj_p(nextfill:wtd_p_sindex(k)) = wtd_p_sorted(k);
            nextfill = wtd_p_sindex(k)+1;
            if nextfill>m
                break;
            end;
        end;
    end;
    adj_p=reshape(adj_p(unsort_ids),s);
end

rej=p_sorted<=thresh;
max_id=find(rej,1,'last'); %find greatest significant pvalue
if isempty(max_id),
    crit_p=0;
    h=pvals*0;
else
    crit_p=p_sorted(max_id);
    h=pvals<=crit_p;
end

if strcmpi(report,'yes'),
    n_sig=sum(p_sorted<=crit_p);
    if n_sig==1,
        fprintf('Out of %d tests, %d is significant using a false discovery rate of %f.\n',m,n_sig,q);
    else
        fprintf('Out of %d tests, %d are significant using a false discovery rate of %f.\n',m,n_sig,q);
    end
    if strcmpi(method,'pdep'),
        fprintf('FDR procedure used is guaranteed valid for independent or positively dependent tests.\n');
    else
        fprintf('FDR procedure used is guaranteed valid for independent or dependent tests.\n');
    end
end


end



