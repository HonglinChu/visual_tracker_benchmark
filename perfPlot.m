%clear
%close all;
addpath('/home/ubuntu/visual_tracker_benchmark/util');
addpath('/home/ubuntu/visual_tracker_benchmark/rstEval');
PATH='/home/ubuntu/visual_tracker_benchmark/results/results_OPE_CVPR13/';%需要修改的地方


attPath = './anno/att/'; % The folder that contains the annotation files for sequence attributes
attName={'illumination variation'	'out-of-plane rotation'	'scale variation'	'occlusion'	'deformation'	'motion blur'	'fast motion'	'in-plane rotation'	'out of view'	'background clutter' 'low resolution'};
attFigName={'illumination_variations'	'out-of-plane_rotation'	'scale_variations'	'occlusions'	'deformation'	'blur'	'abrupt_motion'	'in-plane_rotation'	'out-of-view'	'background_clutter' 'low_resolution'};

%颜色线条
plotDrawStyleAll={ struct('color',[1,0,0],'lineStyle','-'),...
    struct('color',[0,1,0],'lineStyle','-'),...
    struct('color',[0,0,1],'lineStyle','-'),...
    struct('color',[0,0,0],'lineStyle','-'),...%struct('color',[1,1,0],'lineStyle','-'),...%yellow
    struct('color',[1,0,1],'lineStyle','-'),...%pink
    struct('color',[0,1,1],'lineStyle','-'),...
    struct('color',[0.5,0.5,0.5],'lineStyle','-'),...%gray-25%
    struct('color',[136,0,21]/255,'lineStyle','-'),...%dark red
    struct('color',[255,127,39]/255,'lineStyle','-'),...%orange
    struct('color',[0,162,232]/255,'lineStyle','-'),...%Turquoise
    struct('color',[163,73,164]/255,'lineStyle','-'),...%purple    %%%%%%%%%%%%%%%%%%%%
    struct('color',[1,0,0],'lineStyle','--'),...
    struct('color',[0,1,0],'lineStyle','--'),...
    struct('color',[0,0,1],'lineStyle','--'),...%
    struct('color',[0,0,0],'lineStyle','--'),...%    struct('color',[1,1,0],'lineStyle','--'),...%yellow
    struct('color',[1,0,1],'lineStyle','--'),...%pink
    struct('color',[0,1,1],'lineStyle','--'),...
    struct('color',[0.5,0.5,0.5],'lineStyle','--'),...%gray-25%
    struct('color',[136,0,21]/255,'lineStyle','--'),...%dark red
    struct('color',[255,127,39]/255,'lineStyle','--'),...%orange
    struct('color',[0,162,232]/255,'lineStyle','--'),...%Turquoise
    struct('color',[163,73,164]/255,'lineStyle','--'),...%purple    %%%%%%%%%%%%%%%%%%%
    struct('color',[1,0,0],'lineStyle','-.'),...
    struct('color',[0,1,0],'lineStyle','-.'),...
    struct('color',[0,0,1],'lineStyle','-.'),...
    struct('color',[0,0,0],'lineStyle','-.'),...%    struct('color',[1,1,0],'lineStyle',':'),...%yellow
    struct('color',[1,0,1],'lineStyle','-.'),...%pink
    struct('color',[0,1,1],'lineStyle','-.'),...
    struct('color',[0.5,0.5,0.5],'lineStyle','-.'),...%gray-25%
    struct('color',[136,0,21]/255,'lineStyle','-.'),...%dark red
    struct('color',[255,127,39]/255,'lineStyle','-.'),...%orange
    struct('color',[0,162,232]/255,'lineStyle','-.'),...%Turquoise
    struct('color',[163,73,164]/255,'lineStyle','-.'),...%purple
    };

%线的风格
plotDrawStyle10={struct('color',[1,0,0],'lineStyle','-'),...
    struct('color',[0,1,0],'lineStyle','--'),...
    struct('color',[0,0,1],'lineStyle',':'),...
    struct('color',[0,0,0],'lineStyle','-'),...%    struct('color',[1,1,0],'lineStyle','-'),...%yellow
    struct('color',[1,0,1],'lineStyle','--'),...%pink
    struct('color',[0,1,1],'lineStyle',':'),...
    struct('color',[0.5,0.5,0.5],'lineStyle','-'),...%gray-25%
    struct('color',[136,0,21]/255,'lineStyle','--'),...%dark red
    struct('color',[255,127,39]/255,'lineStyle',':'),...%orange
    struct('color',[0,162,232]/255,'lineStyle','-'),...%Turquoise
    };

seqs=configSeqs;

trackers=configTrackers;

numSeq=length(seqs);
numTrk=length(trackers);

