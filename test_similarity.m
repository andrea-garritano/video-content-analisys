setup ;

senti = 1;
id = 1;

% load a pretrained model

net = load('data/imagenet-vgg-verydeep-16.mat') ;


load('onekconcept_senti.mat');
weightVideo = single(zeros(3089,1)) ;

d = dir([strcat('/home/andrea/Tesi/video/', num2str(id),'/'), '*.jpg']);
num = length(d(not([d.isdir])));
nFrame = num;

for j = 1 : nFrame
    % obtain and preprocess an image
    fprintf('nFrame %d/%d\n',j,nFrame);
    im = imread(strcat('/home/andrea/Tesi/video/', num2str(id),'/',num2str(j),'.jpg') );
    im_ = single(im) ; % note: 255 range
    im_ = imresize(im_, net.normalization.imageSize(1:2)) ;
    im_ = im_ - net.normalization.averageImage ;

    % run the CNN
    res = vl_simplenn(net, im_) ;
        
    % show the classification result
    scores = squeeze(gather(res(end).x)) ;

    command = strcat('cd /home/andrea/Tesi/DeepSentiBank/DeepSentiBank/ && python /home/andrea/Tesi/DeepSentiBank/DeepSentiBank/sentiBank_backup.py /home/andrea/Tesi/video/', num2str(id), '/', num2str(j), '.jpg');
    system(command);
    
    %SentiBank
    f = fopen(['/home/andrea/Tesi/video/' num2str(id) '/' num2str(j) '-features_prob.dat']);
    features_senti = fread(f,[2089 1],'single');
    fclose(f);
        
    scores = vertcat(scores,features_senti);
    weightVideo = weightVideo + scores;
end
norm2 = norm(weightVideo);
weightVideo = weightVideo *1/norm2;

% Search minime distace (weightVideo, x)
minId = 0 ;
minDistance = Inf ;
[m,n] = size(resultMatrix);

nCols = n ;

for k = 1 : nCols
    dataset = resultMatrix (:,k);
    distance =norm(weightVideo - dataset);
    if distance < minDistance
        minId = k;
        minDistance = distance;
    end
end

fprintf ('VideoId %d is similar to VideoId %d\n', id, minId);
