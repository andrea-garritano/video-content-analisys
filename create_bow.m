setup ;

% load a pretrained model
net = load('data/imagenet-vgg-verydeep-16.mat') ;

resultMatrix = [] ;

d = dir(['/home/andrea/Tesi/video/', '*.mp4']);
num = length(d(not([d.isdir])));
nVideoTot = num * 90/100;
nVideo = fix(nVideoTot) ;

for i = 1:nVideo
    d = dir([strcat('/home/andrea/Tesi/video/', num2str(i),'/'), '*.jpg']);
    num = length(d(not([d.isdir])));
    nFrame = num;
    
    weightVideo = single(zeros(3089,1)) ;
    for j = 1 : nFrame
        % obtain and preprocess an image
        fprintf('nVideo: %d/%d nFrame %d/%d\n',i,nVideo,j,nFrame)
        im = imread(strcat('/home/andrea/Tesi/video/', num2str(i),'/',num2str(j),'.jpg') );
        im_ = single(im) ; % note: 255 range
        im_ = imresize(im_, net.normalization.imageSize(1:2)) ;
        im_ = im_ - net.normalization.averageImage ;

        % run the CNN
        res = vl_simplenn(net, im_) ;
        
        % show the classification result
        scores = squeeze(gather(res(end).x)) ;
        
        weightVideo = weightVideo + scores ;
        
    end
    norm2 = norm(weightVideo);
    weightVideo = weightVideo *1/norm2;
    resultMatrix = [resultMatrix weightVideo] ;
end

save('resultMatrixBpca.mat', 'resultMatrix')
% run Pca for squeezing the features array
pca_percent = 1/16;
proj_size_senti = round(size(resultMatrix,1) * pca_percent);
[ Dproj, Dmean ] = pca_means(resultMatrix, proj_size_senti);
resultMatrix = project_with_pca(resultMatrix, Dmean, Dproj);
disp(strcat('size PCA descr: ',num2str(size(resultMatrix(1,:), 2))));
save('resultMatrixApca.mat', 'resultMatrix')
