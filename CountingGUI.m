function varargout = CountingGUI(varargin)
% COUNTINGGUI MATLAB code for CountingGUI.fig
%      COUNTINGGUI, by itself, creates a new COUNTINGGUI or raises the existing
%      singleton*.
%
%      H = COUNTINGGUI returns the handle to a new COUNTINGGUI or the handle to
%      the existing singleton*.
%
%      COUNTINGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COUNTINGGUI.M with the given input arguments.
%
%      COUNTINGGUI('Property','Value',...) creates a new COUNTINGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CountingGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CountingGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CountingGUI

% Last Modified by GUIDE v2.5 16-May-2016 19:18:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CountingGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @CountingGUI_OutputFcn, ...
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


% --- Executes just before CountingGUI is made visible.
function CountingGUI_OpeningFcn(hObject, eventdata, handles, varargin)
global imcheck
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CountingGUI (see VARARGIN)

% Choose default command line output for CountingGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CountingGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

imcheck = 0; %initialize the imagecheck condition to 0, i.e. no image has been selected



% --- Outputs from this function are returned to the command line.
function varargout = CountingGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%here is where the image gets loaded
global im im2 imcheck
[path,user_cance]=imgetfile();
if user_cance
   msgbox(sprintf('Please select an image file'),'Error','Error');
   return
end
im = imread(path);
im=im2double(im);
im2 = im;
axes(handles.axes1);
imshow(im);
imcheck = 1;

set(handles.text7,'string',path);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%here is the counting algorithm
global im imcheck

if(imcheck ~= 1)
    msgbox(sprintf('Please load an image first'),'Error','Error');