nameTrkAll=cell(numTrk,1);
for idxTrk=1:numTrk
    t = trackers{idxTrk};
    nameTrkAll{idxTrk}=t.namePaper;
end

nameSeqAll=cell(numSeq,1);
numAllSeq=zeros(numSeq,1);

att=[];
for idxSeq=1:numSeq
    s = seqs{idxSeq};
    nameSeqAll{idxSeq}=s.name;
    
    s.len = s.endFrame - s.startFrame + 1;
    
    numAllSeq(idxSeq) = s.len;
    
    att(idxSeq,:)=load([attPath s.name '.txt']);
end

attNum = size(att,2);

figPath = './figs/overall/';

%perfMatPath = './perfMat/overall/'; z

perfMatPath = './figs/overall/';

if ~exist(figPath,'dir')
    mkdir(figPath);
end

evalTypeSet = 'OPE';
metricTypeSet = {'overlap','error'};
rankingType = {'AUC','threshold'};%对于error，根据threshod进行排名，对于overlop根据AUC进行排名

%rankNum = 24;%number of plots to show  L2RLS+KCF
rankNum =30;  

if rankNum == 10
    plotDrawStyle=plotDrawStyle10;
else
    plotDrawStyle=plotDrawStyleAll;
end

thresholdSetOverlap = 0:0.05:1;
thresholdSetError = 0:50;

for i=1:length(metricTypeSet)
    
    metricType = metricTypeSet{i};%error,overlap
    switch metricType
        case 'overlap'
            thresholdSet = thresholdSetOverlap;
            rankIdx = 11;   %计算代表中间值，这个值很重要百分之五十
            xLabelName = 'Overlap threshold';
            yLabelName = 'Success rate';
        case 'error'
            thresholdSet = thresholdSetError;
            rankIdx = 21;  %像素是20
            xLabelName = 'Location error threshold';
            yLabelName = 'Precision';
    end  
    
    tNum = length(thresholdSet);
    
    for j=1:1
        
        evalType = evalTypeSet;%SRE, TRE, OPE
        
        plotType = [metricType '_' evalType];
        
        switch metricType
            case 'overlap'
                titleName = ['Success plots of ' evalType '-OTB2013'];
            case 'error'
                titleName = ['Precision plots of ' evalType '-OTB2013'];
        end

        dataName = [perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_'  plotType '.mat'];
        
        % If the performance Mat file, dataName, does not exist, it will call
        % genPerfMat to generate the file.
        %改动
%         if ~exist(dataName)
%             genPerfMat(seqs, trackers, evalType, nameTrkAll, perfMatPath,PATH);
%         end %        
        genPerfMat(seqs, trackers, evalType, nameTrkAll, perfMatPath,PATH);
        
        load(dataName);
        numTrk = size(aveSuccessRatePlot,1);        
        
        if rankNum > numTrk | rankNum <0
            rankNum = numTrk;
        end
        
        figName= [figPath 'quality_plot_' plotType '_' rankingType{i}];
        idxSeqSet = 1:length(seqs);
        
        %metricType=alpha;
        
        
        % Success and  Precision Plots
        % draw and save the overall performance plot
        plotDrawSave(numTrk,plotDrawStyle,aveSuccessRatePlot,idxSeqSet,rankNum,rankingType{i},rankIdx,nameTrkAll,thresholdSet,titleName, xLabelName,yLabelName,figName,metricType);
        
        % Attribute Plots
%         attTrld = 0;
%         for attIdx=1:attNum 
%             idxSeqSet=find(att(:,attIdx)>attTrld);
%             if length(idxSeqSet) < 2
%                 continue;
%             end
%             disp([attName{attIdx} ' ' num2str(length(idxSeqSet))])
%             
%             figName=[figPath attFigName{attIdx} '_'  plotType '_' rankingType{i}];
%             titleName = ['Plots of ' evalType ': ' attName{attIdx} ' (' num2str(length(idxSeqSet)) ')'];
%             
%             switch metricType
%                 case 'overlap'
%                     %titleName = ['Success plots of ' evalType ' - ' attName{attIdx} ' (' num2str(length(idxSeqSet)) ')'];
%                      titleName = ['Success plots of ' evalType ' - ' attName{attIdx}];
%                 case 'error'
%                     titleName = ['Precision plots of ' evalType ' - ' attName{attIdx}];
%             end
%             
%             plotDrawSave(numTrk,plotDrawStyle,aveSuccessRatePlot,idxSeqSet,rankNum,rankingType{i},rankIdx,nameTrkAll,thresholdSet,titleName, xLabelName,yLabelName,figName,metricType);
%         end        
%     end
    end
end




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
    
