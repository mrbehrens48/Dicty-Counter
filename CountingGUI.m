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

% Last Modified by GUIDE v2.5 02-Jun-2016 16:25:07

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

imcheck = 0; %initialize the image check condition to 0 to show no image has been selected.



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
[path,user_cance]=imgetfile(); %have the user navigate in the explorer to an image
if user_cance
   msgbox(sprintf('Please select an image file'),'Error','Error');
   return
end
im = imread(path); %read the image that the user selected
im=im2double(im); %convert to double
im2 = im; %duplicate the image for future use
axes(handles.axes1); %set the main axes
imshow(im); %display the image
imcheck = 1; %set the flag that shows that an image has been selected

set(handles.text7,'string',path); %dispaly the path to the chosen image above the image axes.

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%here is the counting algorithm
global im imcheck

if(imcheck ~= 1) %check to maek sure that an image has been loaded before counting
    msgbox(sprintf('Please load an image first'),'Error','Error');
else

    wait = waitbar(0,'Please wait...'); %set up a wait bar so that the user can see that something is happening.

    B = rgb2gray(im); %convert the image to grayscale
    B2 = B; %save a copy of the original
    [h,w]=size(B); %determine the dimensions of the image
    B = imadjust(B); %automatically adjsut the contrast and brightness
    B = wiener2(B,[5 5]); %apply a light blur to remove high frequency noise
    edged = edge(B,'canny'); %perform a canny edge detection algorithm on the image
    C = imgaussfilt(B,60); %apply a very strong blur
    C = imcomplement(C); %compliment the blurred image
    B = B+C; %add the compliment of the blurred image back to the original; this extracts the cells


    [H,theta,rho] = hough(edged); %peform a hough transform of the edged image

    %find the maxima on the hough transform, which correspond to the strongest
    %straight lines in the image.
    P = houghpeaks(H,44,'threshold',ceil(0.2*max(H(:)))); 

    %extract the theta and rho data from the hough transform. These two
    %variables describe position and orientation of the lines.
    x = theta(P(:,2));
    y = rho(P(:,1));

    %calculate the lines found by the hough transform
    lines = houghlines(B,theta,rho,P,'FillGap',800,'MinLength',900);

    waitbar(.25) %set the waitbar to 25% complete

    %identify the lines that outline the ROI
    for i = 1:length(lines)
        for j = i+1:length(lines)
            %vertical lines
            if (abs(lines(i).theta) < 2) && (abs(lines(j).theta) < 2) %check if the lines are vertical, to within 2 degrees
                if abs(lines(i).point1(1) - lines(j).point1(1)) > 930 %check the distance between lines
                    if abs(lines(i).point1(1) - lines(j).point1(1)) < 980
                        for k = 1:length(lines)
                           if abs(lines(i).point1(2) - lines(k).point1(2)) < 60 || ...
                                abs(lines(j).point1(2) - lines(k).point1(2)) < 60 
                               xyA = [lines(i).point1; lines(i).point2]; %this vector identifies the coordinate of the line
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

    %if all the lines around the ROI could not be detected, throw up an error,
    %and have the user manually select the ROI
    if (~exist('xyA')|~exist('xyB')|~exist('xyC')|~exist('xyD'))
        msg = 'Sorry, The background lines could not be automatically detected. Hit ok, then use the mouse to drag a rectangle around the area you want to count cells in.';
        axes(handles.axes1);
        imshow(im);
        axes(handles.axes1); 
        uiwait(msgbox(msg)) %make the user read the error before continuing
        rect = getrect(handles.axes1); %the user selects a rectangle on screen with the mouse

        %use the user-defined rectangle to define the ROI
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

    else %the lines were detected automatically
        %turn the picture black everywhere but in the ROI
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


    bw = im2bw(B, graythresh(B)); %perform a binary threshhold
    bw = ~bw; %invert the image
    UB = 30;
    I = bwareaopen(bw,UB); %remove all objects smaller than UB pixels
    I= imfill(I,'holes'); %fill holes in the image

    se = strel('disk',3); 
    dilatedBW = imdilate(I,se); %dilate the image to close incomplete circles
    se = strel('disk',4);
    img= imerode(dilatedBW,se); %dilate teh image to return the image to the correct size

    bw = xor(img , bwareaopen(img , 5000)); %remove all objects larger than 5000 pixels

    D = bwdist(~bw); %Perform a distance transformation
    D = -D; %invert the distance transform
    L = watershed(D); %run the watershed algorithm to separate cells 

    %turn the result of the watershed into a binary image
     for i = 1:h
        for j = 1:w
            if L(i,j) ~= 0
                L(i,j) = inf;
            end;
        end;
    end;

    Lbw = im2bw(L);
    bw5 = bw.*Lbw; %multiply the original binary image by the watershed
    bw6 = bwareaopen(bw5,100); %remove all objects smaller than 100 pixels

    bwf = xor(bw6,bw); 
    se = strel('disk',3);
    bwf = imopen(bwf,se); 

    final = bwf + bw6; %the final binary mask, with watershed lines
    cc = bwconncomp(final,4); %extract a list of all objects of connected pixels
    number = cc.NumObjects; %count how many objects were found

    avecell = bwarea(final)/number; %determine the average area of a cell

    labeled = labelmatrix(cc); %create a labeled matrix of obejcts, where each object is assigned an index

    %calcualte the statistics of each object
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

    %create a normalized vector of features to input to the classifier
    nfv = [areas/norm(areas) perim/norm(perim)...
        eqd/norm(eqd) MajLen/norm(MajLen) MinLen/norm(MinLen) radii/norm(radii)];


    %This structure is the trained classifier. It should be included in the
    %Current directory when running this program
    load('DictyClass3.mat') 
    guess = DictyClass3.predictFcn(nfv); %use the classifier to predicty the class of each object
    count = sum(guess); %sum all of the guesses together to obtain the total count

    waitbar(.75)

    Scount = num2str(count); %convert the count to a string
    Scount = strcat(Scount,' e+4 cells/ml'); %concatenate strings
    set(handles.countDisp,'string',Scount); %set the textbox to display the count

    newCount = get(handles.newCount,'string'); %obtain the desired count from the GUI
    newCount = str2num(newCount); %convert to a number 
    newVol = get(handles.newVol,'string'); %obtain the desired new volume from the GUI
    newVol = str2num(newVol); %convert to a number

    oldVol = newCount*newVol/count; %calcualte the ammount of old culture to add to the dilution
    HL5 = newVol-oldVol; %calculate the ammount of new media to add

    oldVol = round(oldVol,2); %truncate the result to 2 decimal places
    HL5 = round(HL5,1); %truncate the result to 1 decimal place
    s1 = 'Dilute    ';

    oldVol = num2str(oldVol); %convert to string
    oldVol = strcat(s1 , oldVol,' ml of old culture'); %concatenate strings


    HL5 = num2str(HL5); %convert to string
    HL5 = strcat('with ', HL5,' ml of HL5'); %concatenate strings

    set(handles.X,'string',oldVol); %set the appropriate field in the GUI to dispaly the answer
    set(handles.Y,'string',HL5); %set the appropriate field in the GUI to dispaly the answer




    axes(handles.axes1); %call the axis to display the image on
    imshow(im); %display the image

    %create sets of objects belonging to the same class
    global BWone BWtwo BWthree BWfour BWfive BWsix %declare global varaibles to be used in all functions
    BWone = ismember(labeled,find(guess == 1)); 
    BWtwo = ismember(labeled,find(guess == 2));
    BWthree = ismember(labeled,find(guess == 3));
    BWfour = ismember(labeled,find(guess == 4));
    BWfive = ismember(labeled,find(guess == 5));
    BWsix = ismember(labeled,find(guess == 6));

    %create the colored masks to overlay on the image
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
    %set the objects to be displayed transparently over the image in the
    %correct color
    set(singles, 'AlphaData', BWone.*.3)
    set(doubles, 'AlphaData', BWtwo.*.3)
    set(triples, 'AlphaData', BWthree.*.3)
    set(quads, 'AlphaData', BWfour.*.3)
    set(quints, 'AlphaData', BWfive.*.3)
    set(sexts, 'AlphaData', BWsix.*.3)

    %If the count is too high, the results are unlikely to be accurate. Pop up
    %an error message in this case.
    if (count > 800)
        msg = 'This culture is too dense to count accurately. For accurate results you will have to make a dilution and then recount. Try a four-fold dilution.';
        errordlg(msg)
        set(handles.countDisp,'string','Too dense. Dilute and recount.');
        set(handles.X,'string','Too dense. Dilute and recount.');
        set(handles.Y,'string','Too dense. Dilute and recount.');
    end
    waitbar(1)
    close(wait)
    
end %end the check for a loaded image


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

%This function allows the user to input the count manually, and
%recalculates the dilution volumes.
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

%This function displays or hides the shaded overlay based on the imput from
%the checkbox.
check = get(handles.checkbox1,'Value')
global im
if (check == 1)
    imshow(im)
else
    imshow(im);
    global BWone BWtwo BWthree BWfour BWfive BWsix
    global redscreen greenscreen bluescreen yellowscreen cyanscreen whitescreen
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

