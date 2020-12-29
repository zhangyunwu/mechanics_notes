function [K, M] = Get_K_M(N)
%读取Nastran的pch文件，得到模型的总体质量和刚度矩阵
%输入：N，模型节点个数
%输出：模型总体质量矩阵M，总体刚度矩阵K
%2009年8月24日

[filename, filepath] = uigetfile('*.pch', '请选择pch数据文件'); %选择需要处理的pch文件

file_path_name = strcat(filepath, filename); %将字符串 文件名称和路径连接

fid = fopen(file_path_name);%打开文件

case1 = 'DMIG';
case2 = 'DMIG*';
case3 = '*';  %每行第一串字符的三种情况

while (~feof(fid)) %判断文件是否结束
    line = fgetl(fid);    %读取一行数据,返回字符串
    line_head = strread(line(1:8), '%s', 1);%第一串字符，三种情况：‘DMIG’，‘DMIG*’或‘*’
    
    if strcmp(line_head, case1)%如果第一串字符是 DMIG
        lie = 0;
        [matrix_name, zero1, ifo, tin, tout, matrix_size]=...
            strread(line(9:end),' %s %d %d %d %d %d');%提取该行数据,字母含义参考Nastran文档
        switch matrix_name{1, 1}%根据矩阵名称判断是什么矩阵，并初始化。cell数据类型，用{}；
            case 'KAAX'
                K = zeros(6*N, 6*N);
            case 'MAAX'
                M = zeros(6*N, 6*N);
            otherwise
                disp('读到未知矩阵类型1');      
        end
    elseif strcmp(line_head, case2)%如果第一串字符是 DMIG* ,开始矩阵中新的一列；
        [lie_node_number, lie_freedom_number]=...
            strread(line(33:end), '%d %d');%提取列节点 与 列节点自由度编号
        lie=(lie_node_number-1)*6+lie_freedom_number;
    else %如果第一串字符是‘*’，向矩阵增加一个数据
        [hang_node_number,hang_freedom_number,data]=...
            strread(line(17:end),'%d %d %f');%提取行节点、行节点自由度编号和数据。
        hang = (hang_node_number-1)*6+hang_freedom_number;
        switch matrix_name{1,1}%将数据装入不同的矩阵
            case 'KAAX'
                K(hang,lie) = data;
            case 'MAAX'
                M(hang,lie) = data;
            otherwise
                 disp('读到未知矩阵类型2');
        end
    end
end

fclose(fid);

K = K + K' - diag(diag(K));
save K K;

M = M + M' - diag(diag(M));
save M M;
end