function varargout = gui_proiect(varargin)

global cameraOn ;
cameraOn=true;


% Begin initialization for GUI
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_proiect_OpeningFcn, ...
    'gui_OutputFcn',  @gui_proiect_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT




% --- Executes just before gui_proiect is made visible.
function gui_proiect_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for gui_proiect
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = gui_proiect_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function text3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% % --- Executes on button press in AntrenareRetea.
function AntrenareRetea_Callback(hObject, eventdata, handles)
TrainAndValidate;



%% --- Executes on button press in BtnVerifyImage.
function BtnVerifyImage_Callback(hObject, eventdata, handles)
% hObject    handle to BtnVerifyImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global imag1
[fileName, filePath] = uigetfile({'*.jpg;*.png;*.bmp', 'Image Files (*.jpg, *.png, *.bmp)'}, 'Select an Image');

%Incarcarea retelei antrenate de noi
load('D:\Facultate\An 3\Semestrul 2\SVA\Proiect SVA\Proiect\fileREZ\REZtrainedAll.mat', 'netTransfer');

if fileName ~= 0

    % Read the selected image
    imagePath = fullfile(filePath, fileName);
    imag = imread(imagePath);

    axes(handles.axes1);
    imshow(imag)

    % Preprocess the image 
    % // pentru a fi conform parametrilor necesari in primul layer de intrare al retelei
    inputSize = [227 227 3];
    imag = imresize(imag, inputSize(1:2));

    %Propagarea inainte se face prin reteaua netTransfer
    %Se realizeaza calculul scorului si stocarea lui in scores
    %Functia va utiliza imagine imag si reteaua netTransfer si va realiza suprapunerea si clasificarea
    [label,scores]= classify(netTransfer, imag);


    % Get the top 3 labels and their corresponding scores
    [~, sortedIndices] = sort(scores, 'descend');
    top3Labels = netTransfer.Layers(end).ClassNames(sortedIndices(1:3));
    top3Scores = scores(sortedIndices(1:3));

    % Construct the string to display in text10
    labelString = '';
    for i = 1:numel(top3Labels)
        confidencePercentage = top3Scores(i) * 100;
        labelString = [labelString, sprintf('%s: %.2f%%', top3Labels{i}, confidencePercentage)];

        if i < numel(top3Labels)
            labelString = [labelString, newline];
        end
    end

    set(handles.text7,'String',label)
    set(handles.text10, 'String', labelString);
else
    msgbox(sprintf('Imaginea nu a fost selectata corect !'),'Error','Warning');
    return
end




% --- Executes on button press in DetectWithCamera.
function DetectWithCamera_Callback(hObject, eventdata, handles)
global cameraOn ;

% Load the pre-trained model
load('D:\Facultate\An 3\Semestrul 2\SVA\Proiect SVA\Proiect\fileREZ\REZtrainedAll.mat', 'netTransfer');

% Create a webcam object
cam = webcam();

% Continuously capture and process images
while cameraOn

    % Acquire a photo from the camera
    img = snapshot(cam);

    % Display the acquired photo
    axes(handles.axes1);
    imshow(img);

    % Preprocess the image
    inputSize = [227 227 3];
    img = imresize(img, inputSize(1:2));

    % Classify the image using the trained model using AlexNet's layers
    [label, scores] = classify(netTransfer, img);

    % Get the top 3 labels and their corresponding scores
    [~, sortedIndices] = sort(scores, 'descend');
    top3Labels = netTransfer.Layers(end).ClassNames(sortedIndices(1:3));
    top3Scores = scores(sortedIndices(1:3));

    % Construct the string to display in text10
    labelString = '';
    for i = 1:numel(top3Labels)
        confidencePercentage = top3Scores(i) * 100;
        labelString = [labelString, sprintf('%s: %.2f%%', top3Labels{i}, confidencePercentage)];

        if i < numel(top3Labels)
            labelString = [labelString, char(10)];
        end
    end

    % Update the labels
    set(handles.text7, 'String', label);
    set(handles.text10, 'String', labelString);


    % Allow the GUI to update
    drawnow;
end

% Close the camera
clear cam;




% --- Executes on button press in cameraOff.
function cameraOff_Callback(hObject, eventdata, handles)

global cameraOn ;
if cameraOn ==true

    cameraOn = false

    cla(handles.axes1, 'reset');
    whiteImage = ones(227, 227, 3);
    image(handles.axes1, whiteImage);
    axis(handles.axes1, 'off');
else
    cameraOn = true;
end
