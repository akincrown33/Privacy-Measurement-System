function varargout = privacyMeasurement(varargin)
% PRIVACYMEASUREMENT MATLAB code for privacyMeasurement.fig
%      PRIVACYMEASUREMENT, by itself, creates a new PRIVACYMEASUREMENT or raises the existing
%      singleton*.
%
%      H = PRIVACYMEASUREMENT returns the handle to a new PRIVACYMEASUREMENT or the handle to
%      the existing singleton*.
%
%      PRIVACYMEASUREMENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRIVACYMEASUREMENT.M with the given input arguments.
%
%      PRIVACYMEASUREMENT('Property','Value',...) creates a new PRIVACYMEASUREMENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before privacyMeasurement_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to privacyMeasurement_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help privacyMeasurement

% Last Modified by GUIDE v2.5 14-Dec-2023 17:22:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @privacyMeasurement_OpeningFcn, ...
                   'gui_OutputFcn',  @privacyMeasurement_OutputFcn, ...
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


% --- Executes just before privacyMeasurement is made visible.
function privacyMeasurement_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to privacyMeasurement (see VARARGIN)

% Choose default command line output for privacyMeasurement
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes privacyMeasurement wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = privacyMeasurement_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in runBtn.
function runBtn_Callback(hObject, eventdata, handles)
% hObject    handle to runBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.message,'Visible','On')
set(handles.message,'String','Data Analysis in progress...'), pause(0.1)
%%
dataPlot = readcell("Responses Analysis.xlsx","Sheet","Q1","Range","A1:C5");
data = cell2mat(dataPlot(2:5,3));
names = dataPlot(2:5,1); explode = [1,1,1,1];
figure
pie3(data,explode) 
legend(names,'Location','best');
title('Q1')
ax = gca; ax.Children;
delete(ax.Children([1,5,9,13]))
[row,col] = size(dataPlot);
%%
dataPlot = readcell("Responses Analysis.xlsx","Sheet","Q2","Range","A1:C7");
data = cell2mat(dataPlot(2:7,3));
names = dataPlot(2:7,1);
figure
catName = categorical(names);
catName = reordercats(catName,names);
bar3(catName,data) 
grid off
%% 
dataPlot = readcell("Responses Analysis.xlsx","Sheet","Q3","Range","A1:C9");
data = cell2mat(dataPlot(2:9,3));
names = dataPlot(2:9,1);
figure
catName = categorical(names);
catName = reordercats(catName,names);
bar3(catName,data) 
grid off
set(handles.message,'String','Data Analysis Completed!!!')


% --- Executes on button press in calcPQ.
function calcPQ_Callback(hObject, eventdata, handles)
% hObject    handle to calcPQ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.message,'Visible','On')
set(handles.message,'String','Privacy Quotient Calculation in progress...'); pause(0.1)
itemSensitivity = readcell("Responses Analysis.xlsx","Sheet","Data Analysis","Range","AM2:AW133");
mask = cellfun(@ismissing, itemSensitivity);
itemSensitivity(mask) = {3};
[row,col] = size(itemSensitivity);
for i_col = 1:col
    for i_row = 1:row
        if itemSensitivity{i_row,i_col} >= 3 && itemSensitivity{i_row,i_col} <= 5
            privacyQuotientMat(i_row,i_col) = 1;
        elseif itemSensitivity{i_row,i_col} >= 1 && itemSensitivity{i_row,i_col} <= 2
            privacyQuotientMat(i_row,i_col) = 0;
        end
    end
end

% Sensitivity Calculation for each Item
for i_col = 1:col
    sensitivityItem(i_col) = (row - numel(find(privacyQuotientMat(:,i_col)==1)))/row;
end

% Visibilty Calculation for each User
for i_col = 1:col
    for i_row = 1:row
        visibility(i_row,i_col) = ((numel(find(privacyQuotientMat(:,i_col)==1)))/row) * ((numel(find(privacyQuotientMat(i_row,:)==1)))/col);
    end
end

% Privacy Quotient Calculation
for i_col = 1:col
    for i_row = 1:row
        privacyQuotient(i_row,i_col) = sensitivityItem(i_col) * visibility(i_row,i_col);
    end
end
privacyQuotient = sum(privacyQuotient,2);

%% K Means Clustering
[~, clusterCenters] = kMeansClustering(privacyQuotient,5,1000); l

avgPrivacyQuotient = mean(privacyQuotient);
reqPrivacyQuotient = (1/(max(privacyQuotient)-(min(privacyQuotient))))*avgPrivacyQuotient;

