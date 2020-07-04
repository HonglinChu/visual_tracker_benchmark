clear
close all;
clc
addpath('/home/ubuntu/visual_tracker_benchmark/util');
addpath('/home/ubuntu/visual_tracker_benchmark/rstEval');
PATH='/home/ubuntu/visual_tracker_benchmark/results/results_OPE_CVPR13/';%需要修改的地方
attPath = './anno/att/'; % The folder that contains the annotation files for sequence attributes

attName={'illumination variation'	'out-of-plane rotation'	'scale variation'	'occlusion'	'deformation'	'motion blur'	'fast motion'	'in-plane rotation'	'out of view'	'background clutter' 'low resolution'};

attFigName={'illumination_variations'	'out-of-plane_rotation'	'scale_variations'	'occlusions'	'deformation'	'blur'	'abrupt_motion'	'in-plane_rotation'	'out-of-view'	'background_clutter' 'low_resolution'};

plotDrawStyleAll={ struct('color',[1,0,0],'lineStyle','-'),...
    struct('color',[0,1,0],'lineStyle','-'),...
    struct('color',[0,0,1],'lineStyle','-'),...
    struct('color',[0,0,0],'lineStyle','-'),...%    struct('color',[1,1,0],'lineStyle','-'),...%yellow
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

% seqs = seqs(1:10);
% trackers = trackers(1:10);

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

metricTypeSet = {'overlap','error'};
evalTypeSet = 'OPE';

rankingType = {'overlap','error'};%对于error，根据threshod进行排名，对于o据verlop根AUC进行排名

%rankNum = 24;% number of plots to show  L2RLS+KCF
rankNum =30;  % L2RLS +chuan tong

if rankNum == 10
    plotDrawStyle=plotDrawStyle10;
else
    plotDrawStyle=plotDrawStyleAll;
end

for i=1:length(metricTypeSet)
    metricType = metricTypeSet{i};%error,overlap
    switch metricType
        case 'overlap'
            xLabelName = 'Number';
            yLabelName = 'Overlap rate';
        case 'error'
            xLabelName = 'Number';
            yLabelName = 'Position error';
    end  
    
    for j=1:1
        
        evalType = evalTypeSet;%SRE, TRE, OPE
        
        plotType = [metricType '_' evalType];

        dataName = [perfMatPath 'curve_Seq_' num2str(numTrk) 'alg_curve_' evalType '.mat'];
        
     
        Curve_genPerfMat(seqs, trackers, evalType, nameTrkAll, perfMatPath,PATH);
        
        load(dataName);
        numTrk = size(curve_Seq,1); %       
        
        if rankNum > numTrk | rankNum <0
            rankNum = numTrk;
        end
        
        figName= [figPath 'curve_Seq' plotType '_' metricTypeSet{i}];
        %序列的长度
        % draw and save the overall performance plot
        Curve_plotDrawSave(numTrk,plotDrawStyle,curve_Seq,seqs,rankNum,metricTypeSet{i},nameTrkAll, xLabelName,yLabelName);
        
    end
end
