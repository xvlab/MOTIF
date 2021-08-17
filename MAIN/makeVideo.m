%make a video for basic motifs and save them
clear;clc;
load('G:\temp\Mokoghost\fpCNMF\Results\thy1-gcamp6s-m2-0114-2(motif-2s)\thy1-gcamp6s-m2-0114-2_MMStack_Pos0\results\W_basis.mat','W_basis');
W=reshape(W_basis,[200,200,size(W_basis,2),size(W_basis,3)]);
filename="basic motif.gif";
for i = 1:size(W,3)
    filename="basic motif"+i+".gif";
    for j=1:size(W,4)
        cvals = prctile(W(:),99.9);
        imagesc(W(:,:,i,j),[0 cvals]); title(sprintf('Motif %d Frame %d',i,j));
        %         F((((i-1)*size(W,4)+j)-1)*3+1)=getframe;
        %         F((((i-1)*size(W,4)+j)-1)*3+2)=getframe;
        %         F((((i-1)*size(W,4)+j)-1)*3+3)=getframe;
        
        I=frame2im(getframe);
        [I,map]=rgb2ind(I,256);
        for k=1:2
            if j == 1
                imwrite(I,map,filename,'gif', 'Loopcount',inf,'DelayTime',0.2);
            else
                imwrite(I,map,filename,'gif','WriteMode','append','DelayTime',0.2);
            end
        end
    end
    temp=squeeze(W(:,:,i,:));
    %save("basic_motif"+i,'temp');
    
end
% writerObj = VideoWriter('video.avi');
% open(writerObj);
% writeVideo(writerObj, F)
% close(writerObj);