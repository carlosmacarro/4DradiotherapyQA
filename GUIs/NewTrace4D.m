function varargout = NewTrace4D(varargin)
% NEWTRACE4D MATLAB code for NewTrace4D.fig
%      NEWTRACE4D, by itself, creates a new NEWTRACE4D or raises the existing
%      singleton*.
%
%      H = NEWTRACE4D returns the handle to a new NEWTRACE4D or the handle to
%      the existing singleton*.
%
%      NEWTRACE4D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEWTRACE4D.M with the given input arguments.
%
%      NEWTRACE4D('Property','Value',...) creates a new NEWTRACE4D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NewTrace4D_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NewTrace4D_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NewTrace4D

% Last Modified by GUIDE v2.5 24-Jun-2021 16:46:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NewTrace4D_OpeningFcn, ...
                   'gui_OutputFcn',  @NewTrace4D_OutputFcn, ...
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


% --- Executes just before NewTrace4D is made visible.
function NewTrace4D_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NewTrace4D (see VARARGIN)

% Choose default command line output for NewTrace4D
handles.output = hObject;

if isempty(varargin)
    error('Load RegionGrowing data to workspace and use it as parameter');
else

handles.RG = varargin{1};

if ~isfield(handles.RG, 'vol')
    f=errordlg('Data struct has not "vol" field. No representation available');
    uiwait(f);
    close;
end
[handles.M, handles.lim] = slicesMatrix(handles.RG, 512, 512);
handles.zoomstate=0;
handles.lungstate=0;
handles.overlapstate=0;
handles.fixaxes=0;
handles.newpoints=[];
set(handles.edit1, 'enable', 'off');
set(handles.slider2, 'enable', 'off');
set(handles.slider1, 'enable', 'off');
set(handles.overlapsVolumesButton, 'enable', 'off');
set(handles.shownewtraceButton, 'enable', 'off');
set(handles.validatePointButton, 'enable', 'off');
set(handles.showInLungButton, 'enable', 'off');
set(handles.text5, 'Visible', 'off');



% Update handles structure
guidata(hObject, handles);
end
% UIWAIT makes NewTrace4D wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NewTrace4D_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in showVolumeButton.
function showVolumeButton_Callback(hObject, eventdata, handles)
% hObject    handle to showVolumeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Comprueba que los datos tienen los campos necesarios
if ~isfield(handles.RG, 'masks')
    f=warndlg('Data struct has not "masks" field. Centroid option is not available');
    set(handles.centroidCheckBox, 'enable', 'off');
%     set(handles.traceCentroidsButton, 'enable', 'off');
    uiwait(f);
end

set(handles.slider1, 'enable', 'on');
set(handles.slider2, 'enable', 'off');
set(handles.slider1, 'Min', 1);
set(handles.slider1, 'Max', numel(fieldnames(handles.M)));
set(handles.slider1, 'Value', 1);
set(handles.slider1, 'SliderStep', [1/ (numel(fieldnames(handles.M))-1) 10/ (numel(fieldnames(handles.M))-1)]);
set(handles.edit1, 'enable', 'off');
set(handles.overlapsVolumesButton, 'enable', 'on');
set(handles.validatePointButton, 'enable', 'off');
set(handles.text3, 'Visible', 'off');
set(handles.showInLungButton, 'enable', 'on');
handles.lungstate=0;

for j=1:numel(fieldnames(handles.M))
    rep=handles.M.(['phase' num2str(j)]);
    faseRG=handles.RG.vol.(['phase' num2str(j)]);
    r=[];
    c=[];
    z=[];
    k=1;
    for i=1:size(rep, 3)
        [ri,ci]=find(rep(:,:,i)==1);
        zi=ones(size(ri,1),1);
        if ~isempty(ri)
            zi=zi.*k+faseRG(1,3)-1;
            r=[r; ri];
            c=[c; ci];
            z=[z; zi];
            k=k+1;
        end
    end
    handles.rT{j} = c;
    handles.cT{j} = r;
    handles.zT{j} = z;
    handles.repT{j} = rep;
    handles.sT{j} = regionprops3(rep, 'Centroid');
    
    slider1_Callback(hObject, eventdata, handles);
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in overlapsVolumesButton.
function overlapsVolumesButton_Callback(hObject, eventdata, handles)
% hObject    handle to overlapsVolumesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hold off
set(handles.edit1, 'enable', 'on');

