function Curve_genPerfMat(seqs, trackers, evalType, nameTrkAll, perfMatPath,resultsPath)

pathAnno = './anno/';
numTrk = length(trackers);%

thresholdSetOverlap = 0:0.05:1;
thresholdSetError = 0:50;

switch evalType
    case 'SRE'
        rpAll=['./results/results_SRE_CVPR13/'];
    case {'TRE', 'OPE'}
        %rpAll=['./results/results_TRE_CVPR13/'];
        rpAll=[resultsPath];
end

for idxSeq=1:length(seqs)%依次计算每一个视频的精度
    s = seqs{idxSeq};
    
    s.len = s.endFrame - s.startFrame + 1;
    s.s_frames = cell(s.len,1);
    nz	= strcat('%0',num2str(s.nz),'d'); %number of zeros in the name of image
    for i=1:s.len
        image_no = s.startFrame + (i-1);
        id = sprintf(nz,image_no);
        s.s_frames{i} = strcat(s.path,id,'.',s.ext);
    end
    
    rect_anno = dlmread([pathAnno s.name '.txt']);
    numSeg = 20;
    [subSeqs, subAnno]=splitSeqTRE(s,numSeg,rect_anno);
    
    nameAll=[];
    for idxTrk=1:numTrk
        t = trackers{idxTrk};
        %         load([rpAll s.name '_' t.name '.mat'], 'results','coverage','errCenter');
        
        load([rpAll s.name '_' t.name '.mat'])
        disp([s.name ' ' t.name]);
        
        aveCoverageAll=[];
        aveErrCenterAll=[];
        errCvgAccAvgAll = 0;
        errCntAccAvgAll = 0;
        errCoverageAll = 0;
        errCenterAll = 0;
        
        lenALL = 0;
        
        switch evalType
            case 'SRE'
                idxNum = length(results);
                anno=subAnno{1};
            case 'TRE'
                idxNum = length(results);
            case 'OPE'
                idxNum = 1;
                anno=subAnno{1};
        end
        
        successNumOverlap = zeros(idxNum,length(thresholdSetOverlap));
        successNumErr = zeros(idxNum,length(thresholdSetError));
        
        for idx = 1:idxNum
            
            res = results{idx};
            
            if strcmp(evalType, 'TRE')
                anno=subAnno{idx};
            end
            
            len = size(anno,1);
            
            if isempty(res.res)
                break;
            end
            
            if ~isfield(res,'type')&&isfield(res,'transformType')
                res.type = res.transformType;
                res.res = res.res';
            end
            %计算当前video的 平均重叠率 ，平均中心误差，每一帧的errCoverage重叠率 和每一帧的errCenter中心误差 
            [aveCoverage, aveErrCenter, errCoverage, errCenter] = calcSeqErrRobust(res, anno);
            
        end
        
        
        if strcmp(evalType, 'OPE')
            %aveSuccessRatePlot(idxTrk, idxSeq,:) = successNumOverlap/(lenALL+eps);
            %aveSuccessRatePlotErr(idxTrk, idxSeq,:) = successNumErr/(lenALL+eps);
            %aveErrCenter=sum(errCenter<=20)/length(errCenter);
            curve_Seq(idxTrk, idxSeq,:)= {aveCoverage, aveErrCenter,errCoverage, errCenter};
    
        else
            %aveSuccessRatePlot(idxTrk, idxSeq,:) = sum(successNumOverlap)/(lenALL+eps);
            %aveSuccessRatePlotErr(idxTrk, idxSeq,:) = sum(successNumErr)/(lenALL+eps);
        end
    end
end
%

dataName3=[perfMatPath 'curve_Seq_' num2str(numTrk) 'alg_curve_' evalType '.mat'];
save(dataName3,'curve_Seq','nameTrkAll');

