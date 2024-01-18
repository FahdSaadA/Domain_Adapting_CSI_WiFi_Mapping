
%%
%% upload file article_10_dataset
%% Transfer learning 
%% This is the code where we are using domain learning, with adapting decoder in the new domain

%% first need to run online_offline_domain_learning_together_v1
%%
% Define the input and output sizes
%% we will work on A dual attention LSTM lightweight model based on

inputSize = 110;
numHiddenUnitsEncoder = 128;
numHiddenUnitsDecoder = 128;
numClasses = 13;



% Encoder layers (pre-trained layers)
encoderLayers = [
    sequenceInputLayer(inputSize)
    bilstmLayer(numHiddenUnitsEncoder, 'OutputMode', 'sequence')
    dropoutLayer(0.2)
    bilstmLayer(100, 'OutputMode', 'sequence')
];

% Decoder layers (to be trained on the target domain)
decoderLayers = [
    bilstmLayer(numHiddenUnitsDecoder, 'OutputMode', 'last')
    dropoutLayer(0.2)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer
];



% Combine encoder and decoder layers
layers = [
    encoderLayers
    decoderLayers
];

% Prepare the training data for domain learning
Data_Train_LSTM_Domain = Data_Train_LSTM; % Your domain training data
Labels_Train_Domain = Labels_Train; % Your domain training labels

% % Set the training options for domain learning
% maxEpochsDomain = 30;
% miniBatchSizeDomain = 32;
% optionsDomain = trainingOptions('adam', ...
%     'ExecutionEnvironment', 'auto', ...
%     'GradientThreshold', 1, ...
%     'MaxEpochs', maxEpochsDomain, ...
%     'MiniBatchSize', miniBatchSizeDomain, ...
%     'InitialLearnRate', 0.0001, ...
%     'Shuffle', 'every-epoch', ...
%     'Verbose', 0, ...
%     'Plots', 'training-progress', ...
%     'ExecutionEnvironment', 'auto', ...
%     'Verbose', false);

% Set the training options for domain learning
maxEpochsDomain = 10;
miniBatchSizeDomain = 32; % Adjusted batch size
optionsDomain = trainingOptions('adam', ...
    'ExecutionEnvironment', 'gpu', ... % Utilize GPU acceleration
    'GradientThreshold', 1, ...
    'MaxEpochs', maxEpochsDomain, ...
    'MiniBatchSize', miniBatchSizeDomain, ...
    'InitialLearnRate', 0.0001, ...
    'Shuffle', 'every-epoch', ...
    'Verbose', 0, ...
    'Plots', 'training-progress', ...
    'ExecutionEnvironment', 'auto', ...
    'Verbose', false);

% Train the domain model
net_domain = trainNetwork(Data_Train_LSTM_Domain, Labels_Train_Domain, layers, optionsDomain);

% Prepare the test data
Data_Test_LSTM_Online = Data_Test_LSTM;
Labels_Test_Online = Labels_Test;

% Predict the classes using the domain-trained model
Prediction_Domain = classify(net_domain, Data_Test_LSTM_Online, ...
    'MiniBatchSize', miniBatchSizeDomain, ...
    'SequenceLength', 'shortest');

% Convert the test labels to categorical arrays
Labels_Test_Online = categorical(Labels_Test_Online);

% Compute the confusion matrix and visualize it
figure
analyzeNetwork(net_domain)
title('Domain LSTM Classifier')

LSTM_DP_Domain = confusionchart(Labels_Test_Online, Prediction_Domain);
LSTM_DP_Domain.Title = 'Domain LSTM Classifier';
LSTM_DP_Domain.RowSummary = 'row-normalized';
LSTM_DP_Domain.ColumnSummary = 'column-normalized';

save('your_pretrained_model.mat', 'net_domain');


%% using the model in another domain
%%
% Load the pre-trained model
pretrainedModel = load('your_pretrained_model.mat'); % Replace with the actual file/path

% Extract the pre-trained encoder layers
pretrainedEncoderLayers = pretrainedModel.net_domain.Layers(1:4); % Adjust the indices based on your pre-trained model architecture

% Set the learn rate factors to zero for the pre-trained layers
for i = 1:numel(pretrainedEncoderLayers)
    if isprop(pretrainedEncoderLayers(i), 'WeightLearnRateFactor')
        pretrainedEncoderLayers(i).WeightLearnRateFactor = 0;
    end
    if isprop(pretrainedEncoderLayers(i), 'BiasLearnRateFactor')
        pretrainedEncoderLayers(i).BiasLearnRateFactor = 0;
    end
end

% Yes, the code provided effectively freezes the layers by setting their 
% learn rate factors to zero. By doing this, you prevent the optimization 
% algorithm from updating the weights and biases of these layers during 
% training, effectively "freezing" them.


% Define the new decoder layers to be trained
newDecoderLayers = [
    bilstmLayer(numHiddenUnitsDecoder, 'OutputMode', 'last')
    dropoutLayer(0.2)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer
];

% Combine the pre-trained encoder and new decoder layers
layers = [
    pretrainedEncoderLayers
    newDecoderLayers
];

% Prepare the training data for domain adaptation
Data_Train_LSTM_Domain = Data_Train_LSTM_Domain; % Your domain training data
Labels_Train_Domain = Labels_Train_Domain; % Your domain training labels




% Set the training options for domain adaptation 
%here the learnrate is scehdualed to find the best learning rate
maxEpochsDomain = 30;
miniBatchSizeDomain = 32;
optionsDomain = trainingOptions('adam', ...
    'ExecutionEnvironment', 'gpu', ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.1, ...
    'LearnRateDropPeriod', 10, ...
    'GradientThreshold', 1, ...
    'MaxEpochs', maxEpochsDomain, ...
    'MiniBatchSize', miniBatchSizeDomain, ...
    'InitialLearnRate', 0.0001, ...
    'Shuffle', 'every-epoch', ...
    'Verbose', 0, ...
    'Plots', 'training-progress', ...
    'ExecutionEnvironment', 'auto', ...
    'Verbose', false);

% Train the adapted model
net_adapted = trainNetwork(Data_Train_LSTM_Domain, Labels_Train_Domain, layers, optionsDomain);

% Prepare the test data
Data_Test_LSTM_Online = Data_Test_LSTM;
Labels_Test_Online = Labels_Test;

% Predict the classes using the adapted model
Prediction_Adapted = classify(net_adapted, Data_Test_LSTM_Online, ...
    'MiniBatchSize', miniBatchSizeDomain, ...
    'SequenceLength', 'shortest');

% Convert the test labels to categorical arrays
Labels_Test_Online = categorical(Labels_Test_Online);

% Compute the confusion matrix and visualize it
figure
analyzeNetwork(net_adapted)
title('Adapted LSTM Classifier')

LSTM_DP_Adapted = confusionchart(Labels_Test_Online, Prediction_Adapted);
LSTM_DP_Adapted.Title = 'Adapted LSTM Classifier';
LSTM_DP_Adapted.RowSummary = 'row-normalized';
LSTM_DP_Adapted.ColumnSummary = 'column-normalized';


print(gcf,'Attention Mechanism Learning.png','-dpng','-r300');        
