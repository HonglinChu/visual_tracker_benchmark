clear
close all;
clc
 
addpath('./util');

seqs=configSeqs;
 
trackers=configTrackers;
 
% seqs = seqs(1:10);
% trackers = trackers(1:10);
 
numSeq=length(seqs);
numTrk=length(trackers);
 
evalType = 'OPE';
 
switch evalType
    case 'SRE'
        rpAll=['./results/results_SRE_CVPR13/'];
    case {'TRE', 'OPE'}
        rpAll=['./results/results_OPE_CVPR13/'];
end
for idxTrk=1:numTrk
    t = trackers{idxTrk};
%     time=0;
%     frame=0;
    totalFPS=0;
    for idxSeq=1:numSeq
        s = seqs{idxSeq};
        load([rpAll s.name '_' t.name '.mat']);
        res = results{1};
%       time=time+(s.endFrame-s.startFrame+1)/res.fps;  %总时间
%       frame=frame+(s.endFrame-s.startFrame+1);   %总帧数
        totalFPS=totalFPS+res.fps;
    end
%   average_FPS=frame/time;   %平均FPS
    average_FPS=totalFPS/numSeq;
    disp([trackers{idxTrk}.name]);
    disp(['FPS:',num2str(average_FPS)]);
end
