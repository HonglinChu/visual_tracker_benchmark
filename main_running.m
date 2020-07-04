close all
clear 
clc
warning off all;
addpath('/home/ubuntu/visual_tracker_benchmark/util');
%addpath('./util');
addpath(('/home/ubuntu/visual_tracker_benchmark/vlfeat-0.9.21-bin/vlfeat-0.9.21/toolbox'));
vl_setup

addpath(('/home/ubuntu/visual_tracker_benchmark/rstEval'));
addpath(['/home/ubuntu/visual_tracker_benchmark/trackers/VIVID_Tracker'])

seqs=configSeqs;% 1-test only 2;    2-otb100 
trackers=configTrackers;

shiftTypeSet = {'left','right','up','down','topLeft','topRight','bottomLeft','bottomRight','scale_8','scale_9','scale_11','scale_12'};

evalType='OPE'; %'OPE','SRE','TRE'

diary(['/home/ubuntu/visual_tracker_benchmark/tmp/' evalType '.txt']);

numSeq=length(seqs);
numTrk=length(trackers);   

finalPath = ['/home/ubuntu/visual_tracker_benchmark/results/results_' evalType '_CVPR13/'];

if ~exist(finalPath,'dir')
    mkdir(finalPath); 
    endi 
end

tmpRes_path = ['/home/ubuntu/visual_tracker_benchmark/tmp/' evalType '/'];
bSaveImage=0;

if ~exist(tmpRes_path,'dir')
    mkdir(tmpRes_path);
end
 
pathAnno = '/home/ubuntu/visual_tracker_benchmark/anno/';

for idxSeq=1:length(seqs)
    s = seqs{idxSeq};
    s.len = s.endFrame - s.startFrame + 1;
    s.s_frames = cell(s.len,1);
    nz	= strcat('%0',num2str(s.nz),'d'); %number of zeros in the name of image
    for i=1:s.len
        image_no = s.startFrame + (i-1);
        id = sprintf(nz,image_no);
        s.s_frames{i} = strcat(s.path,id,'.',s.ext);
    end
    
    img = imread(s.s_frames{1});
    [imgH,imgW,ch]=size(img);
    
    rect_anno = dlmread([pathAnno s.name '.txt']);
    numSeg = 20;
    addpath('/home/ubuntu/visual_tracker_benchmark/util');
    [subSeqs, subAnno]=splitSeqTRE(s,numSeg,rect_anno);
    
    switch evalType
        
        case 'SRE'
            subS = subSeqs{1};
            subA = subAnno{1};
            subSeqs=[];
            subAnno=[];
            r=subS.init_rect;
            
            for i=1:length(shiftTypeSet)
                subSeqs{i} = subS;
                shiftType = shiftTypeSet{i};
                subSeqs{i}.init_rect=shiftInitBB(subS.init_rect,shiftType,imgH,imgW);
                subSeqs{i}.shiftType = shiftType;
                subAnno{i} = subA;
            end

        case 'OPE'
            subS = subSeqs{1};
            subSeqs=[];
            subSeqs{1} = subS;
            
            subA = subAnno{1};
            subAnno=[];
            subAnno{1} = subA;
        otherwise
    end
            
    for idxTrk=1:numTrk
        t = trackers{idxTrk};
        switch t.name
            case {'VTD','VTS'}
                continue;
        end

        results = [];
        for idx=1:length(subSeqs)
            disp([num2str(idxTrk) '_' t.name ', ' num2str(idxSeq) '_' s.name ': ' num2str(idx) '/' num2str(length(subSeqs))])       

            rp = [tmpRes_path s.name '_' t.name '_' num2str(idx) '/'];
            if bSaveImage&~exist(rp,'dir')
                mkdir(rp);
            end
            
            subS = subSeqs{idx};
            
            subS.name = [subS.name '_' num2str(idx)];
            
            funcName = ['res=run_' t.name '(subS, rp, bSaveImage);'];

            try
                switch t.name
                    case {'VR','TM','RS','PD','MS'}
                    otherwise
                        cd(['./trackers/' t.name]);
                        addpath(genpath('./'))
                end
                
                eval(funcName);
                
                switch t.name
                    case {'VR','TM','RS','PD','MS'}
                    otherwise
                        rmpath(genpath('./'))
                        cd('../../');
                end
                if isempty(res)
                    results = [];
                    break;
                end
                
            catch  err
                disp(err);
                err.stack
                rmpath(genpath('/home/ubuntu/visual_tracker_benchmark/'))
                cd('../../');
                res=[];
                continue;
            end
            
            res.len = subS.len;
            res.annoBegin = subS.annoBegin;
            res.startFrame = subS.startFrame;
                    
            results{idx} = res; 
        end
        save([finalPath s.name '_' t.name '.mat'], 'results');
    end
end

figure
t=clock;
t=uint8(t(2:end));
disp([num2str(t(1)) '/' num2str(t(2)) ' ' num2str(t(3)) ':' num2str(t(4)) ':' num2str(t(5))]);

