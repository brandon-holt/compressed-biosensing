function table_content = read_R_csv(filename)

sep = ',';

fid = fopen(filename);
d = fread(fid,[1,inf],'char'); d = char(d); fclose(fid);
d(d==char(13))=[];

% number of rows
num_rows = sum(d==char(10));
row_end_ind = find(d==char(10));
% first row and number of columns
header_txt = d(1:row_end_ind(1)-1);
header_row = parse_one_row(header_txt, sep);

subsequent_rows = [];
for i=2:num_rows
    subsequent_row_txt = d((row_end_ind(i-1)+1):(row_end_ind(i)-1));
    subsequent_rows = [subsequent_rows; parse_one_row(subsequent_row_txt, sep)];
end

if length(header_row)==0
    table_content = subsequent_rows;
    return
end

if size(subsequent_rows,1)==0
    table_content = header_row;
    return
end

if length(header_row) == size(subsequent_rows,2)
    table_content = [header_row; subsequent_rows];
    return
end

if length(header_row) < size(subsequent_rows,2)
    header_row = [repmat({' '},1,size(subsequent_rows,2)-length(header_row)),header_row];
    table_content = [header_row; subsequent_rows];
    return
end





function parsed_row = parse_one_row(txt,sep)

sep_ind = find(txt==sep);

quote_ind = find(txt=='"');
quote_start_ind = quote_ind(1:2:end);
quote_end_ind = quote_ind(2:2:end);
inside_quote_ind = [];
for i=1:length(quote_start_ind)
    inside_quote_ind = [inside_quote_ind, quote_start_ind(i):quote_end_ind(i)];
end

sep_ind = setdiff(sep_ind,inside_quote_ind);
sep_ind = [0, sep_ind, length(txt)+1];
for j=1:length(sep_ind)-1
    tmp = txt(sep_ind(j)+1:sep_ind(j+1)-1);
    tmp(tmp=='"')=[];
    if isempty(tmp)
        parsed_row{j} = ' ';
    else
        parsed_row{j} = tmp;
    end
end



% double_quote_ind = find(txt=='"');
% start_ind = double_quote_ind(1:2:end);
% end_ind = double_quote_ind(2:2:end);
% 
% for j=1:length(start_ind)
%     parsed_row{1,j} = txt(start_ind(j)+1:end_ind(j)-1);
%     if isempty(parsed_row{j})
%         parsed_row{j} = ' ';
%     end
% end
% 
