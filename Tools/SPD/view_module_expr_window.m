function varargout = view_module_expr_window(varargin)
% VIEW_MODULE_EXPR_WINDOW M-file for view_module_expr_window.fig
%      VIEW_MODULE_EXPR_WINDOW, by itself, creates a new VIEW_MODULE_EXPR_WINDOW or raises the existing
%      singleton*.
%
%      H = VIEW_MODULE_EXPR_WINDOW returns the handle to a new VIEW_MODULE_EXPR_WINDOW or the handle to
%      the existing singleton*.
%
%      VIEW_MODULE_EXPR_WINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEW_MODULE_EXPR_WINDOW.M with the given input arguments.
%
%      VIEW_MODULE_EXPR_WINDOW('Property','Value',...) creates a new VIEW_MODULE_EXPR_WINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before view_module_expr_window_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to view_module_expr_window_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help view_module_expr_window

% Last Modified by GUIDE v2.5 31-May-2009 12:42:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @view_module_expr_window_OpeningFcn, ...
                   'gui_OutputFcn',  @view_module_expr_window_OutputFcn, ...
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


% --- Executes just before view_module_expr_window is made visible.
function view_module_expr_window_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to view_module_expr_window (see VARARGIN)

% Choose default command line output for view_module_expr_window
handles.output = hObject;
handles.filtered_data = varargin{1};
handles.filtered_probe_names = varargin{2};
handles.idx = varargin{3};
handles.exp_names = varargin{4};
handles.color_code_names = varargin{5};
handles.color_code_vectors = varargin{6};
handles.mother_window_handles = varargin{7};
handles.module_means = get_module_mean(handles.filtered_data, handles.idx);
handles.sample_order = [];
handles.sample_ordered_value = [];
guidata(hObject, handles);
Listbox_modules_CreateFcn(handles.Listbox_modules, [], handles);
[handles.sample_order,handles.sample_ordered_value] = Listbox_order_samples_CreateFcn(handles.Listbox_order_samples, [], handles);
guidata(hObject, handles);
Axes_module_mean_CreateFcn(handles.Axes_module_mean, [], handles);
Axes_module_heatmap_CreateFcn(handles.Axes_module_heatmap, [], handles);
Axes_ordering_vector_CreateFcn(handles.Axes_ordering_vector, [], handles);


% --- Outputs from this function are returned to the command line.
function varargout = view_module_expr_window_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in Listbox_modules.
function Listbox_modules_Callback(hObject, eventdata, handles)
% hObject    handle to Listbox_modules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.Listbox_modules,'Enable','inactive');
set(handles.Listbox_order_samples,'Enable','inactive');
draw_module_mean(handles.Axes_module_mean, handles);
draw_module_heatmap(handles.Axes_module_heatmap, handles);
draw_ordering_vector(handles.Axes_ordering_vector, handles)
set(handles.Listbox_order_samples,'Enable','on');
set(handles.Listbox_modules,'Enable','on');

% --- Executes during object creation, after setting all properties.
function Listbox_modules_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Listbox_modules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
if isstruct(handles) && isfield(handles,'filtered_data') && isfield(handles,'idx')
    tmp_for_listbox = [];
    for i=1:max(handles.idx)
        tmp_for_listbox = [tmp_for_listbox; {['Module ',num2str(i),' (', num2str(sum(handles.idx==i)),' genes)']}];
    end
    set(hObject,'string',tmp_for_listbox);
    set(hObject,'value',1);
end



% --- Executes on selection change in Listbox_order_samples.
function Listbox_order_samples_Callback(hObject, eventdata, handles)
% hObject    handle to Listbox_order_samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.Listbox_order_samples,'Enable','inactive');
set(handles.Listbox_modules,'Enable','inactive');
draw_module_mean(handles.Axes_module_mean, handles);
draw_module_heatmap(handles.Axes_module_heatmap, handles);
draw_ordering_vector(handles.Axes_ordering_vector, handles)
set(handles.Listbox_modules,'Enable','on');
set(handles.Listbox_order_samples,'Enable','on');


% --- Executes during object creation, after setting all properties.
function [sample_order,sample_order_derived_from] = Listbox_order_samples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Listbox_order_samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
if isstruct(handles) && isfield(handles,'filtered_data') && isfield(handles,'idx')
    tmp_for_listbox = [{'original order'}];
    sample_order = [1:size(handles.filtered_data,2)];    
    sample_order_derived_from = [1:size(handles.filtered_data,2)];
    if ~isempty(handles.color_code_names) && ~isempty(handles.color_code_vectors) && size(handles.color_code_vectors,2)==size(handles.filtered_data,2)
        tmp_for_listbox = [tmp_for_listbox;handles.color_code_names];
        [Y,I] = sort(handles.color_code_vectors,2);
        sample_order = [sample_order;I];
        sample_order_derived_from = [sample_order_derived_from;handles.color_code_vectors];
    end
    for i=1:max(handles.idx)
        tmp_for_listbox = [tmp_for_listbox; {['Module avg ',num2str(i),' (', num2str(sum(handles.idx==i)),' genes)']}];
    end
    [Y,I] = sort(handles.module_means,2);
    sample_order = [sample_order;I];
    sample_order_derived_from = [sample_order_derived_from;handles.module_means];
    set(hObject,'string',tmp_for_listbox);
    set(hObject,'value',1);
