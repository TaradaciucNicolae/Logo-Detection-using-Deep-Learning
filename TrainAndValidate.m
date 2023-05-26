function TrainAndValidate(~,~)

%% CNN for image classification
%+++++++++++++++++++++++++++++++++++

clear all
clc


%% PARAMETERS   // Etapa 1 -> Colectarea si pregatirea setului de date.                                    stage1
% the size of the input images
inputSize = [227 227 3];
% training parameters
MBS=10;% mini-batch size
NEP=30; % number of epochs


%% TRAINING AND VALIDATION DATASETS                       

% indicate the path to the training and validation images
pathImagesTrain='D:\Facultate\An 3\Semestrul 2\SVA\Proiect SVA\Proiect\images';
% full path of the folder with training images. The folder includes a separate subfolder for each class


% // Etapa 2-> separarea setului de date in subset de antrenare si unul de testare                            stage 2
% //        -> Augmentarea datelor     

% create the datastore with the training and validation images
imds = imageDatastore(pathImagesTrain,'IncludeSubfolders',true,'LabelSource','foldernames');
% split the dataset into training and validation datasets
[imdsTrain,imdsValidation] = splitEachLabel(imds,0.7,'randomized');
numClasses = numel(categories(imdsTrain.Labels)); %the number of classes
% augment the training and validation dataset
pixelRange = [-30 30];
imageAugmenter = imageDataAugmenter( ... 
    'RandXReflection',true, ... // reflexia in oglinda
    'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange);
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain, ...
    'DataAugmentation',imageAugmenter,'ColorPreprocessing', 'gray2rgb');
augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation,'ColorPreprocessing', 'gray2rgb');



%% DESIGN THE ARCHITECTURE  //  Etapa 3 din antrenare -> Definirea arhitecturii retelei                      stage3
% load the pretrained model
net = alexnet;
% take the layers for transfer of learning
layersTransfer = net.Layers(1:end-3);

% create the new architecture: the last fully connected layer is configured for the necessary number of classes

layersNew = [ %        // Etapa 4 de initializare a parametrilor retelei                                     stage4
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer]; %% pondere  -  rata de invatare (Cu cat e mai mic cu atat se reduc mai mult instabilitatile si
                                                                                        % oscilatiile in invatarea retelei
                                                                                        
                          %% bias = decalaje (reprezinta controlul fin al procesului de invatare)



%% TRAIN THE CNN // Etapa 5 din antrenarea -> Propagarea inainte ( Antrenarea retelei )                      stage5
% //implică aplicarea imaginilor de antrenare prin rețea, de la stratul de intrare la stratul de ieșire    
% indicate the training parameters 
options = trainingOptions('sgdm', ...
    'MiniBatchSize',MBS,...
    'MaxEpochs',NEP, ...
    'InitialLearnRate',1e-4, ...
    'ValidationData',augimdsValidation, ...
    'ValidationFrequency',3, ...
    'ValidationPatience',Inf, ...
    'Verbose',false, ...
    'Plots','training-progress');


% train the model
netTransfer = trainNetwork(augimdsTrain,layersNew,options);                                                 %stage 6
% Calculul functiei de pierdere este vizibil in meniul de antrenare, fiind
% un parametru calculat implicit de functia trainNetwork

% save the trained model
feval(@save,'D:\Facultate\An 3\Semestrul 2\SVA\Proiect SVA\Proiect\fileREZ\REZtrained.mat','netTransfer');

end