else

    wait = waitbar(0,'Please Wait...');

    B = rgb2gray(im);
    B2 = B;
    [h,w]=size(B);
    B = imadjust(B);
    B = wiener2(B,[5 5]);
    B_mean = mean(mean(B));
    edged = edge(B,'canny');
    C = imgaussfilt(B,60);
    C = imcomplement(C);
    B = B+C;
    B_mean = mean(mean(B))

    [H,theta,rho] = hough(edged);

    P = houghpeaks(H,44,'threshold',ceil(0.2*max(H(:))));

    x = theta(P(:,2));
    y = rho(P(:,1));

    lines = houghlines(B,theta,rho,P,'FillGap',800,'MinLength',900);

    waitbar(.5)

    for i = 1:length(lines)
        for j = i+1:length(lines)
            %vertical lines
            if (abs(lines(i).theta) < 2) && (abs(lines(j).theta) < 2) 
                if abs(lines(i).point1(1) - lines(j).point1(1)) > 930
                    if abs(lines(i).point1(1) - lines(j).point1(1)) < 980
                        for k = 1:length(lines)
                           if abs(lines(i).point1(2) - lines(k).point1(2)) < 60 || ...
                                abs(lines(j).point1(2) - lines(k).point1(2)) < 60 
                               xyA = [lines(i).point1; lines(i).point2];
                               plot(xyA(:,1),xyA(:,2),'LineWidth',2,'Color','yellow');
                               xyB = [lines(j).point1; lines(j).point2];
                               plot(xyB(:,1),xyB(:,2),'LineWidth',2,'Color','blue');
                           end;
                        end;
                    end;
                end;
            end;
            %horizontal lines
            if (abs(lines(i).theta) > 88) && (abs(lines(j).theta) > 88)
                if abs(lines(i).point1(2) - lines(j).point1(2)) > 930
                    if abs(lines(i).point1(2) - lines(j).point1(2)) < 980
                       xyC = [lines(i).point1; lines(i).point2];
                       plot(xyC(:,1),xyC(:,2),'LineWidth',2,'Color','green');
                       xyD = [lines(j).point1; lines(j).point2];
                       plot(xyD(:,1),xyD(:,2),'LineWidth',2,'Color','red');
                    end;
                end;
            end;
        end;
    end;
    %turn the picture black everywhere but in the ROI
    if (~exist('xyA')|~exist('xyB')|~exist('xyC')|~exist('xyD'))
        msg = 'Sorry, the background lines could not be automatically detected. Hit ok, then use the mouse to drag a rectangle around the area you want to count cells in.';
        axes(handles.axes1);
        imshow(im)
        axes(handles.axes1);
        
        uiwait(msgbox(msg))
        rect = getrect(handles.axes1);

        for i = 1:rect(2)
            B(i,:) = 255;
        end
        for i = 1:rect(1)
            B(:,i) = 255;
        end
        for i = rect(2)+rect(4):h
            i = i-mod(i,1);
            B(i,:) = 255;
        end
        for i = rect(1)+rect(3):w
            i = i-mod(i,1);
            B(:,i) = 255;
        end

    else
        if xyA(1,1) > xyB(1,1)
            for i = 1:h
                for j = xyA(1,1):w
                    B(i,j) = 255;
                end;
            end;
            for i = 1:h
                for j = 1:xyB(1,1)
                    B(i,j) = 255;
                end;
            end;
        else
            for i = 1:h
                for j = xyB(1,1):w
                    B(i,j) = 255;
                end;
            end;
            for i = 1:h
                for j = 1:xyA(1,1)
                    B(i,j) = 255;
                end;
            end;
        end;

        if xyC(1,2) > xyD(1,2)
            for i = xyC(1,2):h
                for j = 1:w
                    B(i,j) = 255;
                end;
            end;
            for i = 1:xyD(1,2)
                for j = 1:w
                    B(i,j) = 255;
                end;
            end;
        else
            for i = 1:xyC(1,2)
                for j = 1:w
                    B(i,j) = 255;
                end;
            end;
            for i = xyD(1,2):h
                for j = 1:w
                    B(i,j) = 255;
                end;
            end;
        end;
    end;
    bw = im2bw(B, graythresh(B));
    bw = ~bw;
    UB = 30;
    I = bwareaopen(bw,UB);
    I= imfill(I,'holes');

    se = strel('disk',3); 
    dilatedBW = imdilate(I,se); 
    se = strel('disk',4);
    img= imerode(dilatedBW,se);

    bw = xor(img , bwareaopen(img , 5000));
    D = bwdist(~bw);
    % figure
    % subplot(2,2,1),imshow(bw,[]);
    % subplot(2,2,2),imshow(D,[]);

    D = -D;
    % figure
    % imshow(D,[])
    L = watershed(D);

     for i = 1:h
        for j = 1:w
            if L(i,j) ~= 0
                L(i,j) = inf;
            end;
        end;
    end;

    Lbw = im2bw(L);
    bw5 = bw.*Lbw;
    bw6 = bwareaopen(bw5,100);

    bwf = xor(bw6,bw);
    se = strel('disk',3);
    bwf = imopen(bwf,se);

    final = bwf + bw6;
    cc = bwconncomp(final,4);
    number = cc.NumObjects;

    avecell = bwarea(final)/number;

    labeled = labelmatrix(cc);

    stats = regionprops('table',cc,B2,'Area','MajorAxisLength',...
        'MinorAxisLength','Eccentricity','EquivDiameter','Perimeter');
    areas = stats.Area;
    perim = stats.Perimeter;
    ecc = stats.Eccentricity;
    eqd = stats.EquivDiameter;
    MajLen = stats.MajorAxisLength;
    MinLen = stats.MinorAxisLength;
    diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
    radii = diameters/2;
    featureVector = [areas perim ecc eqd MajLen MinLen radii];
    nfv = [areas/norm(areas) perim/norm(perim)...
        eqd/norm(eqd) MajLen/norm(MajLen) MinLen/norm(MinLen) radii/norm(radii)];
    [nh,hw]= size(nfv);

    load('DictySVM.mat')
    guess = predict(DictySVM,nfv);
    % load('QuadSVM.mat')
    % guess = predict(QuadSVM,nfvm);
    count = sum(guess);

    Scount = num2str(count);
    Scount = strcat(Scount,' e+4 cells/ml');
    set(handles.countDisp,'string',Scount); %set the textbox to display the count
    newCount = get(handles.newCount,'string');
    newCount = str2num(newCount);
    newVol = get(handles.newVol,'string');
    newVol = str2num(newVol);

    oldVol = newCount*newVol/count;
    HL5 = newVol-oldVol;

    oldVol = round(oldVol,2);
    HL5 = round(HL5,1);
    s1 = 'Dilute    ';

    if (oldVol == 1)
        oldVol = num2str(oldVol);
        oldVol = strcat(s1 , oldVol,' ml of old culture');
    else
        oldVol = num2str(oldVol);
        oldVol = strcat(s1 , oldVol,' ml of old culture');
    end

    HL5 = num2str(HL5);
    HL5 = strcat('with ', HL5,' ml of HL5');

    set(handles.X,'string',oldVol);
    set(handles.Y,'string',HL5);




    axes(handles.axes1); %call the axis to display the image on
    imshow(im);
    global BWone BWtwo BWthree BWfour BWfive BWsix
    BWone = ismember(labeled,find(guess == 1));
    BWtwo = ismember(labeled,find(guess == 2));
    BWthree = ismember(labeled,find(guess == 3));
    BWfour = ismember(labeled,find(guess == 4));
    BWfive = ismember(labeled,find(guess == 5));
    BWsix = ismember(labeled,find(guess == 6));

    global redscreen greenscreen bluescreen yellowscreen cyanscreen whitescreen
    redscreen = cat(3, ones(size(B)), zeros(size(B)), zeros(size(B)));
    greenscreen = cat(3, zeros(size(B)), ones(size(B)), zeros(size(B)));
    bluescreen = cat(3, zeros(size(B)), zeros(size(B)), ones(size(B)));
    yellowscreen = cat(3, ones(size(B)), ones(size(B)), zeros(size(B)));
    cyanscreen = cat(3, zeros(size(B)), ones(size(B)), ones(size(B)));
    whitescreen = cat(3, ones(size(B)), ones(size(B)), ones(size(B)));
    hold on
    global singles doubles triples quads quints sexts
    singles = imshow(redscreen);
    doubles = imshow(greenscreen);
    triples = imshow(bluescreen);
    quads = imshow(yellowscreen);
    quints = imshow(cyanscreen);
    sexts = imshow(whitescreen);
    hold off
    set(singles, 'AlphaData', BWone.*.3)
    set(doubles, 'AlphaData', BWtwo.*.3)
    set(triples, 'AlphaData', BWthree.*.3)
    set(quads, 'AlphaData', BWfour.*.3)
    set(quints, 'AlphaData', BWfive.*.3)
    set(sexts, 'AlphaData', BWsix.*.3)

    if (count > 800)
        msg = 'This culture is too dense to count accurately. For accurate results you will have to make a dilution and then recount. Try a four-fold dilution.';
        errordlg(msg)
        set(handles.countDisp,'string','Too dense. Dilute and recount');
        set(handles.X,'string','Too dense. Dilute and recount');
        set(handles.Y,'string','Too dense. Dilute and recount');
    end
    waitbar(1)
    close(wait)