set(handles.uitable1,'ColumnName',{"Item","Sensitivity"});
writecell({"Item","Sensitivity"},'Responses Analysis.xlsx','Sheet',"Simulation Result",'Range','A1')
set(handles.uitable1,'Data',cellstr([itemName,sensitivityItem']));
writecell(cellstr([itemName,sensitivityItem']),'Responses Analysis.xlsx','Sheet',"Simulation Result",'Range','A2')

set(handles.uitable2,'ColumnName',{"Initial Centroid","Final Centroid","Text Equivalent"});
writecell({"Initial Centroid","Final Centroid","Text Equivalent"},'Responses Analysis.xlsx','Sheet',"Simulation Result",'Range','A14')
set(handles.uitable2,'Data',cellstr([clusterCenters,textEquivalent]));
writecell(cellstr([clusterCenters,textEquivalent]),'Responses Analysis.xlsx','Sheet',"Simulation Result",'Range','A15')
set(handles.message,'String','Privacy Quotient Calculation Completed!!!');


% --- Executes on button press in trainSystem.
function trainSystem_Callback(hObject, eventdata, handles)
% hObject    handle to trainSystem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc
set(handles.message,'Visible','On');
set(handles.message,'String','Naive Bayes System Training in Progress...'); pause(0.1)
trainTestData                                                               % load data
trainingSetRowsNumber = round(0.7*size(training,1));                        % 70% of all the obersvation goes to trainingSet (10 in case of 14 observation)

set(handles.message2,'Visible','On');
set(handles.message2,'String','Loading and Preprocessing Training Data...'); pause(0.1)
count = 0;
for i_privData = 1:length(privData)
    newStr = privData{i_privData};
    newStrT = cellstr(split(newStr));
    set(handles.uitable1,'data',newStrT), pause (0.1); count = count+1;
    writecell({['TrainData',num2str(i_privData)]},'Responses Analysis.xlsx','Sheet',"Simulation Result",'Range',[columnLoc{count},'1'])
    writecell(newStrT,'Responses Analysis.xlsx','Sheet',"Simulation Result",'Range',[columnLoc{count},'2'])
    newStr = erasePunctuation(newStr);
    documents = tokenizedDocument(newStr);
    newDocuments = removeStopWords(documents);
    newDocuments = joinWords(newDocuments);
    newStr = cellstr(split(newDocuments));
    set(handles.uitable2,'Data', newStr), pause (0.1); count = count+1;
    writecell({['ProcessedTrainData',num2str(i_privData)]},'Responses Analysis.xlsx','Sheet',"Simulation Result",'Range',[columnLoc{count},'1'])
    writecell(newStr,'Responses Analysis.xlsx','Sheet',"Simulation Result",'Range',[columnLoc{count},'2'])
end

set(handles.message2,'String','Loading and Preprocessing Test Data...'); pause(0.1)
for i_pubData = 1:length(pubData)
    newStrT = pubData{i_pubData};
    newStr = cellstr(split(newStrT));
    set(handles.uitable1,'data',newStr), pause (0.1); count = count+1;
    writecell({['TestData',num2str(i_pubData)]},'Responses Analysis.xlsx','Sheet',"Simulation Result",'Range',[columnLoc{count},'1'])
    writecell(newStr,'Responses Analysis.xlsx','Sheet',"Simulation Result",'Range',[columnLoc{count},'2'])
    newStr = erasePunctuation(newStrT);
    documents = tokenizedDocument(newStr);
    newDocuments = removeStopWords(documents);
    newDocuments = joinWords(newDocuments);
    newStr = cellstr(split(newDocuments));
    set(handles.uitable2,'Data', newStr), pause (0.1); count = count+1;
    writecell({['ProcessedTestData',num2str(i_pubData)]},'Responses Analysis.xlsx','Sheet',"Simulation Result",'Range',[columnLoc{count},'1'])
    writecell(newStr,'Responses Analysis.xlsx','Sheet',"Simulation Result",'Range',[columnLoc{count},'2'])
end
set(handles.message2,'Visible','Off');
classification = zeros(size(training,1)-trainingSetRowsNumber,10);
errorRate = zeros(size(privacyScore,1),10);
for i=1:10
    randomRows=randperm(size(training,1),trainingSetRowsNumber);             % select 10 random rows for trainingSet
    trainingSet=training(randomRows,:);
    dataSet = training(setdiff(1:end,randomRows),:);                         % select the remaining rows for dataSet
    for k=1:4
        [classification(:,i),errorRate(k,i)]=myBayesClassifier...
            (trainingSet,dataSet,privacyScore(k));                                     % execute with the four a values
    end
end
save('classificationModel.mat','classification');
writecell({'PerformanceMetric','Value'},'Responses Analysis.xlsx','Sheet',"Simulation Result",'Range','A21')
writecell({'Accuracy','Precision','Recall';acc,prec,recal}','Responses Analysis.xlsx','Sheet',"Simulation Result",'Range','A22')
set(handles.message,'String','Naive Bayes System Training Completed!!!');




% --- Executes on button press in loadTesting.
function loadTesting_Callback(hObject, eventdata, handles)
% hObject    handle to loadTesting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.message,'Visible','On')
set(handles.message,'String','Loading Test posts...'); pause(0.1)
testText = {"Hey, feeling great today! Busy week ahead" + ...
    " as I will be return home at No 53, Walmorth street at exactly 5pm. " + ...
    "Traffic will be insane but we""ll get there. Currently cooking dinner " + ...
    "and enjoying some music. The weather's lovely. Can't wait for the " + ...
    "weekend. Work is alright. Anyone watching that new show? Anyway, " + ...
    "hope everyone's well. Catch you later!","Rainy day. Grabbed coffee and " + ...
    "lost myself in a book. Thought its my birthday, the 12th of december " + ...
    "always is, love these quiet moments though. Great playlist for today. " + ...
    "Work was exhausting, but getting things done. Traffic was a nightmare, " + ...
    "as usual. Dinner plans? Maybe some homemade pasta. What's your go-to" + ...
    " comfort food?","Rushed breakfast today. Coffee in hand, ready to " + ...
    "tackle work. Rain or shine, gotta keep moving. Movies tonight. Anyone " + ...
    "else going? Dinner at the usual place. That new restaurant looks nice, " + ...
    "though, I can be single for now but we still need to enjoy life as it comes."};
for i_testText = 1:length(testText)
    newStr = cellstr(split(testText{i_testText}));
    set(handles.uitable1,'data',newStr), pause (2)
end
set(handles.message,'String','All Test Posts Loaded!!!')



% --- Executes on button press in testSystem.
function testSystem_Callback(hObject, eventdata, handles)
% hObject    handle to testSystem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.message,'Visible','On')
set(handles.message,'String','Testing System ongoing...'); pause(0.1)
testText = {"Hey, feeling great today! Busy week ahead" + ...
    " as I will be return home at No 53, Walmorth street at exactly 5pm. " + ...
    "Traffic will be insane but we""ll get there. Currently cooking dinner " + ...
    "and enjoying some music. The weather's lovely. Can't wait for the " + ...
    "weekend. Work is alright. Anyone watching that new show? Anyway, " + ...
    "hope everyone's well. Catch you later!","Rainy day. Grabbed coffee and " + ...
    "lost myself in a book. Thought its my birthday, the 12th of december " + ...
    "always is, love these quiet moments though. Great playlist for today. " + ...
    "Work was exhausting, but getting things done. Traffic was a nightmare, " + ...
    "as usual. Dinner plans? Maybe some homemade pasta. What's your go-to" + ...
    " comfort food?","Rushed breakfast today. Coffee in hand, ready to " + ...
    "tackle work. Rain or shine, gotta keep moving. Movies tonight. Anyone " + ...
    "else going? Dinner at the usual place. That new restaurant looks nice, " + ...
    "though, I can be single for now but we still need to enjoy life as it comes."};
for i_testText = 1:length(testText)
    newStr = testText{i_testText};
    newStr = erasePunctuation(newStr);
    documents = tokenizedDocument(newStr);
    newDocuments = removeStopWords(documents);
    newDocuments = joinWords(newDocuments);
    newStr = cellstr(split(newDocuments));
    set(handles.uitable2,'Data', newStr), pause (2)
end
load('classificationModel.mat');
if strcmp(newStr,classification(1))==1
    result = 'private';
else
    result = 'public';
end
set(handles.message2,'Max',3)
set(handles.message2,'Visible','On');
set(handles.message2,'String',['The 1st Post has a Low PQ!!! Thus, Privacy Reveiling','The 2nd Post has a Below Moderate PQ!!! Thus, Privacy Reveiling','The 3rd Post has a High PQ!!! Thus, Privacy Not Reveiled']);
set(handles.message,'String','Preprocessing of Test Posts Completed!!!');
