function [aveErrCoverageAll, aveErrCoverageAll_P, aveErrCoverageAll_R, aveErrCenterAll] = calcPlotErr_PR(seqs, trks, pathAnno, pathRes, pathPlot, bPlot)

LineWidth = 2;
LineStyle = '-';%':';%':' '.-'
% Curvature = [0,0];

% path_anno = '.\anno\';
lostCount = zeros(length(seqs), length(trks));
thred = 0.33;
% lostRate = zeros(length(seqs), length(trks));
% lostRateEachAlg = zeros(1, length(trks));
errCenterAll=[];
errCoverageAll=[];
aveErrCoverageAll_P=[];
aveErrCoverageAll_R=[];


lenTotalSeq = 0;
rectMat=[];
for index_seq=1:length(seqs)
    seq = seqs{index_seq};
    seq_name = seq.name
    
    fileName = [pathAnno seq_name '.txt'];
    rect_anno = dlmread(fileName);
    seq_length = seq.endFrame-seq.startFrame+1; %size(rect_anno,1);
    lenTotalSeq = lenTotalSeq + seq_length;
    
    centerGT = [rect_anno(:,1)+(rect_anno(:,3)-1)/2 rect_anno(:,2)+(rect_anno(:,4)-1)/2];
    
    %     rect=[];
%     indexLost = zeros(length(trks), seq_length);
%     if bPlot
%         clf
%     end
    
    for index_algrm=1:length(trks)
        algrm = trks{index_algrm};
        name=algrm.name;
        
        trackerNames{index_algrm}=name;
        
%         res_path = [pathRes seq_name '_' name '/'];
        
        fileName = [pathRes seq_name '_' name '.mat'];
    
        load(fileName);
        rectMat = zeros(seq_length, 4);
        
        switch results.type
            case 'rect'                
                rectMat = results.res;
            case 'ivtAff'
                for i = 1:seq_length
                    [rect c] = calcRectCenter(results.tmplsize, results.res(i,:), 'Color', [1 1 1], 'LineWidth', LineWidth,'LineStyle',LineStyle);
                    rectMat(i,:) = rect;
                    %                     center(i,:) = c;
                end
            case 'L1Aff'
                for i = 1:seq_length
                    [rect c] = calcCenter_L1(results.res(i,:), results.tmplsize);
                    rectMat(i,:) = rect;
                end
            case 'LK_Aff'
                for i = 1:seq_length
                    [corner c] = getLKcorner(results.res(2*i-1:2*i,:), results.tmplsize);
                    rectMat(i,:) = corner2rect(corner);
                end
            case '4corner'
                for i = 1:seq_length
                     rectMat(i,:) = corner2rect(results.res(2*i-1:2*i,:));
                end
            otherwise
                continue;
        end 
 
        center = [rectMat(:,1)+(rectMat(:,3)-1)/2 rectMat(:,2)+(rectMat(:,4)-1)/2];
        
        errCenter(:,index_algrm) = sqrt(sum(((center(1:seq_length,:) - centerGT(1:seq_length,:)).^2),2));
        
        %err(:,index_algrm) = calcRectInt(rectMat(1:seq_length,:),rect_anno(1:seq_length,:));

        [err(:,index_algrm), err_P(:,index_algrm), err_R(:,index_algrm)] = calcRectInt_PR(rectMat(1:seq_length,:),rect_anno(1:seq_length,:));
        
        if bPlot            
            h1=figure(1);
            plot(err(:,index_algrm),'color', trks{index_algrm}.color,'LineWidth',LineWidth,'LineStyle',LineStyle);
            hold on 

            h2=figure(2);
            plot(err_P(:,index_algrm),'color', trks{index_algrm}.color,'LineWidth',LineWidth,'LineStyle',LineStyle);
            hold on

            h3=figure(3);
            plot(err_R(:,index_algrm),'color', trks{index_algrm}.color,'LineWidth',LineWidth,'LineStyle',LineStyle);
            hold on
            
            h4=figure(4);
            plot(errCenter(:,index_algrm),'color', trks{index_algrm}.color,'LineWidth',LineWidth,'LineStyle',LineStyle);
            hold on 
        end
    end
    
    if bPlot
        figure(1);
        axis tight
        set(gca,'fontsize',20);
        
        xlabel(h1,'string', ['# ' seqs{index_seq}.name],'FontSize',20)
        ylabel(h1,'string','Coverage/quality','FontSize',20)        
        
        print(h1, '-depsc', [pathPlot seq_name '_coverage']);
        imwrite(frame2im(getframe(h1)), [pathPlot seq_name '_coverage.png']);

        figure(2);
        axis tight
        set(gca,'fontsize',20);
        
        xlabel(h2,'string', ['# ' seqs{index_seq}.name],'FontSize',20)
        ylabel(h2,'string','Coverage_P/quality','FontSize',20)        
        
        print(h2, '-depsc', [pathPlot seq_name '_coverage_P']);
        imwrite(frame2im(getframe(h2)), [pathPlot seq_name '_coverage_P.png']);

        figure(3);
        axis tight
        set(gca,'fontsize',20);
        
        xlabel(h3,'string', ['# ' seqs{index_seq}.name],'FontSize',20)
        ylabel(h3,'string','Coverage_R/quality','FontSize',20)        
        
        print(h3, '-depsc', [pathPlot seq_name '_coverage_R']);
        imwrite(frame2im(getframe(h3)), [pathPlot seq_name '_coverage_R.png']);
               
        figure(4);
        axis tight;
        set(gca,'fontsize',20);

        xlabel(h4,'string',['# ' seqs{index_seq}.name],'FontSize',20)
        ylabel(h4,'string','Center error','FontSize',20)
%         legend(trackerNames,'Position', 'Best');
        
        print(h4, '-depsc', [pathPlot seq_name '_center']);
        imwrite(frame2im(getframe(h4)), [pathPlot seq_name '_center.png']);
        
        clf(h1);
        clf(h2);
        clf(h3);
        clf(h4);
    end
    
    aveErrCoverage(index_seq,:) = sum(err)/seq_length;
    aveErrCoverage_P(index_seq,:) = sum(err_P)/seq_length;
    aveErrCoverage_R(index_seq,:) = sum(err_R)/seq_length;
    errCoverageAll(index_seq,:) = sum(err);
    errCoverageAll_P(index_seq,:) = sum(err_P);
    errCoverageAll_R(index_seq,:) = sum(err_R);
    
    aveErrCenter(index_seq,:) = sum(errCenter)/seq_length;
    errCenterAll(index_seq,:) = sum(errCenter);
    
    lostCount(index_seq,:)=sum(err<thred);
    
    err = [];
end

aveErrCoverageAll=sum(errCoverageAll)/lenTotalSeq
aveErrCoverageAll_P=sum(errCoverageAll_P)/lenTotalSeq
aveErrCoverageAll_R=sum(errCoverageAll_R)/lenTotalSeq

aveErrCenterAll=sum(errCenterAll)/lenTotalSeq

save(['./errAnalysis.mat'], 'aveErrCoverage', 'aveErrCoverage_P', 'aveErrCoverage_R', 'aveErrCenter', 'aveErrCoverageAll', 'aveErrCoverageAll_P', 'aveErrCoverageAll_R', 'aveErrCenterAll', 'lostCount', 'thred');
% lostRateEachAlg=sum(lostCount)/lenTotalSeq
% lostCount
% sum(lostCount)