end; %end check if image has been loaded


function newCount_Callback(hObject, eventdata, handles)
% hObject    handle to newCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newCount as text
%        str2double(get(hObject,'String')) returns contents of newCount as a double


% --- Executes during object creation, after setting all properties.
function newCount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function newVol_Callback(hObject, eventdata, handles)
% hObject    handle to newVol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newVol as text
%        str2double(get(hObject,'String')) returns contents of newVol as a double


% --- Executes during object creation, after setting all properties.
function newVol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newVol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% display help data
run('helpGUI')                


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
manual_count = inputdlg('Enter the count manually:','Manual Count')
manual_count_num = str2num(manual_count{:});
Scount = strcat(manual_count,' e+4 cells/ml');
set(handles.countDisp,'string',Scount); %set the textbox to display the count
newCount = get(handles.newCount,'string');
newCount = str2num(newCount);
newVol = get(handles.newVol,'string');
newVol = str2num(newVol);

oldVol = newCount*newVol/manual_count_num;
HL5 = newVol-oldVol;

oldVol = round(oldVol,2);
HL5 = round(HL5,1);
s1 = 'Dilute    ';

if (oldVol == 1)
    oldVol = num2str(oldVol);
    oldVol = strcat(s1 , oldVol,' ml of old culture');
else
    oldVol = num2str(oldVol);
    oldVol = strcat(s1 , oldVol,' ml of old culture');
end

HL5 = num2str(HL5);
HL5 = strcat('with ', HL5,' ml of HL5');

set(handles.X,'string',oldVol);
set(handles.Y,'string',HL5);





    


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
check = get(handles.checkbox1,'Value');
global im
if (check == 1)
    imshow(im)
else
    imshow(im);
    global BWone BWtwo BWthree BWfour BWfive BWsix
%     BWone = ismember(labeled,find(guess == 1));
%     BWtwo = ismember(labeled,find(guess == 2));
%     BWthree = ismember(labeled,find(guess == 3));
%     BWfour = ismember(labeled,find(guess == 4));
%     BWfive = ismember(labeled,find(guess == 5));
%     BWsix = ismember(labeled,find(guess == 6));

    global redscreen greenscreen bluescreen yellowscreen cyanscreen whitescreen
%     redscreen = cat(3, ones(size(B)), zeros(size(B)), zeros(size(B)));
%     greenscreen = cat(3, zeros(size(B)), ones(size(B)), zeros(size(B)));
%     bluescreen = cat(3, zeros(size(B)), zeros(size(B)), ones(size(B)));
%     yellowscreen = cat(3, ones(size(B)), ones(size(B)), zeros(size(B)));
%     cyanscreen = cat(3, zeros(size(B)), ones(size(B)), ones(size(B)));
%     whitescreen = cat(3, ones(size(B)), ones(size(B)), ones(size(B)));
    hold on
    global singles doubles triples quads quints sexts
    singles = imshow(redscreen);
    doubles = imshow(greenscreen);
    triples = imshow(bluescreen);
    quads = imshow(yellowscreen);
    quints = imshow(cyanscreen);
    sexts = imshow(whitescreen);
    hold off
    set(singles, 'AlphaData', BWone.*.3)
    set(doubles, 'AlphaData', BWtwo.*.3)
    set(triples, 'AlphaData', BWthree.*.3)
    set(quads, 'AlphaData', BWfour.*.3)
    set(quints, 'AlphaData', BWfive.*.3)
    set(sexts, 'AlphaData', BWsix.*.3)
    
end
