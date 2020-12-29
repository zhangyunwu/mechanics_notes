function [K, M] = Get_K_M(N)
%��ȡNastran��pch�ļ����õ�ģ�͵����������͸նȾ���
%���룺N��ģ�ͽڵ����
%�����ģ��������������M������նȾ���K
%2009��8��24��

[filename, filepath] = uigetfile('*.pch', '��ѡ��pch�����ļ�'); %ѡ����Ҫ�����pch�ļ�

file_path_name = strcat(filepath, filename); %���ַ��� �ļ����ƺ�·������

fid = fopen(file_path_name);%���ļ�

case1 = 'DMIG';
case2 = 'DMIG*';
case3 = '*';  %ÿ�е�һ���ַ����������

while (~feof(fid)) %�ж��ļ��Ƿ����
    line = fgetl(fid);    %��ȡһ������,�����ַ���
    line_head = strread(line(1:8), '%s', 1);%��һ���ַ��������������DMIG������DMIG*����*��
    
    if strcmp(line_head, case1)%�����һ���ַ��� DMIG
        lie = 0;
        [matrix_name, zero1, ifo, tin, tout, matrix_size]=...
            strread(line(9:end),' %s %d %d %d %d %d');%��ȡ��������,��ĸ����ο�Nastran�ĵ�
        switch matrix_name{1, 1}%���ݾ��������ж���ʲô���󣬲���ʼ����cell�������ͣ���{}��
            case 'KAAX'
                K = zeros(6*N, 6*N);
            case 'MAAX'
                M = zeros(6*N, 6*N);
            otherwise
                disp('����δ֪��������1');      
        end
    elseif strcmp(line_head, case2)%�����һ���ַ��� DMIG* ,��ʼ�������µ�һ�У�
        [lie_node_number, lie_freedom_number]=...
            strread(line(33:end), '%d %d');%��ȡ�нڵ� �� �нڵ����ɶȱ��
        lie=(lie_node_number-1)*6+lie_freedom_number;
    else %�����һ���ַ��ǡ�*�������������һ������
        [hang_node_number,hang_freedom_number,data]=...
            strread(line(17:end),'%d %d %f');%��ȡ�нڵ㡢�нڵ����ɶȱ�ź����ݡ�
        hang = (hang_node_number-1)*6+hang_freedom_number;
        switch matrix_name{1,1}%������װ�벻ͬ�ľ���
            case 'KAAX'
                K(hang,lie) = data;
            case 'MAAX'
                M(hang,lie) = data;
            otherwise
                 disp('����δ֪��������2');
        end
    end
end

fclose(fid);

K = K + K' - diag(diag(K));
save K K;

M = M + M' - diag(diag(M));
save M M;
end