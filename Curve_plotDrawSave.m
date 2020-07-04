function Curve_plotDrawSave(numTrk,plotDrawStyle,curve_Seq,seqs,rankNum,rankingType,nameTrkAll,xLabelName,yLabelName)

scrsz = get(0,'ScreenSize');
for idxSeq=1:length(seqs)%对于每一个视频
    for idxTrk=1:numTrk  %遍历每一个tracking
                         %each row is the sr plot of one sequence
        tmp=curve_Seq(idxTrk, idxSeq,:);
        switch rankingType
            case 'overlap'
                perf(idxTrk) = tmp{1};%AUC曲线下面积
            case 'error'
                perf(idxTrk) = tmp{2};%像素点误差小于20个像素点的精度
        end
    end
    
    switch rankingType
            case 'overlap'
                perf(idxTrk) = tmp{1};               %AUC曲线下面积
                [tmp,indexSort]=sort(perf,'descend');%sort函数默认是升序排列
            case 'error'
                perf(idxTrk) = tmp{2};%像素点误差小于20个像素点的精度f
                [tmp,indexSort]=sort(perf);%sort函数默认是升序排列
    end
   
    i=1;
    fontSize = 16;%16
    fontSizeLegend = 10;

    figure1 = figure;
    
    axes1 = axes('Parent',figure1,'FontSize',14);
    for idxTrk=indexSort(1:rankNum)% rankNum是算法的数量 ,从大到小排列
        tmp=curve_Seq(idxTrk,idxSeq,:);
        switch rankingType
            case 'overlap'  
                score=sprintf('%.3f', tmp{1});
                thresholdSet=1:2:length(tmp{3}); %当图片数量太多的时候间隔抽取
                bb=tmp{3}(1:2:end);
                axis([-inf, inf ,0 ,1]) 
                
            case 'error'
                
                score=sprintf('%.1f', tmp{2});  %保留一位小数
                score=str2num(score);
                zhengshu=fix(score);     %取整数部分
                yushu =score-zhengshu;   %小数部分
                a=num2str(zhengshu,'%03d');
                b=num2str(yushu*10);
                score=[a '.' b];
                thresholdSet=1:2:length(tmp{4});%当图片数量太多的时候间隔抽取
                bb=tmp{4}(1:2:end);
                axis([-inf, inf, 0, 50]) 
        end    
       
        tmpName{i} = [nameTrkAll{idxTrk} ' [' score ']'];
        h(i) = plot(thresholdSet,bb,'color',plotDrawStyle{i}.color, 'lineStyle', plotDrawStyle{i}.lineStyle,'lineWidth', 1,'Parent',axes1);
        grid on
        hold on
        i=i+1;
    end

    titleName=seqs{idxSeq}.name;
    legend(tmpName,'Interpreter', 'none','fontsize',fontSizeLegend);
    %title([rankingType ' of ' titleName],'fontsize',fontSize);
    xlabel(titleName,'fontsize',fontSize);
    ylabel(yLabelName,'fontsize',fontSize);
    
%     titleName=seqs{idxSeq}.name;
%     %xLabelName=[titleName 'sequence'];
%     set(gca,'fontsize',10,'FontWeight','bold');
%     legend(tmpName,'Interpreter', 'none','fontsize',fontSizeLegend,'FontWeight','bold','location','eastoutside');
%     %title([rankingType ' of ' titleName],'Interpreter','none','fontsize',fontSize,'FontWeight','bold');
%     xlabel(titleName,'Interpreter','none','fontsize',fontSize,'FontWeight','bold');
%     ylabel(yLabelName,'fontsize',fontSize,'FontWeight','bold');
    
    
    hold off
    
    figWidth=1000;   % figWidth = 702; % ͼƬ���
    figHeight = 200; % 
    numTrkThre = 20; % 
    heightIntv = 8;  % 
    if numTrk <= numTrkThre
        figSize = [0 0 figWidth figHeight];
    else
        figHeight_2 = figHeight + (heightIntv * numTrk - numTrkThre);
        figSize = [0 0 figWidth figHeight_2];
    end
    figName=['./Curve_plot/' rankingType '/' titleName];
    set(gcf, 'position', figSize);
    tightfig;
    print(gcf, '-dpdf',  [figName, '.pdf']); % ��Ҫ����ű���
    %saveas(gcf,'-r300', figName,'png');
    print(gcf, '-dpng', '-r300', [figName, '.png']); % ��Ҫ����ű���
    
    %saveas(gcf,['./Curve_plot/' rankingType '/' titleName],'png');
end

end
