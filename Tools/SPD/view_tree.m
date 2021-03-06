function varargout = view_tree(varargin)
% VIEW_TREE M-file for view_tree.fig
%      VIEW_TREE, by itself, creates a new VIEW_TREE or raises the existing
%      singleton*.
%
%      H = VIEW_TREE returns the handle to a new VIEW_TREE or the handle to
%      the existing singleton*.
%
%      VIEW_TREE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEW_TREE.M with the given input arguments.
%
%      VIEW_TREE('Property','Value',...) creates a new VIEW_TREE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before view_tree_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to view_tree_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help view_tree

% Last Modified by GUIDE v2.5 06-Jul-2009 11:30:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @view_tree_OpeningFcn, ...
                   'gui_OutputFcn',  @view_tree_OutputFcn, ...
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


% --- Executes just before view_tree is made visible.
function view_tree_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to view_tree (see VARARGIN)

% Choose default command line output for view_tree
handles.output = hObject;
handles.progression_module = varargin{1};
handles.exp_names = varargin{2};
handles.color_code_names = varargin{3};
handles.color_code_vectors = varargin{4};
handles.mother_window_handles = varargin{5};
handles.mouse_selected_nodes = [];
% Update handles structure
guidata(hObject, handles);
[coeff] = Axes_mst_CreateFcn(handles.Axes_mst, [], handles);
[color_code_vectors, color_code_names] = Listbox_colorcode_options_CreateFcn(handles.Listbox_colorcode_options, [], handles);
handles.progression_module.node_position = coeff;
handles.color_code_names = color_code_names;
handles.color_code_vectors = color_code_vectors;

