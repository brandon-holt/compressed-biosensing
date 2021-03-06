function [fcshdr] = readfcs_v2_only_header(filename)

% check whether the input filename exists or not
if exist(filename) ~= 2
    display([filename,': The file does not exist!']);
    data = []; marker_names = []; channel_names = [];
    fcsdat = []; fcshdr = [];
    return;
end



%fid = fopen(filename,'r','ieee-be');
fid = fopen(filename,'r','b');
fcsheader  = fread(fid,58,'char');       % length of 58 defined by FCS3.0 standard
fcsheader_type = char(fcsheader(1:6)');  % the first 6 char's specify file standard, followed by 4 spaces
%
%reading the header
%
if strcmp(fcsheader_type,'FCS1.0')
    display('FCS 1.0 file type is not supported!');
    data = []; marker_names = []; channel_names = [];
    fcsdat = []; fcshdr = [];
    fclose(fid);
    return
elseif  strcmp(fcsheader_type,'FCS2.0') || strcmp(fcsheader_type,'FCS3.0')  || strcmp(fcsheader_type,'FCS3.1')% FCS2.0 or FCS3.0 or 3.1 types
    fcshdr.fcstype      = fcsheader_type;
    FcsTextStartPos     = str2num(char(fcsheader(11:18)'));  % numbers/coordinates defined by FCS3.0 standard
    FcsTextStopPos      = str2num(char(fcsheader(19:26)'));
    FcsDataStartPos     = str2num(char(fcsheader(27:34)'));   
    FcsDataStopPos      = str2num(char(fcsheader(35:42)'));   
    FcsAnalysisStartPos = str2num(char(fcsheader(43:50)'));   
    FcsAnalysisStopPos  = str2num(char(fcsheader(51:58)'));   
    status = fseek(fid,FcsTextStartPos,'bof');
    fcstext_main = fread(fid,FcsTextStopPos-FcsTextStartPos+1,'char');%read the main header
    warning off MATLAB:nonIntegerTruncatedInConversionToChar;
    fcshdr.filename = filename;
    fcshdr.filepath = '\';
    % The first character of the primary TEXT segment contains the delimiter (FCS standard)
    if fcstext_main(1) == 12
        mnemonic_separator = 'FF';
    else
        mnemonic_separator = char(fcstext_main(1));
    end
    if mnemonic_separator == '@'
        display([': The file can not be read (Unsupported FCS type: WinMDI histogram file)']);
        data = []; marker_names = []; channel_names = [];
        fcsdat = []; fcshdr = [];
        fclose(fid);
        return;
    end
    
    fcshdr.NumOfPar = str2num(get_mnemonic_value('$PAR',fcstext_main, mnemonic_separator));
    for i=1:fcshdr.NumOfPar
        fcshdr.par(i).bit = str2num(get_mnemonic_value(['$P',num2str(i),'B'],fcstext_main, mnemonic_separator));
        fcshdr.par(i).display = get_mnemonic_value(['$P',num2str(i),'D'],fcstext_main, mnemonic_separator);
        fcshdr.par(i).name = get_mnemonic_value(['$P',num2str(i),'N'],fcstext_main, mnemonic_separator);
        fcshdr.par(i).name2 = get_mnemonic_value(['$P',num2str(i),'S'],fcstext_main, mnemonic_separator);
        fcshdr.par(i).range = str2num(get_mnemonic_value(['$P',num2str(i),'R'],fcstext_main, mnemonic_separator));
        
        % linear scaling factor
        tmp = get_mnemonic_value(['$P',num2str(i),'G'],fcstext_main, mnemonic_separator);
        if isempty(tmp) || isequal(str2num(tmp),0)
            fcshdr.par(i).G = 1;
        else
            fcshdr.par(i).G = str2num(tmp);
        end
 
        % this part of code handles the display option, log/linear transformation, scale and limit of axes, this is useless
        par_exponent_str= (get_mnemonic_value(['$P',num2str(i),'E'],fcstext_main, mnemonic_separator));
        if isempty(par_exponent_str)
            % There is no "$PiE" mnemonic in the Lysys format
            % in that case the PiDISPLAY mnem. shows the LOG or LIN definition
            islogpar = get_mnemonic_value(['P',num2str(i),'DISPLAY'],fcstext_main, mnemonic_separator);
            if length(islogpar)==3 && isequal(islogpar, 'LOG')  % islogpar == 'LOG'
               par_exponent_str = '5,1'; 
            else % islogpar = LIN case
                par_exponent_str = '0,0';
            end
        end
        par_exponent= str2num(par_exponent_str);
        fcshdr.par(i).decade = par_exponent(1);
        if fcshdr.par(i).decade == 0
            fcshdr.par(i).log = 0;
            fcshdr.par(i).logzero = 0;
        else
            fcshdr.par(i).log = 1;
            if (par_exponent(2) == 0)
              fcshdr.par(i).logzero = 1;
            else
              fcshdr.par(i).logzero = par_exponent(2);
            end
        end
    end
    % get the marker_names and channel_names
    for i=1:length(fcshdr.par), 
        marker_names{i,1} = fcshdr.par(i).name2;  
        if isequal(unique(fcshdr.par(i).name2),' ')  || isempty(marker_names{i,1})
            marker_names{i,1} = fcshdr.par(i).name;  
        end
        channel_names{i,1} = fcshdr.par(i).name;
        % channel_names{i,1}(channel_names{i,1}=='>' | channel_names{i,1}=='<')=[]; % this line is useless, create to accomodate a very weird file 
    end
    
    fcshdr.TotalEvents = str2num(get_mnemonic_value('$TOT',fcstext_main, mnemonic_separator));
    fcshdr.byteorder = get_mnemonic_value('$BYTEORD',fcstext_main, mnemonic_separator);          % this influences the reading of the data
    fcshdr.datatype = get_mnemonic_value('$DATATYPE',fcstext_main, mnemonic_separator);
    fcshdr.datamode = get_mnemonic_value('$MODE',fcstext_main, mnemonic_separator);              % this can be L, C, U, refer to FCS3.0 standard for their meanings
    if ~isequal(upper(fcshdr.datamode),'L')
        display('This reader only handles listmode format. Files with histograms cannot be read here~');
        fclose(fid);
        return
    end
    
    fcshdr.starttime = get_mnemonic_value('$BTIM',fcstext_main, mnemonic_separator);
    fcshdr.stoptime = get_mnemonic_value('$ETIM',fcstext_main, mnemonic_separator);
    fcshdr.date = get_mnemonic_value('$DATE',fcstext_main, mnemonic_separator);
    fcshdr.cytometry = get_mnemonic_value('$CYT',fcstext_main, mnemonic_separator);
    fcshdr.system = get_mnemonic_value('$SYS',fcstext_main, mnemonic_separator);
    fcshdr.project = get_mnemonic_value('$PROJ',fcstext_main, mnemonic_separator);
    fcshdr.experiment = get_mnemonic_value('$EXP',fcstext_main, mnemonic_separator);
    fcshdr.cells = get_mnemonic_value('$Cells',fcstext_main, mnemonic_separator);
    fcshdr.creator = get_mnemonic_value('CREATOR',fcstext_main, mnemonic_separator);
    
    % deal with the compensation matrix or spill over matrix 
    tmp = get_mnemonic_value('$COMP',fcstext_main, mnemonic_separator);
    if ~isempty(tmp)
        display(['This reader cannot handle compensation matrix under $COMP keyword, but can handle SPILL']);
        fclose(fid);
        return
    end
    
    tmp1 = get_mnemonic_value('SPILL',fcstext_main, mnemonic_separator);
    tmp2 = get_mnemonic_value('SPILLOVER',fcstext_main, mnemonic_separator);
    tmp3 = get_mnemonic_value('$SPILLOVER',fcstext_main, mnemonic_separator);
    if double(~isempty(tmp1)) + double(~isempty(tmp2)) + double(~isempty(tmp2))>=2
        fclose(fid);
        error('More than one of the keywords SPILL/SPILLOVER/$SPILLOVER appear in TEXT segment');
    end
    tmp = [tmp1,tmp2,tmp3];
    if ~isempty(tmp)
        fcshdr.SPILLOVER = tmp;
        seg_start = [1,strfind(tmp,',')+1];
        seg_end   = [strfind(tmp,',')-1,length(tmp)];
        seg_to_remove = [];
        for k=1:length(channel_names)
            s1 = strfind(fcshdr.SPILLOVER,channel_names{k});
            if isempty(s1), continue; end
            seg_to_remove = union(seg_to_remove, find(ismember(seg_start, s1+1:s1+length(channel_names{k}))));
        end
        seg_start(seg_to_remove) = []; seg_end = [seg_start(2:end)-2, length(tmp)];  % this is to deal with cases where ',' appear in channel names
        num_compensated_channels = str2num(fcshdr.SPILLOVER(seg_start(1):seg_end(1)));
        compensated_channel_names = [];
        for k = 1:num_compensated_channels
            compensated_channel_names{k,1} = fcshdr.SPILLOVER(seg_start(k+1):seg_end(k+1));
        end
        spillover_matrix = str2num(fcshdr.SPILLOVER(seg_start(1+num_compensated_channels+1):end));
        spillover_matrix = reshape(spillover_matrix,num_compensated_channels,num_compensated_channels)';
        [C,IA,IB] = intersect(channel_names,compensated_channel_names);
        fcshdr.spillover_matrix = eye(length(channel_names));
        fcshdr.spillover_matrix(IA,IA) = spillover_matrix(IB,IB);
        fcshdr.compensated_channels = sort(IA);
        fcshdr.inv_spillover_matrix = inv(fcshdr.spillover_matrix);  % row vector of data of one event multiply with this matrix yields compensated values
        if length(C)~=num_compensated_channels
            display('Channel names in $SPILLOVER do not match with $PnN');
            display('$SPILLOVER ignored and compensation not performed');
            fcshdr.spillover_matrix = eye(length(channel_names));
            fcshdr.inv_spillover_matrix = eye(length(channel_names));
            fcshdr.compensated_channels = setdiff(1:length(channel_names),[isInList(channel_names,'time'),isInList(channel_names,'event'),isInList(marker_names,'time'),isInList(marker_names,'event')]);
        end
    else
        fcshdr.SPILLOVER = [];
        fcshdr.spillover_matrix = eye(length(channel_names));
        fcshdr.inv_spillover_matrix = eye(length(channel_names));
        fcshdr.compensated_channels = setdiff(1:length(channel_names),[isInList(channel_names,'time'),isInList(channel_names,'event'),isInList(marker_names,'time'),isInList(marker_names,'event')]);
    end
    
else
    hm = msgbox([FileName,': The file can not be read (Unsupported FCS type)'],'FcAnalysis info','warn');
    fcsdat = []; fcshdr = [];
    fclose(fid);
    return;
end
fclose(fid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mneval = get_mnemonic_value(mnemonic_name,fcsheader,mnemonic_separator)

if strcmp(mnemonic_separator,'\')  || strcmp(mnemonic_separator,'!') ...
        || strcmp(mnemonic_separator,'|') || strcmp(mnemonic_separator,'@')...
        || strcmp(mnemonic_separator, '/') % added by GAP 1/22/08
    mnemonic_startpos = findstr(char(fcsheader'),mnemonic_name);
    mnemonic_length = length(mnemonic_name);
    mnemonic_stoppos = mnemonic_startpos + mnemonic_length;
    mnemonic_startpos(char(fcsheader(mnemonic_stoppos))~=mnemonic_separator | char(fcsheader(mnemonic_startpos-1))~=mnemonic_separator)=[];
    if isempty(mnemonic_startpos) 
        mneval = [];
        return;
    end
    if length(mnemonic_startpos)>1
        display(['In the TEXT segment, keyword ''',mnemonic_name,''' appeared more than once']);
        mnemonic_startpos = mnemonic_startpos + mnemonic_length;
        mneval=[];
        for k=1:length(mnemonic_startpos)
            next_slashes = findstr(char(fcsheader(mnemonic_stoppos(k)+1:end)'),mnemonic_separator);
            next_slash = next_slashes(1) + mnemonic_stoppos(k);
            tmp = char(fcsheader(mnemonic_stoppos(k)+1:next_slash-1)');
            if ~isempty(tmp) && ~isempty(mneval) && ~isequal(tmp,mneval)
                error(['In the TEXT segment, keyword ''',mnemonic_name,''' appeared more than once, with nonempty values']);
            end
            if ~isempty(tmp) && isempty(mneval)
                mneval = tmp;
            end
        end
    else
        mnemonic_stoppos = mnemonic_startpos + mnemonic_length;
        next_slashes = findstr(char(fcsheader(mnemonic_stoppos+1:end)'),mnemonic_separator);
        next_slash = next_slashes(1) + mnemonic_stoppos;
        mneval = char(fcsheader(mnemonic_stoppos+1:next_slash-1)');
    end
elseif strcmp(mnemonic_separator,'FF')
    mnemonic_startpos = findstr(char(fcsheader'),mnemonic_name);
    if isempty(mnemonic_startpos)
        mneval = [];
        return;
    end
    mnemonic_length = length(mnemonic_name);
    mnemonic_stoppos = mnemonic_startpos + mnemonic_length ;
    next_formfeeds = find( fcsheader(mnemonic_stoppos+1:end) == 12);
    next_formfeed = next_formfeeds(1) + mnemonic_stoppos;

    mneval = char(fcsheader(mnemonic_stoppos + 1 : next_formfeed-1)');
end