end

% --- Executes on button press in Button_show_avg_expr_new_window.
function Button_show_avg_expr_new_window_Callback(hObject, eventdata, handles)
% hObject    handle to Button_show_avg_expr_new_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    module_ind = get(handles.Listbox_modules,'value');
    order_ind = get(handles.Listbox_order_samples,'value');
    I = handles.sample_order(order_ind,:);
    figure
    plot(handles.module_means(module_ind,I),'-o');
    axis tight;
    axis_range = axis;
    axis([[-1,1]+axis_range(1:2),(axis_range(4)-axis_range(3))*0.3*[-1,1]+axis_range(3:4)]);
    axis_range = axis;
    y_range = axis_range(3:4);
    text_y_position = y_range(1)+(y_range(2)-y_range(1))/20;
    for i=1:length(I)
        text(i,text_y_position,num2str(I(i)),'FontSize',6);
    end


% --- Executes on button press in Button_show_module_heatmap_in_new_window.
function Button_show_module_heatmap_in_new_window_Callback(hObject, eventdata, handles)
% hObject    handle to Button_show_module_heatmap_in_new_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    module_ind = get(handles.Listbox_modules,'value');
    order_ind = get(handles.Listbox_order_samples,'value');
    I = handles.sample_order(order_ind,:);
    figure; 
    imagesc(handles.filtered_data(handles.idx==module_ind,I));
%     axis goff;


% --- Executes on button press in Button_Export_gene_names.
function Button_Export_gene_names_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Export_gene_names (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    module_ind = get(handles.Listbox_modules,'value');
    filename = handles.mother_window_handles.data_filename;
    filename = [filename(1:max(find(filename=='\'))),'module_member_genes.txt'];
    write_to_txt(filename,[],handles.filtered_probe_names(handles.idx==module_ind,:),[],char(9));
    


% --- Executes during object creation, after setting all properties.
function Axes_module_mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Axes_module_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if isstruct(handles) && isfield(handles,'filtered_data') && isfield(handles,'idx')
    draw_module_mean(hObject, handles)
end


% --- Executes during object creation, after setting all properties.
function Axes_module_heatmap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Axes_module_heatmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if isstruct(handles) && isfield(handles,'filtered_data') && isfield(handles,'idx')
    draw_module_heatmap(hObject, handles)
end


% --- Executes during object creation, after setting all properties.
function Axes_ordering_vector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Axes_ordering_vector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if isstruct(handles) && isfield(handles,'filtered_data') && isfield(handles,'idx')
    draw_ordering_vector(hObject, handles)
end



function draw_module_mean(hObject, handles)
    module_ind = get(handles.Listbox_modules,'value');
    order_ind = get(handles.Listbox_order_samples,'value');
    I = handles.sample_order(order_ind,:);
    axes(hObject);
    plot(handles.module_means(module_ind,I),'-o');
    axis tight;
    x_range = get(hObject,'XLim');
    set(hObject,'XLim',[-1,1]+x_range);
    y_range = get(hObject,'YLim');
    set(hObject,'YLim',[y_range(1)-(max(y_range)-min(y_range))*0.3, y_range(2)+(max(y_range)-min(y_range))*0.3])
    y_range = get(hObject,'YLim');
    text_y_position = y_range(1)+(y_range(2)-y_range(1))/20;
    for i=1:length(I)
        text(i-0.5,text_y_position,num2str(I(i)),'FontSize',6);
    end


function draw_module_heatmap(hObject, handles)
    module_ind = get(handles.Listbox_modules,'value');
    order_ind = get(handles.Listbox_order_samples,'value');
    I = handles.sample_order(order_ind,:);
    axes(hObject);
    if sum(handles.idx==module_ind)>1 & length(I)>1
        HCC_heatmap(handles.filtered_data(handles.idx==module_ind,I),'r');
    else
        imagesc(handles.filtered_data(handles.idx==module_ind,I));
    end
%     axis off;

function draw_ordering_vector(hObject, handles)
    order_ind = get(handles.Listbox_order_samples,'value');
    I = handles.sample_order(order_ind,:);
    axes(hObject);
    imagesc(handles.sample_ordered_value(order_ind,I));
    axis off;