% Update handles structure
guidata(hObject, handles);
    




function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
value = get(hObject, 'String');
fases = str2num(value);
if any(fases>numel(fieldnames(handles.RG.vol)))
    errordlg(['There are only ' num2str(numel(fieldnames(handles.RG.vol))) ' phases'])
else
index=1;
phases=[];
centroids=[];
colors=distinguishable_colors(length(fases));
for j=1:length(fases)
    i=fases(index);
    k = boundary(handles.rT{i}, handles.cT{i},handles.zT{i});
    trisurf(k, handles.rT{i}, handles.cT{i},handles.zT{i}, 'Parent', handles.axes1,...
    'facecolor', [colors(index), colors(index+length(fases)),...
    colors(index+length(fases)*2)], 'facealpha', 0.1);
    handles.axes1.YLim = [handles.lim(3)-5 handles.lim(4)+5];
    handles.axes1.XLim = [handles.lim(1)-5 handles.lim(2)+5];
    handles.axes1.ZLim = [handles.lim(5)-5 handles.lim(6)+5];
    phase=['Phase ' num2str(i)];
    phases =[phases string(phase)];
    if get(handles.centroidCheckBox, 'value') ==1
        hold on;
%         s=regionprops3(handles.repT{i}, 'Centroid');
        s=regionprops3(handles.RG.masks.(['phase' num2str(i)]), 'Centroid');
        plot3(s.Centroid(1), s.Centroid(2), s.Centroid(3),'.', 'color',[colors(index),...
        colors(index+length(fases)),colors(index+length(fases)*2)], 'markersize', 15);
        hold off
        centroid=['Centroid ' num2str(i)];
        centroids=[centroids string(centroid)];
    end
    hold on
    index=index+1;
end
if get(handles.centroidCheckBox, 'value') ==0
    legend(phases, 'Location', 'northeast');
else
    leg=strings([1,length(phases)*2]);
    leg(1:2:end)=phases;
    leg(2:2:end)=centroids;
    legend(leg, 'Location', 'northeast');
end
hold off
end


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rotateCheckBox.
function rotateCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to rotateCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rotateCheckBox

if get(hObject, 'Value')==1
    axes(handles.axes1);
    handles.fixaxes=0;
    guidata(hObject, handles);
    set(handles.fixAxisButton, 'String', 'Fix Axis');
    rotate3d on
else
    axes(handles.axes1);
    rotate3d off
end


% --- Executes on button press in centroidCheckBox.
function centroidCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to centroidCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of centroidCheckBox
if strcmp(get(handles.overlapsVolumesButton, 'enable'), 'off')
    errordlg('Click on "Show ROIs" to load data');
else

    if strcmp(get(handles.edit1, 'Enable'), 'on')
        edit1_Callback(handles.edit1, eventdata, handles);
    elseif strcmp(get(handles.slider1, 'Enable'), 'on')
        slider1_Callback(handles.slider1, eventdata, handles);
    else
        slider2_Callback(handles.slider2, eventdata, handles);
    end
end



% --- Executes on button press in traceCentroidsButton.
function traceCentroidsButton_Callback(hObject, eventdata, handles)
% hObject    handle to traceCentroidsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.overlapsVolumesButton, 'enable'), 'off')
    errordlg('Click on "Show ROIs" to load data');
else
    x=[];
    y=[];
    z=[];
    for i=1:length(handles.sT)
        x=[x handles.sT{1,i}.Centroid(1)];
        y=[y handles.sT{1,i}.Centroid(2)];
        z=[z handles.sT{1,i}.Centroid(3)];
    end
    x=[x handles.sT{1,1}.Centroid(1)];
    y=[y handles.sT{1,1}.Centroid(2)];
    z=[z handles.sT{1,1}.Centroid(3)];
%     plot3(x(:),y(:),z(:),'k-', 'Marker', '.', 'Color', 'b');
    P=[x;y;z];
    t=linspace(0,1,100);
    Q=Bezier(P,t);
    plot3(Q(1,:), Q(2,:), Q(3,:), 'Color', 'b', 'LineWidth',2);
    hold on
    plot3(P(1,:),P(2,:),P(3,:),'g:','LineWidth',2)        % plot control polygon
    plot3(P(1,:),P(2,:),P(3,:),'ro','LineWidth',2)     % plot control points
    hold off
    legend('Smoothed trace', 'Normal trace','Centroids','Location', 'northeast');
