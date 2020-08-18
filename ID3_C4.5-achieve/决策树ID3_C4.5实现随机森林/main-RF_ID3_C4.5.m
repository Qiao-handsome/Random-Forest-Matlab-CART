clear 
clc
%warning off 
% ��������

 % [allresultch2,~,~] = xlsread('D:\���ɭ�����ݿ�\qiEXC\qi\2\pi2.xlsx');
[allresultch2,~,~] = xlsread('C:\Users\Administrator\Desktop\allresultch-2.xlsx');

new_data = data_resize(allresultch2,185,185);

% b = [1,3,40,12,24,36,48,75,71,58,67,52,33,56,72,25,76]; % ��һ�� 0.575
% b = [1,71,10,63,27,47,67,80,35,18,52,60,69,54,49,62,72]; % �ڶ��� 0.69167
% b = [1,71,49,20,46,5,65,24,3,44,33,4,70,64,37,34,17,68,25]; % ������ 0.65806
% b = [1,3,53,27,12,48,68,44,75,60,24,71,77,58,65,70,79]; % ������ 0.66452
% b = [1,10,5,20,16,4,18,29,8,67,48,64,26,27,40,12,68,35,59]; % ������ 0.69677
b = [1,72,35,21,70,46,49,73,26,45,68,57,25,28,66,11,41,69];  % RF��ȡ������0.1���Լ�����0.64667��0.65311(C4.5)

 data = new_data(:,b);
% data = allresultch2(:,b);
Train = data(:,2:end);
Test = data(:,1);

accuracy = zeros(1,5);
% for i = 1:5
   [inputdata_col,inputdata_row] = size(Train);
    indices=crossvalind('Kfold',Train(1:inputdata_col,inputdata_row),5);  %��������ְ�
   

    for k=1:5  %������֤k=5��5����������Ϊ���Լ�
        test = (indices == k);   %���test��Ԫ�������ݼ��ж�Ӧ�ĵ�Ԫ���
        ktrain = ~test;  %train��Ԫ�صı��Ϊ��testԪ�صı��
        P_train=Train(ktrain,:);%�����ݼ��л��ֳ�train����������
        T_train=Test(ktrain,:);
        P_test=Train(test,:);  %test������
        T_test=Test(test,:);

    
     P_train= bsxfun(@rdivide, bsxfun(@minus, P_train, mean(P_train)), var(P_train) + 1e-10); 
     P_test= bsxfun(@rdivide, bsxfun(@minus, P_test, mean(P_test)), var(P_test) + 1e-10); 
    


     % �������ɭ��

%     rand('state', 0);
%     randn('state', 0);

    opts= struct;
    opts.depth= 9;
    opts.numTrees= 300;
    opts.numSplits= 6; % Ϊ���ѡ�����������Ժ��ѭ��������
    opts.verbose= false; % ����Ϊtrue��ʱ�������ϸ��ʾ���ڹ�������ľ
    opts.classifierID= [1,2,3,4]; % 1-������׮��2-��ά���Ծ���ѧϰ��3-��ά�������߷ֶ�ѧϰ��Բ׶����ѧϰ����4-RBF��ѧϰ:ѡȡʵ�������ݾ�����ֵ���о���
    opts.classifierCommitFirst= false; % ����Ϊtrue��ʱ��opts.classifierID �е��㷨�������ѡȡ����һ������Ϊfalse��������������㷨������ȡ�������ŵģ�
    opts.algorithmclass = 2; % ����Ϊ1��ʱ��ʹ��ID3�㷨������Ϊ2��ʱ��ʹ��C4.5�㷨

    tic;
    m= forestTrain(P_train, T_train, opts);
    timetrain= toc;
    tic;
    T_sim = forestTest(m, P_test,opts);
    timetest= toc;
    
    
% Look at classifier distribution for fun, to see what classifiers were
% chosen at split nodes and how often
fprintf('Classifier distributions:\n');
classifierDist= zeros(1, 4);
unused= 0;
for b=1:length(m.treeModels)
    for j=1:length(m.treeModels{b}.weakModels)
        cc= m.treeModels{b}.weakModels{j}.classifierID;
        if cc>1 %otherwise no classifier was used at that node
            classifierDist(cc)= classifierDist(cc) + 1;
        else
            unused= unused+1;
        end
    end
end
fprintf('%d nodes were empty and had no classifier.\n', unused);
for b=1:4
    fprintf('Classifier with id=%d was used at %d nodes.\n', b, classifierDist(b));
end

    % �������
    count_B = length(find(T_train == 0));
    count_M = length(find(T_train == 1));
    total_B = length(find(data(:,1) == 0));
    total_M = length(find(data(:,1) == 1));
    number_B = length(find(T_test == 0));
    number_M = length(find(T_test == 1));
    number_B_sim = length(find(T_sim == 0& T_test == 0));
    number_M_sim = length(find(T_sim == 1& T_test == 1));

    disp(['����������' num2str(length(data)) ...
    '    ���ԣ�' num2str(total_B) '    ���ԣ�' num2str(total_M)]);
    disp(['ѵ��������������' num2str(length(Train)) '    ���ԣ�' num2str(count_B) ...
    '    ���ԣ�' num2str(count_M)]);
    disp(['���Լ�����������' num2str(length(Test)) '    ���ԣ�' num2str(number_B) ...
    '    ���ԣ�' num2str(number_M)]);
    disp(['������������ȷ�' num2str(number_B_sim) '    ���' num2str(number_B - number_B_sim) ...
    '    ȷ���ʣ�' num2str(number_B_sim/number_B*100) '%']);
    disp(['������������ȷ�' num2str(number_M_sim) '    ���' num2str(number_M - number_M_sim) ...
    '    ȷ���ʣ�' num2str(number_M_sim/number_M*100) '%']);
    disp(['ƽ��׼ȷ�ʣ� ' num2str(length(find(T_test == T_sim))/length(T_test)) ]);
    accuracy(k) = length(find(T_test == T_sim))/length(T_test);
    fprintf('Training accuracy = %.2f\n', mean(T_sim == T_test));
end 
disp(['ÿ��ƽ��׼ȷ��Ϊ�� ' num2str(accuracy)]);
disp([ ' �ܷ����ʣ�' num2str(mean(accuracy)) ]);

