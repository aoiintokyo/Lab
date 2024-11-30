% 必要な変数の初期化
clc
clear
close all

%保存先のエクセル
excel_name ='/Users/kajitsukasousei/Personal/Lab/HeadPosture/data/excel/face.xlsx';

for data_num = 0:0
    disp(data_num)
    
    % 読み込むファイル名を設定
    num_str = num2str(data_num); % 文字列に変換
    currentDir = fileparts(mfilename('fullpath'));
    % data/csv ディレクトリへのパスを作成
    csvDir = fullfile(currentDir,'..','data', 'csv','20241116');
    data_name_face = fullfile(csvDir, append('A_', num_str, '.csv'));
    disp(['読み込むファイル: ', data_name_face]);
    
    % CSVファイルからデータを読み込む
    allfacedatafile = readmatrix(data_name_face);
    
    % データの範囲を指定して取得
    row_face = allfacedatafile(23:10023, 2); % データの範囲と列を適宜調整してください
    
    % 時間軸を作成
    sweep_time_face = 9.37; % データ収集時間（秒）
    X_face = linspace(0, sweep_time_face, length(row_face)); % 時間軸
    
    % サンプリング周波数の計算
    fs_face = length(row_face) / sweep_time_face; % サンプリング周波数 [Hz]
    
    [filter_face, e] = lowpass(row_face,0.9,fs_face,'ImpulseResponse','iir');
    ave_dis = mean(filter_face)
    disp(mean(filter_face));

    head_num = data_num;
    head_num = head_num +1 ;
    head_num_str = num2str(head_num); %文字列に変換
    head = append('F',head_num_str);

 
    A = [ave_dis];
    writematrix(A,excel_name,'Range',head);
    disp('done');
end