end

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% if get(hObject, 'Value')==0
%     set(hObject, 'Value', handles.slvalues(end));
% end
hold off
set(handles.edit1, 'Enable', 'off');
set(handles.overlapsVolumesButton, 'Value', 0);
value = get(hObject, 'Value');
i = round(value);
axes(handles.axes1);
lungtxt=[];

if handles.lungstate==1
    trisurf(handles.kl, handles.P(:,1), handles.P(:,2), handles.P(:,3),'facecolor', 'b', 'facealpha', 0.1,...
        'linestyle', ':', 'edgecolor', 'b', 'linewidth', 0.01);
    lungtxt = 'Lung';
    hold on
end
k = boundary(handles.rT{i}, handles.cT{i},handles.zT{i});
trisurf(k, handles.rT{i}, handles.cT{i},handles.zT{i},'facecolor', 'r', 'facealpha', 0.1);
if handles.lungstate==0 %&& handles.fixaxes==0
    ylim([handles.lim(3)-5 handles.lim(4)+5]);
    xlim([handles.lim(1)-5 handles.lim(2)+5]);
    zlim([handles.lim(5)-5 handles.lim(6)+5]);
end
if handles.fixaxes==1
    handles.axes1.CameraPosition = handles.fixlim;
end

if get(handles.centroidCheckBox, 'Value') ==1
    hold on
%     s=regionprops3(handles.repT{i}, 'Centroid');
    s=regionprops3(handles.RG.masks.(['phase' num2str(i)]), 'Centroid');
    plot3(s.Centroid(1), s.Centroid(2), s.Centroid(3),'.', 'color', 'b', 'markersize', 15);
    legend(lungtxt,['Phase ' num2str(i)], ['Centroid ' num2str(i)], 'Location', 'northeast');
    hold off
else
    legend(lungtxt,['Phase ' num2str(i)], 'Location', 'northeast');
end
hold off
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles, lungview)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in zoomButton.
function zoomButton_Callback(hObject, eventdata, handles)
% hObject    handle to zoomButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.rotateCheckBox, 'Value', 0);
if handles.zoomstate==0
    pan on
    zoom on
    handles.zoomstate=1;
    set(hObject, 'String', 'Zoom off');
else
    pan off
    zoom off
    handles.zoomstate=0;
    set(hObject, 'String', 'Zoom on');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in defineNewTraceButton.
function defineNewTraceButton_Callback(hObject, eventdata, handles)
% hObject    handle to defineNewTraceButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.overlapsVolumesButton, 'enable'), 'off')
    errordlg('Click on "Show ROIs" to load data');
else
    set(hObject, 'enable', 'off');
    set(handles.validatePointButton, 'enable', 'on');
    set(handles.shownewtraceButton, 'enable', 'on');
    hf = figure;
    h =350;
    l=50;
    for i=1:numel(fieldnames(handles.M))
        if h<=50
            h=350;
            l=150;
        end
            handles.cbx{i} = uicontrol('style','checkbox','units','pixels',...
                    'position',[l,h,112,15],'string',['Phase ' num2str(i)], 'value', 1);
            h=h-30;
    end
    htext = uicontrol('style','text','units','pixels',...
                    'position',[75,380,400,20],'string','Select the phases to be included in the new trace');
    set(htext, 'Foregroundcolor', 'r', 'FontSize', 13);
    hbutton = uicontrol('style','pushbutton','units','pixels',...
                    'position',[230,20,90,40],'string','VALIDATE');
    guidata(hObject, handles); 
    set(hbutton, 'callback', @(hObject, eventdata) validateButton_Callback(hObject, eventdata, handles));
end

function validateButton_Callback(hObject, eventdata, handles)
    for i=1:length(handles.cbx)
    if get(handles.cbx{i},'Value') == 1
        handles.info{i}=1;
    else
        handles.info{i}=0;
    end
    end
    if length(find(cell2mat(handles.info)))<4
        errordlg('Select a minimun of 4 phases');
    else
        set(handles.defineNewTraceButton, 'enable', 'on');
        set(handles.slider1, 'enable', 'off');
        set(handles.slider2, 'enable', 'on');
        set(handles.slider2, 'Value', 1);
        set(handles.slider2, 'Min', 1);
        handles.tam=find(cell2mat(handles.info));
        set(handles.slider2, 'Max',length(handles.tam));
        handles.newpoints=zeros(length(handles.tam), 3);
        range=length(handles.tam)-1;
        set(handles.slider2, 'SliderStep', [1/range 10/range]);
        set(handles.rotateCheckBox, 'value', 0);
        guidata(hObject, handles); 
        rotateCheckBox_Callback(handles.rotateCheckBox, eventdata, handles);
        slider2_Callback(handles.slider2, eventdata, handles);
        closereq();
    end
    

% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

hold off
guidata(hObject, handles); 
value = get(hObject, 'Value');
set(handles.edit1,'enable','off');
set(handles.text3, 'Visible', 'off');
handles.val = round(value);
i = handles.tam(handles.val);
axes(handles.axes1);
k = boundary(handles.rT{i}, handles.cT{i},handles.zT{i});
tri=trisurf(k, handles.rT{i}, handles.cT{i},handles.zT{i},'facecolor', 'r', 'facealpha', 0.1);
ylim([handles.lim(3)-5 handles.lim(4)+5]);
xlim([handles.lim(1)-5 handles.lim(2)+5]);
zlim([handles.lim(5)-5 handles.lim(6)+5]);
if handles.fixaxes==1
    handles.axes1.CameraPosition = handles.fixlim;
end
hold on
maxz = max(handles.zT{i});
minz = min(handles.zT{i});
maxy = max(handles.cT{i});
miny = min(handles.cT{i});
maxx = max(handles.rT{i});
minx = min(handles.rT{i});

x=rand(1,500)*(maxx-minx)+minx;
y=rand(1,500)*(maxy-miny)+miny;
z=rand(1,500)*(maxz-minz)+minz;

kd=delaunay(handles.rT{i}, handles.cT{i},handles.zT{i});
pointCloud = [x(:) y(:) z(:)];
vol=[handles.rT{i}, handles.cT{i}, handles.zT{i}];
t=tsearchn(vol,kd,pointCloud);
TF=isnan(t);
x2=zeros(1,length(TF)-length(find(TF)));
y2=zeros(1,length(TF)-length(find(TF)));
z2=zeros(1,length(TF)-length(find(TF)));
w=1;
for r=1:length(TF)
    if TF(r)==0
        x2(w)=x(r);
        y2(w)=y(r);
        z2(w)=z(r);
        w=w+1;
    end