nodes_handles = get(handles.Axes_mst,'children'); N = size(handles.progression_module.gene_expr,2);
nodes_handles = nodes_handles(N:-1:1);
for i=1:length(nodes_handles)
    set(nodes_handles(i),'ButtonDownFcn','view_tree(''edit_NodesPositions_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
end
handles.nodes_handles=nodes_handles; 
guidata(hObject, handles);

% UIWAIT makes view_tree wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = view_tree_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Button_Redraw_mst.
function Button_Redraw_mst_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Redraw_mst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.Axes_mst)
handles.progression_module.node_position=[];
guidata(hObject, handles);
coeff = draw_on_Axes_mst(handles);
handles.progression_module.node_position = coeff;
guidata(hObject, handles);
% determine the handles of the drawn nodes
nodes_handles = get(handles.Axes_mst,'children');
N = size(handles.progression_module.gene_expr,2);
nodes_handles = nodes_handles(N:-1:1);
% here is the magic that links the nodes to a function 
for i=1:length(nodes_handles)
    set(nodes_handles(i),'ButtonDownFcn','view_tree(''edit_NodesPositions_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
end
handles.nodes_handles=nodes_handles;
guidata(hObject,handles)


% --- Executes on button press in Button_show_new_window.
function Button_show_new_window_Callback(hObject, eventdata, handles)
% hObject    handle to Button_show_new_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure; coeff = draw_on_Axes_mst(handles);
title(handles.color_code_names{get(handles.Listbox_colorcode_options,'value')},'Interpreter','none'); axis off;
% determine the handles of the drawn nodes
nodes_handles = get(handles.Axes_mst,'children'); N = size(handles.progression_module.gene_expr,2);
nodes_handles = nodes_handles(N:-1:1);
for i=1:length(nodes_handles)
    set(nodes_handles(i),'ButtonDownFcn','view_tree(''edit_NodesPositions_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
end
handles.nodes_handles=nodes_handles; guidata(handles.Axes_mst,handles)


% --- Executes on button press in Button_Save_layout.
function Button_Save_layout_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Save_layout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
coeff = handles.progression_module.node_position;
visualized_gene_modules = unique(handles.progression_module.gene_modules);
for i=1:length(handles.mother_window_handles.progression_modules)
    if isequal(visualized_gene_modules, unique(handles.mother_window_handles.progression_modules(i).gene_modules))
        handles.mother_window_handles.progression_modules(i).node_position = coeff;
    end
end
for i=1:length(handles.mother_window_handles.handpicked_progression)
    if isequal(visualized_gene_modules, unique(handles.mother_window_handles.handpicked_progression(i).gene_modules))
        handles.mother_window_handles.handpicked_progression(i).node_position = coeff;
    end
end
guidata(handles.mother_window_handles.figure1,handles.mother_window_handles)



% --- Executes on button press in Button_close.
function Button_close_Callback(hObject, eventdata, handles)
% hObject    handle to Button_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Button_Close.
function Button_Close_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close

% --- Executes on button press in Checkbox_is_color_code.
function Checkbox_is_color_code_Callback(hObject, eventdata, handles)
% hObject    handle to Checkbox_is_color_code (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
draw_on_Axes_mst(handles);
nodes_handles = get(handles.Axes_mst,'children'); N = size(handles.progression_module.gene_expr,2);
nodes_handles = nodes_handles(N:-1:1);
for i=1:length(nodes_handles)
    set(nodes_handles(i),'ButtonDownFcn','view_tree(''edit_NodesPositions_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
end
handles.nodes_handles=nodes_handles; guidata(handles.Axes_mst,handles)


% --- Executes on selection change in Listbox_colorcode_options.
function Listbox_colorcode_options_Callback(hObject, eventdata, handles)
% hObject    handle to Listbox_colorcode_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.Checkbox_is_color_code,'value')==1
    draw_on_Axes_mst(handles);
    nodes_handles = get(handles.Axes_mst,'children'); N = size(handles.progression_module.gene_expr,2);
    nodes_handles = nodes_handles(N:-1:1);
    for i=1:length(nodes_handles)
        set(nodes_handles(i),'ButtonDownFcn','view_tree(''edit_NodesPositions_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
    end
    handles.nodes_handles=nodes_handles; guidata(handles.Axes_mst,handles)
    clc
    [AA,BB,CC] = table(handles.color_code_vectors(get(hObject,'value'),:))
end


% --- Executes during object creation, after setting all properties.
function [color_code_vectors, color_code_names] =Listbox_colorcode_options_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Listbox_colorcode_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
if isstruct(handles) && isfield(handles,'progression_module')
    color_code_vectors = handles.color_code_vectors;
    color_code_names = handles.color_code_names;
    for i=1:size(handles.progression_module.gene_modules_mean,1)
        color_code_vectors = [color_code_vectors;handles.progression_module.gene_modules_mean(i,:)];
        if sum(handles.mother_window_handles.idx==handles.progression_module.gene_modules(i))==1
            color_code_names = [color_code_names; {['Module ',num2str(handles.progression_module.gene_modules(i)),' (', num2str(sum(handles.mother_window_handles.idx==handles.progression_module.gene_modules(i))),' genes) - ',handles.mother_window_handles.probe_names{handles.mother_window_handles.filter_gene_ind(handles.mother_window_handles.idx==handles.progression_module.gene_modules(i))}]}];
        else
            color_code_names = [color_code_names; {['Module ',num2str(handles.progression_module.gene_modules(i)),' (', num2str(sum(handles.mother_window_handles.idx==handles.progression_module.gene_modules(i))),' genes)']}];
        end
    end
    set(hObject,'string',color_code_names);
end


% --- Executes during object creation, after setting all properties.
function [coeff] = Axes_mst_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Axes_mst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
coeff=[];
if isstruct(handles) && isfield(handles,'progression_module')
    coeff = draw_on_Axes_mst(handles);
end



function [coeff] = draw_on_Axes_mst(handles)
% compute the locations of each node, if there is no node_position info existing
mst_tree = handles.progression_module.adj1;
if isempty(handles.progression_module.node_position)
    tree_for_embedding = mst_tree;
    tree_for_embedding(triu(tree_for_embedding,1)==1) = 1 + rand(sum(sum(triu(tree_for_embedding,1)==1)),1)*10;
    tree_for_embedding = (tree_for_embedding + tree_for_embedding')/2;
%     [positions] = hd_embedding(tree_for_embedding,5);
%     hold off; [coeff] = multiclass_pcaplot(positions); 
%     coeff(1,:) = coeff(1,:)/max(abs(coeff(1,:)))*50;
%     coeff(2,:) = coeff(2,:)/max(abs(coeff(2,:)))*50;
    coeff = arch_layout(double(tree_for_embedding~=0));
else
    coeff = handles.progression_module.node_position;
end
adj = mst_tree;

% draw edges
hold off; plot(0); hold on;
pairs = find_matrix_big_element(triu(adj,1),1);
for k=1:size(pairs,1), line(coeff(1,pairs(k,:)),coeff(2,pairs(k,:)),'color','b'); end
% draw labels
if get(handles.Radiobutton_label_numbers,'value')==1
    for k=1:size(coeff,2), text(coeff(1,k)+2,coeff(2,k),num2str(k),'FontSize',7); end  
elseif get(handles.Radiobutton_label_exp_names,'value')==1
    for k=1:size(coeff,2), 
        tmp = handles.exp_names{k}; tmp(tmp=='_')='-';
        text(coeff(1,k)+2,coeff(2,k),tmp,'FontSize',7); 
    end  
elseif get(handles.Radiobutton_label_none,'value')==1
    1; % do nothing
end
% draw nodes
if get(handles.Checkbox_is_color_code,'value')==0
    for k=1:size(coeff,2), plot(coeff(1,k),coeff(2,k),'o','markersize',8,'color','k','markerfacecolor','k'); end
else
    color_code_vector = handles.color_code_vectors(get(handles.Listbox_colorcode_options,'value'),:);
    if sum(isnan(color_code_vector))~=0
        color_code_vector(isnan(color_code_vector)) = nanmedian(color_code_vector);
    end
    if max(color_code_vector)==min(color_code_vector)
        color_code_vector = ones(size(color_code_vector));
    elseif length(unique(color_code_vector))==2
        color_code_vector = (color_code_vector - min(color_code_vector))/(max(color_code_vector)-min(color_code_vector))*0.9+0.1;
        color_code_vector(color_code_vector==min(color_code_vector))=0.5;
    else
        color_code_vector = (color_code_vector - min(color_code_vector))/(max(color_code_vector)-min(color_code_vector))*0.9+0.1;
    end
    color_code_vector = 1 - color_code_vector;  % higher value ==> smaller color_code ==> darker in plot
    colormap('default'); cmap_tmp = flipud(colormap);
    for k=1:size(coeff,2), 
        color_tmp = [1,1,1]*color_code_vector(k);        % gray
%         color_tmp = [1,0,0]+[0,1,0]*color_code_vector(k);  % yellow-red
        color_tmp = interp1(((1:size(cmap_tmp,1))'-1)/(size(cmap_tmp,1)-1),cmap_tmp,color_code_vector(k));  % blue-red        
        plot(coeff(1,k),coeff(2,k),'o','markersize',8,'markerfacecolor',color_tmp,'color',color_tmp); 
    end
end
hold off;
% axis(reshape([-max(abs(coeff)');+max(abs(coeff)')],1,4)*1.1)
axis([min(-50,-max(abs(coeff(1,:)))*1.1), max(50,max(abs(coeff(1,:)))*1.1), min(-50,-max(abs(coeff(2,:)))*1.1), max(50,max(abs(coeff(2,:)))*1.1) ]);


% --- Executes on button press in Radiobutton_label_numbers.
function Radiobutton_label_numbers_Callback(hObject, eventdata, handles)
% hObject    handle to Radiobutton_label_numbers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'value')==0
    set(hObject,'value',1);
else
    draw_on_Axes_mst(handles);
    nodes_handles = get(handles.Axes_mst,'children'); N = size(handles.progression_module.gene_expr,2);
    nodes_handles = nodes_handles(N:-1:1);
    for i=1:length(nodes_handles)
        set(nodes_handles(i),'ButtonDownFcn','view_tree(''edit_NodesPositions_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
    end
    handles.nodes_handles=nodes_handles; 
    guidata(handles.Axes_mst,handles)
end




% --- Executes on button press in Radiobutton_label_exp_names.
function Radiobutton_label_exp_names_Callback(hObject, eventdata, handles)
% hObject    handle to Radiobutton_label_exp_names (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'value')==0
    set(hObject,'value',1);
else
    draw_on_Axes_mst(handles);
    nodes_handles = get(handles.Axes_mst,'children'); N = size(handles.progression_module.gene_expr,2);
    nodes_handles = nodes_handles(N:-1:1);
    for i=1:length(nodes_handles)
        set(nodes_handles(i),'ButtonDownFcn','view_tree(''edit_NodesPositions_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
    end
    handles.nodes_handles=nodes_handles; 
    guidata(handles.Axes_mst,handles)
end


% --- Executes on button press in Radiobutton_label_none.
function Radiobutton_label_none_Callback(hObject, eventdata, handles)
% hObject    handle to Radiobutton_label_none (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'value')==0
    set(hObject,'value',1);
else
    draw_on_Axes_mst(handles);
    nodes_handles = get(handles.Axes_mst,'children'); N = size(handles.progression_module.gene_expr,2);
    nodes_handles = nodes_handles(N:-1:1);
    for i=1:length(nodes_handles)
        set(nodes_handles(i),'ButtonDownFcn','view_tree(''edit_NodesPositions_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
    end
    handles.nodes_handles=nodes_handles; 
    guidata(handles.Axes_mst,handles)
end


% functions for moving nodes around
function edit_NodesPositions_ButtonDownFcn(hObject, eventdata, handles)
% disp('visited_down_local')
selected_node = find(handles.nodes_handles==hObject);
handles.mouse_selected_nodes = selected_node;
guidata(hObject,handles)
% set(handles.figure1,'WindowButtonDownFcn','view_tree(''edit_Axes_WindowButtonDownFcn'',gcbo,[],guidata(gcbo))');
set(handles.figure1,'WindowButtonMotionFcn','view_tree(''edit_Axes_WindowButtonMotionFcn'',gcbo,[],guidata(gcbo))');
set(handles.figure1,'WindowButtonUpFcn','view_tree(''edit_Axes_WindowButtonUpFcn'',gcbo,[],guidata(gcbo))');


function edit_Axes_WindowButtonDownFcn(hObject, eventdata, handles)

function edit_Axes_WindowButtonUpFcn(hObject, eventdata, handles)
% disp('visited_up_global')
handles.mouse_selected_nodes = [];
set(handles.figure1,'WindowButtonUpFcn',[]);
set(handles.figure1,'WindowButtonMotionFcn',[]);

nodes_handles = get(handles.Axes_mst,'children'); N = size(handles.progression_module.gene_expr,2);
nodes_handles = nodes_handles(N:-1:1);
for i=1:length(nodes_handles)
    set(nodes_handles(i),'ButtonDownFcn','view_tree(''edit_NodesPositions_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
end
handles.nodes_handles=nodes_handles; 
guidata(hObject,handles);
% get(handles.Axes_mst,'currentpoint')

function edit_Axes_WindowButtonMotionFcn(hObject, eventdata, handles)
% disp('visited_motion_global')
current_mouse_position =  get(handles.Axes_mst,'currentpoint');
x = current_mouse_position(1,1);
y = current_mouse_position(1,2);
handles.progression_module.node_position(1:2,handles.mouse_selected_nodes)=[x;y];
guidata(hObject,handles)
draw_on_Axes_mst(handles);


% --- Executes on button press in Button_Export_Gene_List.
function Button_Export_Gene_List_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Export_Gene_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
result_file_directory = handles.mother_window_handles.data_filename(1:max(find(handles.mother_window_handles.data_filename=='\')));
all_genes = handles.mother_window_handles.probe_names(:,1);

% all_genes = handles.mother_window_handles.probe_names(:,2);
% for i=1:length(all_genes)
%     ind = find(all_genes{i}==' ');
%     if length(ind)<2
%         all_genes{i} = ' ';
%     else
%         all_genes{i} = all_genes{i}(ind(1)+1:ind(2)-1);
%     end
% end

interesting_modules = handles.progression_module.gene_modules;
filter_gene_ind =  handles.mother_window_handles.filter_gene_ind;
idx = handles.mother_window_handles.idx;
fid = fopen([result_file_directory,'progression_genes.gmt'],'w');
for i=1:length(interesting_modules)
    tmp = all_genes(filter_gene_ind(idx==interesting_modules(i)));
    line_to_write = ['module-',num2str(interesting_modules(i)) , char(9), 'module-',num2str(interesting_modules(i)) ];
    for j=1:length(tmp)
        line_to_write = [line_to_write, char(9), tmp{j}];
    end
    fprintf(fid,'%s\n', line_to_write);
end
fclose(fid);


entries_to_write=cell(0);
for i=1:length(interesting_modules)
    tmp = all_genes(filter_gene_ind(idx==interesting_modules(i)));    
    entries_to_write(1:length(tmp),i) = tmp;
end
write_to_txt([result_file_directory,'progression_genes.txt'], [], entries_to_write, [], char(9))


entries_to_write=cell(0);
for i=1:length(interesting_modules)
    tmp = all_genes(filter_gene_ind(idx==interesting_modules(i)));    
    entries_to_write = [entries_to_write;tmp];
end
write_to_txt([result_file_directory,'progression_genes2.txt'], [], entries_to_write, [], char(9))
