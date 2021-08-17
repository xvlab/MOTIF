function multiplot(matrix)
    figure;
    for i = 1:size(matrix,3)
        subplot(round(size(matrix,3)^0.5),size(matrix,3)/round(size(matrix,3)^0.5),i);
        imagesc(squeeze(matrix(:,:,i)));
    end
end