end
pointCloud=[x2(:) y2(:) z2(:)];
h = click3DPoint(pointCloud');

if get(handles.centroidCheckBox,'Value') ==1
    hold on
%     s=regionprops3(handles.repT{i}, 'Centroid');
    s=regionprops3(handles.RG.masks.(['phase' num2str(i)]), 'Centroid');
    p=plot3(s.Centroid(1), s.Centroid(2), s.Centroid(3),'.', 'color', 'b', 'markersize', 15);
    legend([tri,p],['Phase ' num2str(i)], ['Centroid ' num2str(i)], 'Location', 'northeast');
%     hold off
else
    legend(['Phase ' num2str(i)], 'Location', 'northeast');
end

if handles.newpoints(handles.val) ~= [0 0 0]
    plot3(handles.newpoints(handles.val, 1),handles.newpoints(handles.val, 2)...
        ,handles.newpoints(handles.val, 3), '.', 'color', 'r', 'markersize', 15); 
end
guidata(hObject, handles); 


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function h = click3DPoint(pointCloud)
%CLICKA3DPOINT
%   H = CLICKA3DPOINT(POINTCLOUD) shows a 3D point cloud and lets the user
%   select points by clicking on them. The selected point is highlighted 
%   and its index in the point cloud will is printed on the screen. 
%   POINTCLOUD should be a 3*N matrix, represending N 3D points. 
%   Handle to the figure is returned.
%
%   other functions required:
%       CALLBACKCLICK3DPOINT  mouse click callback function
%       ROWNORM returns norms of each row of a matrix
%       
%   To test this function ... 
%       pointCloud = rand(3,100)*100;
%       h = clickA3DPoint(pointCloud);
% 
%       now rotate or move the point cloud and try it again.
%       (on the figure View menu, turn the Camera Toolbar on, ...)
%
%   To turn off the callback ...
%       set(h, 'WindowButtonDownFcn',''); 
%
%   by Babak Taati
%   http://rcvlab.ece.queensu.ca/~taatib
%   Robotics and Computer Vision Laboratory (RCVLab)
%   Queen's University
%   May 4, 2005 
%   revised Oct 30, 2007
%   revised May 19, 2009

if nargin ~= 1
    error('Requires one input arguments.')
end

if size(pointCloud, 1)~=3
    error('Input point cloud must be a 3*N matrix.');
end

% show the point cloud
h = gcf;
plot3(pointCloud(1,:), pointCloud(2,:), pointCloud(3,:), 'c.'); 
cameratoolbar('Show'); % show the camera toolbar
hold on; % so we can highlight clicked points without clearing the figure

% set the callback, pass pointCloud to the callback function
set(h, 'WindowButtonDownFcn', {@callbackClick3DPoint, pointCloud}); 

function callbackClick3DPoint(src, eventData, pointCloud)
% CALLBACKCLICK3DPOINT mouse click callback function for CLICKA3DPOINT
%
%   The transformation between the viewing frame and the point cloud frame
%   is calculated using the camera viewing direction and the 'up' vector.
%   Then, the point cloud is transformed into the viewing frame. Finally,
%   the z coordinate in this frame is ignored and the x and y coordinates
%   of all the points are compared with the mouse click location and the 
%   closest point is selected.
%
%   Babak Taati - May 4, 2005
%   revised Oct 31, 2007
%   revised Jun 3, 2008
%   revised May 19, 2009

point = get(gca, 'CurrentPoint'); % mouse click position
camPos = get(gca, 'CameraPosition'); % camera position
camTgt = get(gca, 'CameraTarget'); % where the camera is pointing to

camDir = camPos - camTgt; % camera direction
camUpVect = get(gca, 'CameraUpVector'); % camera 'up' vector

% build an orthonormal frame based on the viewing direction and the 
% up vector (the "view frame")
zAxis = camDir/norm(camDir);    
upAxis = camUpVect/norm(camUpVect); 
xAxis = cross(upAxis, zAxis);
yAxis = cross(zAxis, xAxis);

rot = [xAxis; yAxis; zAxis]; % view rotation 

% the point cloud represented in the view frame
rotatedPointCloud = rot * pointCloud; 

% the clicked point represented in the view frame
rotatedPointFront = rot * point' ;

% find the nearest neighbour to the clicked point 
pointCloudIndex = dsearchn(rotatedPointCloud(1:2,:)', ... 
    rotatedPointFront(1:2));

h = findobj(gca,'Tag','pt'); % try to find the old point
selectedPoint = pointCloud(:, pointCloudIndex); 

if isempty(h) % if it's the first click (i.e. no previous point to delete)
    
    % highlight the selected point
    h = plot3(selectedPoint(1,:), selectedPoint(2,:), ...
        selectedPoint(3,:), 'r.', 'MarkerSize', 20); 
    set(h,'Tag','pt'); % set its Tag property for later use   

else % if it is not the first click

    delete(h); % delete the previously selected point
    
    % highlight the newly selected point
    h = plot3(selectedPoint(1,:), selectedPoint(2,:), ...
        selectedPoint(3,:), 'r.', 'MarkerSize', 20);  
    set(h,'Tag','pt');  % set its Tag property for later use

end

fprintf('you clicked on point %d, %d, %d\n', selectedPoint(1,:), selectedPoint(2,:), ...
        selectedPoint(3,:));


% --- Executes on button press in validatePointButton.
function validatePointButton_Callback(hObject, eventdata, handles)
% hObject    handle to validatePointButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
h = findobj(gca, 'Tag', 'pt');
if isempty(h)
    errordlg('Select a point before validation');
else
    pt = [h.XData h.YData h.ZData];
    handles.newpoints(handles.val, :)= pt;
    guidata(hObject, handles); 
    set(handles.text3, 'Visible', 'on');
end

% --- Executes on button press in shownewtraceButton.
function shownewtraceButton_Callback(hObject, eventdata, handles)
% hObject    handle to shownewtraceButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = gcf;
set(h, 'WindowButtonDownFcn', []); 
hold off
x=handles.newpoints(:,1);
y=handles.newpoints(:,2);
z=handles.newpoints(:,3);
% plot3(x(:),y(:),z(:),'k-', 'Marker', '.', 'Color', 'b');
x=[x; handles.newpoints(1,1)];
y=[y; handles.newpoints(1,2)];
z=[z; handles.newpoints(1,3)];


P=[x';y';z'];
t=linspace(0,1,100);
Q=Bezier(P,t);
plot3(Q(1,:), Q(2,:), Q(3,:), 'Color', 'b', 'LineWidth',2);
hold on
plot3(P(1,:),P(2,:),P(3,:),'g:','LineWidth',2)        % plot control polygon
plot3(P(1,:),P(2,:),P(3,:),'ro','LineWidth',2)     % plot control points
hold off
legend('Smoothed trace', 'Normal trace','Centroids','Location', 'northeast');


% --- Executes on button press in showInLungButton.
function showInLungButton_Callback(hObject, eventdata, handles)
% hObject    handle to showInLungButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.lungstate=1;
if isfield(handles, 'P')
    slider1_Callback(hObject, eventdata, handles)
else
f=helpdlg('Select folder with the DICOM case images');
uiwait(f);
path=uigetdir(matlabroot, 'Select folder with the DICOM case images');

if path~=0
files=dir(path);
if contains(path, "\")
    file=dicominfo([path '\' files(3).name]);
else
    file=dicominfo([path '/' files(3).name]);
end
nslices=file.ImagesInAcquisition;
dicom=cell(nslices,1);
for i=1:nslices
    if contains(path, "\")
        dicom{i,1}=dicominfo([path '\' files(i+2).name]);
    else
        dicom{i,1}=dicominfo([path '/' files(i+2).name]);
    end
    positions(i)=dicom{i,1}.ImagePositionPatient(3);    
end
sortedpositions=sort(positions);
for j=1:nslices
    for i=1:nslices
        if sortedpositions(j)==dicom{i,1}.ImagePositionPatient(3)
            infoD{j}=dicom{i,1};
        end
    end
end

for i=1:nslices
    Ii=dicomread(infoD{i}.Filename);
    I(:,:,i)=Ii;
end
set(handles.text5, 'Visible', 'on');
% Corte transversal
mid=fix(size(I,3)/2);
h = imshow(I(:,:,mid),[]);
[y,x]=ginput(1);
[nrows, ncols] = size(get(h, 'CData'));
xdata = get(h, 'XData');
ydata = get(h, 'YData');
px=fix(axes2pix(ncols, xdata, x));
py=fix(axes2pix(nrows, ydata, y));
set(handles.text5, 'Visible', 'off');

tic
% % Corte sagital
% Is=permute(I,[1 3 2]);
% hs=imshow(Is(:,:,fix(size(Is,3)/2)),[]);
% [y,x]=ginput(1);
% [nrows, ncols] = size(get(hs, 'CData'));
% xdata = get(hs, 'XData');
% ydata = get(hs, 'YData');
% psx=fix(axes2pix(ncols, xdata, x));
% psy=fix(axes2pix(nrows, ydata, y));
% % Corte coronal
% Ic=permute(I, [3 2 1]);
% hc=imshow(Ic(:,:,fix(size(Ic,3)/2)),[]);
% [y,x]=ginput(1);
% [nrows, ncols] = size(get(hc, 'CData'));
% xdata = get(hc, 'XData');
% ydata = get(hc, 'YData');
% pcx=fix(axes2pix(ncols, xdata, x));
% pcy=fix(axes2pix(nrows, ydata, y));
% 
% [Ps,~]=regrow(Is,[psx fix(size(Is,3)/2) psy],300,inf);
% [Pc,~]=regrow(Ic,[fix(size(Ic,3)/2) pcy pcx],300,inf);
[handles.P,~]=regrow(I,[px py mid],300,inf);
% handles.P =[handles.P Ps Pc];

toc
handles.kl = boundary(handles.P(:,1), handles.P(:,2), handles.P(:,3));
% trisurf(handles.kl, P(:,1), P(:,2), P(:,3),'facecolor', 'b', 'facealpha', 0.1);
guidata(hObject, handles); 
slider1_Callback(hObject, eventdata, handles)
end
end


% --- Executes on button press in fixAxisButton.
function fixAxisButton_Callback(hObject, eventdata, handles)
% hObject    handle to fixAxisButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fixAxisButton
if handles.fixaxes==0
    handles.fixlim = handles.axes1.CameraPosition;
    handles.fixaxes=1;
    set(hObject, 'String', 'Unfix Axis');
    set(handles.rotateCheckBox, 'Value', 0);
else
    handles.fixaxes=0;
    set(hObject, 'String', 'Fix Axis');
end
guidata(hObject, handles);
rotateCheckBox_Callback(handles.rotateCheckBox, eventdata, handles);
