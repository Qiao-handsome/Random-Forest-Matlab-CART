clear
clc

[allresultch2,~,~] = xlsread('C:\Users\Administrator\Desktop\allresultch-2.xlsx');
new_data = data_resize(allresultch2,185,185);
% b = [1,72,35,21,70,46,49,73,26,45,68,57,25,28,66,11,41,69];  % RF��ȡ������0.1���Լ�����0.74368
b = [1,2,12,14,17,58,77,46,8,7,10,4,42,18,61,70,15,75,40,56,73];  % ŷʽ����

originalglszm = new_data(:,b);
Train = originalglszm(:,2:end);
Test = originalglszm(:,1);
[inputdata_col,inputdata_row] = size(Train);
indices=crossvalind('Kfold',Train(1:inputdata_col,inputdata_row),5);  %��������ְ�
meanaccuracy = zeros(1,5);

for k=1:5  %������֤k=5��5����������Ϊ���Լ�
        test = (indices == k);   %���test��Ԫ�������ݼ��ж�Ӧ�ĵ�Ԫ���
        ktrain = ~test;  %train��Ԫ�صı��Ϊ��testԪ�صı��
        P_train=Train(ktrain,:);%�����ݼ��л��ֳ�train����������
        T_train=Test(ktrain,:)';
        P_test=Train(test,:);  %test������
        T_test=Test(test,:);


    % Training Forest
    maxGiniImpurity = 0.5; % ���ᴿ�Ȳ�������̫�ͣ���Ȼ����������ѭ��
    numOfTree = 300;
    baggingSampleSize = 400;
    numRandFeatures = floor(sqrt(size(originalglszm,2))); % floor(x) ��������ȡ����ceil(x) ��������ȡ����round(x) ����ȡ��ӽ�������
    train_data_split = false;
    
    L = trainForest(P_train, T_train, maxGiniImpurity, numOfTree, ...
    baggingSampleSize, numRandFeatures, train_data_split);
    disp('Forest is trained.')
    
    % ����
%     p_test = P_test(3,:);
    outputlist = zeros(size(P_test,1),1);
    for key = 1:size(P_test,1)
        
        T = testData(L,P_test(key,:));
        outputlist(key,1) = leafLabelDistri(T);
    end
    
        count_B = length(find(T_train == 0));
        count_M = length(find(T_train == 1));
        total_B = length(find(originalglszm(:,1) == 0));
        total_M = length(find(originalglszm(:,1) == 1));
        number_B = length(find(T_test == 0));
        number_M = length(find(T_test == 1));
        number_B_sim = length(find(outputlist == 0& T_test == 0));
        number_M_sim = length(find(outputlist == 1& T_test == 1));
        meanaccuracy(k) = length(find(T_test == outputlist))/length(T_test);
        disp(['����������' num2str(total_B + total_M) ...
        '    ���ԣ�' num2str(total_B) '    ���ԣ�' num2str(total_M)]);
        disp(['ѵ��������������' num2str(length(P_train)) '    ���ԣ�' num2str(count_B) ...
        '    ���ԣ�' num2str(count_M)]);
        disp(['���Լ�����������' num2str(length(P_test)) '    ���ԣ�' num2str(number_B) ...
        '    ���ԣ�' num2str(number_M)]);
        disp(['������������ȷ�' num2str(number_B_sim) '    ���' num2str(number_B - number_B_sim) ...
        '    ȷ���ʣ�' num2str(number_B_sim/number_B*100) '%']);
        disp(['������������ȷ�' num2str(number_M_sim) '    ���' num2str(number_M - number_M_sim) ...
        '    ȷ���ʣ�' num2str(number_M_sim/number_M*100) '%']);
        disp(['��׼ȷ��:' num2str(length(find(T_test == outputlist))/length(T_test))]);
        
    
%     totalmean(i) = mean(meanaccuracy);
end
disp(['���۽�����֤׼ȷ�ʷֱ�Ϊ�� ' num2str(meanaccuracy) ]);
disp(['ƽ������׼ȷ��Ϊ�� ' num2str(mean(meanaccuracy)) ]);