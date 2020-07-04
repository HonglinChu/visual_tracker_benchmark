close all
clear 
%clc
warning off all;
addpath('/home/ubuntu/visual_tracker_benchmark/util');

addpath('/home/ubuntu/visual_tracker_benchmark/vlfeat-0.9.21-bin/vlfeat-0.9.21/toolbox');
vl_setup
 
addpath('/home/ubuntu/visual_tracker_benchmark/rstEval');
addpath('/home/ubuntu/visual_tracker_benchmark/trackers/VIVID_Tracker')

seqs=configSeqs2;
trackers=configTrackers2;

shiftTypeSet = {'left','right','up','down','topLeft','topRight','bottomLeft','bottomRight','scale_8','scale_9','scale_11','scale_12'};

evalType='OPE'; %'OPE','SRE','TRE'

diary(['/home/ubuntu/visual_tracker_benchmark/tmp/' evalType '.txt']);

numSeq=length(seqs);
numTrk=length(trackers);

%finalPath = ['/home/ubuntu/visual_tracker_benchmark/results/results_' evalType '_CVPR13/'];
finalPath=['/home/ubuntu/visual_tracker_benchmark/results/OURS_2/'];%OTB50
if ~exist(finalPath,'dir')
    mkdir(finalPath); 
end

tmpRes_path = ['/home/ubuntu/visual_tracker_benchmark/tmp/' evalType '/'];
bSaveImage=0;

if ~exist(tmpRes_path,'dir')
    mkdir(tmpRes_path);
end
 
pathAnno = '/home/ubuntu/visual_tracker_benchmark/anno/';

%------------------------------------------------------%
%注意，有些算法无法开启并行运算，或者并行运算过程会提示有些文件找不到，是因为算法实现部分应该是启用了不能进行并行计算的函数

delete(gcp('nocreate'));
if parpool('local')==0
   parpool open;
end   

%lambda=[0.05,0.075,0.1,0.15,0.25,0.5]; %在0.5左右OTB50表现比较好
%lambda=[0.08,0.085,0.09,0.095,0.105,0.110,0.115,0.12,0.125];
%lambda=[0.01,0.025,0.045,0.05,0.055];
%lambda=[0.000002,0.000004,0.000005,0.000006,0.000008];%0.0001
%5*e6 --- 1e-5  效果最好
lambda=[1];
%lambda2=[15, 15.5, 16, 16.5, 17]
lambda2=[15];
rate=[1.4]%
for k=1:1
    ratio=rate(k);
for i=1
    lambda_1=lambda(i);
for j=1:1
    lambda_2=lambda2(j);
for alpha=1
 % disp(['lambda_1->' sprintf('%.3f',lambda_1) 'lambda_2->'  sprintf('%.3f',lambda_2) ',alpha->' sprintf('%.3f',alpha)]);
  disp(['alpha->' sprintf('%.3f',alpha) ',ratio->' sprintf('%.3f',ratio) ',lambda2->' sprintf('%.3f',lambda_2)]);
  %------------------------------------------------------%
  parfor idxSeq=1:length(seqs)
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
            %disp([num2str(idxTrk) '_' t.name ', ' num2str(idxSeq) '_' s.name ': ' num2str(idx) '/' num2str(length(subSeqs))])       

            rp = [tmpRes_path s.name '_' t.name '_' num2str(idx) '/'];
            if bSaveImage&~exist(rp,'dir')
                mkdir(rp);
            end
            subS = subSeqs{idx};
            subS.name = [subS.name '_' num2str(idx)];
            %---------------------多线程--------------------------%
            run_function=str2func(['run_' t.name]);
            %funcName = ['res=run_' t.name '(subS, rp, bSaveImage);'];
            %------------------------------------------------------%

            try
                switch t.name
                    case {'VR','TM','RS','PD','MS'}
                    otherwise
                        cd(['./trackers/' t.name]);
                        addpath(genpath('./'))
                end
                %---------------------多线程--------------------------%
                %eval(funcName);%eval不能
                subS.alpha=alpha;
                subS.lambda_1=lambda_1;
                subS.lambda_2=lambda_2;
                subS.ratio=ratio;
                res=run_function(subS, rp, bSaveImage);
                %------------------------------------------------------%
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
            %catch err% 这里进行适当的修改
            catch  err
                disp(err.message);
                %disp(err.stack.line);
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
        %---------------------多线程--------------------------%
           parpoolsave(finalPath,s.name,t.name,results);
           %save([finalPath s.name '_' t.name '.mat'], 'results');
        %------------------------------------------------------%
    end
  end
  perfPlot2;
end
end
end
end
%关闭进程
delete(gcp('nocreate'));

figure
t=clock;
t=uint8(t(2:end));
disp([num2str(t(1)) '/' num2str(t(2)) ' ' num2str(t(3)) ':' num2str(t(4)) ':' num2str(t(5))]);


